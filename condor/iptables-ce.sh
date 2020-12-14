#!/bin/bash
#Скрипт с правилами iptables применяемый на обычной рабочей станции
echo "Loading iptables rules"

NET_JINR="159.93.0.0/16"
NET_221="10.93.220.0/22" # Сеть серых ip для кластера grid nova work-nodes
NET_NBN="79.111.0.0/16"  # Сеть провайдера
NET_220_priv="10.220.16.0/22" # Сеть серых ip для кластера grid nova work-nodes


IFACE="eth0"


# В этот раз форвардить придется. Т.к хочу передать ftp соединение на другой сервер
#It's not a router so don't forward
echo 1 > /proc/sys/net/ipv4/ip_forward


iptables -F
iptables -X
iptables -t nat -F
iptables -t nat -X
iptables -t mangle -F
iptables -t mangle -X
iptables -t filter -F
iptables -t filter -X

iptables -F -t raw

iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT

echo "loopback allowed..."
iptables -A INPUT -i lo -j ACCEPT # А на выход вообще всё везде открыто

#Table mangle

iptables -t mangle -A PREROUTING -j ACCEPT
iptables -t mangle -A INPUT      -j ACCEPT
iptables -t mangle -A FORWARD    -j ACCEPT
iptables -t mangle -A OUTPUT     -j ACCEPT

iptables -t mangle -A POSTROUTING -j ACCEPT


#Table filter


iptables -t filter -A INPUT -p tcp -m tcp --dport 22 -m comment --comment "Allow SSH" -j ACCEPT
#iptables -t filter -A INPUT -p tcp -m tcp --dport 21 -m comment --comment "Allow ftp" -j ACCEPT
iptables -t filter -A INPUT -s $NET_JINR -j ACCEPT
iptables -t filter -A INPUT -s $NET_221  -m comment --comment "Allow local 10.93.221.xxx cluster, though it's already fine" -j ACCEPT

iptables -t filter -A INPUT -s $NET_220_priv  -m comment --comment "Allow local 10.220.16.0/22 cluster, though it's already fine" -j ACCEPT


iptables -t filter -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT

#iptables -t filter -A INPUT -p tcp --dport 9619:9620 -m comment --comment "HTCondor-CE" -j ACCEPT
iptables -t filter -A INPUT -p tcp -m tcp --dport 9619 -m comment --comment "HTCondor-CE" -j ACCEPT

iptables -t filter -A INPUT -p icmp -m comment --comment "Allow pings" -j ACCEPT
iptables -t filter -A INPUT -p udp -m udp --dport 137:138 -m comment --comment "Silent drop of WIN SCAN" -j DROP


#Table nat
iptables -t nat -A PREROUTING  -j ACCEPT
iptables -t nat -A POSTROUTING -j ACCEPT
iptables -t nat -A OUTPUT      -j ACCEPT

# port forwarding
#iptables -t nat -A PREROUTING -i venet0:0 -p tcp -d 159.93.221.119 --dport 21 -j DNAT --to-destination 10.93.221.141
#iptables -t nat -A PREROUTING -i venet0:0 -p tcp --sport 21 -s $TargetIP -d 159.93.221.119 -j DNAT --to-destination $FtpClient

#iptables -t nat -A PREROUTING -i $IFACE -p tcp -d 159.93.221.119 --dport 443 -j DNAT --to-destination 10.93.221.8
#iptables -t nat -A PREROUTING -i $IFACE -p tcp -d 159.93.221.119 --dport 8443 -j DNAT --to-destination 10.93.221.8

#iptables -t nat -A POSTROUTING -j MASQUERADE
#iptables -t nat -A POSTROUTING -o venet0:0  -p tcp --dst 10.93.221.141 --dport 21 -j SNAT --to-source 159.93.221.119
#iptables -t nat -A POSTROUTING -o venet0:0  -p tcp --dport 21 --dst 79.111.58.71 -j SNAT --to-source 159.93.221.119
#iptables -t nat -A POSTROUTING -p tcp -s $TargetIP --dst $FtpClient -j SNAT --to-source 159.93.221.119



#iptables -t nat -A OUTPUT --dst $TargetIP -p tcp --dport 21 -j SNAT --to-source $FtpClient
#iptables -t nat -A OUTPUT -s $TargetIP --dst 159.93.221.119 -p tcp --dport 21 -j DNAT --to-destination $FtpClient


#Table nat
#iptables -t nat -A PREROUTING  -j ACCEPT
#iptables -t nat -A POSTROUTING -j ACCEPT
#iptables -t nat -A OUTPUT      -j ACCEPT




#iptables -A FORWARD  -d $TargetIP -p tcp -m tcp --dport 21 -j ACCEPT



#iptables -t nat -A POSTROUTING -o venet0:0 -p tcp --dport 21 -s 10.93.221.141 -j SNAT --to-source 159.93.221.119
#iptables -t nat -A POSTROUTING -o venet0:0 -p tcp --
# iptables -t nat -A POSTROUTING -o eth1 -p tcp --dport 80 -d 192.168.1.2 -j SNAT --to-source 192.168.1.1

#Table raw
iptables -t raw -A PREROUTING  -j ACCEPT
iptables -t raw -A OUTPUT      -j ACCEPT

