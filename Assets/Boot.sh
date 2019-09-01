# IDEA create a boot screen for the first load up

boot ()
{
    # If game is loaded on a terminal outside of a GUI environment
    if [[ "$DISPLAY" == "" || "$TERM" == "linux" ]]; then
        _inTTY=1
        setSimpleColourMode
    else
        _inTTY=0
        setNormalColourMode
    fi

    setColours
    loadScreens
    [[ -s "$HIGHSCORE_LOG" ]] || >"$HIGHSCORE_LOG" # Create score log if doesn"t exist

    exec 2>"$ERROR_LOG"
    exec 5>"$DEBUG_LOG"

    if (( $_debug )); then
        # Debug mode sends STDERR to an error file
        set -xT
    fi
}
