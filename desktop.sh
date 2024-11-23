#!/bin/bash

# Actualizar repositorios e instalar dependencias necesarias
sudo apt update -y && sudo apt upgrade -y
sudo apt install -y wget zsh pulseaudio xfce4 xfce4-goodies feathernotes \
                    xfce4-terminal xfce4-appmenu-plugin geany netsurf synaptic

# Configuración de Zsh
mv ~/.zshrc ~/.zshrc.backup 2>/dev/null
wget https://github.com/atamshkai/Termux-Zsh/raw/main/zsh.tar.xz
tar -xvJf zsh.tar.xz
rm -rf zsh.tar.xz
wget https://github.com/atamshkai/Termux-Desktop-2/raw/main/.zshrc
wget https://github.com/atamshkai/Termux-Desktop-2/raw/main/.zsh_history
chsh -s $(which zsh)

# Configuración de escritorios "Windows a Mac" y "Mac a Windows"
mv ~/.config ~/.config.backup 2>/dev/null
mkdir -p ~/scripts
cat <<EOF >~/scripts/win2mac.sh
#!/bin/bash
mv ~/.config ~/.config.win
mv ~/.config.backup ~/.config
mv ~/.zshrc ~/.zshrc.win
mv ~/.zshrc.backup ~/.zshrc
EOF

cat <<EOF >~/scripts/mac2win.sh
#!/bin/bash
mv ~/.config ~/.config.backup
mv ~/.config.win ~/.config
mv ~/.zshrc ~/.zshrc.backup
mv ~/.zshrc.win ~/.zshrc
EOF

chmod +x ~/scripts/win2mac.sh ~/scripts/mac2win.sh

# Descargar y configurar tema estilo Windows
wget https://github.com/atamshkai/Termux-Desktop-2/releases/download/Windows-11-Style-Termux-X11-Desktop/win.tar.xz
tar -xvJf win.tar.xz
rm -rf win.tar.xz

# Scripts para iniciar y detener xfce4 con estilo
cat <<EOF >~/scripts/start-xfce4.sh
#!/bin/bash
startxfce4 &
EOF

cat <<EOF >~/scripts/stop-xfce4.sh
#!/bin/bash
pkill xfce4-session
EOF

chmod +x ~/scripts/start-xfce4.sh ~/scripts/stop-xfce4.sh

# Mensaje final
echo "Instalación completada. Por favor, reinicia tu sesión para aplicar los cambios."
