#!/bin/bash
# Este Script es el mismo del autor James A. Chambers a diferencia que fue traducido al español (This Script is the same as that of the author James A. Chambers, unlike that it was translated into Spanish.)
# Script de instalación del servidor de Minecraft - James A. Chambers - https://jamesachambers.com
#
# Instrucciones: https://jamesachambers.com/minecraft-bedrock-edition-ubuntu-dedicated-server-guide/
# Para ejecutar el script de configuración, use:
# wget https://raw.githubusercontent.com/TheRemote/MinecraftBedrockServer/master/SetupMinecraft.sh
# chmod +x SetupMinecraft.sh
# ./SetupMinecraft.sh
#
# Repositorio de GitHub: https://github.com/TheRemote/MinecraftBedrockServer

echo "Script de instalación de Minecraft Bedrock Server por James Chambers - 24 de julio de 2019"
echo "La última versión siempre en https://github.com/TheRemote/MinecraftBedrockServer"
echo "¡No olvide configurar el reenvío de puertos en su enrutador! El puerto predeterminado es 19132"

# Función para leer la entrada del usuario con un mensaje
function read_with_prompt {
  variable_name="$1"
  prompt="$2"
  default="${3-}"
  unset $variable_name
  while [[ ! -n ${!variable_name} ]]; do
    read -p "$prompt: " $variable_name < /dev/tty
    if [ ! -n "`which xargs`" ]; then
      declare -g $variable_name=$(echo "${!variable_name}" | xargs)
    fi
    declare -g $variable_name=$(echo "${!variable_name}" | head -n1 | awk '{print $1;}')
    if [[ -z ${!variable_name} ]] && [[ -n "$default" ]] ; then
      declare -g $variable_name=$default
    fi
    echo -n "$prompt : ${!variable_name} -- aceptar? (y/n)"
    read answer < /dev/tty
    if [ "$answer" == "${answer#[Yy]}" ]; then
      unset $variable_name
    else
      echo "$prompt: ${!variable_name}"
    fi
  done
}

# Instale las dependencias necesarias para ejecutar el servidor de Minecraft en segundo plano
echo "Instalando screen, unzip, sudo, net-tools, wget.."
if [ ! -n "`which sudo`" ]; then
  apt-get update && apt-get install sudo -y
fi
sudo apt-get update
sudo apt-get install screen unzip wget -y
sudo apt-get install net-tools -y
sudo apt-get install libcurl4 -y
sudo apt-get install openssl -y

# Verifique si el directorio principal del servidor de Minecraft ya existe
cd ~
if [ ! -d "minecraftbe" ]; then
  mkdir minecraftbe
  cd minecraftbe
else
  cd minecraftbe
  if [ -f "bedrock_server" ]; then
    echo "Migración del antiguo servidor Bedrock a minecraftpe/old"
    cd ~
    mv minecraftbe old
    mkdir minecraftbe
    mv old minecraftbe/old
    cd minecraftbe
    echo "Migración completa a minecraftbe/old"
  fi
fi

# Configuración del nombre del servidor
echo "Ingrese un nombre corto para el servidor nuevo o existente..."
echo "Se utilizará como nombre de la carpeta y el nombre del servicio..."

read_with_prompt ServerName "Nombre de Servidor"

echo "Introduzca el puerto IPV4 del servidor (predeterminado 19132): "
read_with_prompt PortIPV4 "Puerto IPV4 del servidor" 19132

echo "Introduzca el puerto IPV6 del servidor (predeterminado 19133): "
read_with_prompt PortIPV6 "Puerto IPV6 del servidor" 19133

