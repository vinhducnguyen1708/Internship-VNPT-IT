# Giới thiệu về Nova

## *Mục lục*:
- [1. Giới thiệu về Nova](#1)
- [2. Các thành phần của Nova](#2)
- [3. Workflow](#3)
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
