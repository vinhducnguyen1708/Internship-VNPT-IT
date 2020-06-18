# Tích hợp tính năng live-Migrate cho Openstack

## Thực hiện trên node compute

### Cấu hình service libvirtd giữa các node

#### Trên Compute1

- **Bước 1**: Thực hiện kiểm tra kết nối đến compute 2
```
virsh -c qemu+tcp://192.168.10.51/system
```

===> *KẾT QUẢ*

- Nếu kết quả này tức là thành công sẵn sàng thực hiện migrate:
```sh
[root@compute1 ~]# virsh -c qemu+tcp://192.168.10.51/system
Welcome to virsh, the virtualization interactive terminal.

Type:  'help' for help with commands
       'quit' to quit

virsh #
```
- Nếu kết quả này tức là chưa thành công tiếp tục làm các bước tiếp theo:
```sh
[root@compute1 ~]# virsh -c qemu+tcp://192.168.10.51/system
error: unable to connect to server at 'host:16509': Connection refused
error: failed to connect to the hypervisor
```

- **Bước 2**: Kiểm tra tiến trình libvirtd đang chạy trên compute
```sh
ps aux | grep libvirtd

netstat -lntp | grep libvirtd
````

===> *Kết quả*
```sh
[root@compute1 ~]# netstat -lntp | grep libvirtd

[root@compute1 ~]#



[root@compute1 ~]#  ps aux | grep libvirtd
root     13720  0.0  0.0 112812   972 pts/1    S+   08:25   0:00 grep --color=auto libvirtd
```


- **Bước 3**: Cấu hình libvirtd giao tiếp qua TCP trong file /etc/libvirt/libvirtd.conf
===> *KẾT QUẢ nội dung file cấu hình*
```sh
[root@compute1 ~]# cat /etc/libvirt/libvirtd.conf  | egrep -v "^#|^$"
listen_tls = 0
listen_tcp = 1
tcp_port = "16509"
listen_addr = "0.0.0.0"
auth_tcp = "none"
```

- **Bước 4**: Cấu hình livirtd khởi động sẽ được Listen qua TCP trong file 
===> *KẾT QUẢ nội dung file cấu hình*
```sh
[root@compute1 ~]# cat /etc/sysconfig/libvirtd | egrep -v "^#|^$"
LIBVIRTD_ARGS="--listen"
```


- **Bước 5**: Restart libvirtd
```sh
systemctl restart libvirtd
```
Kiểm tra lại kết nối như bước 1

#### Thực hiện lại các bước với các node compute còn lại

Kiểm tra lại kết nối như bước 1

### Cấu hình livirtd trong Openstack

#### Thực hiện trên tất cả các node compute

- **Bước 1:** Cấu hình trong file config của nova-compute
```sh
	crudini --set /etc/nova/nova.conf libvirt inject_partition -2
	crudini --set /etc/nova/nova.conf libvirt inject_password  false
	crudini --set /etc/nova/nova.conf libvirt live_migration_flag VIR_MIGRATE_UNDEFINE_SOURCE,VIR_MIGRATE_PEER2PEER,VIR_MIGRATE_LIVE,VIR_MIGRATE_PERSIST_DEST
	crudini --set /etc/nova/nova.conf libvirt inject_key False
	crudini --set /etc/nova/nova.conf libvirt disk_cachemodes "network=writeback"
	crudini --set /etc/nova/nova.conf libvirt hw_disk_discard  unmap 
```

- **Bước 2**: Restart các service trên node nova-compute
```sh
systemctl restart libvirtd

