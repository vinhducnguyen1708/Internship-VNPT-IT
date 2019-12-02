# Giới thiệu về Nova

## *Mục lục*:
- [1. Giới thiệu về Nova](#1)
- [2. Các thành phần của Nova](#2)
- [3. Workflow](#3)
- [4. Cài đặt Nova](#4)
- [Tham khảo](#tk)

---
<a name="1"></a>
## 1. Giới thiệu Nova

- Nova project có chức năng quản trị các VM, lập lịch chạy, xóa các máy ảo,..
- Nova bao gồm nhiều tiến trình trong server, mỗi tiến trình thực hiện chức năng khác nhau.
-  Nova cung cấp REST API để tương tác với user, các thành phần bên trong Nova truyền thông với nhau thông qua cơ chế truyền RPC message.
- Các API servers thực hiện các REST request, điển hình nhất là thao tác đọc, ghi vào cơ sở dữ liệu, với tùy chọn là gửi các bản tin RPC tới các dịch vụ khác của Nova. Các bản tin RPC dược thực hiện nhờ thư viện oslo.messaging - lớp trừu tượng ở phía trên của các message queue. Hầu hết các thành phần của nova có thể chạy trên nhiều server và có một trình quản lý lắng nghe các bản tin RPC. Ngoại trừ nova-compute, vì dịch vụ nova-compute được cài đặt trên các máy compute - các máy cài đặt hypervisor mà nova-compute quản lý.

<a name="2"></a>
## 2. Các dịch vụ và thành phần của Nova

### Các dịch vụ của Nova

- API server
API server là trái tim của cloud framwork, nơi thực hiện các lệnh và điều khiển hypervisor, storage và networking sẵn có đến users.
API endpoint cơ bản là HTTP web services, xử lý authentication, authorization, và các câu lệnh cơ bản và chức năng điều khiển sử dụng API interface khác nhau của Amazon, Rackspace, và các mô hình liên quan khác. Điều này cho phép sự tương thích API với nhiều bộ tool để tương tác với các vendor khác nhau. Khả năng tương thích rộng này ngăn chặn vấn đề phụ thuộc vào nhà cung cấp dịch vụ.
- Message queue
Messaging queue được xem như môi giới tương tác giữa các compute nodes, networking contrllers ( phần mềm điều khiển cơ sở hạ tầng network), API endpoints, scheduler (xác định physical hardware cần phân bố cho tài nguyên ảo) và thành phần tương tự.
Giao tiếp đến và từ could controller được xử lý bởi HTTP request thông qua nhiều API endpoints.
Một sự kiện bắt đầu với thông điệp tiêu biểu mà API server nhận được từ yêu cầu của user. API server chứng thực user và đảm bảo user được phép đưa ra lệnh đó. Nếu các object liên quan đến yêu cầu là sẵn có thì yêu cầu sẽ được chuyển đến queuing engine cho những worker liên quan. Workers liên tục lắng nghe quêu dựa trên role của họ. Khi đến lượt yêu cầu được thực hiện, worker phân conng nhiệm vụ và thực hiện yêu cầu đó. Sau khi hoàn thành, phản hồi được gửi đến queue được nhận bởi API server và chuyển tiếp tới user. Các thao tác truy vấn, nhập và xóa là cần thiết trong quá trình.
- Compute worker
Compute worker quản lý computing instance trên host machine. API truyền lệnh đến compute worker để hoàn thành các tác vụ:
    - Chạy instances
    - Xóa instances
    - Khởi động lại instances
    - Attach volumes
    - Detach volumes
    - Get console output

### Các thành phần của Nova

- nova-api service:
Tiếp nhận và trả lời các compute API call của end user. Service hỗ trợ OpenStack Compute API, Amazon EC2 API, và Admin API đặc biệt cho user thực hiện các tác vụ quản trị. Nó thực hiện một số chính sách và khởi tạo hầu hết các hoạt động điều phối, chẳng hạn như tạo máy ảo,…
- nova-api-metadata service:
Tiếp nhận yêu cầu lấy metadata từ instances. nova-api-metadata service được sử dụng khi bạn chạy chế độ mlti-host với nova-network
- nova-compute servece:
Một worker daemon quản lý vòng đời máy ảo như tạo, hủy thông qua hypervisor APIs. Ví dụ:

    - XenAPI cho XenServer/XCP
    - libvirt cho KVM hoặc QEMU
    - VMwareAPI cho VMware

Xử lý các tiến trính là khá phức tạp. Vê cơ bản, daemon chấp nhận hành động từ queue và thực hiện một loạt các lệnh hệ thống như khởi tạo một KVM instance và updating trạng thái của nó trong databases.
- nova-placement-api service: Thay thế cho nova-scheduler dùng để lập lịch 
- nova-scheduler service:
Xác virtual machine instance được yêu cầu từ queue sẽ đặt tại compute server nào.
- nova-conductor module:
Trung gian tương tác giữa nova-compute service và databases. Nó loại bỏ truy cập trực tiếp vào cloud databases được thực hiện vởi nova-compute service nhằm mục đích bảo mật, tránh trường hợp máy ảo bị xóa mà không có chủ ý của người dùng.

- nova-consoleauth daemon:
Ủy quyền token cho user mà console proxies cung cấp. Dịch vụ này phải chạy với console proxies để làm việc. Nhìn nova-novncproxy và nova-xvpvncproxy.
- nova-novncproxy daemon:
Cung cấp proxy cho việc truy cập instance đang chạy thông kết nối VNC. Hỗ trợ browser dựa trên novnc clients.

- nova-xvpvncproxy daemon: Cung cấp proxy cho việc truy cập instance đang chạy thông qua kết nối VNC. Hỗ trợ OpenStack-specific Java client.
- The queue:
Một trung tâm trung chuẩn các thông điệp giữa các daemons. Thường sử dụng RabbitMQ, cũng có thể thực hiện với một AMQP message queue khác là ZeroMQ.
- SQL database:
Lưu trữ hầu hết các trạng thái tại buil-time và run-time của cloud infrastructure, bao gồm:

    - Các loại instance đang có sẵn
    - Instances đang sử dụng
    - Networks có sẵn
    - Projects

Về mặt lý thuyết, OpenStack Compute có thể hỗ trợ bất kỳ database nào mà SQLAlchemy hỗ trợ. Database chung là SQLite3 cho công việc kiểm tra và phát triển : MSQL, MariaDB và PostgreSQL.
- Nova cell: Phân chia tài nguyên.
<a name="3"></a>
## 3. Workflow for provisioning Instance

![images](Images/nova1.png)

- Bước 1: Từ Dashboard hoặc CLI, nhập thông tin chứng thực (ví dụ: user name và password) và thực hiện lời gọi REST tới Keystone để xác thực
- Bước 2: Keystone xác thực thông tin người dùng và tạo ra một token xác thực gửi trở lại cho người dùng, mục đích là để xác thực trong các bản tin request tới các dịch vụ khác thông qua REST
- Bước 3: Gửi request khởi tạo máy ảo vào API
- Bước 4: Nova API sẽ xác thực lại user có quyền tạo VM không
- Bước 5: Keystone xác nhận yêu cầu xác thực với nova-api
- Bước 6: Ghi DB
- Bước 7: Xác nhận ghi DB thành công 
- Bước 8: Gửi yêu cầu khởi tạo VM vào Queue
- Bước 9: Nova scheduler sẽ nhận message từ Queue để lập lịch
- Bước 10: Nova scheduler gửi message xác nhận với DB các thông tin về khởi tạo VM đã được xử lý hay chưa
- Bước 11: DB xác nhận thông tin với Nova scheduler
- Bước 12: Sau khi tìm được node phù hợp thì sẽ gửi message vào Queue.
- Bước 13: Nova compute nhận được request từ Nova sche
- Bước 14: nova-compute gửi rpc.call request tới nova-conductor để lấy thông tin như host ID và flavor(thông tin về RAM, CPU, disk) (chú ý, nova-compute lấy các thông tin này từ database thông qua nova-conductor vì lý do bảo mật, tránh trường hợp nova-compute mang theo yêu cầu bất hợp lệ tới instance entry trong database)
- Bước 15: Xác nhận thông tin với nova-scheduler
- Bước 16: Nova-conductor lấy request từ Queue
- Bước 17: Nova-database trả lại thông tin của máy ảo mới cho nova-conductor, nova condutor gửi thông tin máy ảo vào Queue.
- Bước 18: nova-compute lấy thông tin máy ảo từ Queue
- Bước 19: nova-compute thực hiện lời gọi REST bằng việc gửi token xác thực tới glance-api để lấy Image URI với Image ID và upload image từ image storage.
- Bước 20: glance-api xác thực auth-token với keystone
- Bước 21: nova-compute lấy metadata của image(image type, size, ...)
- Bước 22: nova-compute thực hiện REST-call mang theo auth-token tới Network API để xin cấp phát IP và cấu hình mạng cho máy ảo
- Bước 23: quantum-server (neutron server) xác thực auth-token với keystone
- Bước 24: nova-compute lấy thông tin về network
- Bước 25: nova-compute thực hiện Rest call mang theo auth-token tới Volume API để yêu cầu volumes gắn vào máy ảo
- Bước 26: cinder-api xác thực auth-token với keystone
- Bước 27: nova-compute lấy thông tin block storage cấp cho máy ảo
- Bước 28: nova-compute tạo ra dữ liệu cho hypervisor driver và thực thi yêu cầu tạo máy ảo trên Hypervisor (thông qua libvirt hoặc api - các thư viện tương tác với hypervisor) bằng các tạo ra một file .xml với đầy đủ các thông tin 

<a name="4"></a>
## 4. Cài đặt Nova

<a name="4.1"></a>
### 1.File /etc/nova/nova.conf trên node controller


- Tạo database và endpoint cho nova
Đăng nhập vào database với quyền root
```
 mysql -uroot -p<Pass_DB>
```
- Tạo database
```
 CREATE DATABASE nova_api;
 CREATE DATABASE nova;

 GRANT ALL PRIVILEGES ON nova_api.* TO 'nova'@'localhost' IDENTIFIED BY 'Welcome123';
 GRANT ALL PRIVILEGES ON nova_api.* TO 'nova'@'%' IDENTIFIED BY 'Welcome123';
 GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'localhost' IDENTIFIED BY 'Welcome123';
 GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'%' IDENTIFIED BY 'Welcome123';

 FLUSH PRIVILEGES;

 exit;
 ```
- Khai báo biến môi trường
```
 source admin-openrc
```
- Tạo user, phân quyền và tạo endpoint cho dịch vụ nova

Tạo user có tên là nova 

``` 
openstack user create nova --domain default --password Welcome123
```
- Phân quyền cho tài khoản nova
 ```
 openstack role add --project service --user nova admin
```
- Kiểm chứng lại xem tài khoản nova đã có quyền admin hay chưa bằng lệnh dưới

```
openstack role list --user nova --project service
```
- Tạo service có tên là nova 
```
 openstack service create --name nova --description "OpenStack Compute" compute
```
- Tạo endpoint 
```
openstack endpoint create --region RegionOne compute public http://controller:8774/v2.1/%\(tenant_id\)s

openstack endpoint create --region RegionOne compute internal http://controller:8774/v2.1/%\(tenant_id\)s

openstack endpoint create --region RegionOne compute admin http://controller:8774/v2.1/%\(tenant_id\)s
```
- Cài đặt các gói cho nova và cấu hình
```
 apt-get -y install nova-api nova-cert nova-conductor nova-consoleauth nova-novncproxy nova-scheduler
 ```
- Sao lưu file /etc/nova/nova.conf trước khi cấu hình
```
 cp /etc/nova/nova.conf /etc/nova/nova.conf.orig
```
- Sửa file config  `/etc/nova/nova.conf`

- Trong `[api_database]` và `[database]` sections, cấu hình truy cập database:  
```

[api_database]
# ...
connection = mysql+pymysql://nova:NOVA_DBPASS@controller/nova_api

[database]
# ...
connection = mysql+pymysql://nova:NOVA_DBPASS@controller/nova
```

Thay  `NOVA_DBPASS` với mật khẩu bạn chọn cho Compute databases.  

- Trong `[DEFAULT]` section, cấu hình truy cập RabbitMQ message queue:  
```
[DEFAULT]
# ...
rpc_backend = rabbit
auth_strategy = keystone
rootwrap_config = /etc/nova/rootwrap.conf
transport_url = rabbit://openstack:RABBIT_PASS@controller
```

Thay `RABBIT_PASS` bằng mật khẩu bạn cho account openstack trong RabbitMQ.  

- Trong `[api]` và `[keystone_authtoken]` sections, cấu hình truy cập Identity service:  
```
[api]
# ...
auth_strategy = keystone

[keystone_authtoken]
# ...
auth_uri = http://controller:5000
auth_url = http://controller:35357
memcached_servers = controller:11211
auth_type = password
project_domain_name = default
user_domain_name = default
project_name = service
username = nova
password = NOVA_PASS
```

Thay `NOVA_PASS` bằng mật khẩu bạn cho nova user trong Identity service.  

>Chú ý: 
Comment hoặc xóa bất kỳ options nào khác trong `[keystone_authtoken]` section.

- Trong `[DEFAULT]` section, cấu hình `my_ip` option sử dụng để management interface IP address của node controller:  
```
[DEFAULT]
# ...
my_ip = 10.0.0.11
```

Thay `10.0.0.11` với địa chỉ IP dùng để quản lý của node controller.  

- Trong `[DEFAULT]` section, enable hỗ trợ Networking service:  
```
[DEFAULT]
# ...
use_neutron = True
firewall_driver = nova.virt.firewall.NoopFirewallDriver
```

>Note:  
Mặc định, Compute sử dụng internal firewall driver. Từ khi Networking service bao gồm firewall driver, bạn phải disable Compute firewall driver bằng cách sử dụng `nova.virt.firewall.NoopFirewallDriver` firewall driver.

- Trong `[vnc]` section, cấu hình VNC proxy để sử dụng địa chỉ IP interface quản lý của node controller:  
```
[vnc]
enabled = true
# ...
vncserver_listen = $my_ip
vncserver_proxyclient_address = $my_ip
```

- Trong `[glance]` section, cấu hình để xác định vị trí của Image service API:  
```
[glance]
# ...
api_servers = http://controller:9292
```

- Trong `[oslo_concurrency]` section, cấu hình lock path:  
```
[oslo_concurrency]
# ...
lock_path = /var/lib/nova/tmp
```

- Khai báo trong section [oslo_messaging_rabbit] các dòng dưới. Do section [oslo_messaging_rabbit] chưa có nên ta khai báo thêm.
```
[oslo_messaging_rabbit]
rabbit_host = controller
rabbit_userid = openstack
rabbit_password = PASS_
```

- Do bug, xóa bỏ `log_dir` option từ `[DEFAULT]` section.  

- Trong `[placement]` section, cấu hình Placement API:  
```
[placement]
# ...
os_region_name = RegionOne
project_domain_name = Default
project_name = service
auth_type = password
user_domain_name = Default
auth_url = http://controller:35357/v3
username = placement
password = PLACEMENT_PASS
```

Thay `PLACEMENT_PASS` với password bạn cho cho placement user trong Identity service. Comment bất kỳ option nào trong `[placement]` section.

- Khai báo thêm section mới [neutron] để nova làm việc với neutron
```
 [neutron]
 url = http://controller:9696
 auth_url = http://controller:35357
 auth_type = password
 project_domain_name = default
 user_domain_name = default
 region_name = RegionOne
 project_name = service
 username = neutron
 password = NEUTRON_PASS

 service_metadata_proxy = True
 metadata_proxy_shared_secret = NEUTRON_PASS
```

- Tạo database cho nova
```
su -s /bin/sh -c "nova-manage api_db sync" nova
su -s /bin/sh -c "nova-manage db sync" nova
```

- Khởi động lại các dịch vụ của nova sau khi cài đặt & cấu hình nova
```
 service nova-api restart
 service nova-cert restart
 service nova-consoleauth restart
 service nova-scheduler restart
 service nova-conductor restart
 service nova-novncproxy restart
 ```
- Xóa database mặc định của Nova
```
 rm -f /var/lib/nova/nova.sqlite
```

<a name="4.2"></a>
### 2.File /etc/nova/nova.conf trên node compute
- Trong `[DEFAULT]` section, cấu hình truy cập RabbitMQ message queue :  
```
[DEFAULT]
# ...
transport_url = rabbit://openstack:RABBIT_PASS@controller
```

Thay thế `RABBIT_PASS` với password bạn chọn cho account openstack trong RabbitMQ.  

\- Trong `[api]` và `[keystone_authtoken]` sections, cấu hình truy cập Identity service:  
```
[api]
# ...
auth_strategy = keystone

[keystone_authtoken]
# ...
auth_uri = http://controller:5000
# Các bản sau bỏ port 35357
auth_url = http://controller:35357
memcached_servers = controller:11211
auth_type = password
project_domain_name = default
user_domain_name = default
project_name = service
username = nova
password = NOVA_PASS
```

Thay thế `NOVA_PASS` với password bạn chọn cho nova user trong Identity service.  

>Note
Comment hoặc xóa bất kỳ tùy chọn nào trong [keystone_authtoken] section.  

- Trong `[DEFAULT]` section, cấu hình `my_ip` option:  
```
[DEFAULT]
# ...
rpc_backend = rabbit
auth_strategy = keystone
rootwrap_config = /etc/nova/rootwrap.conf
my_ip = MANAGEMENT_INTERFACE_IP_ADDRESS
enabled_apis=osapi_compute,metadata
```

Thay thế `MANAGEMENT_INTERFACE_IP_ADDRESS` với địa chỉ IP của management network interface trên node compute.  

- Trong `[DEFAULT]` section, enable support cho Networking service:  
```
[DEFAULT]
# ...
rpc_backend = rabbit
auth_strategy = keystone
use_neutron = True
firewall_driver = nova.virt.firewall.NoopFirewallDriver
```

>Note:  
Mặc định, Compute sử dụng internal firewall driver. Từ khi Networking service bao gồm firewall driver, bạn phải disable Compute firewall driver bằng cách sử dụng `nova.virt.firewall.NoopFirewallDriver` firewall driver.

- Trong `[vnc]` section, enable và cấu hình truy cập remote console:  
```
[vnc]
# ...
enabled = True
# Server lằng nghe tất cả các địa chỉ IP hoặc IP MGNT của node Controller
vncserver_listen = 0.0.0.0
vncserver_proxyclient_address = $my_ip
novncproxy_base_url = http://controller:6080/vnc_auto.html
```

- Trong `[glance]` section, cấu hình để xác định vị trí của Image service API:  
```
[glance]
# ...
api_servers = http://controller:9292
```

- Trong `[oslo_concurrency]` section, cấu hình lock path:  
```
[oslo_concurrency]
# ...
lock_path = /var/lib/nova/tmp
```

- Do bug, xóa bỏ `log_dir` option từ `[DEFAULT]` section.  

- Trong `[placement]` section, cấu hình Placement API:  
```
[placement]
# ...
os_region_name = RegionOne
project_domain_name = Default
project_name = service
auth_type = password
user_domain_name = Default
auth_url = http://controller:35357/v3
username = placement
password = PLACEMENT_PASS
```

Thay `PLACEMENT_PASS` với password bạn cho cho placement user trong Identity service. Comment bất kỳ option nào trong `[placement]` section.

- Khai báo thêm section [neutron] và các dòng dưới.
```
[neutron]
url = http://controller:9696
auth_url = http://controller:35357
auth_type = password
project_domain_name = default
user_domain_name = default
region_name = RegionOne
project_name = service
username = neutron
password = NEUTRON_PASS
```
- Khởi động lại dịch vụ nova-compute
```
 service nova-compute restart
```
- Xóa database mặc định của hệ thống tạo ra
```
 rm -f /var/lib/nova/nova.sqlite
```
Dùng lệnh vi admin-openrc chứa nội dung dưới
```
 export OS_PROJECT_DOMAIN_NAME=default
 export OS_USER_DOMAIN_NAME=default
 export OS_PROJECT_NAME=admin
 export OS_USERNAME=admin
 export OS_PASSWORD=Welcome123
 export OS_AUTH_URL=http://controller:35357/v3
 export OS_IDENTITY_API_VERSION=3
 export OS_IMAGE_API_VERSION=2
 ```
- Thực thi file admin-openrc
```
 source admin-openrc
```
- Kiểm tra lại các dịch vụ của nova đã được cài đặt thành công hay chưa
```
 openstack compute service list
 ```