#### install
> sudo virt-install --noautoconsole --virt-type kvm --cdrom=/opt/CentOS-7-x86_64-Minimal-1810.iso --network bridge=br0 --vcpus 2 --ram 2048 --graphics vnc,listen=0.0.0.0,port=5911 --disk path=/home/qemu/kvms/vm11.img --name vm11
