# Cài đặt KVM sử dụng OvS

## Chuẩn bị môi trường

- Host:  Ubuntu 16.04 
- 2 card mạng ens3(), ens4(cung cấp network cho Vm)

## Các bước cài đặt trên Host


### 1.  Cài đặt KVM

```
PACKAGES="qemu-kvm libvirt-bin bridge-utils virtinst"
sudo apt-get update
sudo apt-get dist-upgrade -qy

sudo apt-get install -qy ${PACKAGES}
 ```

- Gán quyển cho user libvirtd và kvm

```
sudo adduser `id -un` libvirtd
 sudo adduser `id -un` kvm
 ```
 - Khi cài đặt KVM sẽ mặc định sử dụng Linux Bridge nên sẽ sinh ra `virbr0`
```
brctl show
```
- Xóa bridge do Linux Bridge tạo ra

```
sudo virsh net-destroy default 
sudo virsh net-autostart --disable default
```

- Kiểm tra lại

### 2. Cài đặt OpenvSwitch

- Cài đặt OpenvSwitch

```
 sudo apt-get install -qy openvswitch-switch openvswitch-common 
 sudo service openvswitch-switch start
```

- Cấu hình hỗ trợ OVS
```
 sudo echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
 sudo sysctl -p /etc/sysctl.conf
 ```
 - Thực hiện tạo Bridge OvS và gán NIC vào OvS

 ```
 ovs-vsctl add-br br0
 ovs-vsctl add-port br0 ens4
 ```
 - Kiểm tra bằng lệnh
 ```
 ovs-vsctl show
 ```

 ### 3. Cấu hình network cho máy chủ

 - Thêm dòng này trong file `/etc/network/interfaces`
 ```
auto br0
iface br0 inet dhcp
 ```

 - Restart lại card mạng của HOST
 ```
 ifdown --force -a && ifup --force -a
 ```

### Cài đặt với KVM
- Cài đặt `virt-manager`
```
apt-get install -y virt-manager xorg openbox
```

- kiểm tra các network trong KVM bằng lệnh 
```
 virsh net-list --all
 ```
- Tạo file cho libvirt network để gán OVs vào KVm

(Tạo file ovsnet.xml)

```
<network>
   <name>br0</name>
   <forward mode='bridge'/>
   <bridge name='br0'/>
   <virtualport type='openvswitch'/>
 </network>
 ```

 - Gán ovs vào KVM
```
 virsh net-define ovsnet.xml
 virsh net-start br0
 virsh net-autostart br0
```

- Kiểm tra lại 


--- Tham khảo
https://github.com/hocchudong/KVM-QEMU/blob/master/docs/catdat-kvm-openvswitch-ubuntu16.04.md