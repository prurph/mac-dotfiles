return {
  colorscheme = "catppuccin",
  -- TODO: beautify statusline
  heirline = {
    attributes = {
      git_branch = { bold = false },
      git_diff = { bold = false },
    },
    icon_highlights = {
      breadcrumbs = true,
    },
    separators = {
      breadcrumbs = " ❱ ",
    },
  },
}
