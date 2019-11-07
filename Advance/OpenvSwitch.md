# OpenvSwitch




## 1. Khái niệm OpenvSwitch

### OpenvSwitch là gì?
  
* OpenvSwitch là phần mềm switch mã nguồn mở, dùng để hỗ trợ giao thức OpenFlow
* OpenvSwitch được sử dụng với các hypervisor để kết nối giữa các máy ảo trên một host vật lý và các máy ảo , giữa các host vật lý khác nhau qua mạng.
*  OpenvSwitch cũng được sử dụng trên một số các thiết bị chuyển mạch vật lý.
* OpenvSwitch là một trong những thành phần quan trọng hỗ trợ SDN.

### Tính năng trong OpenvSwitch

* Hỗ trợ VLAN tagging và chuẩn 802.1q trunking
* Hỗ trợ STP (Spanning tree protocol 802.1D)
* Hỗ trợ LACP
* Hỗ trợ sử dụng giao thức Sflow, netflow( Flow Export)
* Hỗ trợ các giao thức tunnels(GRE, VXLAN,IPSEC tunneling)
* Hỗ trợ kiểm soát QoS

## 2.Kiến trúc OpenvSwitch

### 2.1 Kiến trúc tổng quan

![images](../images/ovs1.jpg)

* OpenvSwitch thường dùng để kết nối các VMs/containers trong máy chủ vật lý. 

* Ba thành phần chính của OvS:

    **0vs-vswitchd**

    - là OpenvSwitch daemon chạy trên user space
    - ovs-vswitchd là daemon của Open vSwitch chạy trên userspace. Nó đọc cấu hình của Open vSwitch từ ovsdb-server thông qua kênh IPC (Inter Process Communication) và đẩy cấu hình xuống ovs bridge (là các instance của thư viện ofproto). Nó cũng đẩy trạng thái và thông tin thống kê từ các ovs bridges vào trong database.
    - ovs-switchd giao tiếp :
        - **Outside** - sử dụng OpenFlow
        - **ovs-dbserver** - sử dụng giao thức OVSDB protocol
        - **kernel** - thông qua netlink (tương tự như Unix socket domain)
        - **system** - thông qua abstract interface là netdev
    - tools: `ovs-appctl`, `ovs-dpctl`, `ovs-ofctl`, `sFlowTrend`

    - ovs-vswitchd triển khai mirroring, bonding và VLANs

    **ovsdb-server**

    - là database server của OpenvSwitch chạy trên user space.

    - Các cấu hình bền vững sẽ được lưu trữ trong ovsdb và vẫn lưu giữ khi sau khi khởi động lại hệ thống. Các cấu hình này bao gồm cấu hình về bridge, port, interface, địa chỉ của OpenFlow controller ()nếu sử dụng),...

    - tools:  `ovs-vsctl`, `ovsdb-client`

    **kernel module**(datapath)
    - Là module thuộc kernel space, thực hiện công việc chuyển tiếp gói tin
    
    - Module chính chịu trách nhiệm chuyển tiếp gói tin trong Open vswitch, triển khai trong kernelspace nhằm mục đích đạt hiệu năng cao. Nó caches lại OpenFlow flows và thực thi các action trên các gói tin nhận được nếu các gói tin nó match với một flow đã tồn tại. Nếu gói tin không khớp với bất kì flow nào thì gói tin sẽ được chuyển lên ovs-vswitchd. Nếu flow matching tại vswitchd thành công thì nó sẽ gửi gói tin lại cho kernel datapath kèm theo các action tương ứng để xử lý gói tin đồng thời thực hiện cache lại flow đó vào datapath để datapath xử lý những gói tin cùng loại đến tiếp sau. Hiệu năng cao đạt được ở đây là vì thực tế hầu hết các gói tin sẽ match flows thành công tại datapath và do đó sẽ được xử lý trực tiếp tại kernelspace.


    - tools: ovs-dpctl

### 3. Công cụ chính tương tác với OpenvSwitch

![images](../images/ovs3.jpg)

* `ovs-vsctl`: tiện ích chính sử dụng để quản lý các switch, nó tương tác với ovsdb-server để lưu cấu hình vào database của Open vSwitch. ovs-vsctl thực hiện truy vấn và áp dụng các thay đổi vào database tùy thuộc vào lệnh ta thực hiện. ovsdb-server sẽ nói chuyện với ovs-vswitchd qua giao thức OVSDB. Sau đó, nếu ovs-vsctl áp dụng bất kì thay đổi nào thì mặc định nó sẽ đợi ovs-vswitchd kết thúc việc tái cấu hình lại switch.

* `ovs-appctl`: cũng là công cụ để quản lý ovs-vswitchd bênh cạnh ovs-vsctl, nó gửi một số command nội bộ tới ovs-vswitchd để thay đổi một số cấu hình và in ra phản hồi từ ovs-vswitchd. ovs-vswitchd đồng thời cũng lưu lại các cấu hình này vào database bằng việc tương tác với ovsdb-server thông qua Unix domain socket.

* `ovs-dpctl`: đôi khi ta cần quản lý dapapath trong kernel trực tiếp mà thậm chí ovsdb-server không chạy, ta có thể sử dụng ovs-dpctl tương tác với ovs-vswitchd để quản lý datapath trong kernelspace trực tiếp mà không cần database.

* `ovsdb-client` và `ovsdb-tool`: khi cần nói chuyện với ovsdb-server để thực hiện một số thao tác với database, ta sử dụng ovsdb-client, hoặc nếu muốn xử lý database trực tiếp không thông qua ovsdb-server thì sử dụng ovsdb-tool.

* `ovs-ofctl` và `sFlowTrend`: Open vSwitch có thể được quản trị và giám sát bởi một remote controller. Điều này lý giải tại sao ta có thể định nghĩa mạng bằng phần mềm (hay Open vSwitch hỗ trợ SDN). Cụ thể hơn, sFlow là giao thức dể lấy mẫu gói tin và giám sát, trong khi OpenFlow là giao thức để quản lý flow table của switch, bridge hoặc device. Open vSwitch hỗ trợ cả OpenFlow và sFlow. Với ovs-ofctl, ta có thể sử dụng OpenFlow để kết nối với switch và thực hiện giám sát và quản trị từ xa. Trong khi đó sFlowTrend không phải là thành phần trong Open vSwitch packet mà là phần mềm độc lập hỗ trợ giám sát sử dụng sFlow.


---

https://blog.csdn.net/ifzing/article/details/41308449


https://arthurchiao.github.io/blog/ovs-deep-dive-0-overview/