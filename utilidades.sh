#!/bin/bash
#
# @(#)$Id: utilizades.sh 1234 2024-12-20 10:15:30Z javier bermejo $
#
# Descripción:
# Script de menú para obtener información del sistema y realizar operaciones de archivos.
#   Este script proporciona un menú interactivo para gestionar información del sistema,
#   incluyendo el espacio libre en disco, uso de procesador, y operaciones de archivos.
#
# Usage
#   ./utilidades.sh
#
# Author
#   Javier Bermejo
#
# License
#   MIT License

# Limpiar la pantalla
clear

# Definición de colores usando códigos ANSI con sintaxis $'...'
ROJO=$'\033[0;31m'
VERDE=$'\033[0;32m'
AMARILLO=$'\033[1;33m'
AZUL=$'\033[0;34m'
MAGENTA=$'\033[0;35m'
CIAN=$'\033[0;36m'
NC=$'\033[0m' # No Color

# Archivo para almacenar el número de usuarios conectados la última vez
LAST_USERS_FILE="/tmp/last_users_count.tmp"

# Función para obtener el espacio libre del disco
espacio_libre() {
    echo -e "${VERDE}Espacio libre del disco:${NC}"
    df -h
}

# Función para obtener el tamaño ocupado por un directorio
tamaño_directorio() {
    read -rp "${AMARILLO}Introduce la ruta del directorio: ${NC}" dir
    if [ -d "$dir" ]; then
        du -sh "$dir"
    else
        echo -e "${ROJO}El directorio no existe.${NC}"
    fi
}

# Función para obtener el uso del procesador con detección de OS
uso_procesador() {
    echo -e "${VERDE}Uso del procesador:${NC}"
    OS=$(uname)
    if [ "$OS" == "Darwin" ]; then
        # Comando para macOS
        top -l 1 | grep "CPU usage"
    else
        # Asumir Linux u otro sistema Unix
        top -b -n1 | grep "Cpu(s)"
    fi
}

# Función para obtener el número de usuarios conectados
numero_usuarios() {
    count=$(who | wc -l)
    echo -e "${VERDE}Número de usuarios conectados: ${AMARILLO}$count${NC}"
}

# Función para obtener el cambio en el número de usuarios desde la última consulta
usuarios_desde_ultima() {
    current_count=$(who | wc -l)
    if [ -f "$LAST_USERS_FILE" ]; then
        last_count=$(cat "$LAST_USERS_FILE")
        diff=$((current_count - last_count))
        echo -e "${VERDE}Cambio en el número de usuarios desde la última vez: ${AMARILLO}$diff${NC}"
    else
        echo -e "${CIAN}Esta es la primera vez que se consulta el número de usuarios.${NC}"
    fi
    echo "$current_count" > "$LAST_USERS_FILE"
}

# Función para mostrar las últimas cinco líneas de un archivo
mostrar_lineas() {
    read -rp "${AMARILLO}Introduce la ruta del archivo de texto: ${NC}" file
    if [ -f "$file" ]; then
        echo -e "${VERDE}Últimas cinco líneas de $file:${NC}"
        tail -n 5 "$file"
    else
        echo -e "${ROJO}El archivo no existe.${NC}"
    fi
}

# Función para copiar archivos .sh y .c de un directorio a otro
copiar_archivos() {
    read -rp "${AMARILLO}Introduce el directorio de origen: ${NC}" origen
    read -rp "${AMARILLO}Introduce el directorio de destino: ${NC}" destino

    if [ ! -d "$origen" ]; then
        echo -e "${ROJO}El directorio de origen no existe.${NC}"
        return
    fi

    # Crear el directorio de destino si no existe
    if [ ! -d "$destino" ]; then
        mkdir -p "$destino"
        echo -e "${AZUL}Directorio de destino creado: $destino${NC}"
    fi

    # Copiar archivos .sh
    if cp "$origen"/*.sh "$destino" 2>/dev/null; then
        contador_sh=$(find "$origen" -maxdepth 1 -type f -name '*.sh' | wc -l)
        echo -e "${VERDE}Archivos .sh copiados exitosamente a $destino: ${AMARILLO}$contador_sh${NC}"
    else
        echo -e "${ROJO}Hubo un error al copiar los archivos .sh.${NC}"
    fi

    # Copiar archivos .c
    if cp "$origen"/*.c "$destino" 2>/dev/null; then
        contador_c=$(find "$origen" -maxdepth 1 -type f -name '*.c' | wc -l)
        echo -e "${VERDE}Archivos .c copiados exitosamente a $destino: ${AMARILLO}$contador_c${NC}"
    else
        echo -e "${ROJO}Hubo un error al copiar los archivos .c.${NC}"
    fi
}

# Función para mostrar el menú con colores
mostrar_menu() {
    echo -e "${MAGENTA}-----------------------------------------${NC}"
    echo -e "${MAGENTA}         Menú de Información            ${NC}"
    echo -e "${MAGENTA}-----------------------------------------${NC}"
    echo -e "${CIAN}1.${NC} Obtener el espacio libre del disco."
    echo -e "${CIAN}2.${NC} Obtener el tamaño ocupado por un directorio."
    echo -e "${CIAN}3.${NC} Obtener el uso del procesador."
    echo -e "${CIAN}4.${NC} Obtener el número de usuarios conectados."
    echo -e "${CIAN}5.${NC} Obtener el cambio en el número de usuarios desde la última consulta."
    echo -e "${CIAN}6.${NC} Mostrar las últimas cinco líneas de un archivo de texto."
    echo -e "${CIAN}7.${NC} Copiar archivos .sh y .c de un directorio a otro."
    echo -e "${CIAN}8.${NC} Salir."
    echo -e "${MAGENTA}-----------------------------------------${NC}"
}

# Bucle principal del menú
while true; do
    mostrar_menu
    read -rp "${AMARILLO}Selecciona una opción [1-8]: ${NC}" opcion
    case $opcion in
        1)
            espacio_libre
            ;;
        2)
            tamaño_directorio
            ;;
        3)
            uso_procesador
            ;;
        4)
            numero_usuarios
            ;;
        5)
            usuarios_desde_ultima
            ;;
        6)
            mostrar_lineas
            ;;
        7)
            copiar_archivos
            ;;
        8)
            echo -e "${VERDE}Saliendo del programa. ¡Hasta luego!${NC}"
            exit 0
            ;;
        *)
            echo -e "${ROJO}Opción no válida. Por favor, elige una opción entre 1 y 8.${NC}"
            ;;
    esac
    echo
    read -rp "${AMARILLO}Presiona Enter para continuar...${NC}" 
    clear
done
