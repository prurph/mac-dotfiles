local nvim_tmux_navigation = require "nvim-tmux-navigation"

return {
  n = {
    -- ~~~ Movement
    -- Unmap the defaults to close all to left/right
    ["<leader>bl"] = nil,
    ["<leader>br"] = nil,
    ["<S-h>"] = {
      function() require("astronvim.utils.buffer").nav(-(vim.v.count > 0 and vim.v.count or 1)) end,
      desc = "Buffer to left",
    },
    ["<S-l>"] = {
      function() require("astronvim.utils.buffer").nav(vim.v.count > 0 and vim.v.count or 1) end,
      desc = "Buffer to right",
    },
    ["<C-h>"] = {
      nvim_tmux_navigation.NvimTmuxNavigateLeft,
      desc = "Move to split left [P]",
    },
    ["<C-j>"] = {
      nvim_tmux_navigation.NvimTmuxNavigateDown,
      desc = "Move to split below [P]",
    },
    ["<C-k>"] = {
      nvim_tmux_navigation.NvimTmuxNavigateUp,
      desc = "Move to split below [P]",
    },
    ["<C-l>"] = {
      nvim_tmux_navigation.NvimTmuxNavigateRight,
      desc = "Move to split right [P]",
    },
    ["<C-\\>"] = {
      nvim_tmux_navigation.NvimTmuxNavigateLastActive,
      desc = "Move to last active split [P]",
    },
    ["<C-Space>"] = {
      nvim_tmux_navigation.NvimTmuxNavigateNext,
      desc = "Move to next split [P]",
    },
  },
  i = {
    ["<C-k>"] = {
      vim.lsp.buf.signature_help,
      desc = "Signature help",
    },
  },
}
