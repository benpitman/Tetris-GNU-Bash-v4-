################################## GENERAL #####################################

declare -rg -- LOG_DIR="/var/games/tetris"
declare -rg -- REPLAY_DIR="/var/games/tetris/replays"

declare -rg -- PS4='+(${LINENO}) ${FUNCNAME[0]}(): '

declare -rg -- HIGHSCORE_LOG="$LOG_DIR/highscores.ths"
declare -rg -- SETTINGS="$LOG_DIR/settings.txt"
declare -rg -- ERROR_LOG="$LOG_DIR/error.log"
declare -rg -- DEBUG_LOG="$LOG_DIR/debug.log"
declare -rg -- INPUT_LOG="$LOG_DIR/input.log"

declare -rg -- UP="A"
declare -rg -- DOWN="B"
declare -rg -- RIGHT="C"
declare -rg -- LEFT="D"

declare -rg -- CEILING=2
declare -rg -- FLOOR=23
declare -rg -- RIGHT_WALL=20
declare -rg -- LEFT_WALL=2

declare -arg -- X_POSITIONS=({2..20..2})

if (( ${BASH_VERSINFO[0]} == 4 && ${BASH_VERSINFO[1]} < 4 )); then
    declare -rg -- LEGACY=1
else
    declare -rg -- LEGACY=0
fi

if [[ -s "$SETTINGS" ]] && (( $_replay == 0 )); then
    source "$SETTINGS"
fi

################################## Screens #####################################

