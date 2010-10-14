############################################
# This file is generated via a script
# 
# http://github.com/ghoneycutt/buildiptables
#
# Do *NOT* edit manually
############################################

# Show commands as they are executed
set -x

# Set Variables
IPTABLES="/sbin/iptables"

# === defines ===
# corp office
CORP_OFFICE="1.2.3.136/29"

# private network 
PRIV_NET="10.0.0.0/24"

# hosts @ garretthoneycutt.com
WWW1="192.168.1.2"
DB1="192.168.1.3"

# aliased interfaces on www1
SITE_FOO="192.168.1.4"
SITE_BAR="192.168.1.5"

# Home IP
YOUR_HOME="1.2.3.4"

# === generic ===
# zero counters, flush chains, and delete chains
$IPTABLES -Z
$IPTABLES -F
$IPTABLES -X

# Default Deny
$IPTABLES -P INPUT DROP
$IPTABLES -P OUTPUT DROP
$IPTABLES -P FORWARD DROP

# Allow all loopback traffic
$IPTABLES -A INPUT -p ALL -i lo -j ACCEPT
$IPTABLES -A OUTPUT -p ALL -o lo -j ACCEPT

# Keep state on all inbound traffic
$IPTABLES -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT

# === generic-eth0 ===
# Allow new outbound connections on eth0 and keep state
$IPTABLES -A OUTPUT -o eth0 -m state --state NEW,RELATED,ESTABLISHED -j ACCEPT

# Allow icmp echo request on eth0
$IPTABLES -A INPUT -i eth0 -p icmp --icmp-type echo-request -j ACCEPT

# === generic-eth1 ===
# Allow new outbound connections on eth1 and keep state
$IPTABLES -A OUTPUT -o eth1 -m state --state NEW,RELATED,ESTABLISHED -j ACCEPT

# Allow icmp echo request on eth1
$IPTABLES -A INPUT -i eth1 -p icmp --icmp-type echo-request -j ACCEPT

# === ssh-all ===
$IPTABLES -A INPUT -p tcp --dport 22 -j ACCEPT

# === tftp-all ===
$IPTABLES -A INPUT -p tcp --dport 69 -j ACCEPT
$IPTABLES -A INPUT -p udp --dport 69 -j ACCEPT

# === log-dropped-connections ===
$IPTABLES -A INPUT -p tcp -m state --state NEW -j LOG --log-level INFO --log-prefix "DROPPED TCP CONN:"
$IPTABLES -A INPUT -p udp -j LOG --log-level INFO --log-prefix "DROPPED UDP PACKET:"

