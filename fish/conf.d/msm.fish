# Minimal Snippet Manager

# Implemented as a native fish script
# Source this file to use it

# Define these variables to change msm behavior
not set -q MSM_STORE   && set -g MSM_STORE ~/snippets.sh
not set -q MSM_PREVIEW && set -g MSM_PREVIEW cat

set -l _msm_help 'Usage: msm subcommand [string]

    msm help                   Show this message
    msm save "<snippet>"       Save snippet
    msm validate               Validate snippet store structure
    msm validate "<snippet>"   Validate snippet
    msm search                 Interactively search for snippets'

function msm -a subcommand -a snippet -d 'msm command line interface'
    switch $subcommand
        case save
            _msm_save "$snippet"
        case validate
            if test -z "$snippet"
                _msm_validate_snippet_store
            else
                _msm_validate_snippet "$snippet"
            end
        case search
            _msm_search
        case help
            echo "$_msm_help"
        case '*'
            echo "Invalid subcommand '$msm_subcommand'" >&2
            msm help
    end
end

function _msm_validate_snippet -a snippet
    set -l description (echo "$snippet" | sed -n '1p')
    set -l definition (echo "%s\n" "$snippet" | sed -n '2,$ p')

    if not echo "$description" | grep --quiet "^#"
        echo "Missing snippet description" >&2
        echo "$snippet" | nl -w 1 -v 0 -b a -s ": " >&2
        return 1
    end

    # match description
    if echo "$definition" | grep -n "^#" >&2
        echo "Cannot have comments in definition (description can be one-line only)" >&2
        echo "$snippet" | nl -w 1 -v 0 -b a -s ": " >&2
        return 1
    end

    if echo "$definition" | grep -n -E '^[ \t]*$' >&2
        echo "Cannot have empty (or white) lines in definition" >&2
        echo "$snippet" | nl -w 1 -v 0 -b a -s ": " >&2
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

# TODO: check
function _msm_save -a snippet
    # If the first line doesn't start with #, prepend a blank description line
    if not printf "%s\n" "$snippet" | sed -n '1p' | grep --quiet '^#'
        set snippet "#
$snippet"
    end

    _msm_validate_snippet "$snippet" || return 1

    # write in snippet store, adding space at the end
    printf "%s\n\n" "$snippet" >> $MSM_STORE[1]
end

function _msm_search -d 'Search snippets'
    $MSM_PREVIEW $MSM_STORE | _msm_split_snippet_store |
        fzf --read0 \
            --ansi \
            --tac \
            --prompt="Snippets> " \
            --delimiter="\n" \
            --with-nth=2..,1 \
            --preview="echo {} | $MSM_PREVIEW" \
            --preview-window="bottom:5:wrap" \
            --tabstop=2 |
        sed -n '2,$ p'
end

function msm_capture -d 'Save current commandline as snippet'
    _msm_save "$(commandline)" || return 1
    commandline --replace ''
end

function msm_recall -d 'Search snippet and insert it in commandline'
    set -l output (_msm_search)

    if test -n "$output"
        commandline --insert "$output"
    end
end
