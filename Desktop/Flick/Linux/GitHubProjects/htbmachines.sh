#!/bin/bash
#Colores 
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"
#Colores definidos 


main_url="https://htbmachines.github.io/bundle.js"
parameter_counter=0 
chivato_dificultad=0 
chivato_sistema=0 
function ctrl_c(){
echo -e "\n${redColour}[!] Saliendo...${endColour}\n\n"
tput cnorm; exit 1 
}
trap ctrl_c INT


function helpPanel(){
  echo -e "\n${purpleColour}[+]${endColour} ${grayColour}Panel de ayuda${endColour} ${yellowColour}->${endColour} ${turquoiseColour}-h${endColour} ${grayColour}Abrir panel de ayuda${endColour}"
  echo -e "                      ${turquoiseColour}-u${endColour} ${grayColour}Actualizar sistema${endColour}"
  echo -e "                      ${turquoiseColour}-i${endColour} ${grayColour}Buscar máquinas por IP específica${endColour}"
  echo -e "                      ${turquoiseColour}-y${endColour} ${grayColour}Buscar writeup de una máquina${endColour}"
  echo -e "                      ${turquoiseColour}-c${endColour} ${grayColour}Listar máquinas por certificado${endColour}"
  echo -e "                      ${turquoiseColour}-r${endColour} ${grayColour}Obtener shell de $0${endColour}"
  echo -e "                      ${turquoiseColour}-s${endColour} ${grayColour}Buscar máquinas por skill${endColour}"
  echo -e "                      ${turquoiseColour}-d${endColour} ${grayColour}Listar máquinas por dificultad${endColour}"
  echo -e "                      ${turquoiseColour}-o${endColour} ${grayColour}Listar máquinas por sistema operativo${endColour}"
  echo -e "                      ${turquoiseColour}-a${endColour} ${grayColour}Listar el total de máquinas existentes${endColour}"
} 

function getMachines(){
machineName=$1 
validacion=$(cat bundle.js | grep -i "name: \"$1\"" -A 8 | tr -d '"' | tr -d ',' | grep -vE "sku:|id:" | sed 's/^ *//g')
if [ "$validacion" ]; then 
echo -e "${yellowColour}[+]${endColour}${grayColour} Listando las propiedades de la máquina${endColour} ${purpleColour}$1${endColour}${grayColour}:${endColour}\n"
echo -e ${grayColour}"$(cat bundle.js | grep -i "name: \"$1\"" -A 8 | tr -d '"' | tr -d ',' | grep -vE "sku:|id:" | sed 's/^ *//g')"${endColour}
else 
echo -e "\n${redColour}[!] Debes de indicar una máquina${endColour}"
exit 1
fi
}

function updateFiles(){
if [ ! -f "bundle.js" ]; then 
echo -ne "\n${blueColour}[+]${endColour} ${grayColour}El archivo bundle.js no existe, ¿Deseas descargarlo?${endColour} " && read si_no
if [ "$si_no" == "si" ]; then 
curl -s $main_url >> bundle.js 
js-beautify bundle.js | sponge bundle.js 
elif [ "$si_no" == "no" ]; then 
  echo " " 
else 
  echo -e "\n${turquoiseColour}[!]${endColour} ${grayColour}Debes de decidir una acción${endColour}"
exit 0
fi
else 
echo -ne "\n${yellowColour}[+]${endColour} ${grayColour}El archivo existe, ¿Deseas revisar si hay actualizaciones?${endColour} " && read yes_or_no
if [ "$yes_or_no" == "si" ] || [ "$yes_or_no" == "s" ] || [ "$yes_or_no" == "S" ] || [ "$yes_or_no" == "y" ] || [ "$yes_or_no" == "Y" ] || [ "$yes_or_no" == "yes" ] || [ "$yes_or_no" == "Si" ]; then 
  curl -s $main_url >> bundle_temp.js 
  js-beautify bundle_temp.js | sponge bundle_temp.js
  md5_original_value=$(md5sum bundle.js | awk '{print $1}')
  md5_temp_value=$(md5sum bundle_temp.js | awk '{print $1}')
  if [ "$md5_original_value" == "$md5_temp_value" ]; then 
    echo -e "\n${blueColour}[+]${endColour} ${grayColour}No se encontraron actualizaciones, estas al día ;)${endColour}"
    rm bundle_temp.js 
  else 
echo -e "\n${yellowColour}[*]${endColour} ${grayColour}Hemos encontrado actualizaciones, esto podría tomar un tiempo...${endColour}"
rm bundle.js 
mv bundle_temp.js bundle.js 
echo -e "\n${blueColour}[+]${endColour} ${grayColour}Estas al día chaval ;)${endColour}"
  fi
elif [ "$yes_or_no" == "no" ] || [ "$yes_or_no" == "x" ] || [ "$yes_or_no" == "NO" ] || [ "$yes_or_no" == "n" ] || [ "$yes_or_no" == "No" ] || [ "$yes_or_no" == "N" ]; then 
exit 0
else 
echo -e "\n${redColour}[!] No puedes dejar un espacio en blanco${endColour}"
exit 1
fi
fi


}

