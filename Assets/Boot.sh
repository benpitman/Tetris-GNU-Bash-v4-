# IDEA create a boot screen for the first load up

boot ()
{
    # If game is loaded on a terminal outside of a GUI environment
    if ! colourModeIsSet; then
        if [[ "$DISPLAY" == "" || "$TERM" == "linux" ]]; then
            setSimpleColourMode
        else
            setNormalColourMode
        fi
    fi

    loadColours
    loadScreens

    [[ -s "$HIGHSCORE_LOG" ]] || >"$HIGHSCORE_LOG" # Create score log if doesn"t exist

    stty -echo  # Disable echo
    tput civis  # Disable cursor blinker

    exec 2>"$ERROR_LOG"
    exec 5>"$DEBUG_LOG"

    if debuggingIsSet; then
        # Debug mode sends STDERR to an error file
        set -xT
    fi
}
