# Install Openstack with script

Yêu cầu:
 - Cài đặt trên Ubuntu Server 16.04 64bits LTS - Mỗi máy đều có 02 NIC: public + private
 - Mặc định các script đều cài OpenStack với OpenvSwitch.
 - Mô hình : Ở đây tôi thực hiện cài đặt 2 node : controller và compute1
 ![images](../images/Ubuntu16Queens.png)

 - Thực hiện cấu hình địa chỉ IP tĩnh cho các node:

```
vim /etc/network/interfaces

# loopback network interface
auto lo
iface lo inet loopback

# external network interface
auto ens3
iface ens3 inet static
address 172.16.68.238
netmask 255.255.255.0
gateway 172.16.68.1
dns-nameservers 8.8.8.8 8.8.4.4

# internal network interface
auto ens4
iface ens4 inet static
address 192.168.30.35
netmask 255.255.255.0
```

- Reset lại card mạng 

```
ifdown -a && ifup -a 
```

- Thêm repo để clone từ git về

```
echo 'Acquire::http::Proxy "http://172.16.68.18:3142";' >  /etc/apt/apt.conf
```
- tải về và cài đặt
 ``` 
apt update -y && apt dist-upgrade -y && apt install git -y
```
Tải script về git clone

```
git clone https://github.com/vinhducnguyen1708/Internship-VNPT-IT/Install-Openstack.git 
```

Cho script quyền thực thi

```
chmod +x Install-OpenStack/Ubuntu16.04-QUEENS/*.sh
```

Sửa lại thông tin trong file config.sh 

- Cài đặt trên node controller: 
```
cd Install-OpenStack/Ubuntu16.04-QUEENS/ && ./ctl-all.sh
```

- Cài đặt trên node compute1:

```
cd Install-OpenStack/Ubuntu16.04-QUEENS/ && ./com-all.sh
```
Do thiếu node Cinder để lưu trữ nên sau khi cài xong sẽ chưa có flavor để tạo tài nguyên cho máy ảo

kết quả :

![images](../images/queensu16.png)

---

## Tham khảo:

https://github.com/TrongTan124/install-OpenStack