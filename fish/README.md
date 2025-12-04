# `msm`: a minimal snippet manager for the shell

Fish-native implementation of [`msm`](../README.md).

## Installation

To install it, you can simply copy [`conf.d/msm.fish`](conf.d/msm.fish) under
your fish installation `conf.d` directory.

```fish
curl https://raw.githubusercontent.com/mnalli/msm/refs/heads/main/fish/conf.d/msm.fish -o $__fish_config_dir/conf.d/msm.fish
```

### Using [`fisher`](https://github.com/jorgebucaran/fisher)

Installation with `fisher` is not supported. Its support will depend on
[this issue](https://github.com/jorgebucaran/fisher/issues/815).

It used to be supported with an independent `msm.fish` repository, but its
support was dropped in favour of a clearer monorepo approach.

## Configuration

In your `config.fish`, you can add configuration variables and bindings for
interactive functions:

```fish
set -g MSM_PREVIEW batcat --decorations=never --color=always -l fish
set -g MSM_STORE $__fish_user_data_dir/snippets.fish

bind \ea msm_capture
bind \ez msm_recall
```

## Usage

View usage tutorial [here](../README.md#usage).

Note: in `fish`, you can add a newline in the command line with `Alt-Enter` by default.

## Using multiple snippet stores

It is possible to configure [multiple snippet stores](../README.md#using-multiple-snippet-stores).

```fish
set -g MSM_STORE $__fish_user_data_dir/snippets.fish ~/paths.path
```

Here's how you can easily interact with different stores:

```sh
# open all stores in vim
vim $MSM_STORE

# open second store
vim $MSM_STORE[2]
```

## Clear screen from errors

If a snippet validation error occurs during capture, stderr will pollute the
command line. To clear the screen while maintaining the current command line
content, you can use `CTRL-l` (`clear-screen`).
