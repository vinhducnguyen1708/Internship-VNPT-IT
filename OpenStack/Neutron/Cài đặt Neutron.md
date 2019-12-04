# Cấu hình neutron


## 1. Trên node Controller

### 1.1 Tạo database cho neutron
- Đăng nhập vào database 
```
mysql -u root -p<password>
```
- Tạo database neutron
```
CREATE DATABASE neutron;
```
- Cấp quyền truy nhập vào neutron database
```
GRANT ALL PRIVILEGES ON neutron.* TO 'neutron'@'localhost' IDENTIFIED BY '<password>';
GRANT ALL PRIVILEGES ON neutron.* TO 'neutron'@'%' IDENTIFIED BY '<password>';

FLUSH PRIVILEGES;
exit;
```

### 1.2 Tạo user, dịch vụ và các endpoint API cho neutron

- Khai báo biến môi trường
```
source admin-openrc
```
- Tạo user neutron
```
openstack user create --domain default --password <password> neutron
```
- Gán role admin cho tài khoản neutron
```
openstack role add --project service --user neutron admin
```
- Tạo dịch vụ tên là neutron
```
 openstack service create --name neutron \
  --description "OpenStack Networking" network
```
- Tạo endpoint tên cho neutron
```
openstack endpoint create --region RegionOne \
network public http://controller:9696

openstack endpoint create --region RegionOne \
network internal http://controller:9696

openstack endpoint create --region RegionOne \
network admin http://controller:9696
```

### 1.3 Cài đặt và cấu hình neutron
- Cài đặt và cấu hình cho dịch vụ neutron. Trong hướng dẫn này lựa chọn cơ chế self-service netwok

- Cài đặt các thành phần cho neutron

```
apt install neutron-server neutron-plugin-ml2 \ 
neutron-openvswitch-agent neutron-dhcp-agent \ 
neutron-metadata-agent -y
```
- Sao lưu file cấu hình gốc của neutron

```
cp /etc/neutron/neutron.conf  /etc/neutron/neutron.conf.orig
```

- Cấu hình cho dịch vụ neutron. Dùng vi chỉnh sửa file /etc/neutron/neutron.conf

    - section [database] để duy nhất:
    ```
    connection mysql+pymysql://neutron:<password>@controller/neutron
    ```
    - Trong section [DEFAULT]:
    ```
    core_plugin = ml2
    service_plugins = router
    transport_url = rabbit://openstack:<password>@controller
    auth_strategy = keystone
    notify_nova_on_port_status_changes = true
    notify_nova_on_port_data_changes = true
    ```
    - trong section [keystone_authtoken]
    ```
    auth_uri = http://controller:5000
    auth_url = http://controller:5000
    memcached_servers = controller:11211
    auth_type = password
    project_domain_name = default
    user_domain_name = default
    project_name = service
    username = neutron
    password = <password_neutron>
    ```
    - Trong section [nova]
    ```
    auth_url = http://controller:5000
    auth_type = password
    project_domain_name = default
    user_domain_name = default
    region_name = RegionOne
    project_name = service
    username = nova
    password = <password_nova>
    ```

- Cài đặt và cấu hình ML2

    - Sao lưu file `/etc/neutron/plugins/ml2/ml2_conf.ini`
    ```
    cp /etc/neutron/plugins/ml2/ml2_conf.ini /etc/neutron/plugins/ml2/ml2_conf.ini.orig
    ```

    - Trong section [ml2]:
    ```
    type_drivers = flat,vlan, vxlan
    tenant_network_types = vxlan
	mechanism_drivers = openvswitch
	extension_drivers = port_security
    ```
    - Trong section [ml2_type_flat ]
    ```
    flat_networks provider
    ```

    - Trong section [ml2_type_vlan]
    ```
	network_vlan_ranges = provider
    ```
    -  Trong section [ml2_type_vxlan]
    ```
    vni_ranges = 1:1000
    ```
    - Trong section [securitygroup]
    ```
    enable_ipset = true
    ```