if (( $_inTTY == 0 )); then
    declare -arg -- MAIN_SCREEN=(
        '┌────────────────────────────────────────┐'
        '│                                        │'
        '│  █▛██▜█ ██ ▜█ █▛██▜█ ██ █▙  ██  ▟▙ ▜█  │'
        '│  ▛ ██ ▜ ██  ▜ ▛ ██ ▜ ██ ██  ██  ▜█▙ ▜  │'
        '│    ██   ██ █    ██   ██ ▛   ██   ▜█▙   │'
        '│    ██   ██  ▟   ██   ██ ▙   ██  ▙ ▜█▙  │'
        '│    ██   ██ ▟█   ██   ██ █▙  ██  █▙ ▜▛  │'
        '│                                        │'
        '│                                        │'
        '│                                        │'
        '│                                        │'
        '│                                        │'
        '│                                        │'
        '│                                        │'
        '│                                        │'
        '│                                        │'
        '│                                        │'
        '│                                        │'
        '│                                        │'
        '│                                        │'
        '│                                        │'
        '│                                        │'
        '│                                        │'
        '└────────────────────────────────────────┘'
    )
    if (( $_holdingIsSet )); then
        declare -arg -- FIELD_SCREEN=(
            '┌────────────────────┬───────────────────┐'
            '│                    │  ┌─────────────╖  │'
            '│                    │  │  S C O R E  ║  │'
            '│                    │  │          0  ║  │'
            '│                    │  ├─────────────╢  │'
            '│                    │  │  L E V E L  ║  │'
            '│                    │  │          0  ║  │'
            '│                    │  ├─────────────╢  │'
            '│                    │  │  L I N E S  ║  │'
            '│                    │  │          0  ║  │'
            '│                    │  ╘═════════════╝  │'
            '│                    │  ┌──────────╖     │'
            '│                    │  │          ║ H   │'
            '│                    │  │          ║ O   │'
            '│                    │  │          ║ L   │'
            '│                    │  │          ║ D   │'
            '│                    │  ╘══════════╝     │'
            '│                    │  ┌──────────╖     │'
            '│                    │  │          ║ N   │'
            '│                    │  │          ║ E   │'
            '│                    │  │          ║ X   │'
            '│                    │  │          ║ T   │'
            '│                    │  ╘══════════╝     │'
            '└────────────────────┴───────────────────┘'
        )
    else
        declare -arg -- FIELD_SCREEN=(
            '┌────────────────────┬───────────────────┐'
            '│                    │  ┌─────────────╖  │'
            '│                    ├──┤  S C O R E  ╟──┤'
            '│                    │  ╘═════════════╝  │'
            '│                    ├───────────────────┤'
            '│                    │             0     │'
            '│                    ├───────────────────┤'
            '│                    │                   │'
            '│                    │  ┌─────────────╖  │'
            '│                    │  │  L E V E L  ║  │'
            '│                    │  │          0  ║  │'
            '│                    │  ╘═════════════╝  │'
            '│                    │  ┌─────────────╖  │'
            '│                    │  │  L I N E S  ║  │'
            '│                    │  │          0  ║  │'
            '│                    │  ╘═════════════╝  │'
            '│                    │                   │'
            '│                    │  ┌──────────╖     │'
            '│                    │  │          ║ N   │'
            '│                    │  │          ║ E   │'
            '│                    │  │          ║ X   │'
            '│                    │  │          ║ T   │'
            '│                    │  ╘══════════╝     │'
            '└────────────────────┴───────────────────┘'
        )
    fi
    declare -arg -- SCORES_SCREEN=(
        '┌────────────────────────────────────────┐'
        '│            ┌─────────────╖             │'
        '├────────────┤ S C O R E S ╟─────────────┤'
        '│            ╘═════════════╝             │'
        '│                                        │'
        '│                                        │'
        '│                                        │'
        '│                                        │'
        '│                                        │'
        '│                                        │'
        '│                                        │'
        '│                                        │'
        '│                                        │'
        '│                                        │'
        '│                                        │'
        '│                                        │'
        '│                                        │'
        '│                                        │'
        '│                                        │'
        '│                                        │'
        '│                                        │'
        '│                                        │'
        '│                                        │'
        '└────────────────────────────────────────┘'
    )
    declare -arg -- SETTINGS_SCREEN=(
        '┌────────────────────────────────────────┐'
        '│          ┌─────────────────╖           │'
        '├──────────┤ S E T T I N G S ╟───────────┤'
        '│          ╘═════════════════╝           │'
        '│                                        │'
        '│                                        │'
        '│                                        │'
        '│                                        │'
        '│                                        │'
        '│                                        │'
        '│                                        │'
        '│                                        │'
        '│                                        │'
        '│                                        │'
        '│                                        │'
        '│                                        │'
        '│                                        │'
        '│                                        │'
        '│                                        │'
        '│                                        │'
        '│                                        │'
        '│                                        │'
        '│                                        │'
        '└────────────────────────────────────────┘'
    )
    declare -arg -- CONSTANTS_SCREEN=(
        '┌────────────────────────────────────────┐'
        '│         ┌───────────────────╖          │'
        '├─────────┤ C O N S T A N T S ╟──────────┤'
        '│         ╘═══════════════════╝          │'
        '│                                        │'
        '│                                        │'
        '│                                        │'
        '│                                        │'
        '│                                        │'
        '│                                        │'
        '│                                        │'
        '│                                        │'
        '│                                        │'
        '│                                        │'
        '│                                        │'
        '│                                        │'
        '│                                        │'
        '│                                        │'
        '│                                        │'
        '│                                        │'
        '│                                        │'
        '│                                        │'
        '│                                        │'
        '└────────────────────────────────────────┘'
    )
