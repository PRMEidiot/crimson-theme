#!/usr/bin/env bash
# Crimson theme installer for Linux Mint Cinnamon
set -e
DIR="$(cd "$(dirname "$0")" && pwd)"
echo "==> Backing up current settings to ~/.crimson-backup.txt"
{ for k in "org.cinnamon.desktop.interface gtk-theme" "org.cinnamon.desktop.interface icon-theme" "org.cinnamon.desktop.wm.preferences theme" "org.cinnamon.theme name" "org.cinnamon.desktop.background picture-uri"; do echo "$k $(gsettings get $k)"; done; } > ~/.crimson-backup.txt

echo "==> Installing dependencies (Mint-Y and Papirus)"
if ! [ -d /usr/share/themes/Mint-Y-Dark-Red ] || ! [ -d /usr/share/icons/Papirus ]; then
  sudo apt install -y mint-themes papirus-icon-theme
fi

echo "==> Building Crimson GTK/Cinnamon theme"
mkdir -p ~/.themes; rm -rf ~/.themes/Crimson
cp -r /usr/share/themes/Mint-Y-Dark-Red ~/.themes/Crimson
sed -i 's/Mint-Y-Dark-Red/Crimson/g' ~/.themes/Crimson/index.theme
for d in gtk-3.0 gtk-4.0; do for f in gtk.css gtk-dark.css; do
  [ -f ~/.themes/Crimson/$d/$f ] && cat "$DIR/gtk/crimson.css" >> ~/.themes/Crimson/$d/$f
done; done
cat "$DIR/gtk/nemo-translucent.css" >> ~/.themes/Crimson/gtk-3.0/gtk.css
cat "$DIR/cinnamon/crimson.css" >> ~/.themes/Crimson/cinnamon/cinnamon.css

echo "==> Building Papirus-Crimson icons (this takes a few seconds)"
python3 "$DIR/scripts/recolor-icons.py"
gtk-update-icon-cache -f ~/.icons/Papirus-Crimson >/dev/null 2>&1 || true

echo "==> Applying theme"
gsettings set org.cinnamon.desktop.interface gtk-theme Crimson
gsettings set org.cinnamon.desktop.wm.preferences theme Crimson
gsettings set org.cinnamon.theme name Crimson
gsettings set org.cinnamon.desktop.interface icon-theme Papirus-Crimson
gsettings set org.cinnamon panels-height "['1:45']"
gsettings set org.cinnamon panel-zone-icon-sizes '[{"panelId": 1, "left": 0, "center": 0, "right": 24}]'
if [ -f "$DIR/wallpaper.jpg" ]; then
  mkdir -p ~/Imagens; cp "$DIR/wallpaper.jpg" ~/Imagens/crimson-wallpaper.jpg
  gsettings set org.cinnamon.desktop.background picture-uri "file://$HOME/Imagens/crimson-wallpaper.jpg"
  gsettings set org.cinnamon.desktop.background picture-options zoom
fi

echo "==> Terminal colors and 25% transparency"
P=$(gsettings get org.gnome.Terminal.ProfilesList default | tr -d \')
S="org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$P/"
gsettings set $S use-theme-colors false
gsettings set $S background-color '#0B0B0D'
gsettings set $S foreground-color '#E8E2E3'
gsettings set $S highlight-colors-set true
gsettings set $S highlight-background-color '#64101F'
gsettings set $S highlight-foreground-color '#E8E2E3'
gsettings set $S cursor-colors-set true
gsettings set $S cursor-background-color '#B51F3B'
gsettings set $S palette "['#0B0B0D','#B51F3B','#8F9A8A','#C9A26B','#64101F','#B51F3B','#9C6B73','#E8E2E3','#3A2A2D','#D93A57','#A8B5A2','#E0BC85','#8A1C30','#D93A57','#C48A93','#FFFFFF']"
gsettings set $S use-transparent-background true
gsettings set $S use-theme-transparency false
gsettings set $S background-transparency-percent 25

echo "==> Bash prompt"
sed -i '/# CRIMSON PROMPT/,/# END CRIMSON/d' ~/.bashrc
cat >> ~/.bashrc <<'RC'
# CRIMSON PROMPT
PS1='\[\e[38;2;181;31;59m\]\u\[\e[38;2;100;16;31m\]@\h \[\e[38;2;232;226;227m\]\w\n\[\e[38;2;181;31;59m\]❯\[\e[0m\] '
# END CRIMSON
RC

PRISM=~/.var/app/org.prismlauncher.PrismLauncher/data/PrismLauncher
if [ -d "$PRISM" ]; then
  echo "==> Prism Launcher theme"
  mkdir -p "$PRISM/themes/Crimson"; cp "$DIR"/prism/* "$PRISM/themes/Crimson/"
  [ -f "$PRISM/prismlauncher.cfg" ] && sed -i 's/^ApplicationTheme=.*/ApplicationTheme=Crimson/; s/^IconTheme=.*/IconTheme=flat_white/' "$PRISM/prismlauncher.cfg"
fi
echo "Done! Press Ctrl+Alt+Esc to reload Cinnamon if something didn't update."
