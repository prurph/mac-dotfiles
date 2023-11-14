local nvim_tmux_navigation = require "nvim-tmux-navigation"

return {
  n = {
    ["<C-h>"] = {
      nvim_tmux_navigation.NvimTmuxNavigateLeft,
      desc = "Move to split left [P]",
      silent = true,
    },
    ["<C-j>"] = {
      nvim_tmux_navigation.NvimTmuxNavigateDown,
      desc = "Move to split below [P]",
      silent = true,
    },
    ["<C-k>"] = {
      nvim_tmux_navigation.NvimTmuxNavigateUp,
      desc = "Move to split below [P]",
      silent = true,
    },
    ["<C-l>"] = {
      nvim_tmux_navigation.NvimTmuxNavigateRight,
      desc = "Move to split right [P]",
      silent = true,
    },
    ["<C-\\>"] = {
      nvim_tmux_navigation.NvimTmuxNavigateLastActive,
      desc = "Move to last active split [P]",
      silent = true,
    },
    ["<C-Space>"] = {
      nvim_tmux_navigation.NvimTmuxNavigateNext,
      desc = "Move to next split [P]",
      silent = true,
    },
  },
}
