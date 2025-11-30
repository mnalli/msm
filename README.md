# `msm`: a minimal snippet manager for the shell

`msm` enables you to interactively capture command snippets from your terminal
and recall them using [`fzf`](https://github.com/junegunn/fzf).

For `fish`, read [here](https://github.com/mnalli/msm.fish/blob/main/README.md).

## Installation

```sh
git clone https://github.com/mnalli/msm.git --depth=1 ~/.msm
```

Note: instead of `~/.msm/` you can use the path you prefer.

## Configuration

Source `msm.sh` (POSIX-compliant) and your specific shell script in your `.rc` file.

```sh
# bash
eval "$(cat ~/.msm/msm.{sh,bash})"

# TODO: zsh
```

ALso, define key bindings for interactive functions:

```sh
# bash
bind -x '"\ea": msm_capture'
bind -x '"\ez": msm_search_interactive'

# TODO: zsh
```

You can customize the behavior of `msm` by defining following variables:

```sh
# command used to preview snippets (default: cat)
MSM_PREVIEW='batcat --decorations=never --color=always -l bash'
# location of the snippet store file (default: ~/snippets.sh)
MSM_STORE=~/.local/share/bash/snippets.sh
```

## Usage

- Capture snippet
    - Capture current content of your command line and add it to the snippet store file
    - Suggested key binding: `Alt-a` (mnemonic: **add**)
- Search
    - Fuzzy search your snippets
    - Suggested key binding: `Alt-z`

To modify your snippets, edit your snippet store directly with your favorite editor:

```sh
vim $MSM_STORE
```

Always leave one white line between one snippet and its neighbors. You can run
`msm validate` to validate the snippet store after you modified it.

## Snippet format

- **Description**: comment at the beginning of the snippet
    - One-line only
    - The description will be searched for during fuzzy search
    - **Optional**: if not provided, a default empty one will be added
- **Definition**
    - Can be of multiple lines
    - No empty lines

## CLI

`msm` has a simple command-line interface.

```sh
# view all subcommands
msm help

# validate snippet store (useful if you modified the file manually)
msm validate
```

## Tutorial

![Usage example](usage.gif)

Write the snippet in your command line and then use `Alt-a` to **add** the snippet to the store.

For example, type the following:

```sh
git rebase -i
```

Now, press `Alt-a`. The command-line should disappear and if you open the
snippet store at `$MSM_STORE` you should see the newly stored snippet, after
an empty description (added by default):

```sh
#
git rebase -i

```

---

If you want to be able to specify a description or to add multiline snippets, you
must be able to **insert newline characters** in your command line. Shells like
`zsh` or `fish` can do this by default (with `Alt-Enter`), but `bash` cannot.
View [here](https://github.com/mnalli/insert_newline.bash) how to add this behavior.

The followings are valid snippets:

```sh
# interactive rebase
git rebase -i
```

```sh
# multiline snippet example
echo this is a
echo multiline snippet
```

---

If you recall a snippet, `msm` will insert it under the cursor in your current
command line. Here are some examples ('_' is the cursor location):

```sh
# recall command that generates a stream
less -f <(_)

# recall hard to remember path
ls _
```
