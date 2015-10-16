#!/bin/bash
######## solo navegacion web
#Limpiar reglas 
iptables -F INPUT
iptables -F FORWARD
iptables -F OUTPUT
#Flush chains
iptables -X
# contador de paquetes y bytes a 0
iptables -Z
#Flush de la tabla NAT
iptables -t nat -F
 
#bloquearemos todo por seguiradad
echo "Aplicando reglas"
iptables -P INPUT DROP
iptables -P OUTPUT DROP
iptables -P FORWARD DROP
 
#localhost servicios internos
iptables -A INPUT -s 127.0.0.1 -i lo -j ACCEPT
iptables -A OUTPUT -d 127.0.0.1 -o lo -j ACCEPT
 
#Permitimos HTTP(80) y HTTPS(443) desde la 1024 a la 65535 solo los puertos de destino 80 y 443
iptables -A OUTPUT -j ACCEPT -o eth0 -p tcp --sport 1024:65535 -m multiport --dports 80,443
#habilitamos consultas  DNS
iptables -A OUTPUT -o eth0 -p udp --sport 1024:65535 --dport 53 -m state --state NEW -j ACCEPT
#Habilitada conexiones entrantes previamente establecidas o relacionadas: HTTP, HTTPS Y DNS
iptables -A INPUT -i eth0 -m state --state ESTABLISHED,RELATED -j ACCEPT
echo "Finalizada reglas"
iptables -n -L -v 