else
    declare -arg -- MAIN_SCREEN=(
        '┌────────────────────────────────────────┐'
        '│                                        │'
        '│  ██████ █████ ██████ █████  ██  █████  │'
        '│    ██   ██      ██   ██  ██ ██ ██      │'
        '│    ██   ████    ██   ████   ██   ██    │'
        '│    ██   ██      ██   ██  ██ ██     ██  │'
        '│    ██   █████   ██   ██  ██ ██ █████   │'
        '│                                        │'
        '│                                        │'
        '│                                        │'
        '│                                        │'
        '│                                        │'
        '│                                        │'
        '│                                        │'
        '│                                        │'
        '│                                        │'
        '│                                        │'
        '│                                        │'
        '│                                        │'
        '│                                        │'
        '│                                        │'
        '│                                        │'
        '│                           © Ben Pitman │'
        '└────────────────────────────────────────┘'
    )
    if (( $_holdingIsSet )); then
        declare -arg -- FIELD_SCREEN=(
            '┌────────────────────┬───────────────────┐'
            '│                    │  ┌─────────────┐  │'
            '│                    │  │  S C O R E  │  │'
            '│                    │  │          0  │  │'
            '│                    │  ├─────────────┤  │'
            '│                    │  │  L E V E L  │  │'
            '│                    │  │          0  │  │'
            '│                    │  ├─────────────┤  │'
            '│                    │  │  L I N E S  │  │'
            '│                    │  │          0  │  │'
            '│                    │  └─────────────┘  │'
            '│                    │  ┌──────────┐     │'
            '│                    │  │          │ H   │'
            '│                    │  │          │ O   │'
            '│                    │  │          │ L   │'
            '│                    │  │          │ D   │'
            '│                    │  └──────────┘     │'
            '│                    │  ┌──────────┐     │'
            '│                    │  │          │ N   │'
            '│                    │  │          │ E   │'
            '│                    │  │          │ X   │'
            '│                    │  │          │ T   │'
            '│                    │  └──────────┘     │'
            '└────────────────────┴───────────────────┘'
        )
    else
        declare -arg -- FIELD_SCREEN=(
            '┌────────────────────┬───────────────────┐'
            '│                    │  ┌─────────────┐  │'
            '│                    ├──┤  S C O R E  ├──┤'
            '│                    │  └─────────────┘  │'
            '│                    ├───────────────────┤'
            '│                    │             0     │'
            '│                    ├───────────────────┤'
            '│                    │                   │'
            '│                    │  ┌─────────────┐  │'
            '│                    │  │  L E V E L  │  │'
            '│                    │  │          0  │  │'
            '│                    │  └─────────────┘  │'
            '│                    │  ┌─────────────┐  │'
            '│                    │  │  L I N E S  │  │'
            '│                    │  │          0  │  │'
            '│                    │  └─────────────┘  │'
            '│                    │                   │'
            '│                    │  ┌──────────┐     │'
            '│                    │  │          │ N   │'
            '│                    │  │          │ E   │'
            '│                    │  │          │ X   │'
            '│                    │  │          │ T   │'
            '│                    │  └──────────┘     │'
            '└────────────────────┴───────────────────┘'
        )
    fi
    declare -arg -- SCORES_SCREEN=(
        '┌────────────────────────────────────────┐'
        '│            ┌─────────────┐             │'
        '├────────────┤ S C O R E S ├─────────────┤'
        '│            └─────────────┘             │'
        '│                                        │'
        '│                                        │'
        '│                                        │'
        '│                                        │'
        '│                                        │'
        '│                                        │'
        '│                                        │'
        '│                                        │'
        '│                                        │'
        '│                                        │'
        '│                                        │'
        '│                                        │'
        '│                                        │'
        '│                                        │'
        '│                                        │'
        '│                                        │'
        '│                                        │'
        '│                                        │'
        '│                                        │'
        '└────────────────────────────────────────┘'
    )
    declare -arg -- SETTINGS_SCREEN=(
        '┌────────────────────────────────────────┐'
        '│          ┌─────────────────┐           │'
        '├──────────┤ S E T T I N G S ├───────────┤'
        '│          └─────────────────┘           │'
        '│                                        │'
        '│                                        │'
        '│                                        │'
        '│                                        │'
        '│                                        │'
        '│                                        │'
        '│                                        │'
        '│                                        │'
        '│                                        │'
        '│                                        │'
        '│                                        │'
        '│                                        │'
        '│                                        │'
        '│                                        │'
        '│                                        │'
        '│                                        │'
        '│                                        │'
        '│                                        │'
        '│                                        │'
        '└────────────────────────────────────────┘'
    )
    declare -arg -- CONSTANTS_SCREEN=(
        '┌────────────────────────────────────────┐'
        '│         ┌───────────────────┐          │'
        '├─────────┤ C O N S T A N T S ├──────────┤'
        '│         └───────────────────┘          │'
        '│                                        │'
        '│                                        │'
        '│                                        │'
        '│                                        │'
        '│                                        │'
        '│                                        │'
        '│                                        │'
        '│                                        │'
        '│                                        │'
        '│                                        │'
        '│                                        │'
        '│                                        │'
        '│                                        │'
        '│                                        │'
        '│                                        │'
        '│                                        │'
        '│                                        │'
        '│                                        │'
        '│                                        │'
        '└────────────────────────────────────────┘'
    )
