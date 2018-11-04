pause()
{
    local unpause
    # Basic pause screen
    printf "\e[%s;%sH%s" ${fieldOptions[pause,y]} ${fieldOptions[pause,x]} "${fieldOptions[pause,text]}"
    while read -rsn1 unpause; do
        [[ "$unpause" == $'\e' ]] && break
    done
    printf "\e[%s;%sH%${#fieldOptions[pause,text]}s" ${fieldOptions[pause,y]} ${fieldOptions[pause,x]}
}

levelUp()
{
    (( _level++ ))
    printf "\e[%s;%sH%${fieldOptions[level,width]}s" ${fieldOptions[level,y]} ${fieldOptions[level,x]} $_level
}

lineUp()
{
    local l

    for (( l = 0; l < $1; l++ )); do
        (( ++_lines % 10 == 0 )) && levelUp
    done

    printf "\e[%s;%sH%${fieldOptions[lines,width]}s" ${fieldOptions[lines,y]} ${fieldOptions[lines,x]} $_lines
}

destroyLines()
{
    local           \
        cleanPid    \
        colour      \
        offset=1    \
        tileType    \
        xPlus       \
        xPos        \
        yPlus       \
        yPos        \
        zeroes=0

    if [[ "$_colourMode" != 'NOIR' ]]; then
        for xPos in {2..20..2}; do
            for yPos in $*; do
                printf '\e[%s;%sH%b' $yPos $xPos "${colours[${coloursLookup[W]}]}${block}${colours[${coloursLookup[R]}]}"
            done
            sleep 0.02
        done
        sleep 0.04
    fi

    for xPos in {2..20..2}; do
        for yPos in $*; do
            printf '\e[%s;%sH%b' $yPos $xPos "${colours[${coloursLookup[W]}]}${blank}${colours[${coloursLookup[R]}]}"
            _lock[$yPos,$xPos]=0
        done
        sleep 0.02
    done

    for (( yPlus = ${@: -1} - 1; yPlus > 1; yPlus-- )); do
        if [[ " $* " =~ " $yPlus " ]]; then
            (( offset++ ))
            continue
        fi

        for xPlus in {2..20..2}; do
            colour=${_lock[$yPlus,$xPlus]}
            if (( $colour )); then
                printf '\e[%s;%sH%b' $yPlus $xPlus "${colours[${coloursLookup[W]}]}${blank}${colours[${coloursLookup[R]}]}"
                printf '\e[%s;%sH%b' $(( $yPlus + $offset )) $xPlus "${colours[$colour]}${block}${colours[${coloursLookup[R]}]}"
                _lock[$yPlus,$xPlus]=0
            else
                (( zeroes++ ))
            fi
            _lock[$(( $yPlus + $offset )),$xPlus]=$colour
        done

        (( $zeroes == 10 )) && break || zeroes=0    # Blank line detected (no further lines above can have colour)
    done
}

checkLines()
{
    local               \
        line            \
        toDestroy=()    \
        xPos            \
        yPos

    for yPos in $*; do
        line=true
        for xPos in {2..20..2}; do
            if ! (( ${_lock[$yPos,$xPos]} )); then
                line=false
                break
            fi
        done
        $line && toDestroy[$yPos]=
    done

    (( ${#toDestroy[@]} )) && destroyLines ${!toDestroy[@]}
    lineUp ${#toDestroy[@]}
}

lockPiece()
{
    local -n piece="$1"
    local           \
        coord       \
        toCheck=()  \
        x=$3        \
        xAx         \
        y=$2        \
        yAx

    for coord in ${piece[$_rotation]}; do
        IFS=, read -r xAx yAx <<< "$coord"
        toCheck[(( $y + $yAx ))]= # Save as keys to avoid duplicates
        _lock[$(( $y + $yAx )),$(( $x + ($xAx * 2) ))]=${coloursLookup[$1]}
    done

    checkLines ${!toCheck[@]}
}

canRender()
{
    local -n piece="$1"
    local                   \
        coord               \
        x=$3                \
        xAx                 \
        y=$2                \
        yAx

    for coord in ${piece[$_rotation]}; do
        IFS=, read -r xAx yAx <<< "$coord"
        (( xAx = $x + ($xAx * 2) ))
        (( yAx = $y + $yAx ))

        # Needs to check tetromino collision first for rotation
        if (( ${_lock[$yAx,$xAx]} )); then
            collides=4
            return 1
        elif (( $xAx > 20 )); then # Right wall
            collides=1
            return 1
        elif (( $xAx < 2 )); then # Left wall
            collides=3
            return 1
        elif (( $yAx > 23 )); then # Floor
            collides=2
            return 1
        fi
    done

    collides=0
    return 0
}

renderPiece()
{
    local -n piece="$1"
    local                   \
        coord               \
        tile                \
        reset=${4:-false}   \
        x=$3                \
        xAx                 \
        y=$2                \
        yAx

    for coord in ${piece[$_rotation]}; do
        IFS=, read -r xAx yAx <<< "$coord"
        if $reset; then
            tile="${blank}"
        else
            tile="${colours[${coloursLookup[$1]}]}${block}${colours[${coloursLookup[R]}]}"
        fi
        printf '\e[%s;%sH%b' $(( $y + $yAx )) $(( $x + ($xAx * 2) )) "$tile"
    done
}

removePiece()
{
    renderPiece "$1" $2 $3 true
}

navigateMenu()
{
    local -n menuOptions="$1"
    local           \
        key1        \
        key2        \
        key3        \
        selected=0  \
        m

    while true; do
        for (( m = 0; $m < (${menuOptions[max]} + 1); m++ )); do
            (( $m == $selected )) && text='\e[7m' || text='\e[0m'
            text+="${menuOptions[$m,text]}\e[0m"
            printf '\e[%s;%sH%b' ${menuOptions[$m,y]} ${menuOptions[$m,x]} "$text"
        done

        IFS= read -srn 1 key1 <&6
        IFS= read -srn 1 -t 0.001 key2 <&6
        IFS= read -srn 1 -t 0.001 key3 <&6

        test -z "$key1" && break

        case $key3 in
            A)  (( $selected == 0 ? selected = ${menuOptions[max]} : selected-- ));; # Up
            B)  (( $selected == ${menuOptions[max]} ? selected = 0 : selected++ ));; # Down
        esac
    done

    return $selected
}

renderMain()
{
    printf '%s' "$mainScreen"

    navigateMenu 'mainOptions'
    case $? in
        0)  _state=1;; # New game
        1)  _state=2;; # Scores
        2)  _state=3;; # Settings
        3)  exit 0;;
    esac
}

renderField()
{
    printf '%s' "$fieldScreen"
}

renderScreen()
{
    local screen=''

    printf '\e[2J\e[1;1H%s' "${colours[0]}"
    setColours

    case $_state in
        0)  renderMain;;
        1)  renderField;;
        2)  return;;
        3)  return;;
    esac
}

renderNextPiece()
{
    local y

    for y in {0..3}; do
        printf '\e[%s;%sH%b' $(( ${nextPiece[R,y]} + $y )) ${nextPiece[R,x]} "${R[0]//0/$blank}"
    done

    renderPiece "$_nextPiece" ${nextPiece[$_nextPiece,y]} ${nextPiece[$_nextPiece,x]}
}
