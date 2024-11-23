#!/bin/bash

# Actualizar el sistema
echo "Actualizando el sistema..."
sudo apt update && sudo apt upgrade -y

# Instalar XFCE y LightDM junto con herramientas necesarias
echo "Instalando XFCE, LightDM y aplicaciones necesarias..."
sudo apt install -y xfce4 xfce4-goodies lightdm zsh libreoffice zenity git curl wget gdebi \
  chromium-browser firefox-esr feathernotes geany synaptic audacious parole xarchiver

# Validar si se proporcionó una aplicación como argumento
if [ -z "$1" ]; then
  zenity --error --text="No se especificó ninguna aplicación para ejecutar." --title="Error"
  exit 1
fi

# Configuración de Zsh
echo "Configurando Zsh..."
cd $HOME
[ -f ".zshrc" ] && mv .zshrc .zshrc.backup
[ -f ".zsh_history" ] && mv .zsh_history .zsh_history.backup

# Descargar y configurar Zsh
wget -q https://github.com/atamshkai/Termux-Zsh/raw/main/zsh.tar.xz
tar -xvJf zsh.tar.xz
rm zsh.tar.xz

wget -q https://github.com/atamshkai/Termux-Desktop-2/raw/main/.zshrc -O ~/.zshrc
wget -q https://github.com/atamshkai/Termux-Desktop-2/raw/main/.zsh_history -O ~/.zsh_history

chsh -s $(which zsh)

# Ejecutar la aplicación con la variable DISPLAY configurada
env DISPLAY=:0 "$@" &> /dev/null &

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
chmod +x /usr/local/bin/app-installer

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
chmod +x ~/Desktop/app-installer.desktop

# Configurar LightDM como gestor de inicio predeterminado
echo "Configurando LightDM como gestor de inicio..."
sudo systemctl set-default graphical.target
sudo dpkg-reconfigure lightdm

# Agregar la ejecución de XFCE al inicio
echo "startxfce4 &" >> ~/.bashrc

# Limpiar archivos innecesarios
echo "Limpiando archivos y paquetes innecesarios..."
sudo apt autoremove -y
sudo apt clean
rm -rf $HOME/zsh.tar.xz

# Mensaje final
clear
echo ""
echo "XFCE instalado y configurado correctamente."
echo "Reinicia el sistema para aplicar los cambios."
echo ""

# Iniciar XFCE inmediatamente si está en un entorno compatible
startxfce4 &
