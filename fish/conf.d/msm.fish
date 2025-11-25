
function msm -a subcommand -a snippet
    sh -c "
        msm_dir='$msm_dir'
        msm_path='$msm_path'
        msm_preview='$msm_preview'

        . '$msm_dir/msm.sh'
        msm $subcommand '$snippet'
    "
end

function __msm_capture

    set snippet (commandline | string collect)

    sh -c "
        msm_dir='$msm_dir'
        msm_path='$msm_path'
        msm_preview='$msm_preview'

        . '$msm_dir/msm.sh'
        msm save '$snippet'
    "

    if test $status -eq 0
        commandline -r ''
    end

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
