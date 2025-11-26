# Minimal Snippet Manager

# Implemented as a native fish script
# Source this file to use it

# Define these variables to change msm behavior
not set -q msm_store   && set -g msm_store ~/snippets.sh
not set -q msm_preview && set -g msm_preview cat

set -l __msm_help 'Usage: msm subcommand [string]

    msm help                   Show this message
    msm save "<snippet>"       Save snippet
    msm validate               Validate snippet store structure
    msm validate "<snippet>"   Validate snippet
    msm search                 Interactively search for snippets
    msm search "<query>"       Interactively search with pre-loaded query'

function msm -a subcommand -a snippet -d 'msm command line interface'
    switch $subcommand
        case save
            __msm_save "$snippet"
        case validate
            if test -z "$snippet"
                __msm_validate_snippet_store
            else
                __msm_validate_snippet "$snippet"
            end
        case search
            __msm_search "$snippet"
        case help
            echo "$__msm_help"
        case '*'
            echo "Invalid subcommand '$msm_subcommand'" >&2
            msm help
    end
end

function __msm_validate_snippet -a snippet
    set -l description (echo "$snippet" | sed -n '1p')
    set -l definition (echo "%s\n" "$snippet" | sed -n '2,$ p')

    if not echo "$description" | grep --quiet "^#"
        echo "Missing snippet description\n" >&2
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

function __msm_split_snippet_store
    # replace empty lines with null characters, then split snippets
    sed 's/^$/\x0/' | sed --null-data -e 's/^\n//' -e 's/\n$//'
end

# Validate the whole snippet store file
function __msm_validate_snippet_store
    set -l rval 0

    # split store into snippets
    set -l raw (__msm_split_snippet_store < "$msm_store")
    set -l snippets (string split \0 -- $raw)

    for snippet in $snippets
        if not __msm_validate_snippet "$snippet"
            set rval 1
        end
    end

    return $rval
end

# TODO: check
function __msm_save -a snippet
    # If the first line doesn't start with #, prepend a blank description line
    if not printf "%s\n" "$snippet" | sed -n '1p' | grep --quiet '^#'
        set snippet "#
$snippet"
    end

    if not __msm_validate_snippet "$snippet"
        return 1
    end

    # write in snippet store, adding space at the end
    printf "%s\n\n" "$snippet" >> "$msm_store"
end

# Search snippets using fzf. Query is optional.
function __msm_search -a query -d 'Search snippets (query is optional)'
    $msm_preview "$msm_store" | __msm_split_snippet_store |
        fzf --read0 \
            --ansi \
            --tac \
            --prompt="Snippets> " \
            --query="$query" \
            --delimiter="\n" \
            --with-nth=2..,1 \
            --preview="echo {} | $msm_preview" \
            --preview-window="bottom:5:wrap" |
        sed -n '2,$ p'
end

function msm_capture -d 'Save current commandline as snippet'
    set -l line "$(commandline)"

    if not __msm_save "$line"
        return 1
    end

    # Clear the commandline
    commandline -r ''
end

function msm_search_interactive
    set -l current (commandline)
    set -l output (__msm_search "$current")

    if test -n "$output"
        # Replace current commandline with the selected snippet text
        commandline -r -- "$output"
    end
end