function searchIP(){
ipMachine=$1
machineName=$(cat bundle.js | grep -i "ip: \"$1" -B 3 | grep -vE "sku:|id:" | sed 's/--//g' | grep name | tr -d '"' | tr -d ',' | awk 'NR==1' | sed 's/name://g' | sed 's/^ *//g')
if [ "$machineName" ]; then 
echo -e "\n${blueColour}[+]${endColour} ${grayColour}La IP ${turquoiseColour}$1${endColour} ${grayColour}le pertenece a la máquina${endColour} ${purpleColour}$machineName${endColour}" 
echo -ne "\n${blueColour}[+]${endColour} ${grayColour}¿Deseas listar las propiedades de la máquina${endColour} ${purpleColour}$machineName${endColour}${grayColour}?${endColour} " && read si_no 
if [ "$si_no" == "si" ] || [ "$si_no" == "s" ] || [ "$si_no" == "S" ] || [ "$si_no" == "SI" ] || [ "$si_no" == "Si" ] || [ "$si_no" == "y" ]; then 
getMachines $machineName 
elif [ "$si_no" == "no" ]; then 
exit 0
else 
  echo -e "\n${redColour}[!] Debe de haber contenido entre tu elección${endColour}"
exit 1
fi
else 
echo -e "\n${redColour}[!] La IP $ipMachine no existe${endColour}"
fi

}

function getYoutubeLink(){
writeup=$1
validtor=$(cat bundle.js | grep -i "$1" -A 8 | grep youtube | awk 'NR==1' | tr -d ',' | tr -d '"' | awk 'NF{print $NF}')
if [ "$validtor" ]; then 
echo -e "\n${blueColour}[+]${endColour} ${grayColour}Aquí tienes el writeup de la máquina${endColour} ${purpleColour}$1${endColour} ${yellowColour}- >${endColour} ${turquoiseColour}$validtor${endColour}"
else 
echo -e "\n${redColour}[-] No se encontro el writeup de la máquina $1${endColour}"
fi
}

function getCerts(){
certs=$1
CertValidator=$(cat bundle.js | grep -i "like: \"$certs\"" -B 7 | grep "name: " | tr -d '"' | tr -d ',' | awk 'NF{print $NF}' | column)
if [ "$CertValidator" ]; then 
echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Listando máquinas que pueden caerte en certificados como${endColour} ${purpleColour}$certs${endColour}"
cat bundle.js | grep -i "like: \"$certs\"" -B 7 | grep "name: " | tr -d '"' | tr -d ',' | awk 'NF{print $NF}' | column
else 
echo -e "\n${redColour}[-]${endColour} ${grayColour}No se encontraron máquinas que puedan caerte en certificados como${endColour} ${purpleColour}$certs${endColour}"
fi
} 

