#!/bin/bash
echo "-------------------------------------------------------"
myUser=${USER}
myHost=${HOSTNAME}
echo $myUser@$myHost
distro=$(cat /etc/redhat-release)
echo "OS: $distro"
echo "Kernel: $(uname -m ) $(uname -sr)"
cpu_py_num=$(grep "physical id" /proc/cpuinfo | sort  | uniq | wc -l)
cpu_vt_num=$(grep "physical id" /proc/cpuinfo | wc -l)
cpu_model=$(grep "model name" /proc/cpuinfo | sort | uniq | awk -F : '{print $2}')
echo CPU: $cpu_model \* $cpu_py_num
echo CPU_CORES: $cpu_vt_num
echo "-------------------------------------------------------"
df -h
echo "-------------------------------------------------------"
free -h
echo "-------------------------------------------------------"
who -b
w
echo "-------------------------------------------------------"
lastlog | grep -v "\*\*"
echo "-------------------------------------------------------"
ss -s | grep ports
echo "-------------------------------------------------------"
ss -ntl
echo "-------------------------------------------------------"
