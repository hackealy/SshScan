#!/bin/bash

# Define o endereço IP ou intervalo de IP a ser escaneado
ip="192.168.0.1/24"

# Realiza o scan de todos os portas abertas no IP especificado e salva em um arquivo XML
nmap -sV -p 22 $ip -oX nmap-results.xml

# Analisa o arquivo XML para identificar os serviços SSH
grep -oP '(?<=\<portid state\=\"open\"\>\<state.*)22/tcp.*name=\"ssh\"' nmap-results.xml > ssh-services.txt

# Verifica se existem serviços SSH listados no arquivo
if [ -s ssh-services.txt ]; then
    echo "Serviços SSH encontrados na rede:"
    cat ssh-services.txt

    # Testa as vulnerabilidades de acesso no SSH
    echo "Testando vulnerabilidades de acesso no SSH..."
    msfconsole -q -x "use auxiliary/scanner/ssh/ssh_version; set RHOSTS `cat ssh-services.txt | awk '{print $2}'`; set VERBOSE true; run; exit"
else
    echo "Nenhum serviço SSH encontrado na rede."
fi

# Limpa os arquivos gerados
rm nmap-results.xml ssh-services.txt
