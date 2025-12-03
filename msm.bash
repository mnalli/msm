# bash functions for interactive usage

msm_capture() {
    if ! _msm_save "$READLINE_LINE"; then
        return 1
    fi

    READLINE_LINE=''
    READLINE_POINT=0
}

msm_search_interactive() {
    local output before after

    output=$(_msm_search) || return 1

    before="${READLINE_LINE:0:READLINE_POINT}"
    after="${READLINE_LINE:READLINE_POINT:${#READLINE_LINE}}"

    # insert output
    READLINE_LINE="$before$output$after"
    READLINE_POINT=$(( ${#before} + ${#output} ))
}
