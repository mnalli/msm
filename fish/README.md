# `msm`: a minimal snippet manager for `fish`

Fish-native implementation of [`msm`](https://github.com/mnalli/msm.fish/blob/main/README.md).

## Installation

To install it, you can simply copy [`conf.d/msm.fish`](conf.d/msm.fish) under
your fish installation `conf.d` directory.

```fish
curl -L https://raw.githubusercontent.com/mnalli/msm.fish/refs/heads/main/conf.d/msm.fish > $__fish_config_dir/conf.d/msm.fish
```

### Using [Fisher](https://github.com/jorgebucaran/fisher)

```fish
fisher install mnalli/msm.fish
```

## Configuration

In your `config.fish`, you can add configuration variables and bindings for
interactive functions:

```fish
set -g MSM_PREVIEW batcat --decorations=never --color=always -l fish
set -g MSM_STORE $__fish_user_data_dir/snippets.fish

bind \ea msm_capture
bind \ez msm_search_interactive
```

## Usage

View usage tutorial [here](https://github.com/mnalli/msm?tab=readme-ov-file#usage).

Note: in `fish`, you can add a newline in the command line with `Alt-Enter` by default.

## Clear screen from errors

If a snippet validation error occurs during capture, stderr will pollute the
command line. To clear the screen while maintaining the current command line
content, you can use `CTRL-l` (`clear-screen`).
