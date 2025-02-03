# `msm`

Minimal Snippet Manager for fish shell.

`msm` allows you to capture and save command line snippets interactively from
your shell, and recall them using user-friendly fuzzy search.

## Installation

Install with Fisher:

```fish
fisher install mnalli/msm
```

Alternatively, you can simply copy `conf.d/msm.d` under your `conf.d` directory.

## Usage

Write the snippet in your command line and then use `Ctrl-a` to **add** the snippet to
the store.

For example, write the following in your command line.

```fish
git rebase -i
```

Now, press `Ctrl-a`. Now the snippet should disappear from the command line and
if you open the snippet store at `$msm_path` you should see the new snippet.

Perform fuzzy search on your snippet with `Ctrl-s`.

You can also add a description to your snippet.

```fish
# interactive rebase
git rebase -i
```

In fish, you can insert a newline in the command line with `Alt-Enter`. You can
also modify the command line using your favorite editor (`Alt-e`).

The **description** can be of one line only: this forces the user to be succint.
The description will be searched for during fuzzy search.

The **definition** can be of multiple lines, but no empty lines are admitted.

`msm` stores all snippets under `$msm_path` (default is `$__fish_user_data_dir/snippets.fish`).
As you can see, this is a simple fish file, no fancy format is used for storing the config.
This means that you are free to modify the snippet store manually using your favorite
text editor and plugins. Just be mindful of maintaining _one blank line_ between two
snippets, otherwise the snippet store will not be considered valid.

You can also call `msm` commands from the command line, using the `msm` function.

```fish
msm help

# validate snippet store (useful if you modified the file manually)
msm validate

# validate single snippet
msm validate "# interactive rebase
git rebase -i"

# save snippet (validation is implicit)
msm save "# interactive rebase
git rebase -i"

# perform fuzzy search
msm search
```