function shell(){ 
  stty sane
shellHelp
  while true; do 
    echo -ne "${yellowColour}[+]${endColour} [$(whoami)]@[htbsearch.io] > " && read command
if [ "$command" == "h" ]; then 
  shellHelp
elif [ "$command" == "ls" ] || [ "$command" == "dir" ]; then 
echo ''
echo -e "${grayColour} bundle.js${endColour} ${greenColour} ${endColour}${grayColour}updateFiles${endColour} ${yellowColour} ${endColour}${grayColour}allMachines${endColour} ${yellowColour} ${endColour}${grayColour}Maquinas${endColour}"
echo ''
elif [ "$command" == "exit" ]; then
  echo -e "\n${greenColour}[+]${endColour} ${grayColour}Saliendo ;)${endColour}"
  exit 0
elif [ "$command" == "u" ] || [ "$command" == "updateFiles" ]; then 
  updateFiles 
elif [ "$command" == "clear" ]; then
  clear 
elif [ "$command" == "a" ] || [ "$command" == "allMachines" ] || [ "$command" == "all" ]; then 
  allMachines  
elif [ "$command" == "m" ]; then
echo -ne "\n${blueColour}[+]${endColour} ${grayColour}¿De que máquina deseas listar el contenido?${endColour} ${yellowColour}- >${endColour} " && read maquina 
if [ "$maquina" ]; then 
validacion=$(cat bundle.js | grep -i "name: \"$maquina\"" -A 8 | tr -d '"' | tr -d ',' | grep -vE "sku:|id:" | sed 's/^ *//g')
if [ "$validacion" ]; then 
echo -e "\n${turquoiseColour}[+]${endColour} ${grayColour}Listando las propiedades de la máquina${endColour} ${purpleColour}$maquina${endColour}"
echo -e ${grayColour}"$(cat bundle.js | grep -i "name: \"$maquina\"" -A 8 | tr -d '"' | tr -d ',' | grep -vE "sku:|id:" | sed 's/^ *//g')"${endColour}
else 
echo -e "\n${redColour}[-]${endColour} ${grayColour}La máquina proporcionada es incorrecta${endColour}"
fi
else 
echo -e "\n${redColour}[-]${endColour} ${grayColour}No puedes dejar en espacios en blanco${endColour}"
fi 
elif [ "$command" == "i" ] || [ "$command" == "I" ]; then 
  echo -ne "\n${turquoiseColour}[*]${endColour} ${grayColour}Sobre que IP deseas hacer una revision${endColour} ${blueColour}- >${endColour} " && read IP
if [ "$IP" ]; then 
  echo -e "\n${greenColour}[*]${endColour}${endColour} ${grayColour}Realizando una busqueda sobre la IP${endColour} ${turquoiseColour}$IP${endColour}${grayColour}...${endColour}"
  sleep 1
  validator=$(cat bundle.js | grep -i "ip: \"$IP" -B 3 | grep -vE "sku:|id:" | sed 's/--//g' | grep name | tr -d '"' | tr -d ',' | awk 'NR==1' | sed 's/name://g' | sed 's/^ *//g')
  if [ "$validator" ]; then 
  MaquinaIP=$(cat bundle.js | grep -i "ip: \"$IP" -B 3 | grep -vE "sku:|id:" | sed 's/--//g' | grep name | tr -d '"' | tr -d ',' | awk 'NR==1' | sed 's/name://g' | sed 's/^ *//g')   
  echo -e "\n${greenColour}[+]${endColour} ${grayColour}La IP${endColour} ${purpleColour}$IP${endColour} ${grayColour}le pertenece a la maquina${endColour} ${turquoiseColour}$MaquinaIP${endColour}"
else 
echo -e "\n${redColour}[-]${endColour} ${grayColour}La IP proporcionada es incorrecta${endColour}"
  fi
else 
echo -e "\n${redColour}[-]${endColour} ${grayColour}No puedes dejar campos vacios${endColour}"
fi
 else 
echo -e "\n${redColour}[-]${endColour} ${grayColour}Command not found "\"${redColour}$command${endColour}${grayColour}"\"${endColour}"
shellHelp | grep -vE "Esta|proceso"
fi
  done
}

function shellHelp(){
  echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Esta revershe shell aun esta en proceso :)${endColour}"
  echo -e "${blueColour}[*]${endColour} ${grayColour}Comandos existentes actuales:${endColour}" 
  echo -e "\t ${purpleColour}-h${endColour} ${grayColour}Llamar al panel de ayuda${endColour}"
  echo -e "\t ${purpleColour}-u${endColour} ${grayColour}Descargar o buscar actualizaciones${endColour}"
  echo -e "\t ${purpleColour}-clear${endColour} ${grayColour}Limpiar pantalla${endColour}"
  echo -e "\t ${purpleColour}-a, -allMachines, -all${endColour} ${grayColour}Listar máquinas existentes${endColour}"
  echo -e "\t ${purpleColour}-m${endColour} ${grayColour}Listar propiedades de una máquina${endColour}"


} 

