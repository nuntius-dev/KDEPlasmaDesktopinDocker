# usar una imagen base oficial de ubuntu
FROM ubuntu:22.04

# establecer variables de entorno necesarias
ENV DEBIAN_FRONTEND=noninteractive \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8 \
    DISPLAY=:1 \
    VNC_PORT=5901 \
    NOVNC_PORT=8080 \
    USER=nuntius

# actualizar e instalar dependencias necesarias (añadido dbus-x11)
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y \
    locales \
    kde-plasma-desktop \
    tigervnc-standalone-server tigervnc-common \
    novnc websockify \
    xfonts-base x11-xserver-utils \
    wget curl nano sudo dbus-x11 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# generar locales
RUN locale-gen en_US.UTF-8 && \
    update-locale LANG=en_US.UTF-8

# crear el usuario 'nuntius', asignarle contraseña y agregarlo al grupo sudo
RUN useradd -m -s /bin/bash nuntius && \
    echo "nuntius:plasma123" | chpasswd && \
    echo "nuntius ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# intentar crear el usuario 'docker'
RUN useradd -m -s /bin/bash docker || true && \
    echo "docker:docker" | chpasswd && \
    usermod -aG sudo docker

# --- CAMBIO: Cambiar definitivamente al usuario 'nuntius' ---
USER nuntius
WORKDIR /home/nuntius

# Desactivar el bloqueo de pantalla automático de KDE
RUN mkdir -p /home/nuntius/.config && \
    echo -e "[Daemon]\nAutolock=false\nLockOnResume=false" > /home/nuntius/.config/kscreenlockerrc

RUN /bin/bash -c ' \
    arquitecturas=$(dpkg --print-architecture) && \
    echo "arquitectura detectada: $arquitecturas" && \
    if [[ "$arquitecturas" == "arm" || "$arquitecturas" == "aarch64" || "$arquitecturas" == "arm64" ]]; then \
        echo "arquitectura arm detectada. instalando pi-apps..." && \
        wget -qO- https://raw.githubusercontent.com/botspot/pi-apps/master/install | bash; \
    else \
        echo "arquitectura no arm detectada. saltando instalación de pi-apps."; \
    fi'

# crear directorios persistentes (ahora en el home del usuario)
VOLUME /home/nuntius/.vnc
VOLUME /home/nuntius/Desktop

# configurar tigervnc de forma no interactiva
RUN mkdir -p /home/nuntius/.vnc && \
    echo "plasma123" | vncpasswd -f > /home/nuntius/.vnc/passwd && \
    chmod 600 /home/nuntius/.vnc/passwd

# crear el script de inicio
RUN echo '#!/bin/bash\n\
set -e\n\
\n\
# limpiar locks previos\n\
rm -rf /tmp/.X1-lock /tmp/.X11-unix/X1\n\
\n\
# iniciar servidor vnc permitiendo conexiones locales\n\
vncserver $DISPLAY -geometry 1280x720 -depth 24 -localhost no\n\
\n\
# exportar dbus para que KDE funcione correctamente\n\
export $(dbus-launch)\n\
\n\
# iniciar plasma desktop\n\
startplasma-x11 &\n\
\n\
# iniciar novnc (sin flag --cert para usar http simple)\n\
websockify --web=/usr/share/novnc/ $NOVNC_PORT localhost:$VNC_PORT &\n\
echo "novnc iniciado en http://localhost:$NOVNC_PORT/vnc.html"\n\
\n\
# mantener el contenedor activo\n\
tail -f /dev/null' > /home/nuntius/start.sh && \
    chmod +x /home/nuntius/start.sh

# puertos expuestos
EXPOSE 5901 8080

# comando para iniciar el contenedor
CMD ["/bin/bash", "/home/nuntius/start.sh"]
