# usar una imagen base oficial de ubuntu
FROM ubuntu:22.04

# establecer variables de entorno necesarias
ENV DEBIAN_FRONTEND=noninteractive \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8 \
    DISPLAY=:1 \
    VNC_PORT=5901 \
    NOVNC_PORT=8080

# actualizar e instalar dependencias necesarias
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y \
    locales \
    kde-plasma-desktop \
    tigervnc-standalone-server tigervnc-common \
    novnc websockify \
    xfonts-base x11-xserver-utils \
    wget curl nano sudo && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# generar locales
RUN locale-gen en_US.UTF-8 && \
    update-locale LANG=en_US.UTF-8

# crear el usuario 'nuntius' y agregarlo al grupo sudo
RUN useradd -m -s /bin/bash nuntius && \
    echo "nuntius ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# intentar crear el usuario 'docker', pero primero verificar si ya existe
RUN useradd -m -s /bin/bash docker || true

# establecer contraseña para el usuario 'docker'
RUN echo "docker:docker" | chpasswd

# agregar usuario 'docker' al grupo sudo
RUN usermod -aG sudo docker

# cambiar temporalmente al usuario 'nuntius' para ejecutar el script
USER nuntius

RUN /bin/bash -c ' \
    arquitecturas=$(dpkg --print-architecture) && \
    echo "arquitectura detectada: $arquitecturas" && \
    if [[ "$arquitecturas" == "arm" || "$arquitecturas" == "aarch64" || "$arquitecturas" == "arm64" ]]; then \
        echo "arquitectura arm detectada. instalando pi-apps..." && \
        wget -qO- https://raw.githubusercontent.com/botspot/pi-apps/master/install | bash; \
    else \
        echo "arquitectura no arm detectada. saltando instalación de pi-apps."; \
    fi'

# cambiar de nuevo al usuario 'root' (opcional)
USER root

# crear directorios persistentes para vnc y desktop
VOLUME /root/.vnc
VOLUME /root/desktop

# configurar tigervnc
RUN mkdir -p /root/.vnc && \
    echo "docker" | vncpasswd -f > /root/.vnc/passwd && \
    chmod 600 /root/.vnc/passwd

# crear el script de inicio
RUN echo '#!/bin/bash\n\
set -e\n\
\n\
# iniciar servidor vnc\n\
vncserver -kill $DISPLAY || true\n\
vncserver $DISPLAY -geometry 1280x720 -depth 24\n\
\n\
# iniciar plasma desktop\n\
startplasma-x11 &\n\
\n\
# iniciar novnc\n\
websockify --web=/usr/share/novnc/ --cert=/root/.vnc/self.pem $NOVNC_PORT localhost:$VNC_PORT &\n\
echo "novnc iniciado en http://localhost:$NOVNC_PORT/vnc.html"\n\
\n\
# mantener el contenedor activo\n\
tail -f /dev/null' > /root/start.sh && \
    chmod +x /root/start.sh

# puertos expuestos para vnc y novnc
EXPOSE 5901 8080

# comando para iniciar el contenedor
CMD ["/bin/bash", "/root/start.sh"]