if [ -d "$ServerName" ]; then
  echo "¡El directorio minecraftbe/$ServerName ya existe!  Actualizando scripts y configurando el servicio..."

  # Obtener la ruta del directorio de inicio y el nombre de usuario
  DirName=$(readlink -e ~)
  UserName=$(whoami)
  cd ~
  cd minecraftbe
  cd $ServerName
  echo "El directorio del servidor es: $DirName/minecraftbe/$ServerName"

  # Eliminar scripts existentes
  rm start.sh stop.sh restart.sh cloud.sh

  # Descarga start.sh desde el repositorio
  echo "Tomando start.sh del repositorio..."
  wget -O start.sh https://raw.githubusercontent.com/digiraldo/Minecraft-BE-Server/main/start.sh
  chmod +x start.sh
  sed -i "s:dirname:$DirName:g" start.sh
  sed -i "s:servername:$ServerName:g" start.sh
  sed -i "s:cloudname:$CloudName:g" start.sh

  # Descargar stop.sh desde el repositorio
  echo "Tomando stop.sh del repositorio..."
  wget -O stop.sh https://raw.githubusercontent.com/digiraldo/Minecraft-BE-Server/main/stop.sh
  chmod +x stop.sh
  sed -i "s:dirname:$DirName:g" stop.sh
  sed -i "s:servername:$ServerName:g" stop.sh
  sed -i "s:cloudname:$CloudName:g" stop.sh

  # Descargar restart.sh desde el repositorio
  echo "Tomando restart.sh del repositorio..."
  wget -O restart.sh https://raw.githubusercontent.com/digiraldo/Minecraft-BE-Server/main/restart.sh
  chmod +x restart.sh
  sed -i "s:dirname:$DirName:g" restart.sh
  sed -i "s:servername:$ServerName:g" restart.sh
  sed -i "s:cloudname:$CloudName:g" restarr.sh
  
  # Descargar cloud.sh desde el repositorio
  echo "Tomando restart.sh del repositorio..."
  wget -O cloud.sh https://raw.githubusercontent.com/digiraldo/Minecraft-BE-Server/main/cloud.sh
  chmod +x cloud.sh
  sed -i "s:dirname:$DirName:g" cloud.sh
  sed -i "s:servername:$ServerName:g" cloud.sh
  sed -i "s:cloudname:$CloudName:g" cloud.sh

  # Actualizar el servicio del servidor de Minecraft
  echo "Configurando el servicio $ServerName..."
  sudo wget -O /etc/systemd/system/$ServerName.service https://raw.githubusercontent.com/TheRemote/MinecraftBedrockServer/master/minecraftbe.service
  sudo chmod +x /etc/systemd/system/$ServerName.service
  sudo sed -i "s/replace/$UserName/g" /etc/systemd/system/$ServerName.service
  sudo sed -i "s:dirname:$DirName:g" /etc/systemd/system/$ServerName.service
  sudo sed -i "s:servername:$ServerName:g" /etc/systemd/system/$ServerName.service
  sed -i "/server-port=/c\server-port=$PortIPV4" server.properties
  sed -i "/server-portv6=/c\server-portv6=$PortIPV6" server.properties
  sudo systemctl daemon-reload
  echo -n "¿Iniciar el servidor de Minecraft automáticamente? (y/n)"
  read answer < /dev/tty
  if [ "$answer" != "${answer#[Yy]}" ]; then
    sudo systemctl enable $ServerName.service

    # Reinicio automático configurado a las 4 am
    echo -n "¿Reiniciar automáticamente y hacer una copia de seguridad del servidor a las 4 am todos los días? (y/n)"
    read answer < /dev/tty
    if [ "$answer" != "${answer#[Yy]}" ]; then
      croncmd="$DirName/minecraftbe/$ServerName/restart.sh"
      cronjob="0 4 * * * $croncmd"
      ( crontab -l | grep -v -F "$croncmd" ; echo "$cronjob" ) | crontab -
      echo "Reinicio diario programado. Para cambiar la hora o eliminar el reinicio automático, escriba crontab -e"
    fi
  fi

  # Configuración completada
  echo "La configuración está completa. Iniciando el servidor Minecraft $ServerName..."
  sudo systemctl start $ServerName.service

  # Duerme durante 4 segundos para que el servidor tenga tiempo de comenzar
  sleep 4s

  screen -r $ServerName

  exit 0
fi

# Crear directorio de servidor
echo "Creando directorio del servidor de Minecraft (~/minecraftbe/$ServerName)..."
cd ~
cd minecraftbe
mkdir $ServerName
cd $ServerName
mkdir downloads
mkdir backups
mkdir logs

