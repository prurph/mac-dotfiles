# Neovim Configuration

Uses [AstroNvim](https://astronvim.com)

## Installation

- Install AstroNvim as directed
- Put this directory into `~/.config/nvim`
  - It contains `lua/user`; desired result is my config files end up at `~/.config/nvim/lua/user`
  - This could probably be better done with a submodule, or at least git sparse checkout

## Some AstroNvim learnings

### Key commands

- Installing language specific stuff
  - `:LspInstall` language servers
  - `:NullLsInstall` install formatters (sylua, prettier, etc) via `mason-null-ls`
    - If format on save isn't working you probably didn't install a formatter, only the lang server!
  - `:TSInstall` language parsers
  - `:DapInstall` debuggers
- AstroNvim commands 
  - `:AstroUpdate`, `<leader>pA`
  - `:AstroUpdatePackages`, `<leader>pa`
- If you define custom mappings like I have in `lua/user/mappings.lua` they get picked up by which key. Cool!
