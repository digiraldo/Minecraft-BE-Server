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
read_with_prompt LevelSeed "Número de Semilla"
echo "========================================================================="


echo "========================================================================="
echo "Configurando el Servidor: servername ..."
sudo sed -i "/gamemode=/c\gamemode=$GamMode" server.properties
sudo sed -i "/difficulty=/c\difficulty=$Difficult" server.properties
sudo sed -i "/allow-cheats=/c\allow-cheats=$AllowCheats" server.properties
sudo sed -i "/max-players=/c\max-players=$MaxPlayers" server.properties
sudo sed -i "/white-list=/c\white-list=$WhiteList" server.properties
sudo sed -i "/level-seed=/c\level-seed=$LevelSeed" server.properties

sudo systemctl daemon-reload
echo "========================================================================="
sleep 2s
echo "========================================================================="
echo "Servidor: servername Configurado..."
echo "========================================================================="
sleep 4s
