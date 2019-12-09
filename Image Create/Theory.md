# Theory 

## 1. Cloud init 

- Để thực hiện một số cấu hình cho VM khi khởi động .Ví dụ như, cài đặt một số gói, khởi động dịch vụ hoặc quản lí các VM. Khi tạo instances trong 1 hệ thống OpenStack cloud, có hai kỹ thuật làm việc với nhau để hỗ trợ việc cấu hình tự động cho các instances tại thời điểm khởi động: user-data và cloud-init.

### 1.1 Userdata

- Là cơ chế mà theo đó người dùng có thể chuyển thông tin chứa trong một tập tin đặt trên local vào trong một instance trong thời gian boot. Trường hợp điển hình chuyển thông tin bằng cách dùng 1 file shell scrip hoặc một file cấu hình user data.

### 1.2 Cloud init
- Khái niệm

    - Cloud init sẽ xác thực cloud os nào đang chạy trong quá trình boot, đọc tất cả các metadata được cung cấp từ cloud os và khởi tạo hệ thống tương ứng
Điều này sẽ đáp ứng các thông số cài đặt về network, lưu trữ, cấu hình ssh và nhiều cài đặt khác của hệ thống.
Và cuối cùng CLoud init sẽ xử lý đưa tất cả các  dữ liệu tùy chọn của user hoặc nhà cung cấp đến VM

    - Khi sử dụng user-data thì VM image phải được cấu hình chạy một dịch vụ khi boot để lấy use data từ server meta-data và thực hiện một số hoạt động dựa trên nội dung của dữ liệu đưa vào. Gói phần mềm Cloud-init được thiết kế thực thi điều này. đặc biệt, cloud-init tương thích với dịch vụ Compute meta-data giống như là các drive dùng để cấu hình máy tính.

- Tính năng của Cloud init
   
    - set root password
    - set timezone
    - add ssh authorized keys for root user
    - set static networking
    - set hostname
    - create users and/or set user passwords
    - run custom scripts and/or commands ....

- Thao tác làm việc với Cloud- init

    Các bước tạo Image có sẵn Cloud- init (thực hiện trên máy cài Ubuntu 16.04 server và dùng Virtual machine để tạo VM)

    - B1: Tạo một VM
    - B2: Install Os
    - B3: Install Cloud- init
    - B4: Chuẩn bị đoạn code python viết cho Jobs mà ta muốn thực hiện sau đó sửa file cấu hình /etc/cloud/cloud.cfg sao cho map tên đầu mục với code đã viết.
    - B5: Tạo ra image từ VM trên (định dạng cho image(qcow2), nén image lại cho nhỏ)
    - B6: Đẩy image vừa tạo lên máy chủ OpenStack


## 2 qemu-guest-agent

- qemu-guest-agent là một daemon chạy trong máy ảo, giúp quản lý và hỗ trợ máy ảo khi cần

- Nó được sử dụng để trao đổi thông tin giữa Host và VM, và để thực thi lệnh trong VM.
 --- 


## 3 Netplug

- Netplug là một deamon chạy trên nền Linux quản lý các Network interfaces để đáp ứng các NIC cắm vào.

 Tham khao
    https://github.com/vdcit/Cloud-Init