systemctl restart openstack-nova-compute
```


## Thực hiện trên node controller

### Thực hiện live migrate VMs

- **Bước 1**: Thực hiện show các VMs trong Openstack
```sh
openstack server list
```
===> *Kết quả*
```sh
[root@controller1 ~]# openstack server list
+--------------------------------------+--------+--------+---------------------------------+-------+--------+
| ID                                   | Name   | Status | Networks                        | Image | Flavor |
+--------------------------------------+--------+--------+---------------------------------+-------+--------+
| c46dc9b3-a3d7-4e0e-aa0c-84928a1da7ca | vinhdc | ACTIVE | service_network=192.168.178.153 |       | tiny   |
+--------------------------------------+--------+--------+---------------------------------+-------+--------+
```

- **Bước 2**: Xem thông tin của VMs
```sh
openstack server show c46dc9b3-a3d7-4e0e-aa0c-84928a1da7ca
```
===> *Kết quả*: VMS đang đứng ở node compute1.hn.vnpt

```sh
root@controller1 ~]# openstack server show c46dc9b3-a3d7-4e0e-aa0c-84928a1da7ca
+-------------------------------------+----------------------------------------------------------+
| Field                               | Value                                                    |
+-------------------------------------+----------------------------------------------------------+
| OS-DCF:diskConfig                   | AUTO                                                     |
| OS-EXT-AZ:availability_zone         | nova                                                     |
| OS-EXT-SRV-ATTR:host                | compute1.hn.vnpt                                         |
| OS-EXT-SRV-ATTR:hypervisor_hostname | compute1.hn.vnpt                                         |
| OS-EXT-SRV-ATTR:instance_name       | instance-00000004                                        |
| OS-EXT-STS:power_state              | Running                                                  |
| OS-EXT-STS:task_state               | None                                                     |
| OS-EXT-STS:vm_state                 | active                                                   |
| OS-SRV-USG:launched_at              | 2020-06-17T18:09:27.000000                               |
| OS-SRV-USG:terminated_at            | None                                                     |
| accessIPv4                          |                                                          |
| accessIPv6                          |                                                          |
| addresses                           | service_network=192.168.178.153                          |
| config_drive                        |                                                          |
| created                             | 2020-06-17T18:08:19Z                                     |
| flavor                              | tiny (8c6d7644-9440-49a5-b012-1622a6df74db)              |
| hostId                              | 56112c89d72fb16d5ffcc5b0da380f689ce404b2fdd500045a9fad74 |
| id                                  | c46dc9b3-a3d7-4e0e-aa0c-84928a1da7ca                     |
| image                               |                                                          |
| key_name                            | None                                                     |
| name                                | vinhdc                                                   |
| progress                            | 0                                                        |
| project_id                          | f26ff72965304f46a87caed4fcda4b91                         |
| properties                          |                                                          |
| security_groups                     | name='default'                                           |
| status                              | ACTIVE                                                   |
| updated                             | 2020-06-17T18:11:04Z                                     |
| user_id                             | 689e3fd8ba814b79ad5a6ee892875a6a                         |
| volumes_attached                    | id='c4e58374-e15a-4da8-9bb0-8347cf057e67'                |
+-------------------------------------+----------------------------------------------------------+
```

- **Bước 3**: Kiểm tra các node compute trong hệ thống
```sh
openstack compute service list
```

===> *Kết quả*: Sẽ chọn node `compute2.hn.vnpt` để migrate sang
```sh
[root@controller1 ~]# openstack compute service list
+----+----------------+---------------------+----------+---------+-------+----------------------------+
| ID | Binary         | Host                | Zone     | Status  | State | Updated At                 |
+----+----------------+---------------------+----------+---------+-------+----------------------------+
| 22 | nova-scheduler | controller1.hn.vnpt | internal | enabled | up    | 2020-06-18T01:50:27.000000 |
| 28 | nova-scheduler | controller2.hn.vnpt | internal | enabled | up    | 2020-06-18T01:50:27.000000 |
| 34 | nova-scheduler | controller3.hn.vnpt | internal | enabled | up    | 2020-06-18T01:50:26.000000 |
| 40 | nova-conductor | controller3.hn.vnpt | internal | enabled | up    | 2020-06-18T01:50:23.000000 |
| 43 | nova-conductor | controller1.hn.vnpt | internal | enabled | up    | 2020-06-18T01:50:26.000000 |
| 46 | nova-conductor | controller2.hn.vnpt | internal | enabled | up    | 2020-06-18T01:50:26.000000 |
| 49 | nova-compute   | compute1.hn.vnpt    | nova     | enabled | up    | 2020-06-18T01:50:25.000000 |
| 52 | nova-compute   | compute2.hn.vnpt    | nova     | enabled | up    | 2020-06-18T01:50:18.000000 |
+----+----------------+---------------------+----------+---------+-------+----------------------------+
```

- **Bước 4**: Thực hiện live-Migrate VMs 
```sh
openstack server migrate c46dc9b3-a3d7-4e0e-aa0c-84928a1da7ca --live compute2.hn.vnpt
```
===> *KẾT QUẢ*:
```sh
Kiểm tra lại thông tin VMs
openstack server show c46dc9b3-a3d7-4e0e-aa0c-84928a1da7ca
```
