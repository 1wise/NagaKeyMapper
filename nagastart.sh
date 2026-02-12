#!/bin/bash
# nagastart.sh - Lanzador de Naga_KeypadMapper para Wayland

# 1) Nos aseguramos de usar el socket del ydotoold de USUARIO
#    (el que has visto en /run/user/1000/.ydotool_socket)
export YDOTOOL_SOCKET=/tmp/.ydotool_socket

# 3) Lanzar el daemon de Naga.
#    Si 'naga' no está en el PATH, cambia por ./naga
exec /usr/local/bin/naga

