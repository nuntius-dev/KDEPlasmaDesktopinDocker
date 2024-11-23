#!/bin/bash

# Actualizar el sistema
echo "Actualizando el sistema..."
sudo apt update && sudo apt upgrade -y

# Instalar XFCE, LightDM y herramientas necesarias
echo "Instalando XFCE, LightDM y aplicaciones necesarias..."
sudo apt install -y xfce4 xfce4-goodies lightdm zsh nano \
  libreoffice libreoffice-l10n-es zenity git curl wget gdebi \
  chromium-browser feathernotes geany synaptic audacious parole xarchiver

# Agregar Brave Browser
echo "Instalando Brave Browser..."
sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list
sudo apt update && sudo apt install brave-browser -y

# Verificar si se proporcionó una aplicación como argumento
if [ -z "$1" ]; then
  zenity --error --text="No se especificó ninguna aplicación para ejecutar." --title="Error"
  exit 1
fi

# Instalar VSCode para ARM64
echo "Instalando VSCode para ARM64..."
curl -L https://aka.ms/linux-arm64-deb > code_arm64.deb
sudo apt install ./code_arm64.deb -y
rm -f code_arm64.deb

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

# Instalar y configurar Postman
echo "Instalando Postman..."
POSTMAN_URL="https://dl.pstmn.io/download/latest/linux"
curl -L $POSTMAN_URL -o postman-linux-x64.tar.gz
tar -xzf postman-linux-x64.tar.gz

# Mover Postman a /opt
if [ -d "/opt/Postman" ]; then
  sudo rm -rf /opt/Postman
fi
sudo mv Postman /opt/Postman
rm -f postman-linux-x64.tar.gz

# Crear enlace simbólico para Postman
if [ ! -f "/usr/bin/postman" ]; then
  sudo ln -s /opt/Postman/Postman /usr/bin/postman
fi

# Crear archivo .desktop para Postman
cat > ~/.local/share/applications/postman.desktop <<EOL
[Desktop Entry]
Encoding=UTF-8
Name=Postman
Exec=postman
Icon=/opt/Postman/app/resources/app/assets/icon.png
Terminal=false
Type=Application
Categories=Development;
EOL

# Crear lanzador para LibreOffice
echo "Creando lanzador para LibreOffice..."
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

# Crear script para instalar aplicaciones adicionales
echo "Creando script para instalador de aplicaciones adicionales..."
cat <<'EOF' > /usr/local/bin/app-installer
#!/bin/bash
REPO_URL="https://github.com/phoenixbyrd/App-Installer.git"
INSTALLER_DIR="$HOME/.App-Installer"

if [ -d "$INSTALLER_DIR" ]; then
  cd "$INSTALLER_DIR" && git pull
else
  git clone "$REPO_URL" "$INSTALLER_DIR"
fi

bash "$INSTALLER_DIR/app-installer"
EOF
chmod +x /usr/local/bin/app-installer

# Crear lanzador para el instalador de aplicaciones
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

# Agregar inicio de XFCE
echo "startxfce4 &" >> ~/.bashrc

# Limpiar archivos innecesarios
echo "Limpiando archivos temporales..."
sudo apt autoremove -y
sudo apt clean

# Mensaje final
clear
echo ""
echo "XFCE instalado y configurado correctamente."
echo "Reinicia el sistema para aplicar los cambios."
echo ""

# Iniciar XFCE inmediatamente si está en un entorno compatible
startxfce4 &
