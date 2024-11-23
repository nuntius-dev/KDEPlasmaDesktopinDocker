#!/bin/bash
# Actualizar el sistema
sudo apt update && sudo apt upgrade -y

# Instalar XFCE y LightDM
sudo apt install xfce4 xfce4-goodies libreoffice zenity git curl wget -y
sudo apt install lightdm -y
# Validar que una aplicación se proporciona como argumento
if [ -z "$1" ]; then
  zenity --error --text="No se especificó ninguna aplicación para ejecutar." --title="Error"
  exit 1
fi

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

# Mensaje final
clear
echo ""
echo "XFCE instalado y configurado."
echo "Reinicia el sistema para aplicar los cambios."
echo ""
startxfce4 &