function getSkills(){
skill=$1 
validator=$(cat bundle.js | grep "skills: " -B 7 | grep "$1" -w -i -B 7 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column) 
if [ "$validator" ]; then 
  echo -e "\n${blueColour}[+]${endColour} ${grayColour}Listando máquinas que requieran de habilidades tipo${endColour} ${turquoiseColour}$1${endColour}\n"
cat bundle.js | grep "skills: " -B 7 | grep "$1" -w -i -B 7 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column 
else 
echo -e "\n${redColour}[-] No encontramos la dificultad $1${endColour}"
fi
}

function getDifficultys(){
Difficulty=$1
validator=$(cat bundle.js | grep -i "dificultad: \"$1\"" -B 5 | grep name | tr -d '"' | tr -d "," | awk 'NF{print $NF}' | column) 
if [ "$validator" ]; then 
if [ "$Difficulty" == "Fácil" ] || [ "$Difficulty" == "fácil" ]; then 
echo -e "\n[+] Listando las máquinas, cuya dificultad es ${greenColour}$1\n${endColour}"
  cat bundle.js | grep -i "dificultad: \"$1\"" -B 5 | grep name | tr -d '"' | tr -d "," | awk 'NF{print $NF}' | column
elif [ "$Difficulty" == "Media" ] || [ "$Difficulty" == "media" ]; then 
echo -e "\n[+] Listando las máquinas, cuya dificultad es ${yellowColour}$1\n${endColour}"
cat bundle.js | grep -i "dificultad: \"$1\"" -B 5 | grep name | tr -d '"' | tr -d "," | awk 'NF{print $NF}' | column 
elif [ "$Difficulty" == "Difícil" ] || [ "$Difficulty" == "difícil" ]; then 
echo -e "\n[*] Listando máquinas, cuya dificultad es ${redColour}$1${endColour}\n"
cat bundle.js | grep -i "dificultad: \"$1\"" -B 5 | grep name | tr -d '"' | tr -d "," | awk 'NF{print $NF}' | column 
elif [ "$Difficulty" == "Insane" ] || [ "$Difficulty" == "insane" ] || [ "$Difficulty" == "INSANE" ]; then 
  echo -e "\n[*] Listando máquinas, cuya dificultad es ${purpleColour}$1${endColour}\n"
  cat bundle.js | grep -i "dificultad: \"$1\"" -B 5 | grep name | tr -d '"' | tr -d "," | awk 'NF{print $NF}' | column
fi 
else 
echo -e "\n${redColour}[-]${endColour} ${grayColour}Debes de indicar una dificultad correcta${endColour}"
difficultyHelp 
exit 0
fi
}

function difficultyHelp(){
  echo -e "\n${turquoiseColour}[+]${endColour} ${grayColour}Listando manual de ayuda para las dificultades:${endColour}\n"
  echo -e "\t ${grayColour}Dificultad${endColour} ${yellowColour}- >${endColour} ${greenColour}Fácil${endColour}"
  echo -e "\t ${grayColour}Dificultad${endColour} ${yellowColour}- >${endColour} ${yellowColour}Media${endColour}"
  echo -e "\t ${grayColour}Dificultad${endColour} ${yellowColour}- >${endColour} ${redColour}Difícil${endColour}"
  echo -e "\t ${grayColour}Dificultad${endColour} ${yellowColour}- >${endColour} ${purpleColour}Insane${endColour}\n"

}

function getOsMachines(){
osSystem=$1 
validator=$(cat bundle.js | grep -i "so: \"$1\"" -B 4 | grep "name: " | tr -d '"' | tr -d ',' | awk 'NF{print $NF}' | sed 's/^ *//g' | column) 
if [ "$validator" ]; then 
if [ "$osSystem" == "windows" ] || [ "$osSystem" == "Windows" ]; then
  echo -e "\n[+] Listando máquinas de sistema operativo ${turquoiseColour}$1${endColour}:\n\n"
cat bundle.js | grep -i "so: \"$1\"" -B 4 | grep "name: " | tr -d '"' | tr -d ',' | awk 'NF{print $NF}' | sed 's/^ *//g' | column
elif [ "$osSystem" == "Linux" ] || [ "$osSystem" == "linux" ]; then
echo -e "\n[+] Listando máquinas de sistema operativo ${greenColour}$1${endColour}:\n\n"
echo -e "$(cat bundle.js | grep -i "so: \"Windows\"" -B 4 | grep "name: " | tr -d '"' | tr -d ',' | awk 'NF{print $NF}' | sed 's/^ *//g' | column)"
 fi
