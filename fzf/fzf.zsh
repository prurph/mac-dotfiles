# Based on https://github.com/jannis-baum/fzf-dotfiles/blob/main/fzf.zsh

# ~~~ Utility formatting functions
_pretty_print_keybinding() {
  sed -e 's/ctrl-/^/' -e 's/alt-/󰘵/' -e 's/enter/󰌑/' <<< $1
}

# Output a pretty display bar with slashes on each side. Arguments:
# $1: the text inside the bar
# $2: text color, by index
# $3: bar color, by index
# $4: bg color of left edge (resets to default if omitted)
_slash_display_bar() {
  [[ -v 4 ]] && bg="48;5;${4}m" || bg="49m"
  echo "\x1b[38;5;${3}m\x1b[38;5;${2}m\x1b[48;5;${3}m$1\x1b[38;5;${3}m\x1b[$bg"
}

_trail_slash_display_bar() {
  [[ -v 4 ]] && bg="48;5;${4}m" || bg="49m"
  echo "\x1b[38;5;${2}m\x1b[48;5;${3}m$1\x1b[38;5;${3}m\x1b[$bg"
}

# ~~~ Default fzf options
# TODO: consolidate this with the pretty print functions in fzf.zsh
# for a consistent appearance of the header hint text.
export FZF_DEFAULT_OPTS=$FZF_DEFAULT_OPTS'
  --color=fg:8,bg:-1,gutter:-1,border:8,preview-border:8,hl:4
  --color=fg+:-1,bg+:-1,hl+:4,scrollbar:3,preview-scrollbar:3
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

ctrl_r_header=$(cat <<EOF
$(_trail_slash_display_bar '  ' 0 2 0)$(_slash_display_bar "'exact ^prefix suffix$ !inverse " 2 0 1)$(_slash_display_bar '󰦂 ' 0 1 0)$(_slash_display_bar "[?]preview [^y]yank " 1 0)
EOF
)
# Desire: add newlines after header so there's a blank line between hints and content
# Problem: command substitution removes trailing lines.
# Solution: use process substitution <( ... ), which doesn't remove trailing lines,
# and read it into the variable with null IFS, which causes read to use all tokens, instead
# of stopping when it hits the newline.
IFS= read -rd '' ctrl_r_header < <( printf "$ctrl_r_header\n\n" )

export FZF_CTRL_R_OPTS="
  --preview 'echo {}'
  --preview-window down:3:hidden:wrap,border-top
  --bind '?:toggle-preview'
  --layout=reverse
  --bind 'ctrl-y:execute-silent(echo -n {2..} | pbcopy)+abort'
  --border=none
  --no-separator
  --header=\"$ctrl_r_header\""

# action_1 for finder
#   - enter           open file in editor / cds to directory
#   - action_1        write pick to buffer (also happens when buffer not empty)
#   - action_2        start finder in selected directory (/ directory of selected file)
#   - action_new      create new file (path can have new directories)
#   - action_reload   reload without ignoring anything (e.g. .git/*)