# Verifique la arquitectura de la CPU para ver si necesitamos hacer algo especial para la plataforma en la que se ejecuta el servidor
echo "Obteniendo la arquitectura de la CPU del sistema..."
CPUArch=$(uname -m)
echo "Arquitectura del sistema: $CPUArch"
if [[ "$CPUArch" == *"aarch"* || "$CPUArch" == *"arm"* ]]; then
  # Arquitectura ARM detectada - descargar QEMU y bibliotecas de dependencia
  echo "Plataforma ARM detectada - instalando dependencias..."
  # Compruebe si la última versión de QEMU disponible es al menos 3.0 o superior
  QEMUVer=$(apt-cache show qemu-user-static | grep Version | awk 'NR==1{ print $2 }' | cut -c3-3)
  if [[ "$QEMUVer" -lt "3" ]]; then
    echo "La versión de QEMU disponible no es lo suficientemente alta para emular x86_64. Descargando alternativa..."
    if [[ "$CPUArch" == *"armv7"* || "$CPUArch" == *"armhf"* ]]; then
      wget http://ftp.us.debian.org/debian/pool/main/q/qemu/qemu-user-static_3.1+dfsg-8_armhf.deb
      wget http://ftp.us.debian.org/debian/pool/main/b/binfmt-support/binfmt-support_2.2.0-2_armhf.deb
      sudo dpkg --install binfmt*.deb
      sudo dpkg --install qemu-user*.deb
    elif [[ "$CPUArch" == *"aarch64"* || "$CPUArch" == *"arm64"* ]]; then
      wget http://ftp.us.debian.org/debian/pool/main/q/qemu/qemu-user-static_3.1+dfsg-8_arm64.deb
      wget http://ftp.us.debian.org/debian/pool/main/b/binfmt-support/binfmt-support_2.2.0-2_arm64.deb
      sudo dpkg --install binfmt*.deb
      sudo dpkg --install qemu-user*.deb
    fi
  else
    sudo apt-get install qemu-user-static binfmt-support -y
  fi

  if [ -n "`which qemu-x86_64-static`" ]; then
    echo "QEMU-x86_64-static installed successfully"
  else
    echo "QEMU-x86_64-static did not install successfully -- please check the above output to see what went wrong."
    exit 1
  fi
  
  # Recuperar depende.zip del repositorio de GitHub
  wget -O depends.zip https://raw.githubusercontent.com/TheRemote/MinecraftBedrockServer/master/depends.zip
  unzip depends.zip
  sudo mkdir /lib64
  # Cree un enlace flexible ld-linux-x86-64.so.2 mapeado a ld-2.28.so
  sudo ln -s ~/minecraftbe/$ServerName/ld-2.28.so /lib64/ld-linux-x86-64.so.2
fi

# Recupere la última versión del servidor dedicado Minecraft Bedrock
echo "Buscando la última versión del servidor Minecraft Bedrock..."
wget -O downloads/version.html https://minecraft.net/en-us/download/server/bedrock/
DownloadURL=$(grep -o 'https://minecraft.azureedge.net/bin-linux/[^"]*' downloads/version.html)
DownloadFile=$(echo "$DownloadURL" | sed 's#.*/##')
echo "$DownloadURL"
echo "$DownloadFile"

# Descargue la última versión del servidor dedicado Minecraft Bedrock
echo "Descargando la última versión del servidor Minecraft Bedrock..."
UserName=$(whoami)
DirName=$(readlink -e ~)
wget -O "downloads/$DownloadFile" "$DownloadURL"
unzip -o "downloads/$DownloadFile"

# Descarga start.sh desde el repositorio
echo "Tomando start.sh del repositorio..."
wget -O start.sh https://raw.githubusercontent.com/digiraldo/Minecraft-BE-Server/main/start.sh
chmod +x start.sh
sed -i "s:dirname:$DirName:g" start.sh
sed -i "s:servername:$ServerName:g" start.sh
sed -i "s:cloudname:$CloudName:g" start.sh

