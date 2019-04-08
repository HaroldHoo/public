#### install
> yum install -y qemu-kvm virt-install libvirt

#### conf br0 network
> https://blog.csdn.net/jiuzuidongpo/article/details/44677565

#### start libvirtd
> systemctl start libvirtd && systemctl enable libvirtd

#### create disk img
> qemu-img create -f qcow2 /home/qemu/kvms/vm.img 128G

#### install new vm
> virt-install --noautoconsole --virt-type kvm --cdrom=/opt/CentOS-7-x86_64-Minimal-1810.iso --network bridge=br0 --vcpus 2 --ram 2048 --graphics vnc,listen=0.0.0.0,port=5910 --disk path=/home/qemu/kvms/vm.img --name vm

#### clone one vm
> virt-clone --original vm --name vm11 --file /home/qemu/kvms/vm11.img

#### modify vnc conf
> vim /etc/libvirt/qemu/vm11.xml (search vnc & autoport='no')  &&  virsh define /etc/libvirt/qemu/vm11.xml
