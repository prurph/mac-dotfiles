# From https://github.com/jannis-baum/fzf-dotfiles/blob/main/options.zsh

# ~~~ Default fzf options
# TODO: consolidate this with the pretty print functions in fzf.zsh
# for a consistent appearance of the header hint text.
export FZF_DEFAULT_OPTS=$FZF_DEFAULT_OPTS'
  --color=fg:8,bg:-1,gutter:-1,border:8,preview-border:8,hl:4
  --color=fg+:-1,bg+:-1,hl+:4
  --color=info:#eacb8a,prompt:#bf6069,pointer:#b48dac
  --color=marker:#a3be8b,spinner:#b48dac
  --bind=ctrl-e:preview-down,ctrl-y:preview-up
  --bind=ctrl-f:preview-page-down,ctrl-b:preview-page-up
  --bind=ctrl-d:preview-half-page-down,ctrl-u:preview-half-page-up
  --bind=alt-j:preview-half-page-down,alt-k:preview-half-page-up
  --bind=alt-h:preview-bottom,alt-l:preview-top
  --marker=" "
  --pointer="⏺"
  --prompt="󰍉 "'
export FZF_CTRL_R_OPTS=$'
  --preview "echo {}"
  --preview-window down:3:hidden:wrap,border-top
  --bind "?:toggle-preview"
  --layout=reverse
  --bind "ctrl-y:execute-silent(echo -n {2..} | pbcopy)+abort"
  --border=none
  --no-separator
  --header "\x1b[38;5;0m\x1b[48;5;0m\x1b[32m 󰦂 \'exact ^prefix suffix$ !inverse \x1b[31m  [?]preview [^y]yank \x1b[38;5;0m\x1b[49m"'

function __opt_or_fallback() {
    # if option is set, make sure it's exported for vim
    # if not, set it to $2
    eval "(( \${+$1} )) && export $1=\"\$$1\" || export $1=\"$2\""
}

# ~~~ Keybindings
# explanation        name                default setting

# for Zsh, Vim & fzf
# - opens the finder in Zsh and Vim
# - opens the selection in a new split in Vim (automatic hsplit/vsplit)
# - writes the current fzf selection to the buffer in Zsh (if the commandline
#   buffer is not empty, you can also simply press `return` to write the pick to
#   the buffer)
__opt_or_fallback    FZFDF_ACT_1         ctrl-t

# for fzf
# - relaunches the finder from the selection's directory in Zsh
# - opens the selected file in a new tab in Vim
__opt_or_fallback    FZFDF_ACT_2         alt-enter

# for fzf
# - prompts to run a command on the selection in Vim, `{}` will be replaced by
#   the selection
__opt_or_fallback    FZFDF_ACT_3         ctrl-b

# for fzf
# - prompts to create a new file in the selection's directory
# - in Vim you can append `v[sp[lit]]` or `s[p[lit]]` to the file name to open
#   the new file in the respective split
__opt_or_fallback    FZFDF_ACT_NEW       ctrl-n

# for fzf
# - reloads the finder without ignoring files such as those that are gitignored
#   (which is the default behavior)
__opt_or_fallback    FZFDF_ACT_RELOAD    ctrl-r

# ~~~ Other
# explanation        name                default setting

# command that is used to list directory contents in the preview window
__opt_or_fallback    FZFDF_LS            "ls -la {}"
__opt_or_fallback    FZFDF_TXT           "bat --style=numbers,changes,header --color=always {}"

if [[ -n "$KITTY_PID" ]]; then
    __opt_or_fallback    FZFDF_IMG       'kitty icat --clear --transfer-mode=memory --stdin=no --place=\${FZF_PREVIEW_COLUMNS}x\${FZF_PREVIEW_LINES}@0x0 {}' 
    __opt_or_fallback    FZFDF_ALL       "printf '\x1b_Ga=d,d=A\x1b\\'" 
else
    __opt_or_fallback    FZFDF_IMG       "echo image: {}"
    __opt_or_fallback    FZFDF_ALL       ""
fi

unset -f __opt_or_fallback
