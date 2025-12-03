msm_capture() {
    _msm_save "$BUFFER" || return 1

    BUFFER=''
    CURSOR=0
}
zle -N msm_capture

msm_search_interactive() {
    local output

    output=$(_msm_search) || return 1

    local before=${BUFFER[1,CURSOR]}
    local after=${BUFFER[CURSOR+1,-1]}

    BUFFER="$before$output$after"
    CURSOR=$(( ${#before} + ${#output} ))
}
zle -N msm_search_interactive