fi

############################## States and Modes ################################

setColourMode ()
{
    _colourMode=$1
}

getReadableColourMode ()
{
    printf -v $1 ${COLOUR_MODES[$_colourMode]}
}

setGameMode ()
{
    _gameMode=$1
}

getReadableGameMode ()
{
    printf -v $1 ${GAME_MODES[$_gameMode]}
}

toggleGhosting ()
{
    (( _ghostingIsSet ^= 1 ))
}

getReadableConstantState  ()
{
    local -n -- constant="$1"
    (( $constant )) && echo "ACTIVE" || echo "INACTIVE"
}

toggleLogging ()
{
    (( _loggingIsSet ^= 1 ))
}

declare -Arg STATES=(
    ['MAIN']=0
    ['FIELD']=1
    ['SCORES']=2
    ['SETTINGS']=3
    ['CONSTANTS']=4
    ['GAME_OVER']=5
)

setState ()
{
    _state=${STATES[$1]}
}

############################### Menu Navigation ################################

declare -rg -- START_POSITION='2,8'

declare -arg -- MAIN_OPTIONS=(
    'N E W   G A M E'
    'S C O R E S'
    'S E T T I N G S'
    'Q U I T'
)

declare -Arg -- MAIN_MENU=(
    ['MAX']=3
    ['OPTIONS']='MAIN_OPTIONS'
    ['PADDING']=' '

    ['0,Y']=11
    ['0,X']=12

    ['1,Y']=14
    ['1,X']=14

    ['2,Y']=17
    ['2,X']=12

    ['3,Y']=20
    ['3,X']=16
)

declare -arg -- SETTINGS_OPTIONS=(
    'COLOUR MODE'
    'GAME MODE'
    'CONSTANTS'
    'BACK'
)

# Settings menu options
declare -Arg -- SETTINGS_MENU=(
    ['MAX']=3
    ['OPTIONS']='SETTINGS_OPTIONS'
    ['PADDING']=' '

    ['0,Y']=10
    ['0,X']=5

    ['1,Y']=12
    ['1,X']=6

    ['2,Y']=14
    ['2,X']=6

    ['3,Y']=22
    ['3,X']=9
)

# Opens up the submenu for selection
declare -Arg -- SETTINGS_CLEAR_SUB_MENU=(
    ['MAX']=11

    ['Y']=8
    ['X']=25

     ['0']='┌────────────┐'
     ['1']='│            │'
     ['2']='│            │'
     ['3']='│            │'
     ['4']='│            │'
     ['5']='│            │'
     ['6']='│            │'
     ['7']='│            │'
     ['8']='│            │'
     ['9']='│            │'
    ['10']='└────────────┘'
)

# Clears the chosen items for repopulation
declare -Arg -- SETTINGS_SUB_MENU=(
    ['MAX']=2
    ['WIDTH']=11

    ['0,FUNCTION']='getReadableColourMode'
    ['0,Y']=10
    ['0,X']=26

    ['1,FUNCTION']='getReadableGameMode'
    ['1,Y']=12
    ['1,X']=26

    ['2']='CUSTOMISE'
    ['2,Y']=14
    ['2,X']=26

    ['CLEAR']='              '
    ['CLEAR,Y']=9
    ['CLEAR,X']=25
    ['CLEAR,MAX']=11
)

declare -Arg -- NOTE=(
    ['CLEAR']='                                        '
    ['Y']=6
    ['X']=22
)

declare -arg -- CONSTANTS_OPTIONS=(
    "SHOW NEXT"
    "SHOW HOLD"
    "GHOST"
    "RECORD INPUTS"
    "ROTATE ONCE"
    "MEMORY GAME"
    "BACK"
)

