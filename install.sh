#!/bin/bash
echo "Checking requirements..."
# ydotool installed check
command -v ydotool >/dev/null 2>&1 || { echo >&2 "I require ydotool but it's not installed! Aborting."; exit 1; }

echo "Compiling code..."
# Compilation
cd src
g++ -std=c++17 -O2 -pipe -flto naga.cpp -o naga
strip naga

if [ ! -f ./naga ]; then
	echo "Error at compile! Ensure you have gcc installed Aborting"
	exit 1
fi

echo "Create config files"
# Configuration
sudo mv naga /usr/local/bin/
sudo chmod 755 /usr/local/bin/naga

cd ..
#HOME=$( getent passwd "$SUDO_USER" | cut -d: -f6 )

sudo cp nagastart.sh /usr/local/bin/
sudo chmod 755 /usr/local/bin/nagastart.sh

#This method is too problematic
#if ! grep -Fxq "bash /usr/local/bin/nagastart.sh &" "$HOME"/.profile; then
#	echo "bash /usr/local/bin/nagastart.sh &" >> "$HOME"/.profile
#fi

echo "Creating udev rule..."

echo 'KERNEL=="event[0-9]*",SUBSYSTEM=="input",GROUP="razer",MODE="640"' > /tmp/80-naga.rules

sudo mv /tmp/80-naga.rules /etc/udev/rules.d/80-naga.rules
sudo groupadd -f razer
sudo gpasswd -a "$(whoami)" razer

echo "Starting daemon..."
# Run
nohup sudo bash /usr/local/bin/nagastart.sh >/dev/null 2>&1 &

echo "Installing user configuration..."

# directorios
mkdir -p "$HOME/.naga"
mkdir -p "$HOME/.config/autostart"
mkdir -p "$HOME/.local/share/icons/hicolor/256x256/apps"

# mappings (solo si no existen)
for f in mapping_01.txt mapping_02.txt mapping_03.txt; do
    if [ ! -f "$HOME/.naga/$f" ]; then
        cp $f "$HOME/.naga/"
    fi
done

# icono
cp nagakeymapper.png "$HOME/.local/share/icons/hicolor/256x256/apps/"

# refrescar icon cache (silencioso)
gtk-update-icon-cache "$HOME/.local/share/icons/hicolor" >/dev/null 2>&1 || true

# autostart
cat > "$HOME/.config/autostart/naga.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=Naga Key Mapper
Comment=Wayland programmable mouse keypad
Exec=/usr/local/bin/naga $HOME/.naga/mapping_01.txt
Icon=nagakeymapper
Terminal=false
X-GNOME-Autostart-enabled=true
Categories=Utility;
EOF

echo "Done. Log out and back in to activate."

