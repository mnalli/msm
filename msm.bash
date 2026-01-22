# Minimal Snippet Manager - bash implementation
# Source this file to use it

# Define these variables to change msm behavior
: "${MSM_STORE:=~/snippets.sh}"
: "${MSM_PREVIEW:=cat}"

# fzf config
: "${MSM_FZF_PREVIEW_WINDOW:=}"
: "${MSM_FZF_LAYOUT:=default}"

msm_help() {
    echo 'msm_* functions

    msm_help                 Show this message
    msm_save "<snippet>"     Save snippet
    msm_validate             Validate snippet store structure
    msm_validate "<snippet>" Validate snippet
    msm_search               Interactively search for snippets'
}

_msm_validate_snippet() {
    local description
    local definition

    description="$(echo "$1" | sed -n '1p')"
    definition="$(echo "$1" | sed -n '2,$p')"

    if ! [[ "$description" =~ ^# ]]; then
        echo "Missing snippet description:" >&2
        echo "$1" | $MSM_PREVIEW >&2
        return 1
    fi

    # match description
    if echo "$definition" | grep --quiet "^#"; then
        echo "Cannot have comments in definition (description can be one-line only):" >&2
        echo "$1" | $MSM_PREVIEW >&2
        return 1
    fi

    if echo "$definition" | grep --quiet -E '^[ \t]*$'; then
        echo "Cannot have empty lines in definition:" >&2
        echo "$1" | $MSM_PREVIEW >&2
        return 1
    fi
}

_msm_split_snippet_store() {
    # split input into paragraph records (group of non-blank lines),
    # then print them separated by NUL bytes
    awk 'BEGIN { RS=""; ORS=" \0" } { print }'
}

_msm_validate_snippet_store() {
    local snippet

    cat "${MSM_STORE[@]}" | _msm_split_snippet_store | while read -r -d '' snippet ; do
        _msm_validate_snippet "$snippet" || return 1
    done
}

msm_validate() {
    local snippet="$1"

    if [[ -z "$snippet" ]]; then
        _msm_validate_snippet_store
    else
        _msm_validate_snippet "$snippet"
    fi
}

msm_save() {
    local snippet="$1"

    # ensure snippet starts with a description
    if ! [[ "$snippet" =~ ^# ]]; then
        snippet="#
$snippet"
    fi

    _msm_validate_snippet "$snippet" || return 1

    # append whitelines to snippet definition and write to master store
    printf '%s\n\n' "$snippet" >> "${MSM_STORE[0]}"
}

msm_search() {
    # shellcheck disable=SC2046,SC2086 # we rely on word-splitting to split MSM_STORE

    # reverse order MSM_STORE elements, so that the master store appears last
    # this way, the last captured snippet will be the first result
    $MSM_PREVIEW $(echo "${MSM_STORE[@]}" | tac -s ' ') | _msm_split_snippet_store |
    fzf --read0 --ansi --tac --tabstop=4   \
        --delimiter='\n' --with-nth=2..,1  \
        --preview="echo {} | $MSM_PREVIEW" \
        --prompt='msm> ' --layout="$MSM_FZF_LAYOUT" \
        --preview-window="$MSM_FZF_PREVIEW_WINDOW"  |
    sed -n '2,$ p'    # remove description line
}


# functions for interactive usage

msm_capture() {
    msm_save "$READLINE_LINE" || return 1

    READLINE_LINE=''
    READLINE_POINT=0
}

msm_recall() {
    local output

    output=$(msm_search) || return 1

    local before="${READLINE_LINE:0:READLINE_POINT}"
    local after="${READLINE_LINE:READLINE_POINT:${#READLINE_LINE}}"

    # insert output
    READLINE_LINE="$before$output$after"
    READLINE_POINT=$(( ${#before} + ${#output} ))
}
