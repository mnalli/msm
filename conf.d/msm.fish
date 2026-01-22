# Minimal Snippet Manager

# Implemented as a native fish script
# Source this file to use it

# Define these variables to change msm behavior
not set -q MSM_STORE   && set -g MSM_STORE ~/snippets.sh
not set -q MSM_PREVIEW && set -g MSM_PREVIEW cat

# fzf config
not set -q MSM_FZF_PREVIEW_WINDOW && set -g MSM_FZF_PREVIEW_WINDOW ''
not set -q MSM_FZF_LAYOUT         && set -g MSM_FZF_LAYOUT default

function msm_help
    echo 'msm_* functions

    msm_help                 Show this message
    msm_save "<snippet>"     Save snippet
    msm_validate             Validate snippet store structure
    msm_validate "<snippet>" Validate snippet
    msm_search               Interactively search for snippets'
end

function _msm_validate_snippet -a snippet
    set -l description (echo "$snippet" | sed -n '1p')
    set -l definition (echo "%s\n" "$snippet" | sed -n '2,$ p')

    if not echo "$description" | grep --quiet "^#"
        echo "Missing snippet description:" >&2
        echo "$snippet" | $MSM_PREVIEW >&2
        return 1
    end

    # match description
    if echo "$definition" | grep --quiet "^#"
        echo "Cannot have comments in definition (description can be one-line only):" >&2
        echo "$snippet" | $MSM_PREVIEW >&2
        return 1
    end

    if echo "$definition" | grep --quiet -E '^[ \t]*$'
        echo "Cannot have empty lines in definition:" >&2
        echo "$snippet" | $MSM_PREVIEW >&2
        return 1
    end
end

function _msm_split_snippet_store
    # split input into paragraph records (group of non‑blank lines),
    # then print them separated by NUL bytes
    awk 'BEGIN { RS=""; ORS=" \0" } { print }'
end

function _msm_validate_snippet_store
    cat $MSM_STORE | _msm_split_snippet_store | while read --null snippet
        _msm_validate_snippet "$snippet" || return 1
    end
end

function msm_validate -a snippet
    if test -z "$snippet"
        _msm_validate_snippet_store
    else
        _msm_validate_snippet "$snippet"
    end
end

function msm_save -a snippet
    # If the first line doesn't start with #, prepend a blank description line
    if not printf "%s\n" "$snippet" | sed -n '1p' | grep --quiet '^#'
        set snippet "#
$snippet"
    end

    _msm_validate_snippet "$snippet" || return 1

    # write in snippet store, adding space at the end
    printf "%s\n\n" "$snippet" >> $MSM_STORE[1]
end

function msm_search -d 'Search snippets'
    $MSM_PREVIEW $MSM_STORE[-1..1] | _msm_split_snippet_store |
        fzf --read0 --ansi --tac --tabstop=4   \
            --delimiter="\n" --with-nth=2..,1  \
            --preview="echo {} | $MSM_PREVIEW" \
            --prompt="msm> " --layout="$MSM_FZF_LAYOUT" \
            --preview-window="$MSM_FZF_PREVIEW_WINDOW"  |
        sed -n '2,$ p'    # remove description line
end

function msm_capture -d 'Save current commandline as snippet'
    msm_save "$(commandline)" || return 1
    commandline --replace ''
end

function msm_recall -d 'Search snippet and insert it in commandline'
    set -l output (msm_search)

    if test -n "$output"
        commandline --insert "$output"
    end
end
