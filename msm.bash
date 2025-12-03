# bash functions for interactive usage

msm_capture() {
    _msm_save "$READLINE_LINE" || return 1

    READLINE_LINE=''
    READLINE_POINT=0
}

msm_search_interactive() {
    local output

    output=$(_msm_search) || return 1

    local before="${READLINE_LINE:0:READLINE_POINT}"
    local after="${READLINE_LINE:READLINE_POINT:${#READLINE_LINE}}"

    # insert output
    READLINE_LINE="$before$output$after"
    READLINE_POINT=$(( ${#before} + ${#output} ))
}
