return {
  "AstroNvim/astrocommunity",
  -- ~~~ Languages
  { import = "astrocommunity.pack.astro" },
  { import = "astrocommunity.pack.lua" },
  { import = "astrocommunity.pack.typescript" },

  { import = "astrocommunity.motion.nvim-surround" },

  -- ~~~ Appearance
  { import = "astrocommunity.bars-and-lines.smartcolumn-nvim" },
  { import = "astrocommunity.colorscheme.catppuccin" },
  {
    "catppuccin",
    -- TODO: determine integrations https://github.com/catppuccin/nvim#integrations
    opts = {
      flavour = "frappe",
    },
  },
}
