# Wireshark - Phân tích gói tin trên mạng

## ***Thực hiện***:

- Chọn interface kết nối với internet:

![interface]()

- Mở trình duyệt kết nối tới google.com ,fb.com, youtube.com,...
- Lựa chọn dạng bản tin

+ Ví dụ: xem bản tin khi truy nhập fb.com
     
     + Phân giải tên miền thành địa chỉ: 31.13.95.36
     + Sử dụng protocol:
        
       + Tiến trình bắt tay ba bước Kết nối TCP 
       + TLSv1.3 (Transport layer Security)- Giao thức bảo mật tầng Transport
    + Thông tin bản tin :
      
      ![info]()
      
      *VD: Bản tin từ server đến client*
      + Time to live: 86
      + Địa chỉ cấp cho client(từ máy cá nhân): 192.168.1.101
      + TCP:

         _ Source Port(443)- Port của HTTPS
         
         _Destination Port(50544)- Port của client
         
         _ Sequence number(4766)- đánh số thứ tự bản tin
         _ Segment Length(35) Độ dài segment
      + Transport layer Security: Thông tin version, mã hóa dữ liệu.
      +
      
