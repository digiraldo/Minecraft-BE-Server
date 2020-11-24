#!/bin/bash
# Autor: Di Giraldo
# Realizar Respaldo de mi nube al Servidor de Minecraft


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
echo "========================================================================="
ls -lt
echo "========================================================================="

echo "-------------------------------------------------------------------------"
echo "Escriba aquí el nombre del mundo a restaurar"
read_with_prompt BackName "Nombre del Mundo"

echo "========================================================================="
echo "-------------------------------------------------------------------------"
echo "Sincronizando Mundo..."
rsync -vh $BackName ~/minecraftbe/servername/backups/
sleep 3s

# Restablecer mundos
cd ~
cd minecraftbe
cd servername
./stop.sh
rm -rf worlds
tar -xf backups/$BackName

echo "========================================================================="
echo "Reiniciando Servidor..."
sleep 2s

# Iniciar servidor
/bin/bash dirname/minecraftbe/servername/start.sh