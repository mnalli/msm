# Minimal Snippet Manager

# Implemented as a POSIX-compliant script
# Should work on sh, dash, bash, ksh, zsh
# Source this file to use it

# Define these variables to change msm behavior
[ -z "$MSM_STORE"   ] && MSM_STORE=~/snippets.sh
[ -z "$MSM_PREVIEW" ] && MSM_PREVIEW='cat'

_msm_help='Usage: msm subcommand [string]

    msm help                   Show this message
    msm save "<snippet>"       Save snippet
    msm validate               Validate snippet store structure
    msm validate "<snippet>"   Validate snippet
    msm search                 Interactively search for snippets'

msm() {
    _msm_subcommand="$1"
    _msm_snippet="$2"

    case "$_msm_subcommand" in
        save)
            _msm_save "$_msm_snippet"
            ;;
        validate)
            if [ -z "$_msm_snippet" ]; then
                _msm_validate_snippet_store
            else
                _msm_validate_snippet "$_msm_snippet"
            fi
            ;;
        search)
            _msm_search "$_msm_snippet"
            ;;
        help)
            echo "$_msm_help"
            ;;
        *)
            echo "Invalid subcommand '$_msm_subcommand'" >&2
            msm help
            ;;
    esac
}

_msm_validate_snippet() {
    _msm_validate_snippet_description="$(echo "$1" | sed -n 1p)"
    _msm_validate_snippet_definition="$(echo "$1" | sed -n '2,$ p')"

    if ! echo "$_msm_validate_snippet_description" | grep --quiet "^#"; then
        echo "Missing snippet description" >&2
        echo "'$1'" | nl -w 1 -v 0 -b a -s ": " >&2
        return 1
    fi

    # match description
    if echo "$_msm_validate_snippet_definition" | grep -n "^#" >&2; then
        echo "Cannot have comments in definition (description can be one-line only)" >&2
        echo "$1" | nl -w 1 -v 0 -b a -s ": " >&2
        return 1
    fi

    if echo "$_msm_validate_snippet_definition" | grep -n -E '^[ \t]*$' >&2; then
        echo "Cannot have empty (or white) lines in definition" >&2
        echo "$1" | nl -w 1 -v 0 -b a -s ": " >&2
        return 1
    fi
}

_msm_split_snippet_store() {
    # split input into paragraph records (group of non‑blank lines),
    # then print them separated by NUL bytes
    awk 'BEGIN { RS=""; ORS=" \0" } { print }'
}

_msm_validate_snippet_store() {
    _msm_validate_snippet_store_status=0

    while read -r -d $'\0' snippet ; do
        if ! _msm_validate_snippet "$snippet"; then
            _msm_validate_snippet_store_status=1
        fi
    done << EOF
$(cat $MSM_STORE | _msm_split_snippet_store)
EOF

    return $_msm_validate_snippet_store_status
}

_msm_save() {
    _msm_save_snippet="$1"

    if ! echo "$_msm_save_snippet" | sed -n 1p | grep --quiet '^#'; then
        _msm_save_snippet="#
$_msm_save_snippet"
    fi

    if ! _msm_validate_snippet "$_msm_save_snippet"; then
        return 1
    fi

    # append whitelines to snippet definition + write to master store
    printf "%s\n\n" "$_msm_save_snippet" >> ${MSM_STORE%% *}
}

_msm_search() {
    $MSM_PREVIEW $MSM_STORE | _msm_split_snippet_store |
    fzf --read0 \
        --ansi \
        --tac \
        --prompt="Snippets> " \
        --delimiter="\n" \
        --with-nth=2..,1 \
        --preview="echo {} | $MSM_PREVIEW" \
        --preview-window="bottom:5:wrap" |
    sed -n '2,$ p'    # remove description line
}
