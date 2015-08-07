#i!/bin/bash
TABLA_1="t0"
TABLA_2="t1"
IP_PUBLICA=$(hostname -I | cut -d' ' -f1)
IP_INTERNA=$(hostname -I | cut -d' ' -f2)
echo "Leyendo ..."
if [ -z "$(cat /etc/iproute2/rt_tables | grep -w $TABLA_1)" ]; then
	echo "creando Tabla $TABLA_1 ..."
	echo "1 "$TABLA_1 >>  /etc/iproute2/rt_tables
fi

if [ -z "$(cat /etc/iproute2/rt_tables | grep -w $TABLA_2)" ]; then
        echo "creando Tabla $TABLA_2 ..."
        echo "2 "$TABLA_1 >>  /etc/iproute2/rt_tables
fi

#generar  gateway 
GATEWAY_IP_PUBLICA=$(echo $IP_PUBLICA | cut -d"." -f1-3)
RED_PUBLICA=$(echo $GATEWAY_IP_PUBLICA)
GATEWAY_IP_PUBLICA=$(echo $GATEWAY_IP_PUBLICA".1")

GATEWAY_IP_INTERNA=$(echo $IP_INTERNA | cut -d"." -f1-3)
RED_INTERNA=$(echo $GATEWAY_IP_INTERNA)
GATEWAY_IP_INTERNA=$(echo $GATEWAY_IP_INTERNA".1")


echo "Gateway ip publica: "$GATEWAY_IP_PUBLICA
echo "Gateway ip interna: "$GATEWAY_IP_INTERNA

#seteamos los gateway por default

route add default gw $GATEWAY_IP_PUBLICA eth0
route add default gw $GATEWAY_IP_INTERNA eth1

#Aplicamos route por defualt  t1
ip route add default via $GATEWAY_IP_PUBLICA  dev eth0 table t0
ip route add default via $GATEWAY_IP_INTERNA  dev eth1 table t1
#segmentos
#ip route add  $RED_INTERNA/24 via $IP_INTERNA
#ip route add  $RED_PUBLICA/24 via $IP_PUBLICA
ip route add $RED_INTERNA/24 dev eth1 src $IP_INTERNA table t1
ip route add $RED_PUBLICA/24 dev eth0 src $IP_PUBLICA table t0 

# Borramos las reglas que existan  sobre estas reglas.
# ...
# ip rule  | grep -w $TABLA_1
# ip rule  | grep -w $TABLA_2
# ...


# Aplicamos reglas 
ip rule add from $IP_PUBLICA table t0
ip rule add from $IP_INTERNA table t1
#aplicamos fordward 
echo "1" > /proc/sys/net/ipv4/ip_forward

# comenzamos con ip publica """la lanzamos siempre
# ip route add default via $GATEWAY  dev eth0 table t2


# Al finalizar
#ip route flush cache












