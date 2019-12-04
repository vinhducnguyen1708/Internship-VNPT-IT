# Tìm hiểu về Project Neutron trong Openstack

## *Mục lục:*
- [1. Các thuật ngữ cơ bản ](#1)
    - [1.1 Router](#1.1)
    - [1.2 Firewalls](#1.2)
    - [1.3 Load balancers](#1.3)
    - [1.4 SNAT](#1.4)
    - [1.5 DNAT](#1.5)
    - [1.6 one to one NAT](#1.6)
    - [1.7 GRE](#1.7)
    - [1.8 VXLAN](#1.8)
- [2. Openstack Networking](#2)
    - [2.1 Khái niệm](#2.1)
     


<a name="1"></a>
## 1 Các thuật ngữ cơ bản
<a name="1.1"></a>
### 1.2 Router
- Router là thiết bị cho phép packet đi từ mạng lớp 3 này đến mạng lớp 3 khác. Router cho phéo giao tiếp giữa 2 node trên các mạng lớp 3 khác nhau không kết nối trực tiếp với nhau. Router hoạt động ở lớp 3 trong mô hình 3.Chúng định tuyến dựa trên địa chỉ IP đích trong packet header.

<a name="1.2"></a>
### 1.2 Firewalls
- Firewalls được sử dụng để điều khiển lưu lượng truy cập đến và đi từ máy chủ hoặc mạng. Firewall có thể là thiết bị chuyên dụng hoặc software-based filtering mechanism implemented được hiện bởi hệ điều hành. Firewall được sử dụng để hạn chế lưu lượng truy cập đến máy chủ dựa trên các rules được định nghĩa trên máy chủ. Chúng lọc packet dựa trên địa chỉ IP nguồn, địa chỉ IP đích, port number, trạng thái kết nối, etc. Cacs hệ điều hành Linux thực hiện tường lửa thông qua iptables.

<a name="1.3"></a>
### 1.3 Load balancers
- Load balancers có thể là phần mềm hoặc thiết bị phần cứng cho phép lưu lượng truy cập được phần phối đồng đều trên nhiều server. Bằng cách phần phối lưu lượng truy cập trên nhiều server, nó tránh quá tải cho 1 server.

<a name="1.4"></a>
### 1.4 SNAT

- Source Network Translation (SNAT) , NAT router sửa đổi địa chỉ IP của bên gửi trong gói tin IP. SNAT thường được sử dụng để cho phép các địa chỉ private kết nối với servers trên public Internet.
- RFC 1918 quy định 3 dỉa subnets sau là địa chỉ private:

    - 10.0.0.0 - 10.255.255.255

    - 172.16.0.0 - 172.31.255.255

    - 192.168.0.0 - 192.168.255.255

- OpenStack sử dụng SNAT để cho phép các ứng dụng chạy bên trong instances có thể kết nối public Internet.

<a name="1.5"></a>
### 1.5 DNAT
- Destination Network Address Translation (DNAT), NAT router thay dổi địa chỉ IP đích trong header gói tin IP.
- OpenStack sử dụng DNAT để định tuyến gói tin từ instances đến OpenStack metadata service.

<a name="1.6"></a>
1.6 one to one NAT
- Trong one-to-one NAT, NAT router duy trù mapping giữa địa chỉ IP private và địa chỉ IP public. OpenStack sử dụng one-to-one NAT để thực hiện địa chỉ IP floating.




<a name="1.7"></a>
### 1.7 GRE 
- Generic routing encapsulation : (GRE) là giao thức chạy trên IP và được sử dụng để tạo kết nối point-to-point bảo mật.Một GRE Tunnel được sử dụng khi các gói dữ liệu cần được gửi giữa các mạng khác nhau thông qua internet. Với GRE được cấu hình, 1 đường hầm ảo được tạo giữa 2 Router và các gói tin gửi giữa 2 mạng nội bộ sẽ được truyền qua GRE Tunnel.

<a name="1.8"></a>
### 1.8 VXLAN

- VXLAN là giao thức tunneling, thuộc giữa lớp 2 và lớp 3.
- Công nghệ VXLAN cung cấp các dịch vụ kết nối các Ethernet end systems và cung cấp phương tiện mở rộng mạng LAN qua mạng L3. VXLAN ID (VXLAN Network Identifier hoặc VNI) là 1 chuỗi 24-bits so với 12 bits của của VLAN ID. Do đó cung cấp hơn 16 triệu ID duy nhất.

<a name="2"></a>
## 2. Openstack networking

<a name="2.1"></a>
### 2.1 Khái niệm

- OpenStack Networking cho phép bạn tạo và quản lý network objects, như networks, subnets, và ports.
- Neutron quản trị network trong Openstack
- Cung cấp cho VM 1 đường kết nối: VM cần IP thì cấp cho IP (public và private)
- Chỉ tác động đến Vm và khối Nova Compute để lấy IP

![neutron](Images/neutron.png)

- *Neutron Server*: Phụ trách về API quản lý database ,..(Core)
- *Neutron service plugins*: Router, Switch, VPN, Load balancer, Firewalls
- *Neutron core Plugin*
    - Vendor : Cisco, Jupiter,.. Neutron tích hợp với các thiết bị phần cứng đặc thù

    - ML2: Quản trị mô hình mạng ( 5 type Drivers)         
        - Flat : Dải Ip mà bạn cấp ( ví dụ cấp /24 thì chỉ cấp được 253 IP cho các Vm cho OPS)
        - VLAN: Bao nhiêu VLAN thì Khai báo bấy nhiêu VLAN vào Neutron
        - VXLAN và GRE: kỹ thuật tunnels triển khai overlay và underlay
        (Muốn triển khai mạng Private phải triển khai hệ thống overlay)
    - Mechanish Drivers:
        - Open vSwitch, Linux Bridge : sw ảo layer2

- RabbitMQ
- Neutron Agents
    - L2 Agent (OVS)
    - L3 Agent (Iptables)
    - DHCP Agent: Dùng dnsmasq để cấp phát IP



***Flow trong neutron*** 

![neu](Images/neutron1.png)





***Các khái niệm trong neutron*** 

- provider network :
    - Provider network được tạo với thông tin quản trị, chỉ định cụ thể mạng là vật lý, phù hợp với mạng đã có trong data center. Chi tiết được mô tả trong một mạng provider: thuộc tính network_type, provider:physical_network, và provider:segmentation_id
    - Provider network có thể có cả flat và vlan

- Self-service :
    - Self-service networks chủ yếu cho phép các projects chung (không có đặc quyền) để quản lý mạng mà không cần đến admin. Các mạng này hoàn toàn là virtual và yêu câu virtual routers tương tác với provider và các mạng bên ngoài Internet. Self-service networks cũng thường cung cấp các DHCP và metadata services đến instances.
    - Trong hầu hết các trường hợp, self-service networks sử dụng overlay protocol như VXLAN và GRE bởi vì chugn có thể hỗ trợ nhiều mạng hơn layer-2 segementation bằng cách sử dụng VLAN tagging (802.1q).
    -   IPv4 self-service network sử dụng dải địa chỉ private IP và tương tác với provider network thông qua source NAT trên virtual routers. Địa chỉ Floating IP cho phép truy cập đến instance từ provider networks thông destionation NAT trên virtual router.

- Kết nối với nova: Neutron cần metadata 
1 VM khi muốn lấy thông tin metadata thì phải lấy IP thông qua neutron

- Security group do neutron quản lý nhằm bảo mật cho Vm 
(giúp Vm hạn chế nhiều traffic không mong muốn)
    - Security groups cung cấp vùng lưu trữ cho virtual firewall rules để kiểm soát lưu lượng truy cập ingress (inbound to instance) và egress (outbound from instance) mạng ở mức port
    - Chỉ có 2 chế độ accept và denied
    - Mỗi project có chứa 1 default security group mà cho phép tát cả lưu lượng egress và từ chối tất cả các lưu lượng ingress. Bạn có thể thay đổi rules trong default security group
    - Bạn launch instance mà không có security group chỉ định, default security group sẽ tự động được áp dụng cho instance đó. Tương tự, nếu bạn tạo 1 port mà không chỉ định security group, default security group tự động được áp cho port đó.

- Port :
    - Port là điểm để kết nối để gắn 1 thiết bị, chẳng hạn NIC của virtual server, đến virtual network. Port cũng mô tả cấu hình mạng liên quan, chả hạn như MAC và địa chỉ IP được sử dụng trên port đó.

- Router:
    - Router cung cấp virtual layer-3 services như routing và NAT giữa self-service network và provider network hoặc giữa các self-service networks phụ thuộc vào project. Networking service sử dụng layer-3 agent để quản lý routers thông qua namespaces.