else 
 echo -e "\n${redColour}[-]${endColour} ${grayColour}Debes de indicar un sistema operativo existente${endColour}"
fi 
}

function allMachines(){
  echo -e "\n${greenColour}[+]${endColour} ${grayColour}Listando el total de máquinas existentes:\n\n${endColour}"
  cat bundle.js | grep "name: \"" | grep "," | grep -vE "StylesContext|DescendantsProvider|TabsContext" | tr -d '"' | tr -d ',' | awk 'NF{print $NF}' | column
}

function OsDifficultys(){
  osSystem=$1
  DifficultyOs=$2
  validator=$(cat bundle.js | grep -i "so: \"$osSystem\"" -C 4 | grep -i "dificultad: \"$DifficultyOs\"" -B 5 | grep name | tr -d '"' | tr -d ',' | awk 'NF{print $NF}' | column) 
  if [ "$validator" ]; then 
echo -e "\n${greenColour}[+]${endColour} ${grayColour}Listando máquinas, cuyo sistema operativo es${endColour} ${purpleColour}$osSystem${endColour} ${grayColour}y su dificultad indicada es${endColour} ${turquoiseColour}$DifficultyOs${endColour}\n"
echo -e "$(cat bundle.js | grep -i "so: \"$osSystem\"" -C 4 | grep -i "dificultad: \"$DifficultyOs\"" -B 5 | grep name | tr -d '"' | tr -d ',' | awk 'NF{print $NF}' | column)" 
else 
echo -e "\n${redColour}[-]${endColour} ${grayColour}El sistema operativo${endColour} ${purpleColour}$osSystem ${grayColour}o la dificultad${endColour} ${turquoiseColour}$DifficultyOs${endColour} ${grayColour}estan incorrectas, favor de revisar...${endColour}\n"
  fi
}


while getopts "uhm:i:y:c:rs:d:o:a" arg; do 
case $arg in 
  h);;
  m)machineName=$OPTARG; let parameter_counter+=1;; 
  u)let parameter_counter+=2;;
  i)ipMachine=$OPTARG; let parameter_counter+=3;;
  y)writeup=$OPTARG; let parameter_counter+=4;; 
  c)certs=$OPTARG; let parameter_counter+=5;; 
  r)let parameter_counter+=6;;
  s)skill=$OPTARG; let parameter_counter+=7;; 
  d)Difficulty=$OPTARG; let chivato_dificultad+=1; let parameter_counter+=8;; 
  o)osSystem=$OPTARG; let chivato_sistema+=1;  let parameter_counter+=9;;
  a)let parameter_counter+=10;;

  esac
done 






if [ "$parameter_counter" -eq 1 ]; then 
getMachines $machineName
elif [ "$parameter_counter" -eq 2 ]; then
updateFiles
elif [ "$parameter_counter" -eq 3 ]; then 
searchIP $ipMachine 
elif [ "$parameter_counter" -eq 4 ]; then 
  getYoutubeLink $writeup
elif [ "$parameter_counter" -eq 5 ]; then 
getCerts $certs 
elif [ "$parameter_counter" -eq 6 ]; then 
  shell shellHelp
elif [ "$parameter_counter" -eq 7 ]; then 
  getSkills $skill
elif [ "$parameter_counter" -eq 8 ]; then 
getDifficultys $Difficulty
elif [ "$parameter_counter" -eq 9 ]; then 
getOsMachines $osSystem
elif [ "$parameter_counter" -eq 10 ]; then 
allMachines
elif [ "$chivato_sistema" -eq 1 ] && [ "$chivato_dificultad" -eq 1 ]; then 
  OsDifficultys $osSystem $Difficulty
else 
  helpPanel
  fi 
