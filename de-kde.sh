#!/bin/bash
# Actualizar el sistema
sudo apt update && sudo apt upgrade -y

# Instalar XFCE y LightDM
sudo apt install xfce4 xfce4-goodies zsh libreoffice zenity git curl wget gdebi lightdm chromium-browser firefox feathernotes geany synaptic audacious parole xarchiver -y
# Validar que una aplicación se proporciona como argumento
if [ -z "$1" ]; then
  zenity --error --text="No se especificó ninguna aplicación para ejecutar." --title="Error"
  exit 1
fi
# Configuración de Zsh
cd $HOME
if [ -f ".zshrc" ]; then
    mv .zshrc .zshrc.backup
fi

if [ -f ".zsh_history" ]; then
    mv .zsh_history .zsh_history.backup
fi

# Descargar y configurar Zsh
wget https://github.com/atamshkai/Termux-Zsh/raw/main/zsh.tar.xz
tar -xvJf zsh.tar.xz
rm zsh.tar.xz

wget https://github.com/atamshkai/Termux-Desktop-2/raw/main/.zshrc -O ~/.zshrc
wget https://github.com/atamshkai/Termux-Desktop-2/raw/main/.zsh_history -O ~/.zsh_history

chsh -s $(which zsh)

# Crear scripts para alternar configuraciones (opcional)
if [ -d "$HOME/.config" ]; then
    mv ~/.config ~/.config.default
fi

echo "mv ~/.config ~/.config.windows
mv ~/.config.default ~/.config
mv ~/.zshrc ~/.zshrc.windows
mv ~/.zshrc.default ~/.zshrc" | sudo tee /usr/local/bin/windows2default
chmod +x /usr/local/bin/windows2default

echo "mv ~/.config ~/.config.default
mv ~/.config.windows ~/.config
mv ~/.zshrc ~/.zshrc.default
mv ~/.zshrc.windows ~/.zshrc" | sudo tee /usr/local/bin/default2windows
chmod +x /usr/local/bin/default2windows

# Ejecutar la aplicación con la variable DISPLAY configurada
env DISPLAY=:0 "$@" &> /dev/null &
EOF

# Hacer el script ejecutable
sudo chmod +x /usr/local/bin/run-app

# Crear un lanzador de escritorio para LibreOffice
cat <<'EOF' > ~/Desktop/libreoffice.desktop
[Desktop Entry]
Version=1.0
Type=Application
Name=LibreOffice
Comment=Suite ofimática
Exec=libreoffice
Icon=libreoffice-startcenter
Categories=Office;
Terminal=false
StartupNotify=true
EOF

# Hacer que el lanzador sea ejecutable
chmod +x ~/Desktop/libreoffice.desktop

# Crear un script para instalar aplicaciones adicionales desde un repositorio personalizado
cat <<'EOF' > /usr/local/bin/app-installer
#!/bin/bash

REPO_URL="https://github.com/phoenixbyrd/App-Installer.git"
INSTALLER_DIR="$HOME/.App-Installer"

# Clonar o actualizar el repositorio
if [ -d "$INSTALLER_DIR" ]; then
  cd "$INSTALLER_DIR" && git pull
else
  git clone "$REPO_URL" "$INSTALLER_DIR"
fi

# Ejecutar el instalador
bash "$INSTALLER_DIR/app-installer"
EOF

# Hacer el script ejecutable
sudo chmod +x /usr/local/bin/app-installer

# Crear un lanzador de escritorio para el instalador de aplicaciones
cat <<'EOF' > ~/Desktop/app-installer.desktop
[Desktop Entry]
Version=1.0
Type=Application
Name=App Installer
Comment=Instala aplicaciones adicionales
Exec=/usr/local/bin/app-installer
Icon=package-install
Categories=System;
Terminal=false
StartupNotify=true
EOF

# Hacer que el lanzador sea ejecutable
chmod +x ~/Desktop/app-installer.desktop

# Mensaje de finalización
zenity --info --text="El entorno se ha configurado correctamente en Ubuntu. Los accesos directos están disponibles en el escritorio." --title="Instalación Completa"

# Configurar LightDM como gestor de inicio predeterminado
sudo systemctl set-default graphical.target
sudo dpkg-reconfigure lightdm

# Agregar la ejecución de XFCE al inicio
echo "startxfce4 &" >> ~/.bashrc

# Limpiar archivos innecesarios
sudo apt autoremove -y
sudo apt clean
rm -rf $HOME/zsh.tar.xz
# Mensaje final
clear
echo ""
echo "XFCE instalado y configurado."
echo "Reinicia el sistema para aplicar los cambios."
echo ""
startxfce4 &