_fzf_finder() {
    [[ -z "$1" ]] && local target_dir="." || local target_dir=$1

    local act_1=$(_pretty_print_keybinding $FZFDF_ACT_1)
    local act_2=$(_pretty_print_keybinding $FZFDF_ACT_2)
    local act_n=$(_pretty_print_keybinding $FZFDF_ACT_NEW)
    local act_r=$(_pretty_print_keybinding $FZFDF_ACT_RELOAD)

    local header=$(cat <<EOF

$(_trail_slash_display_bar '  ' 0 2 0)$(_slash_display_bar "'exact ^prefix suffix$ !inverse " 2 0)
$(_trail_slash_display_bar ' 󰦂 ' 0 1 0)$(_slash_display_bar "[?]preview [󰌑]open [$act_1]paste selected [$act_2]fzf here [$act_n]new file [$act_r]show ignored " 1 0)
EOF
)
#󰦂

    local fd_opts=("--follow" "--strip-cwd-prefix" "--color=always" \
        "--hidden" "--exclude" '**/.git/')
    local out=$(fd $fd_opts --full-path $1 \
        | fzf --ansi \
            --expect=$FZFDF_ACT_1,$FZFDF_ACT_NEW,$FZFDF_ACT_2 \
            --preview="\
                $FZFDF_ALL
                if test -d {}; then \
                    $FZFDF_LS;\
                else \
                    if file --mime-type {} | grep -qF image/; then \
                        $FZFDF_IMG;\
                    else \
                        $FZFDF_TXT;\
                    fi ;\
                fi" \
            --preview-window="down,40%,nohidden" \
            --header="$header" \
            --multi \
            --bind "?:toggle-preview" \
            --bind "${FZFDF_ACT_RELOAD}:reload(fd --no-ignore $fd_opts)") \

    zle reset-prompt
    [[ -n "$FZFDF_ALL" ]] && eval "$FZFDF_ALL"

    local key=$(head -1 <<< $out)
    local pick=$(tail -n +2 <<< $out)
    [[ -z "$pick" ]] && return

    pick=${(q-)pick}
    test -d $pick \
        && local dir="$pick" \
        || local dir="${(q-)$(dirname $pick)}/"

    if [[ -n "$BUFFER" || "$key" == $FZFDF_ACT_1 ]]; then
        LBUFFER+="$pick"
    elif [[ "$key" == $FZFDF_ACT_NEW ]]; then
        LBUFFER="$EDITOR $dir"
    elif [[ "$key" == $FZFDF_ACT_2 ]]; then
        _fzf_finder "$dir" || _fzf_finder "$target"
    else
        test -d $pick \
            && BUFFER="cd $pick" \
            || BUFFER="$EDITOR $pick"
        zle accept-line; zle reset-prompt
    fi
}
zle -N _fzf_finder
bindkey $(sed 's/ctrl-/^/' <<< $FZFDF_ACT_1) _fzf_finder

# commands ---------------------------------------------------------------------

# interactive ripgrep: live search & highlighted preview
#   - enter    open selection in vim, go to selected occurance and highlight
#              search
rgi() {
    local rg_command=("rg" "--column" "--line-number" "--no-heading")
    local selection=$($rg_command "$1" | \
        fzf -d ':' --with-nth=1 +m --disabled --print-query --query "$1" \
            --bind "change:reload:$rg_command {q} || true" \
            --preview-window="right,70%,wrap,nohidden" \
            --preview "\
                bat --style=plain --color=always --line-range {2}: {1} 2> /dev/null\
                    | rg --color always --context 10 {q}\
                || bat --style=plain --color=always --line-range {2}: {1} 2> /dev/null")

    local query=$(head -n 1 <<< $selection)
    local details=$(tail -n 1 <<< $selection)

    if [[ "$details" != "$query" ]]; then
        local file=$(awk -F: '{ print $1 }' <<< $details)
        local line=$(awk -F: '{ print $2 }' <<< $details)
        local column=$(awk -F: '{ print $3 }' <<< $details)
        $EDITOR "+let @/='$query'" "+call feedkeys('/\<CR>:call cursor($line, $column)\<CR>')" "$file"
    fi
}

# dir history picker
#   - enter    go to directory

# keep history file
[[ -n "$ZDOTDIR" ]] \
    && FZFDF_DIR_HIST="$ZDOTDIR/.dir_history" \
    || FZFDF_DIR_HIST="$HOME/.zsh_dir_history"

function _fzfdf_log_dir_history() {
    echo "$(pwd; test -f $FZFDF_DIR_HIST && head -n1000 $FZFDF_DIR_HIST)" > $FZFDF_DIR_HIST
}
autoload -U add-zsh-hook
add-zsh-hook chpwd _fzfdf_log_dir_history
# coloring
_fzfdf_ls_color=$(sed -r 's/^.*di=([^:]+):.*$/\1/' <<< $LS_COLORS)
[[ -n "$_fzfdf_ls_color" ]] && _fzfdf_ls_color="\e[${_fzfdf_ls_color}m"

# actual command
function cdf() {
    test -f $FZFDF_DIR_HIST || return
    # make paths unique and delete non-existing
    local valid_paths=""
    for p in $(
        cat -n $FZFDF_DIR_HIST \
            | sort -uk2 \
            | sort -nk1 \
            | cut -f2-
    ); do
        test -d $p && valid_paths+=$p"\n"
    done
    echo $valid_paths > $FZFDF_DIR_HIST
    [[ -z "$valid_paths" ]] && return

    # pick target
    local target=$(
        printf "$_fzfdf_ls_color$(printf $valid_paths | rg --invert-match "^$(realpath .)\$")" \
        | fzf --ansi --preview-window="nohidden" \
            --preview="$FZFDF_LS")

    # go to dir
    if [[ -n "$target" ]]; then
        cd ${(q-)$(sed "s|~|$HOME|" <<<$target)}
    fi
}
