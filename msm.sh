# Minimal Snippet Manager

# This script tries to be mostly POSIX-compliant
# Should work on bash, ksh and zsh
# Source this file to use it

# shellcheck shell=sh

# Define these variables to change msm behavior
[ -z "$MSM_STORE"   ] && MSM_STORE=~/snippets.sh
[ -z "$MSM_PREVIEW" ] && MSM_PREVIEW='cat'

[ -z "$MSM_FZF_PREVIEW_WINDOW" ] && MSM_FZF_PREVIEW_WINDOW=''
[ -z "$MSM_FZF_LAYOUT"         ] && MSM_FZF_LAYOUT='default'


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
            _msm_search
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
        echo "Missing snippet description:" >&2
        echo "$1" | $MSM_PREVIEW >&2
        return 1
    fi

    # match description
    if echo "$_msm_validate_snippet_definition" | grep --quiet "^#"; then
        echo "Cannot have comments in definition (description can be one-line only):" >&2
        echo "$1" | $MSM_PREVIEW >&2
        return 1
    fi

    if echo "$_msm_validate_snippet_definition" | grep --quiet -E '^[ \t]*$'; then
        echo "Cannot have empty lines in definition:" >&2
        echo "$1" | $MSM_PREVIEW >&2
        return 1
    fi
}

_msm_split_snippet_store() {
    # split input into paragraph records (group of non‑blank lines),
    # then print them separated by NUL bytes
    awk 'BEGIN { RS=""; ORS=" \0" } { print }'
}

_msm_validate_snippet_store() {
    # shellcheck disable=SC2086 # we rely on word-splitting to split MSM_STORE
    # shellcheck disable=SC3045,3003 # these are not POSIX; we'll see if they cause problems
    cat $MSM_STORE | _msm_split_snippet_store | while read -r -d $'\0' snippet ; do
        _msm_validate_snippet "$snippet" || return 1
    done
}

_msm_save() {
    _msm_save_snippet="$1"

    if ! echo "$_msm_save_snippet" | sed -n 1p | grep --quiet '^#'; then
        _msm_save_snippet="#
$_msm_save_snippet"
    fi

    _msm_validate_snippet "$_msm_save_snippet" || return 1

    # append whitelines to snippet definition + write to master store
    printf "%s\n\n" "$_msm_save_snippet" >> "${MSM_STORE%% *}"
}

_msm_search() {
    # shellcheck disable=SC2046,SC2086 # we rely on word-splitting to split MSM_STORE

    # reverse order MSM_STORE elements, so that the master store appears last
    # this way, the last captured snippet will be the first result
    $MSM_PREVIEW $(echo $MSM_STORE | tac -s ' ') | _msm_split_snippet_store |
    fzf --read0 --ansi --tac --tabstop=4   \
        --delimiter='\n' --with-nth=2..,1  \
        --preview="echo {} | $MSM_PREVIEW" \
        --prompt='msm> ' --layout="$MSM_FZF_LAYOUT" \
        --preview-window="$MSM_FZF_PREVIEW_WINDOW"  |
    sed -n '2,$ p'    # remove description line
}
