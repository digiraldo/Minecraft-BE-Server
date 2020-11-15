# Aqui instalamos RClone, tener presente cambio de carpetas

# Instale las dependencias necesarias RClone y fuse para montar la nube
cd ~
echo "Instalando RClone, fuse.."
if [ ! -n "`which sudo`" ]; then
  apt-get update && apt-get install sudo -y
fi
sudo apt-get update
sudo apt-get install curl -y
sudo apt-get install sed -y
sudo curl https://rclone.org/install.sh | sudo bash
sudo apt-get install fuse -y
#sudo apt-get install curl -y




# Obtener la ruta del directorio de home y el nombre de usuario
# Verifique si el directorio de la unidad en la nube ya existe
cd ~
if [ ! -d "drive" ]; then
  mkdir drive
  cd drive
else
  cd drive
    echo "El directorio $DirName/drive es la unidad en la nube"
fi

# Verifique si el directorio drive/minecraft de la copia en la nube ya existe
cd ~
cd drive
if [ ! -d "minecraft" ]; then
  mkdir minecraft
  cd minecraft
else
  cd minecraft
    echo "El directorio $DirName/drive/minecraft es la copia en la nube final"
fi

# Montando la unidad al iniciar la maquina del servidor
cd ~
    echo -n "¿Montar la unidad $DirName/drive/minecraft al iniciar la maquina? (y/n)"
    read answer < /dev/tty
    if [ "$answer" != "${answer#[Yy]}" ]; then
      croncmd="$DirName/drive --allow-other &"
      cronjob="@reboot rclone mount drive: $croncmd"
      ( crontab -l | grep -v -F "$croncmd" ; echo "$cronjob" ) | crontab -
      echo "Montaje de la Unidad programada. Para cambiar o eliminar el montaje automático, escriba crontab -e"
    fi


#@reboot rclone mount drive: /drive --allow-other &


# Modificar archivo fuse.conf
cd ~
sudo chmod +x /etc/fuse.conf
sudo sed -i "s/# Allow non-root users to specify the allow_other or allow_root mount options./ Allow non-root users to specify the allow_other or allow_root mount options./g" /etc/fuse.conf
sudo sed -i "s/#user_allow_other/user_allow_other/g" /etc/fuse.conf
echo "Archivo fuse configurado..."
sudo sed -n "/Allow/p" /etc/fuse.conf
sudo sed -n "/user_allow_other/p" /etc/fuse.conf

sudo rclone mount drive: /drive --allow-other &
