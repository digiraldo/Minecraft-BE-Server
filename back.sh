#!/bin/bash
# Autor: Di Giraldo
# Instale las dependencias necesarias RClone y fuse para montar la nube
echo "tutorial de instalacion en: https://gorobeta.blogspot.com"
sleep 4s

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

echo "========================================================================="
echo "Si vas a instalar o recuperar un mundo en este servidor, este debe estar en la nube cloudname/foldername"
sleep 4s

# Buscar los respaldos en la nube cloudname/foldername
echo "========================================================================="
echo "========================================================================="
echo "Buscando respaldos en su nube dirname/cloudname/foldername"
echo "Espere un momento..."
echo "========================================================================="
sleep 3s

# Verificar archivos sincronizados
cd ~
cd cloudname
cd foldername
echo "========================================================================="
echo "==========================ARCHIVOS EN LA NUBE============================"
ls -lt
echo "========================================================================="

echo "========================================================================="
    echo -n "Si no ve el Mundo, súbelo a la nube y confirma con si (y) para visualizarlo (y/n)"
    read answer < /dev/tty
    if [ "$answer" != "${answer#[Yy]}" ]; then
      # Escanear la nube cloudname/foldername
      cd ~
      cd cloudname
      cd foldername
        echo "========================================================================="
        echo "==========================ARCHIVOS EN LA NUBE============================"
        echo "Iniciando Escaneo de la nube cloudname/foldername"
        ls -lt
        echo "========================================================================="
        sleep 3s
    fi

echo "-------------------------------------------------------------------------"
echo "Escriba aquí el nombre del mundo a restaurar"
read_with_prompt BackName "Nombre del Mundo"

echo "========================================================================="
echo "-------------------------------------------------------------------------"
echo "Sincronizando Mundo..."
sudo rsync -vh $BackName ~/minecraftbe/servername/backups/
sleep 3s

# Restablecer mundos
sudo systemctl daemon-reload
sudo systemctl stop servername.service
cd ~
cd minecraftbe
cd servername
sudo rm -rf worlds
sudo tar -xf backups/$BackName
sleep 5s

# Verificar archivos sincronizados
cd ~
cd minecraftbe
cd servername
cd worlds
echo "========================================================================="
echo "===========================NOMBRE DEL NIVEL=============================="
ls -lt
echo "========================================================================="

sleep 3s

cd ~
cd minecraftbe
cd servername
echo "========================================================================="
echo "Escriba aquí el nivel o nombre del mundo recuperado"
read -p "Nombre del Nivel: " WoName
if [ "$WoName" != "" ]
then
    echo "Actualizando Nombre de nivel a $WoName"
    sudo sed -i "/level-name=/c\level-name=$WoName" server.properties
    echo "========================================================================="
    sudo sed -n "/level-name=/p" server.properties | sed 's/level-name=/Nombre del Nivel: ....... /'
else
    sudo sed -n "/level-name=/p" server.properties | sed 's/level-name=/Nombre del Nivel Actual ........ /'
fi
sudo sed -i "/level-seed=/c\level-seed=" server.properties
sleep 3s

echo "========================REINICIANDO SERVIDOR=============================="

sleep 2s

# Iniciar servidor
/bin/bash dirname/minecraftbe/servername/start.sh