- Cấu hình OVS

    - Sao lưu file `/etc/neutron/plugins/ml2/linuxbridge_agent.ini`
    ```
    cp /etc/neutron/plugins/ml2/linuxbridge_agent.ini  /etc/neutron/plugins/ml2/openvswitch_agent.int.orig
    ```
    - Trong section [ovs]
    ```
    physical_interface_mappings = provider:br-provider
    ```
    - Trong section [securitygroup] 
    ```
    firewall_driver = iptables_hybrid
    ```
    - Trong section [vxlan]
    ```
    enable_vxlan = true
    local_ip = <IP_local>
    l2_population = true
    ```

- Cấu hình DHCP agent

    - Sao lưu file `/etc/neutron/dhcp_agent.ini` gốc
    ```
    cp /etc/neutron/dhcp_agent.ini /etc/neutron/dhcp_agent.ini.orig
    ```
    - Trong section [DEFAULT]
    ```
    interface_driver = openvswitch
    enable_isolated_metadata = true
    force_metadata = True
    ```

- Cấu hình metadata agent
    - Sao lưu file `/etc/neutron/metadata_agent.ini`
    ```
    cp /etc/neutron/metadata_agent.ini /etc/neutron/metadata_agent.ini.orig
    ```
    - Sửa file `vi /etc/neutron/metadata_agent.ini`

    - Trong section [DEFAULT]:
    ```
    nova_metadata_ip = controller
    metadata_proxy_shared_secret = <password>
    ```
- Cấu hình   file `/etc/nova/nova.conf`

    - Trong section [neutron]: 
    ```
    url = http://controller:9696
    auth_url = http://controller:5000
    auth_type = password
    project_domain_name = default
    user_domain_name = default
    region_name = RegionOne
    project_name = service
    username = neutron
    password = <password>
    service_metadata_proxy = true
    metadata_proxy_shared_secret = <password>
     ```

     -  Đồng bộ database cho neutron
     ```
    su -s /bin/sh -c "neutron-db-manage --config-file /etc/neutron/neutron.conf \
    --config-file /etc/neutron/plugins/ml2/ml2_conf.ini upgrade head" neutron
    ```
    - Restart nova-api
    ```
    service nova-api restart
    ```
    - Restart các dịch vụ của neutron
    ```
    service neutron-server restart
    service neutron-linuxbridge-agent restart
    service neutron-dhcp-agent restart
    service neutron-metadata-agent restart
    service neutron-l3-agent restart
    ```

## 2. Trên node Compute

### 2.1 Cài đặt các thành phần

```
apt install neutron-openvswitch-agent -y
```

### 2.2 Cấu hình
- Sao lưu file `/etc/neutron/neutron.conf` trước khi cài đặt
```
cp /etc/neutron/neutron.conf /etc/neutron/neutron.conf.orig
```
- Trong [database] section
    ```
    auth_strategy = keystone
    transport_url = rabbit://openstack:<password>@controller
    ```
- Trong [keystone_authtoken] section:
```
auth_uri = http://controller:5000
auth_url = http://controller:5000
memcached_servers = controller:11211
auth_type = password
project_domain_name = default
user_domain_name = default
project_name = service
username = neutron
password = <password>
```

- Cấu hình OVS
    - Sao lưu file cấu hình gốc

    ``` 
    cp /etc/neutron/plugins/ml2/openvswitch_agent.ini /etc/neutron/plugins/ml2/openvswitch_agent.ini.orig
    ```
    - Trong [ovs] section:

    ```
    bridge_mappings provider:br-provider
    ```

    - Trong [securitygroup] section: 
    ```
    firewall_driver = iptables_hybrid
    ```



 - Cấu hình dịch vụ compute sử dụng dịch vụ network

    - Sửa file `/etc/nova/nova.conf`

    - Trong [neutron] section:
    ```
    url = http://controller:9696
    auth_url = http://controller:5000
    auth_type = password
    project_domain_name = default
    user_domain_name = default
    region_name = RegionOne
    project_name = service
    username = neutron
    password = <password>
    ```

    - Restart nova-compute
    ```
    service nova-compute restart
    ```

    - Restart ovs:
    ```
    service neutron-openvswitch-agent restart
    ```


> Ở đây dùng Open vSwitch làm Mechanism Drivers nên cần cấu hình OVS