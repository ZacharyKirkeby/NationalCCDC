#!/bin/bash
# CentOS E-Com iptables rules
# Supports HTTP, ICMP in
# Supports DNS, HTTP, HTTPS, ICMP, MySQL, NTP, Splunk out

# Variables
AD="172.20.242.200"
External="172.25.22.0/24"
Inside="172.20.240.0/22"
MySQL="172.20.240.20"
Splunk="172.20.241.20"
Win10="172.31.2.5"

# Reset and disable IPv6
ip6tables -t nat -F
ip6tables -t mangle -F
ip6tables -F
ip6tables -X
ip6tables -Z
ip6tables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
ip6tables -P INPUT DROP
ip6tables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
ip6tables -A OUTPUT -o lo -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
ip6tables -P OUTPUT DROP
ip6tables -P FORWARD DROP
ip6tables-save

# Reset IPv4
iptables -t nat -F
iptables -t mangle -F
iptables -F
iptables -X
iptables -Z
iptables -P FORWARD DROP

# IPv4 inbound
iptables -A INPUT -p tcp ! --syn -m state --state NEW -j DROP
iptables -A INPUT -p tcp --tcp-flags ALL ALL -j DROP
iptables -A INPUT -p tcp --tcp-flags ALL NONE -j DROP
iptables -A INPUT -f -j DROP
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
#iptables -A INPUT -m state --state NEW -m limit --limit 20/second --limit-burst 5 -j ACCEPT
iptables -A INPUT -p tcp ! -s "$Inside" --dport 80 -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -p icmp -s "$Inside" --icmp-type echo-reply -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
iptables -P INPUT DROP

# IPv4 outbound
iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A OUTPUT -o lo -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
iptables -A OUTPUT -p tcp -d "$Splunk" --dport 9997 -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
iptables -A OUTPUT -p udp --dport 53 -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
iptables -A OUTPUT -p tcp -d "$MySQL" --dport 3306 -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A OUTPUT -p tcp -d "$Splunk" --dport 8089 -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
iptables -A OUTPUT -p udp -d "$AD" --dport 123 -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
iptables -A OUTPUT -p icmp --icmp-type echo-request -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
iptables -A OUTPUT -d "$Inside" -j DROP
iptables -A OUTPUT -d "$External" -j DROP
iptables -A OUTPUT -d "$Win10" -j DROP
iptables -A OUTPUT -p tcp --dport 80 -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
iptables -A OUTPUT -p tcp --dport 443 -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
iptables -P OUTPUT DROP
iptables-save