# Descargar stop.sh desde el repositorio
echo "Tomando stop.sh del repositorio..."
wget -O stop.sh https://raw.githubusercontent.com/digiraldo/Minecraft-BE-Server/main/stop.sh
chmod +x stop.sh
sed -i "s:dirname:$DirName:g" stop.sh
sed -i "s:servername:$ServerName:g" stop.sh
sed -i "s:cloudname:$CloudName:g" stop.sh

# Descargar restart.sh desde el repositorio
echo "Tomando restart.sh del repositorio..."
wget -O restart.sh https://raw.githubusercontent.com/digiraldo/Minecraft-BE-Server/main/restart.sh
chmod +x restart.sh
sed -i "s:dirname:$DirName:g" restart.sh
sed -i "s:servername:$ServerName:g" restart.sh
sed -i "s:cloudname:$CloudName:g" restart.sh

# Descargar cloud.sh desde el repositorio
echo "Tomando restart.sh del repositorio..."
wget -O cloud.sh https://raw.githubusercontent.com/digiraldo/Minecraft-BE-Server/main/cloud.sh
chmod +x cloud.sh
sed -i "s:dirname:$DirName:g" cloud.sh
sed -i "s:servername:$ServerName:g" cloud.sh
sed -i "s:cloudname:$CloudName:g" cloud.sh

# Configuración del servicio
echo "Configurando el servicio Minecraft $ServerName..."
sudo wget -O /etc/systemd/system/$ServerName.service https://raw.githubusercontent.com/TheRemote/MinecraftBedrockServer/master/minecraftbe.service
sudo chmod +x /etc/systemd/system/$ServerName.service
sudo sed -i "s/replace/$UserName/g" /etc/systemd/system/$ServerName.service
sudo sed -i "s:dirname:$DirName:g" /etc/systemd/system/$ServerName.service
sudo sed -i "s:servername:$ServerName:g" /etc/systemd/system/$ServerName.service
sed -i "/server-port=/c\server-port=$PortIPV4" server.properties
sed -i "/server-portv6=/c\server-portv6=$PortIPV6" server.properties
sudo systemctl daemon-reload

echo -n "¿Iniciar el servidor de Minecraft automáticamente? (y/n)"
read answer < /dev/tty
if [ "$answer" != "${answer#[Yy]}" ]; then
  sudo systemctl enable $ServerName.service

  # Reinicio automático a las 4 am
  TimeZone=$(cat /etc/timezone)
  CurrentTime=$(date)
  echo "Su zona horaria está configurada actualmente en $TimeZone.  Hora actual del sistema: $CurrentTime"
  echo "Puede ajustar / eliminar el tiempo de reinicio seleccionado más tarde escribiendo crontab -e o ejecutando SetupMinecraft.sh nuevamente."
  echo -n "¿Reiniciar automáticamente y hacer una copia de seguridad del servidor a las 4 am todos los días? (y/n)"
  read answer < /dev/tty
  if [ "$answer" != "${answer#[Yy]}" ]; then
    croncmd="$DirName/minecraftbe/$ServerName/restart.sh"
    cronjob="0 4 * * * $croncmd"
    ( crontab -l | grep -v -F "$croncmd" ; echo "$cronjob" ) | crontab -
    echo "Reinicio diario programado. Para cambiar la hora o eliminar el reinicio automático, escriba crontab -e"
  fi
fi

# ¡Terminado!
echo "La configuración está completa. Iniciando el servidor de Minecraft..."
sudo systemctl start $ServerName.service

# Espere hasta 20 segundos para que se inicie el servidor
StartChecks=0
while [ $StartChecks -lt 20 ]; do
  if screen -list | grep -q "$ServerName"; then
    break
  fi
  sleep 1;
  StartChecks=$((StartChecks+1))
done

# Forzar el cierre si el servidor aún está iniciado
if ! screen -list | grep -q "$ServerName"; then
  echo "El servidor de Minecraft no pudo iniciarse después de 20 segundos."
else
  echo "El servidor de Minecraft se ha iniciado.  Escribe -r $ServerName para ver el servidor en ejecución!"
fi

# Adjuntar a la pantalla
screen -r $ServerName
