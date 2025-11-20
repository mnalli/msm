
# these variables must be defined in config.fish
function __msm_config_vars
    echo "
msm_dir='$msm_dir'
msm_preview='$msm_preview'
msm_path='$msm_path'
"
end

function msm
    sh -c "
        $(__msm_config_vars)
        . '$msm_dir/msm.sh' && msm $argv
    "
end

function __msm_capture

    set snippet (commandline | string collect)

    set output (
        sh -c "
            $(__msm_config_vars)
            . '$msm_dir/msm.sh' && msm save '$snippet'
        "
    )

    commandline -r ''

end

function __msm_search

    set output (
        sh -c "
            $(__msm_config_vars)
            . '$msm_dir/msm.sh' && msm search '$(commandline)'
        "
    )

    if test -n "$output"
        commandline -r "$output"
    end

end

bind \ea __msm_capture
bind \ez __msm_search
