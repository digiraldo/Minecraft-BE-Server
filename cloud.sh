#!/bin/bash
# Autor: Di Giraldo
# Instale las dependencias necesarias RClone y fuse para montar la nube

cd ~
echo "Instalando RClone, fuse y otras dependencias..."
sleep 4s
if [ ! -n "`which sudo`" ]; then
  apt-get update && apt-get install sudo -y
fi
sudo apt-get update
sudo apt-get install curl -y
sudo apt-get install sed -y
sudo curl https://rclone.org/install.sh | sudo bash
sudo apt-get install fuse -y

#servernamec="$ServerName"

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

# Configuración del nombre del servidor
echo "Ingrese el nombre de la nube, ej: drive..."
echo "Se utilizará como nombre de la carpeta donde se sincronizara la nube..."

read_with_prompt CloudName "Nombre de la Nube"

# Verifique si el directorio de la unidad en la nube ya existe
cd ~
if [ ! -d "$CloudName" ]; then
  mkdir $CloudName
  cd $CloudName
else
  cd $CloudName
fi
echo "El directorio $DirName/$CloudName es la unidad en la Nube"

# Verifique si el directorio drive/minecraft de la copia en la nube ya existe
cd ~
cd $CloudName
if [ ! -d "minecraft" ]; then
  mkdir minecraft
  cd minecraft
else
  cd minecraft
fi
echo "El directorio $DirName/$CloudName/minecraft es la copia del Mundo Minecraft en la nube"

# Eliminar scrip start.sh para actualizar
cd ~
cd minecraftbe
cd servername

# Modificar start.sh y SetupMinecraft.sh
sudo sed -i "s/cloudname/$CloudName/g" start.sh

echo "Archivos configurados..."
sudo sed -n "/sudo rsync -avz backups/p" start.sh

sleep 5s

# Modificar archivo fuse.conf
cd ~
sudo chmod +x /etc/fuse.conf
#sudo sed -i "s/# Allow non-root users to specify the allow_other or allow_root mount options./ Allow non-root users to specify the allow_other or allow_root mount options./g" /etc/fuse.conf
sudo sed -i "s/#user_allow_other/user_allow_other/g" /etc/fuse.conf
echo "Archivo fuse configurado..."
sudo sed -n "/# Allow/p" /etc/fuse.conf
sudo sed -n "/user_allow_other/p" /etc/fuse.conf

sleep 3s

# Iniciando Configuración Montaje de Unidad
  cd ~
  echo "Realizar el inicio de seccion de la cuenta en la nube para el Montaje del servidor $DirName/$CloudName ..."

  sleep 4s

  sudo rclone config

# Confirme el nombre de la unidad remota de rclone

echo "Confirme el nombre de la unidad remota que escribio en RClone"

read_with_prompt RclonName "nombre"

# Montando la unidad al iniciar la maquina del servidor en crontab -e
cd ~
    echo -n "¿Montar la unidad $DirName/$CloudName/minecraft al iniciar la maquina? (y/n)"
    read answer < /dev/tty
    if [ "$answer" != "${answer#[Yy]}" ]; then
      croncmd="$DirName/$CloudName --allow-other &"
      # El nombre de la unidad en RClone debe ser igual $RclonName 
      cronjob="@reboot rclone mount $RclonName: $croncmd"
      ( crontab -l | grep -v -F "$croncmd" ; echo "$cronjob" ) | crontab -
      echo "Montaje de la Unidad programada. Para cambiar o eliminar el montaje automático, escriba crontab -e"
    fi

#@reboot rclone mount drive: /drive --allow-other &

echo "Montando fuse con RClone..."

echo "rclone mount $RclonName: /$DirName/$CloudName"

sleep 4s

sudo rclone mount $RclonName: $DirName/$CloudName --allow-other

#sudo reboot