# Settings menu options
declare -Arg -- CONSTANTS_MENU=(
    ['MAX']=6
    ['OPTIONS']="CONSTANTS_OPTIONS"
    ['PADDING']=' '

    ['0,Y']=9
    ['0,X']=5

    ['1,Y']=11
    ['1,X']=5

    ['2,Y']=13
    ['2,X']=5
    ['2,NOTE']='(Can cause flicker)'

    ['3,Y']=15
    ['3,X']=5
    ['3,NOTE']='All inputs logged for playback'

    ['4,Y']=17
    ['4,X']=5
    ['4,NOTE']="Limited to 3 rotations per tetromino"

    ['5,Y']=19
    ['5,X']=5
    ['5,NOTE']="Tetrominoes will fade out once placed"

    ['6,Y']=22
    ['6,X']=9
)

declare -arg -- COLOUR_MODES=(
    'NORMAL'
    'SIMPLE'
    'SHADOW'
    'BLEACH'
)

# Settings colour mode submenu options
declare -Arg -- SETTINGS_COLOUR_SUB_MENU=(
    ['MAX']=3
    ['OPTIONS']='COLOUR_MODES'
    ['PADDING']='  '

    ['0,Y']=10
    ['0,X']=27
    ['0,NOTE']="Original Tetris colours"

    ['1,Y']=12
    ['1,X']=27
    ['1,NOTE']="Reduced colours for lower colour depth"

    ['2,Y']=14
    ['2,X']=27
    ['2,NOTE']="White on black"

    ['3,Y']=16
    ['3,X']=27
    ['3,NOTE']="Black on white"
)

# These two are not readonly becuase of the secret heart mode
declare -ag -- GAME_MODES=(
    'NORMAL'
    ' HARD '
)

declare -Ag -- SETTINGS_GAME_SUB_MENU=(
    ['MAX']=1
    ['OPTIONS']='GAME_MODES'
    ['PADDING']='  '

    ['0,Y']=11
    ['0,X']=27
    ['0,NOTE']="It's just Tetris"

    ['1,Y']=13
    ['1,X']=27
)

declare -arg SCORES_OPTIONS=(
    'BACK'
)

declare -Arg -- SCORES_MENU=(
    ['MAX']=0
    ['OPTIONS']='SCORES_OPTIONS'
    ['PADDING']=' '

    ['0,Y']=22
    ['0,X']=18
)

declare -Arg -- SCORES=(
    ['MAX']=13
    ['WIDTH']=30

    ['Y']=7
    ['X']=7
)

declare -Arg -- FIELD_OPTIONS=(
    ['SCORE,X']=28
    ['SCORE,Y']=6
    ['SCORE,WIDTH']=9

    ['LEVEL,X']=28
    ['LEVEL,Y']=11
    ['LEVEL,WIDTH']=9

    ['LINES,X']=28
    ['LINES,Y']=15
    ['LINES,WIDTH']=9

    ['ALERT,PAUSED']='P A U S E D'
    ['ALERT,SINGLE']='S I N G L E'
    ['ALERT,DOUBLE']='D O U B L E'
    ['ALERT,TRIPLE']='T R I P L E'
    ['ALERT,TETRIS']='T E T R I S'
    ['ALERT,GAME_OVER']='GAME   OVER'
    ['ALERT,END_REPLAY']='END  REPLAY'
    ['ALERT,CLEAR']='           '
    ['ALERT,X']=27
    ['ALERT,Y']=8
)

declare -Arg -- NEXT_PIECE=(
    ['R,X']=26  # Reset
    ['R,Y']=19

    ['I,X']=27
    ['I,Y']=19

    ['J,X']=28
    ['J,Y']=20

    ['L,X']=28
    ['L,Y']=20

    ['O,X']=29
    ['O,Y']=20

    ['S,X']=28
    ['S,Y']=20

    ['T,X']=28
    ['T,Y']=20

    ['Z,X']=28
    ['Z,Y']=20
)

################################ Tetrominoes ###################################

declare -rg -- BLANK='\u0020\u0020'
declare -rg -- GHOST='\u2592\u2592'
declare -rg -- BLOCK='\u2588\u2588'

