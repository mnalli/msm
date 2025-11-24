
function msm
    sh -c "
        msm_dir='$msm_dir'
        msm_path='$msm_path'
        msm_preview='$msm_preview'

        . '$msm_dir/msm.sh'
        msm $argv
    "
end

function __msm_capture

    set snippet (commandline | string collect)

    set output (
        sh -c "
            msm_dir='$msm_dir'
            msm_path='$msm_path'
            msm_preview='$msm_preview'

            . '$msm_dir/msm.sh'
            msm save '$snippet'
        "
    )

    commandline -r ''

end

function __msm_search

    set output (
        sh -c "
            msm_dir='$msm_dir'
            msm_path='$msm_path'
            msm_preview='$msm_preview'

            . '$msm_dir/msm.sh'
            msm search '$(commandline)'
        "
    )

    if test -n "$output"
        commandline -r "$output"
    end

end

bind \ea __msm_capture
bind \ez __msm_search
