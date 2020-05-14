#!/bin/bash
#
#Developed by 4null0


#Colours
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"

trap ctrl_c INT

function ctrl_c(){
	echo -e "\n\n${yellowColour}[*]${endColour}${grayColour} Exiting...\n${endColour}"
	tput cnorm;
	exit 0
}

tput civis

#Control de los parametros pasados
if [ $# = 0 ] || [ $# -gt 2 ]; then
	echo "Este script sólo admite un parámetro, que corresponde con la URL"
	echo "Ejemplo: ./spiderBASH.sh https://google.es"
	tput cnorm
	exit 1
else
	fecha=$(date +%d-%m-%Y)
	hora=$(date +%X)

	directorio=$fecha--$hora

	mkdir $directorio
	mkdir $directorio/Descargas

	echo -e "\n${greenColour}[*]${endColour}${grayColour} Inspeccionando el sitio web...\n${endColour}"
	#Descargamos un listado de todas las URL del sitio y las almacenamos en el archivo: datos
	wget --spider --no-check-certificate -U "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:76.0) Gecko/20100101 Firefox/76.0" -r -nd -o "$directorio/datos" $1

	echo -e "\n${greenColour}[*]${endColour}${grayColour} Determinando el esquema del sitio web...\n${endColour}"
	#Parseamos la información para quedarnos exclusivamente con las URLs del sitio web. El archivo donde lo dejaremos es: EsquemaSitioWeb
	cat $directorio/datos | grep "200 OK" -B 2 | grep -e "http" | sed 's/^\-\-[0-9]*\-[0-9]*\-[0-9]*\s[0-9]*\:[0-9]*\:[0-9]*\-\-\s*//g' > $directorio/EsquemaSitioWeb

	echo -e "\n${greenColour}[*]${endColour}${grayColour} Determinando las extensiones de los archivos encontrados en el sitio web...\n${endColour}"

	#Parseamos la información de las URLs para determinar las extensiones que maneja el sitio. Los datos lo dejamos en el archivo: Extensiones
	cat $directorio/EsquemaSitioWeb | grep -e "\.[a-zA-Z]*$" | sed 's/^.*\.//' | sort -u > $directorio/Extensiones
	numext=$(cat $directorio/Extensiones | wc -l)

	if [ $numext == 0 ]; then
		echo -e "\n  ${greenColour}[*]${endColour}${grayColour} No se han encontrado extensiones, ummm\n${endColour}"
	else
		echo -e "  ${greenColour}[*]${endColour}${grayColour} Se han encontrado las siguientes extensiones:\n${endColour}"

		contador=1

		for  exten in $(cat $directorio/Extensiones); do
			echo -e "    ${greenColour}[$contador]${endColour}${grayColour} $exten${endColour}"
			contador=$((contador+1))
		done

		echo -en "\n${greenColour}[?]${endColour}${grayColour}"
 		read -p " Qué extensión quieres descargar?[ENTER]: (a = todas las extensiones // n = ninguna extensión)  " Adescargar
		echo -en "${endColour}"

		if [ "$Adescargar" == "n" ]; then
			echo -e "\n${greenColour}[*]${endColour}${grayColour} Gracias por estar ahí, hasta la próxima ...\n ${endColour}"
			tput cnorm
			exit 0
		elif [ "$Adescargar" == "a" ]; then
			for file in $(cat $directorio/EsquemaSitioWeb); do
				wget --no-check-certificate --no-verbose $file -P $directorio/Descargas 1>/dev/null 2>/dev/null
			done

			echo -e "\n${greenColour}[*]${endColour}${grayColour} Descargas completadas. Disfrute de su descarga,  hasta la  próxima ...\n ${endColour}"
                	tput cnorm
		else

			exten=$(head -n $Adescargar $directorio/Extensiones | tail -n 1)
			echo -e "\n${greenColour}[*]${endColour}${grayColour} Descargando los archivos con extension: $exten${endColour}"

			for  file in $(cat $directorio/EsquemaSitioWeb | grep  "\.$exten"); do
				wget --no-check-certificate --no-verbose $file -P $directorio/Descargas 1>/dev/null 2>/dev/null
			done

			echo -e "\n${greenColour}[*]${endColour}${grayColour} Descargas completadas. ${endColour}"
			echo -e "${greenColour}[*]${endColour}${grayColour} Disfrute de su descarga,  hasta la próxima ...\n ${endColour}"
			tput cnorm
		fi
	fi
fi