setColours()
{
    local -- colourMode

    getReadableColourMode "colourMode"

    case $colourMode in
        'NORMAL')
            declare -ag -- COLOURS=(
                [0]=$'\e[0m'        # Default
                [1]=$'\e[38;5;43m'  # Cyan
                [2]=$'\e[38;5;27m'  # Blue
                [3]=$'\e[38;5;166m' # Orange
                [4]=$'\e[38;5;178m' # Yellow
                [5]=$'\e[38;5;76m'  # Green
                [6]=$'\e[38;5;128m' # Purple
                [7]=$'\e[38;5;160m' # Red
                [8]=$'\e[0;97m'     # White
            )
        ;;
        'SIMPLE')
            declare -ag -- COLOURS=(
                [0]=$'\e[0m'        # Default
                [1]=$'\e[38;5;27m'  # Blue
                [2]=$'\e[38;5;128m' # Purple
                [3]=$'\e[38;5;178m' # Yellow
                [4]=$'\e[38;5;76m'  # Green
                [5]=$'\e[38;5;43m'  # Cyan
                [6]=$'\e[38;5;205m' # Pink
                [7]=$'\e[38;5;160m' # Red
                [8]=$'\e[0;97m'     # White
            )
        ;;
        'SHADOW')
            declare -ag -- COLOURS=(
                [0]=$'\e[0;97m'   # white
                [1]=$'\e[0;97m'
                [2]=$'\e[0;97m'
                [3]=$'\e[0;97m'
                [4]=$'\e[0;97m'
                [5]=$'\e[0;97m'
                [6]=$'\e[0;97m'
                [7]=$'\e[0;97m'
                [8]=$'\e[0;97m'
            )
        ;;
        'BLEACH')
            declare -ag -- COLOURS=(
                [0]=$'\e[38;5;232;47m'   # Inverted white
                [1]=$'\e[38;5;232;47m'
                [2]=$'\e[38;5;232;47m'
                [3]=$'\e[38;5;232;47m'
                [4]=$'\e[38;5;232;47m'
                [5]=$'\e[38;5;232;47m'
                [6]=$'\e[38;5;232;47m'
                [7]=$'\e[38;5;232;47m'
                [8]=$'\e[38;5;232;47m'
            )
        ;;
    esac
}

declare -Arg -- COLOURS_LOOKUP=(
    [R]=0   # Reset
    [I]=1
    [J]=2
    [L]=3
    [O]=4
    [S]=5
    [T]=6
    [Z]=7
    [W]=8   # White
)

declare -arg -- PIECES=( 'I' 'J' 'L' 'O' 'S' 'T' 'Z' )

declare -arg -- I=(
    '0,1 1,1 2,1 3,1'
    '2,0 2,1 2,2 2,3'
    '0,2 1,2 2,2 3,2'
    '1,0 1,1 1,2 1,3'
)

declare -arg -- J=(
    '0,0 0,1 1,1 2,1'
    '1,0 2,0 1,1 1,2'
    '0,1 1,1 2,1 2,2'
    '1,0 1,1 0,2 1,2'
)

declare -arg -- L=(
    '2,0 0,1 1,1 2,1'
    '1,0 1,1 1,2 2,2'
    '0,1 1,1 2,1 0,2'
    '0,0 1,0 1,1 1,2'
)

declare -arg -- O=(
    '0,0 1,0 0,1 1,1'
    '0,0 1,0 0,1 1,1'
    '0,0 1,0 0,1 1,1'
    '0,0 1,0 0,1 1,1'
)

declare -arg -- S=(
    '1,0 2,0 0,1 1,1'
    '1,0 1,1 2,1 2,2'
    '1,1 2,1 0,2 1,2'
    '0,0 0,1 1,1 1,2'
)

declare -arg -- T=(
    '1,0 0,1 1,1 2,1'
    '1,0 0,1 1,1 1,2'
    '0,1 1,1 2,1 1,2'
    '1,0 1,1 2,1 1,2'
)

declare -arg -- Z=(
    '0,0 1,0 1,1 2,1'
    '2,0 1,1 2,1 1,2'
    '0,1 1,1 1,2 2,2'
    '1,0 0,1 1,1 0,2'
)
