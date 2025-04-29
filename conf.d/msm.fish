
function msm -d "Minimal Snippet Manager CLI" -a subcommand -a snippet

    switch $subcommand
        case save
            __msm_save $snippet
        case validate
            if test -z $snippet
                __msm_validate_snippet_store
            else
                __msm_validate_snippet $snippet
            end
        case search
            __msm_search
        case help
            echo "Help:"
        case '*'
            echo "Error: invalid subcommand $subcommand" >&2
    end

end

set -g msm_path $__fish_user_data_dir/snippets.fish


function __msm_validate_snippet -a snippet

    if not fish --no-execute -c $snippet
        echo "Error: invalid snippet" >&2
        return 1
    end

    __msm_validate_snippet_structure $snippet
end

function __msm_validate_snippet_structure -a snippet
    set -l lines (echo $snippet | string split "\n")

    # match description
    if string match --quiet "#*" $lines[1]
        # remove description
        set lines $lines[2..-1]
    end

    __msm_validate_definition_structure $lines
end

function __msm_validate_definition_structure

    set -l lines $argv

    if test (count $lines) -le 0
        echo "Error: missing snippet definition" >&2
        return 1
    end

    for l in $lines
        # match description
        if string match --quiet "#*" $l
            echo "Error: $l" >&2
            echo "Error: cannot have description in definition (description can be one line only)" >&2
            return 1
        end

        if test -z (string trim $l)
            echo "Error: cannot have whitelines in definition" >&2
            return 1
        end
    end

end

function __msm_split_snippet_store
    # replace empty lines with null characters, then split snippets
    sed 's/^$/\x0/' $msm_path | sed -z 's/^\n//' | sed -z 's/\n$//'
end

function __msm_validate_snippet_store

    set -l snippets (__msm_split_snippet_store | string split0)

    for snippet in $snippets
        if not __msm_validate_snippet $snippet
            echo "Error: invalid snippet" >&2
            echo $snippet >&2
            return 1
        end
    end

end

function __msm_save -a snippet

    if not __msm_validate_snippet $snippet
        return 1
    end

    # write in snippet store, adding newline at the end
    echo -e "$snippet\n" >> $msm_path
end

# TODO: set default filtering command
# set -g msm_fuzzy_filter ''

function __msm_search
    set -l snippet (
        __msm_transform_store | fzf --read0 \
            --prompt="Snippets> " \
            --query=(commandline) \
            --delimiter="\n" \
            --with-nth=2..,1 \
            --preview="echo {} | fish_indent --ansi" \
            --preview-window="bottom:5:wrap"
    )

    # remove descriptionline and trailing whitespaces (during expansion)
    commandline --replace $snippet[2..-1]
end

function __msm_get_description -a snippet
    set -l lines (echo $snippet | string split "\n")

    # echo line on match
    string match "#*" $lines[1]
end

function __msm_get_definition -a snippet
    set -l lines (echo $snippet | string split "\n")

    # match description
    if string match --quiet "#*" $lines[1]
        # remove description
        set lines $lines[2..-1]
    end

    for line in $lines
        echo $line
    end
end

function __msm_transform_store

    set -l snippets (__msm_split_snippet_store | string split0)

    for snippet in $snippets
        set -l description (__msm_get_description $snippet)
        set -l definition (__msm_get_definition $snippet | string collect)

        # if empty, print line anyway
        echo $description

        printf "%s\t\t\t\0" $definition
    end

end

function __msm_capture
    set -l snippet (commandline | string collect)

    if not __msm_save $snippet
        return 1
    end

    commandline --replace ""

    # validate full snippet store
    __msm_validate_snippet_store
end

bind \ca __msm_capture
bind \cs __msm_search
