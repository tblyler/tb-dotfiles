# Dotfiles

Useful configuration files ranging from shell scripts to configurations.

Managed with [mise](https://mise.jdx.dev)'s `[dotfiles]`/`bootstrap` support
(currently `[experimental]`) — not [chezmoi](https://github.com/twpayne/chezmoi)
anymore.

## Fresh machine

```sh
git clone git@git.0xdad.com:tblyler/tb-dotfiles.git ~/.dotfiles
~/.dotfiles/bin/mise bootstrap --yes
```

`bin/mise` is a self-installing bootstrap script (via `mise generate bootstrap`)
for machines that don't have mise yet.

## Already have mise

```sh
mise trust ~/.dotfiles/mise.toml
mise bootstrap -C ~/.dotfiles --dry-run   # review first
mise bootstrap -C ~/.dotfiles --force-dotfiles --yes
```

`--force-dotfiles` is only needed the first time on a machine with pre-existing
plain files (e.g. migrating off chezmoi) at the target paths.

## Layout

- `mise.toml` — dotfiles map, bootstrap config (repos, shell activation,
  login shell), and tool versions. Also symlinked to
  `~/.config/mise/config.toml`, so it's the global mise config on any machine
  this is applied to.
- `mise.linux.toml` / `mise.macos.toml` — OS-specific `[bootstrap.packages]`,
  loaded automatically via mise's `auto_env` (see the comment in
  `mise.toml`). Symlinked to `~/.config/mise/config.linux.toml` /
  `config.macos.toml` the same way `mise.toml` is.
- Everything else mirrors its target path under `$HOME` (e.g. `.zshrc` →
  `~/.zshrc`, `.config/nvim` → `~/.config/nvim`).

Licensed Dracula Pro theme assets live in a separate private repo
(`~/repos/dracula-pro`), pulled in via `[bootstrap.repos]`.
