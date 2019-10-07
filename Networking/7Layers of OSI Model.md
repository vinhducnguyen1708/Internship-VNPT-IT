# OSI Model

## 1. Khái niệm cơ bản
* Là một mô hình được tạo ra bởi tổ chức International Organization for Standardization (ISO) 
* Nhằm cho phép các hệ thống truyền thông đa dạng có thể giao tiếp bằng các giao thức chuẩn, cung cấp một tiêu chuẩn cho các máy tính có thể giao tiếp được với nhau
* OSI là một mô hình cho phép nhận biết và thiết kế một kiến trúc mạng linh động, vững chắc và có khả năng liên tác.

![image](https://raw.githubusercontent.com/vinhducnguyen1708/Internship-VNPT-IT/master/images/osiandtcp.png)

*Mô hình OSI và TCP*


## 2. Các Layers trong mô hình OSI
  
 * ## **Physical Layer**
*Sau khi tìm hiểu lớp Vật Lý bạn sẽ nắm được*:

_ Nhận dạng các tùy chọn thiết bị kết nối

_ Mô tả mục đích và chức năng của lớp trong mạng

_ Mô tả nguyên tắc cơ bản về tiêu chuẩn của lớp

### *1. Thiết bị mạng*
![image](https://raw.githubusercontent.com/vinhducnguyen1708/Internship-VNPT-IT/master/images/Physical1.png)

VD: AP(Access Point) Cung cấp một thành phần chuyển mạch với nhiều cổng, cho phép nhiều thiết bị được kết nối với mạng cục bộ (LAN) bằng cáp,..

Ethernet NICs(Network Interface Cards) dùng để kết nối Internet khi sử dụng dây kết nối.

### *2.Chức năng*

* Lớp Physical trong mô hình OSI cung cấp phương tiện để vận chuyển các bit để đưa lên hoặc nhận từ lớp Data Link
* Lớp Physical nhận một khung (frame) hoàn chỉnh từ lớp Data link và mã hõa frame đó thành chuỗi tín hiệu điện, quang, vô tuyến để truyền đi đến các thiết bị trung gian hoặc thiết bị đầu cuối.
* Sau khi truyền đến thiết bị đích, thiết bị đích khôi phục tín hiệu thành khung hoàn chỉnh rồi đưa lên lớp trên.

![image](https://raw.githubusercontent.com/vinhducnguyen1708/Internship-VNPT-IT/master/images/Physical2.png)

### *3.Các chuẩn *
_ Cáp đồng, Cáp quang, Vô tuyến

_ ISO, EIA/TIA, ITU-T, ANSI, IEEE



 * ## **Data Link Layer**
*Sau khi tìm hiểu lớp Vật Lý bạn sẽ nắm được*:

_ Mô tả mục đích và chức năng của Data Link Layer trong việc truyền trong môi trường mạng

![image](https://raw.githubusercontent.com/vinhducnguyen1708/Internship-VNPT-IT/master/images/datalink.png)


### *1.Chức năng*:
* Cho phép các lớp trên truy nhập qua các phương tiện
* Nhận gói (packet) ở lớp 3 rồi đóng gói thành khung (frame).
* Chuẩn bị dữ liệu mạng cho lớp Physical.
* Kiểm soát dữ liệu (kiểm tra lỗi, kiểm soát luồng) được nhận và đặt trên phương tiện
* Trao đổi khung giữa các phương tiện ở lớp vật lý bằng UTP, cáp quang,..
* Nhận và chuyển các gói đến giao thức ở lớp trên.
### *2.Các Protocols*:
PPP, Frame Relay, IEEE 802.5/702.2,...


 * ## **Network Layer**
 *Sau khi tìm hiểu lớp Vật Lý bạn sẽ nắm được*:
 
 _ Mô tả mục đích của Network Layer trong giao tiếp dữ liệu
 _ IPv4, IPv6
 ### *1.Chức năng, mục đích*:
 * Network Layer cung cấp các dịch vụ để cho phép các thiết bị đầu cuối trao đổi dữ liệu trên mạng. 

![Network](https://raw.githubusercontent.com/vinhducnguyen1708/Internship-VNPT-IT/master/images/Network.png)

 * Để thực hiện việc vận chuyển này, Network Layer sử dụng 4 quy trình cơ bản:
 1. Addressing end devices: Thiết bị đích phải được cấu hình một địa chỉ IP duy nhất để nhận dạng trên mạng.
 2. Encapsulation (đóng gói): Network layer đóng gói PDU từ Transport layer thành một Packet (gói). Quá trình đóng gói sẽ thêm thông tin tiêu đề IP nguồn và IP đích.
 3. Routing (Định tuyến): Network layer cung cấp dịch vụ truyền các gói trực tiếp đến đích của mạng khác. Để truyền đến các mạng khác, gói phải được xử lý bởi bộ định tuyến. Vai trò của bộ định tuyến là chọn đường đi tốt nhất và các gói gửi trực tiếp đến đích. Mỗi bộ định tuyến gói đi qua được gọi là hop (bước nhảy).
 4. De-Encapsulation(Giải đóng gói): Khi gói đến Network layer phía đích, máy chủ sẽ kiểm tra tiêu đề của gói IP. Nếu địa chỉ IP đích khớp với địa chỉ IP của nó, tiêu đề IP sẽ bị xóa khỏi gói. Sau khi gói đó sẽ được giải đóng gói bằng Network layer và kết quả là được chuyển lên Transport layer.

 ### *2.IPv4, IPv6*:
* IPv4:
![ipv4](https://raw.githubusercontent.com/vinhducnguyen1708/Internship-VNPT-IT/master/images/Network1.png)
* IPv6:
![ipv6](https://raw.githubusercontent.com/vinhducnguyen1708/Internship-VNPT-IT/master/images/Network2.png)

