#!/bin/bash
# Este Script es el mismo del autor James A. Chambers a diferencia que fue traducido al español (This Script is the same as that of the author James A. Chambers, unlike that it was translated into Spanish.)
# James Chambers
# Script de reinicio de Minecraft Bedrock Server

# Compruebe si el servidor está iniciado
if ! screen -list | grep -q "servername"; then
    echo "¡El servidor no se está ejecutando actualmente!"
    exit 1
fi

echo "Envío de notificaciones de reinicio al servidor..."

# Iniciar aviso de cuenta atrás en el servidor
screen -Rd servername -X stuff "say Server is restarting in 30 seconds! $(printf '\r')"
sleep 23s
screen -Rd servername -X stuff "say Server is restarting in 7 seconds! $(printf '\r')"
sleep 1s
screen -Rd servername -X stuff "say Server is restarting in 6 seconds! $(printf '\r')"
sleep 1s
screen -Rd servername -X stuff "say Server is restarting in 5 seconds! $(printf '\r')"
sleep 1s
screen -Rd servername -X stuff "say Server is restarting in 4 seconds! $(printf '\r')"
sleep 1s
screen -Rd servername -X stuff "say Server is restarting in 3 seconds! $(printf '\r')"
sleep 1s
screen -Rd servername -X stuff "say Server is restarting in 2 seconds! $(printf '\r')"
sleep 1s
screen -Rd servername -X stuff "say Server is restarting in 1 second! $(printf '\r')"
sleep 1s
screen -Rd servername -X stuff "say Closing server...$(printf '\r')"
screen -Rd servername -X stuff "stop$(printf '\r')"

echo "Cerrando servidor..."
# Espere hasta 30 segundos para que se cierre el servidor
StopChecks=0
while [ $StopChecks -lt 30 ]; do
  if ! screen -list | grep -q "servername"; then
    break
  fi
  sleep 1;
  StopChecks=$((StopChecks+1))
done

if screen -list | grep -q "servername"; then
    # El servidor aún no se ha detenido después de 30 segundos, dígale a Screen que lo cierre
    echo "El servidor de Minecraft aún no se ha cerrado después de 30 segundos, cerrando la pantalla manualmente"
    screen -S servername -X quit
    sleep 10
fi

# Iniciar servidor
/bin/bash dirname/minecraftbe/servername/start.sh
