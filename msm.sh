# Minimal Snippet Manager

# Implemented as a POSIX-compliant script
# Should work on sh, dash, bash, ksh, zsh
# To use source this file from your bash profile

__msm_help='Usage: msm subcommand [string]

    msm help                   Show this message
    msm save "<snippet>"       Save snippet
    msm validate               Validate snippet store structure
    msm validate "<snippet>"   Validate snippet
    msm search                 Interactively search for snippets'

msm() {
    msm_subcommand="$1"
    msm_snippet="$2"

    case "$msm_subcommand" in
        save)
            __msm_save "$msm_snippet"
            ;;
        validate)
            if [ -z "$msm_snippet" ]; then
                __msm_validate_snippet_store
            else
                __msm_validate_snippet "$msm_snippet"
            fi
            ;;
        search)
            __msm_search "$msm_snippet"
            ;;
        help)
            echo "$__msm_help"
            ;;
        *)
            echo "Error: invalid subcommand $msm_subcommand" >&2
            ;;
    esac
}

[ -z "$msm_path" ] && msm_path=~/snippets.sh

__msm_validate_snippet() {
    __msm_validate_snippet_snippet="$1"

    if ! __msm_validate_snippet_structure "$__msm_validate_snippet_snippet"; then
        echo "Error: '$__msm_validate_snippet_snippet'" >&2
        return 1
    fi
}

__msm_validate_snippet_structure() {
    __msm_validate_snippet_structure_snippet="$1"

    # matched description?
    if echo "$__msm_validate_snippet_structure_snippet" | sed -n 1p | grep --quiet "^#"; then
        # remove description
        __msm_validate_snippet_structure_snippet="$(echo "$__msm_validate_snippet_structure_snippet" | sed -n '2,$ p')"
    fi

    __msm_validate_definition_structure "$__msm_validate_snippet_structure_snippet"
}

__msm_validate_definition_structure() {
    if [ -z "$1" ]; then
        echo "Error: missing snippet definition" >&2
        return 1
    fi

    # match description
    if echo "$1" | grep "^#" >&2; then
        echo "Error: cannot have comments in definition (description can be one-line only)" >&2
        return 1
    fi

    if echo "$1" | grep -n -E '^[ \t]*$' >&2; then
        echo "Error: cannot have empty or white lines in definition" >&2
        return 1
    fi
}

__msm_split_snippet_store() {
    # replace empty lines with null characters, then split snippets
    sed 's/^$/\x0/' $msm_path | sed --null-data -e 's/^\n//' -e 's/\n$//'
}

__msm_validate_snippet_store() {
    __msm_split_snippet_store | xargs --null -n1 sh -c ". '$msm_dir/msm.sh' && __msm_validate_snippet \"\$1\"" $0
}

__msm_save() {
    __msm_save_snippet="$1"

    if ! __msm_validate_snippet "$__msm_save_snippet"; then
        return 1
    fi

    # write in snippet store, adding space at the end
    printf "%s\n\n" "$__msm_save_snippet" >> $msm_path
}

[ -z "$msm_preview" ] && msm_preview='cat'

__msm_search() {
    query="$1"

    __msm_transform_store |
    fzf --read0 \
        --tac \
        --prompt="Snippets> " \
        --query="$query" \
        --delimiter="\n" \
        --with-nth=2.. \
        --preview="echo {} | $msm_preview" \
        --preview-window="bottom:5:wrap" |
    sed -n '2,$ p'    # remove description line
}

__msm_get_description() {
    # output nothing if it does not exist
    echo "$1" | sed -n 1p | grep "^#"
}

__msm_get_definition() {
    __msm_get_definition_snippet="$1"

    if __msm_get_description "$__msm_get_definition_snippet" >/dev/null; then
        __msm_get_definition_snippet="$(echo "$__msm_get_definition_snippet" | sed -n '2,$ p')"
    fi

    echo "$__msm_get_definition_snippet"
}

__msm_transform_snippet() {
    __msm_transform_snippet_snippet="$1"

    description="$(__msm_get_description "$__msm_transform_snippet_snippet")"
    definition="$(__msm_get_definition "$__msm_transform_snippet_snippet")"

    # if empty, print line anyway
    echo "$description"

    printf "%s\t\0" "$definition"
}

__msm_transform_store() {
    __msm_split_snippet_store | xargs --null -n1 sh -c ". '$msm_dir/msm.sh' && __msm_transform_snippet \"\$1\"" $0
}

__msm_capture() {
    if ! __msm_save "$READLINE_LINE"; then
        return 1
    fi

    READLINE_LINE=""
    READLINE_POINT=${#READLINE_LINE}

    # validate full snippet store
    __msm_validate_snippet_store
}

__msm_search_interactive() {

    __msm_search_interactive_output=$(__msm_search "$READLINE_LINE")

    if [ "$__msm_search_interactive_output" ]; then
        READLINE_LINE="$__msm_search_interactive_output"
        READLINE_POINT=${#READLINE_LINE}
    fi

}
