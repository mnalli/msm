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
    subcommand="$1"
    snippet="$2"

    case "$subcommand" in
        save)
            __msm_save "$snippet"
            ;;
        validate)
            if [ -z "$snippet" ]; then
                __msm_validate_snippet_store
            else
                __msm_validate_snippet "$snippet"
            fi
            ;;
        search)
            __msm_search
            ;;
        help)
            echo "$__msm_help"
            ;;
        *)
            echo "Error: invalid subcommand $subcommand" >&2
            ;;
    esac
}

[ -z "$msm_path" ] && msm_path=~/snippets.sh

__msm_validate_snippet() {
    snippet="$1"

    if ! __msm_validate_snippet_structure "$snippet"; then
        echo "Error: '$snippet'" >&2
        return 1
    fi
}

__msm_validate_snippet_structure() {
    snippet="$1"

    # matched description?
    if echo "$snippet" | sed -n 1p | grep --quiet "^#"; then
        # remove description
        snippet="$(echo "$snippet" | sed -n '2,$ p')"
    fi

    __msm_validate_definition_structure "$snippet"
}

__msm_validate_definition_structure() {
    snippet=$1

    if [ -z "$snippet" ]; then
        echo "Error: missing snippet definition" >&2
        return 1
    fi

    # match description
    if echo "$snippet" | grep "^#" >&2; then
        echo "Error: cannot have comments in definition (description can be one-line only)" >&2
        return 1
    fi

    if echo "$snippet" | grep -n -E '^[ \t]*$' >&2; then
        echo "Error: cannot have empty or white lines in definition" >&2
        return 1
    fi

}

__msm_split_snippet_store() {
    # replace empty lines with null characters, then split snippets
    sed 's/^$/\x0/' $msm_path | sed -z 's/^\n//' | sed -z 's/\n$//'
}

__msm_validate_snippet_store() {
    __msm_split_snippet_store | xargs --null -n1 sh -c '. msm.sh && __msm_validate_snippet "$1"' $0
}

__msm_save() {
    snippet="$1"

    if ! __msm_validate_snippet "$snippet"; then
        return 1
    fi

    # write in snippet store, adding space at the end
    printf "%s\n\n" "$snippet" >> $msm_path
}

[ -z "$msm_preview" ] && msm_preview='cat'

__msm_search() {
    snippet="$(
        __msm_transform_store | fzf --read0 \
            --prompt="Snippets> " \
            --query="$READLINE_LINE" \
            --delimiter="\n" \
            --with-nth=2..,1 \
            --preview="echo {} | $msm_preview" \
            --preview-window="bottom:5:wrap"
    )"

    # remove description line (and trailing whitespaces ???)
    output="$(echo "$snippet" | sed -n '2,$ p')"

    READLINE_LINE="$output"
    READLINE_POINT=${#READLINE_LINE}
}

__msm_get_description() {
    snippet="$1"

    # output nothing if it does not exist
    echo "$snippet" | sed -n 1p | grep "^#"
}

__msm_get_definition() {
    snippet="$1"

    if __msm_get_description "$snippet" >/dev/null; then
        snippet="$(echo "$snippet" | sed -n '2,$ p')"
    fi

    echo "$snippet"
}

__msm_transform_snippet() {
    snippet="$1"

    description="$(__msm_get_description "$snippet")"
    definition="$(__msm_get_definition "$snippet")"

    # if empty, print line anyway
    echo "$description"

    printf "%s\t\0" "$definition"
}

__msm_transform_store() {
    __msm_split_snippet_store | xargs --null -n1 sh -c '. msm.sh && __msm_transform_snippet "$1"' $0
}

__msm_capture() {
    snippet="$READLINE_LINE"

    if ! __msm_save "$snippet"; then
        return 1
    fi

    echo "Appended to $msm_path."

    # validate full snippet store
    __msm_validate_snippet_store
}
