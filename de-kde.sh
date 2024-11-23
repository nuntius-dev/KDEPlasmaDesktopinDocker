#!/bin/bash
# Actualizar el sistema
sudo apt update && sudo apt upgrade -y

# Instalar XFCE y LightDM
sudo apt install xfce4 xfce4-goodies -y
sudo apt install lightdm -y

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
