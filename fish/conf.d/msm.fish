
set -g msm_dir "$HOME/Documents/Technical/Data/1 - Projects/Repos/msm"

set -g msm_preview 'batcat --decorations=never --color=always -l fish'
set -g msm_path ~/snippets.fish

set config_def "
msm_dir='$msm_dir'
msm_preview='$msm_preview'
msm_path='$msm_path'
"

function msm
    sh -c "
        $config_def
        . '$msm_dir/msm.sh' && msm $argv
    "
end

function __msm_capture
    sh -c "
        $config_def
        . '$msm_dir/msm.sh' && __msm_capture
    "
end

function __msm_search
    sh -c "
        $config_def
        . '$msm_dir/msm.sh' && __msm_search
    "
end

bind \ea __msm_capture
bind \ez __msm_search
