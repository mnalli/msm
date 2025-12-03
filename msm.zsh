msm_capture() {
    if ! _msm_save "$BUFFER"; then
        return 1
    fi

    BUFFER=''
    CURSOR=0
}
zle -N msm_capture

msm_search_interactive() {
    local output before after

    output=$(_msm_search "$BUFFER") || return 1

    before=${BUFFER[1,CURSOR]}
    after=${BUFFER[CURSOR+1,-1]}

    BUFFER="$before$output$after"
    CURSOR=$(( ${#before} + ${#output} ))
}
zle -N msm_search_interactive
