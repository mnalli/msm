# `msm`: a minimal snippet manager for the shell

`msm` enables you to interactively capture command snippets from your terminal
and recall them using [`fzf`](https://github.com/junegunn/fzf).

For `fish`, read [here](fish/README.md).

## Installation

```sh
git clone https://github.com/mnalli/msm.git --depth=1 ~/.msm
```

## Configuration

Source `msm.sh` in your .rc file (e.g. `.bashrc`, `.zshrc`, `.kshrc`):

```sh
source ~/.msm/msm.sh
```

Define key bindings for interactive functions:

```bash
bind -x '"\ea": __msm_capture'
bind -x '"\ez": __msm_search_interactive'
```

You can customize the behavior of `msm` by defining following variables:
- `msm_dir`: installation directory of `msm` (default: `~/.msm`)
- `msm_preview`: command used to preview snippets (default: `cat`)
    - You could use [`bat`](https://github.com/sharkdp/bat) to add syntax highlighting (also in `fzf` list)
- `msm_store`: location of the snippet store file (default: `~/snippets.sh`)

Example:

```bash
msm_dir=~/.config/bash/msm
msm_preview='batcat --decorations=never --color=always -l bash'
msm_store=~/.local/share/bash/snippets.sh

source $msm_dir/msm.sh
```

## Usage

- Capture snippet
    - Capture current content of your command line and add it to the snippet store file
    - Suggested binding: `Alt-a` (mnemonic: **add**)
- Search
    - Fuzzy search your snippets
    - Suggested binding: `Alt-z`

To modify your snippets, edit your snippet store directly with your favorite editor:

```sh
vim $msm_store
```

Note: always leave one white line between one snippet and its neighbors.

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

Write the snippet in your command line and then use `Alt-a` to **add** the snippet to the store.

For example, type the following:

```sh
git rebase -i
```

Now, press `Alt-a`. The command-line should disappear and if you open the
snippet store at `$msm_store` you should see the newly stored snippet, after
an empty description (added by default).

```sh
#
git rebase -i

```

---

If you want to be able to specify a description or to add multiline snippets, you
must be able to **insert newlines** in your command line. In most shells you
can't do this by default.

You can do this in `bash` adding the following to your `.bashrc`.

```bash
add_nl() {
    local region="${READLINE_LINE:0:READLINE_POINT}"
    local after="${READLINE_LINE:READLINE_POINT:${#READLINE_LINE}}"

    READLINE_LINE="$region
$after"
    ((READLINE_POINT++))
}

# bind it to Alt-Enter
bind -x '"\e\r": add_nl'
```

Now you can add a description to your snippet or capture multiline snippets,
with `Alt-Enter`.

```sh
# interactive rebase
git rebase -i
```

```sh
# multiline snippet example
echo this is a
echo multiline snippet
```
