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

# Configuración de juego en el servidor
echo "Configuración del Servidor: servername"
sleep 3s

echo "========================================================================="
echo "Usado como nombre del servidor (predeterminado Servidor): "
echo "Valores permitidos: cualquier cadena: "
read_with_prompt SerVer "Nombre del Servidor" Servidor
echo "========================================================================="

echo "========================================================================="
echo "Usado como nombre de nivel o mundo (predeterminado Bedrock level): "
echo "Valores permitidos: cualquier cadena: "
read_with_prompt LevelName "Nombre del Nivel" Bedrock level
echo "========================================================================="

echo "========================================================================="
echo "Establece el modo de juego para nuevos jugadores (predeterminado survival): "
echo "Valores permitidos: "survival", "creative", o "adventure": "
read_with_prompt GamMode "Modo del Juego" survival
echo "========================================================================="

echo "========================================================================="
echo "Establece la dificultad del mundo (predeterminado easy): "
echo "Valores permitidos: "peaceful", "easy", "normal", o "hard": "
read_with_prompt Difficult "Dificultad del Mundo" easy
echo "========================================================================="

echo "========================================================================="
echo "Si es verdadero (true), se pueden usar trucos como comandos (predeterminado false): "
echo "Valores permitidos: "true" o "false": "
read_with_prompt AllowCheats "Usar Trucos" false
echo "========================================================================="

echo "========================================================================="
echo "El número máximo de jugadores que pueden jugar en el servidor (predeterminado 10): "
echo "Valores permitidos: Cualquier entero positivo: "
read_with_prompt MaxPlayers "Número Máximo de Jugadores" 10
echo "========================================================================="

echo "========================================================================="
echo "Si es verdadero (true), debe dar permiso a jugadores en el archivo whitelist.json (predeterminado false): "
echo "Valores permitidos: "true" o "false": "
read_with_prompt WhiteList "Permiso de Jugadores" false
echo "========================================================================="

echo "========================================================================="
echo "Semilla (mundo aleatorio predeterminado): "
echo "Valores permitidos: cualquier cadena: "
    echo -n "¿Deseas agregar un Códgo o Número de Semilla o Mundo? (y/n)"
    read answer < /dev/tty
    if [ "$answer" != "${answer#[Yy]}" ]; then
      # Crear copia de seguridad
        if [ -d "worlds" ]; then
        echo "Copia de seguridad del servidor (en la carpeta minecraftbe/servername/backups)"
        sudo tar -pzvcf backups/$(date +%d.%m.%Y_%H.%M.%S_servername).tar.gz worlds
        fi
        sudo rm -rf worlds
        sudo mkdir worlds
        echo "========================================================================="
        read_with_prompt LevelSeed "Número de Semilla"
        echo "========================================================================="
    fi

echo "========================================================================="
echo "========================================================================="
echo "Configurando el Servidor: servername ..."
sudo sed -i "/server-name=/c\server-name=$SerVer" server.properties
sudo sed -i "/level-name=/c\level-name=$LevelName" server.properties
sudo sed -i "/gamemode=/c\gamemode=$GamMode" server.properties
sudo sed -i "/difficulty=/c\difficulty=$Difficult" server.properties
sudo sed -i "/allow-cheats=/c\allow-cheats=$AllowCheats" server.properties
sudo sed -i "/max-players=/c\max-players=$MaxPlayers" server.properties
sudo sed -i "/white-list=/c\white-list=$WhiteList" server.properties
sudo sed -i "/level-seed=/c\level-seed=$LevelSeed" server.properties

sleep 1s
sudo systemctl daemon-reload
sudo systemctl stop servername.service
sudo systemctl start servername.service


sleep 2s

echo "Servidor: servername Configurado..."
echo "========================================================================="
echo "Nombre del Servidor: .... $SerVer"
echo "Nombre del Nivel: ....... $LevelName"
echo "Modo del Juego: ......... $GamMode"
echo "Dificultad del Mundo: ... $Difficult"
echo "Usar Trucos: ............ $AllowCheats"
echo "Jugadores Máximos: ...... $MaxPlayers"
echo "Permiso de Jugadores: ... $WhiteList"
echo "Número de Semilla: ...... $LevelSeed"
echo "========================================================================="
sleep 4s
