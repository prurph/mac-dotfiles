rm -rf ~/.config/sketchybar
mkdir -p ~/.config/sketchybar/{items,plugins}

ln -sf ~/Dotfiles/sketchybar/sketchybarrc ~/.config/sketchybar/sketchybarrc
ln -sf ~/Dotfiles/sketchybar/items/* ~/.config/sketchybar/items
ln -sf ~/Dotfiles/sketchybar/plugins/* ~/.config/sketchybar/plugins
