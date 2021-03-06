# Log, syslog, rsyslog
# Mục lục
* [1. Log để làm gì?](#1)
* [2. Syslog là gì?](#2)
* [3. Rsyslog là gì?](#3) 
* [4. Logrotation](#4)
* [5. Journal](#5)
* [Tham khảo](#tk)
---

## 1. Log là gì, để làm gì?


*VD*: Khi quản lý một server chưa nhiều dữ liệu quan trọng hoặc đã cài đặt rất nhiều ứng dụng , tính năng. Server hoạt động liên tục 24/24, nhưng tự dưng mất dữ liệu. Muốn điều tra xử lý hay tìm nguyên nhân khắc phục hậu quả xảy ra thì `Log` sẽ giúp việc này.

* 1.1 Log là gì?:

    * `Log` là dữ liệu sinh ra khi hệ thống hoạt động ghi lại liên tục các thông báo về hoạt động của cả hệ thống hoặc của các dịch vụ được triển khai trên hệ thống và file tương ứng.
    
    * Các file log sẽ xuất log cho bạn biết tất cả các tiến trình diễn ra trong hệ thống
    * Trong Linux thì /var/log là nơi lưu lại tất cả log

![log](../../images/log.png)

* 1.2 File Log:

    ***Ví dụ:***

    * *Syslog*: Log hệ thống thông thường chứa các thông tin mặc định của hệ thống, thường được lưu trong /var/log/syslog hoặc /var/log/message.

    ![syslog](../../images/syslog.png)

    *ở đây nói đã thực hiện một cronjob mỗi phút một lần*

    * *Authorization log* lưu các thông tin về các hệ thống ủy quyền, các cơ chế ủy quyền các user, nhắc nhở về user password, ví dụ như hệ thống PAM (Pluggable Authentication Module), sudo command, các đăng nhập tới sshd. Các thông tin này được lưu lại trong /var/log/auth.log File log cung cấp các thông tin về đăng nhập user, việc sử dụng sudo command.

    ![authlog](../../images/authlog.png)

    *ở đây nói đã thay đổi mật khẩu của root, kết thúc phiên user để chuyển sang root*


*Nếu file log lớn thì dùng câu lệnh tail -n để xem các dòng cuối*



![tail](../../images/syslogcat.png)
##

## 2. Syslog

* 2.1 Syslog là gì
    
    * syslog là một giao thức client/server, là giao thức dùng để chuyển log và thông điện đến máy nhận log.( Máy nhận log: syslogd, syslog daemon, syslog server)

    * Syslog được gửi qua UDP port 514

    * Mỗi thông báo trong syslog đều được dán nhãn và được gán ở mức độ nghiêm trọng khác nhau.

* 2.2 Mục đích của Syslog

    * Syslog chuyển tiếp và thu thập log được sử dụng trên một phiên bản Linux.
    * Syslog xác định mức độ nghiêm trọng (severity levels) cũng như mức độ cơ sở(facility levels) giúp người dùng hiểu rõ hơn về nhật ký được sinh ra ở áy.
    * Log có thể được phân tích và hiển thị trên các máy chủ.

* 2.3 Định dạng bản tin Syslog

    * PRI(priority): chi tiết các mức độ ưu tiên của bản tin, các mức độ cơ sở.
    * Header: Bao gồm 2 trường TIMESTAMP(thời gian) và HOSTNAME(Tên máy chủ, máy gửi log).
    * MSG: phần này chứ nội dung đã xảy ra( nội dung nhật ký).


**Cấp độ cơ sở Syslog (Syslog facility levels)**:

* Dùng để xác địch chương trình 
* Xác định Log được tạo ra từ đâu
* Xác định mục đích Log sinh ra
* Nếu một máy khác muốn sinh ra log thì sẽ là một tập hợp các cấp độ facility được bảo lưu từ 16-23 được gọi là "local use" facility levels

|Facility Number|Nguồn tạo log | Ý nghĩa |
|---------|--------------|---------|
|0|kernel | Những log mà do kernel sinh ra |
|1|user | Log ghi lại cấp độ người dùng|
|2|mail | Log của hệ thống mail |
|3|daemon | Log của các tiến trình trên hệ thống |
|4|auth | Log từ quá trình đăng nhập hệ hoặc xác thực hệ thống |
|5|syslog | Log từ chương trình syslogd |
|6|lpr | Log từ quá trình in ấn |
|7|news | Thông tin từ hệ thống | 
|8|uucp | Log UUCP subsystem |
|9||Clock deamon|
|10|authpriv|Quá trình đăng nhập hoặc xác thực hệ thống|
|11|ftp|Log của FTP deamon|
|12||Log từ dịch vụ NTP của các subserver|
|13||Kiểm tra đăng nhập|
|14||Log cảnh báo hệ thống|
|15|cron|Log từ clock daemon|
|16 - 23|local 0 -local 7|Log dự trữ cho sử dụng nội bộ|

**Cấp độ cảnh bảo**

* Dùng để cảnh báo mức độ nghiêm trọng của Log event
* Có 8 cấp độ từ 0-7 , 0 là mức dộ khẩn cấp nhất cần xử lý ngay.

|Code|Mức cảnh báo|	Ý nghĩa|
|---------|--------------|---------|
|0|emerg|	Thông báo tình trạng khẩn cấp|
|1|alert|	Hệ thống cần can thiệp ngay|
|2|crit|	Tình trạng nguy kịch|
|3|error|	Thông báo lỗi đối với hệ thống|
|4|warn|	Mức cảnh báo đối với hệ thống|
|5|notice|	Chú ý đối với hệ thống|
|6|info|	Thông tin của hệ thống|
|7|debug|	Quá trình kiểm tra hệ thống|



## 3. Rsyslog 

* 3.1 Rsyslog là gì?
     * Rsyslog là một sự phát triển của syslog, cung cấp các khả năng như các mô đun có thể cấu hình, được liên kết với nhiều mục tiêu khác nhau (ví dụ chuyển tiếp nhật ký Apache đến một máy chủ từ xa).
    * Rsyslog sử dụng port 10514 cho TCP, đảm bảo rằng không có gói tin nào bị mất trên đường đi.
    * Bạn có thể sử dụng giao thức TLS/SSL trên TCP để mã hóa các gói Syslog của bạn, đảm bảo rằng không có cuộc tấn công trung gian nào có thể được thực hiện để theo dõi log của bạn.

* 3.2 Rsyslog làm gì?:
    
    * rsyslog có thể thu thập các bản ghi từ các thiết bị khác như một máy chủ
    * rsyslog có thể thu thập các bản ghi từ các thiết bị khác

* 3.3 Điều cần nhớ:

    * Facility level: các tiến trình cần ghi log.
    * Priority level: loại thông điệp cần thu thập dựa trên mức cảnh báo đưa ra.
    (ở phần syslog)
    * Destination: nơi cần gửi các bản ghi log đến.
  
* 3.4 Cấu hình
    
    Cài đặt rsyslog: 

    ![rsysloginstall](../../images/rsysloginstall.png)

    Thư mục chứa ryslog:

    ![rsyslogfile](../../images/rsyslogfile.png)


    *Cấu hình syslog dựa trên mô hình sau:*

    ``` [facility-level].[Priority-level]   [Destination] ```

    *Ví dụ:*

    ``` mail.warn      /var/log/mail.warn ```
    
    Giải thích: với các dữ liệu có Facility là mail và tất cả Priority từ Chế độ Warning trở lên sẽ được lưu log lại trong /var/log/mail.warn

    ``` mail.=info      /var/log/mail.info ```

    Giải thích: Dữ liệu có Facility là mail và có chế Priority là info sẽ được lưu lại.

    ``` *.*        @@192.168.69.111:10514 ``` 

    Giải thích: Tất cả các log gồm mọi Facility và Priority sẽ được chuyển đến máy chủ có địa chỉ ip 192.168.69.111 bằng TCP qua port 10514

* 3.5 LAB:
 
     *Ví dụ ta thực hiện ghi hết các log về Quá trình đăng nhập hoặc xác thực hệ thống với tất cả Priority tại file mới /var/log/auth.log, ta sửa file /etc/rsyslog.conf thực hiện lệnh:*
 

    ``` auth,authpriv.*                 /var/log/auth.log```
 
    ![rsyslogconf](../../images/rsyslogconf1.png)

    Kết quả: kiểm tra file /var/log/auth.log

    ![rsyslogconf](../../images/rsyslogconf2.png)


## 4. Rotating log file:

* Để phòng ngừa bản ghi log lấp đầy hệ thống, ta cần có cơ chế rotate*

* Cơ chế này hoạt động khi đến một ngưỡng bất kì, tập log sẽ bị lấp đầy và tập log cũ sẽ đóng và tập log mới sẽ được mở.
* Tính năng Rotatelog được thực hiện định kỳ thông qua cron
   
   *Để phòng ngừa bản ghi log lấp đầy hệ thống, ta cần có cơ chế rotate*

   * Cơ chế này hoạt động khi đến một ngưỡng bất kì, tập log sẽ bị lấp đầy và tập log cũ sẽ đóng và tập log mới sẽ được mở.
   * Tính năng Rotatelog được thực hiện định kỳ thông qua cron

*Các thông số thường gặp trong các tệp tin chính của logrotate*


|Thông số| Chức năng|
|--------|---------------|
|daily|Mỗi ngày|
|weekly|Mỗi tuần|
|monthly|Mỗi tháng|
|yearly|Mỗi năm|
|missingok|Nếu file log bị mất hoặc không tồn tại *.log thì logrotate sẽ di chuyển tới phần cấu hình log của file log khác mà không phải xuất ra báo lỗi|
|nomissingok|ngược lại so với cấu hình missigok|
|notifempty|Không rotate log nếu file này trống|
|rotate|số lượng file log cũ đã được giữ lại sau khi rotate|
|compress|Logrotate sẽ nén tất cả các file log lại sau khi đã được rotate mặc định bằng gzip|
|compresscmd|Khi sử dụng chương trình nén như bzip2, xz hoặc zip|
|delaycompress|Được sử dụng khi không muốn file log cũ phải nén ngay sau khi vừa được rotate|
|nocompress|Không sử dụng tính năng nén đối với file log cũ|
|create|Phân quyền cho file log mới sau khi rotate|
|copytruncate|File log cũ được sao chép vào một tệp lưu trữ, và sau đó nó xóa các dòng log cũ|
|postrotate [command] endscript	|Để chạy lệnh sau khi quá trình rotate kết thúc, chúng ta đặt lệnh thực thi nằm giữa postrotate và endscript|
|prerotate [command] endscript|Để chạy lệnh trước khi quá trình rotate bắt đầu, chúng ta đặt lệnh thực thi nằm giữa prerotate và endscript
|



* Cấu hình mặc định của logrotate được lưu ở file ` /etc/logrotate.conf ` Có chứa các thông tin thiết lập toàn bộ file log mà Logrotate quản lý, bao gồm chu kì lặp, dung lượng file log, nén file,...


    *Ví dụ Chúng ta có thể quy định tiến trình rotate dựa vào dung lượng file*

    * `Với /var/log/wtmp` khi size 150M sẽ tạo tệp mới
    
    ![logrotate](../../images/logrotate.png)

    *Ví dụ trên các tùy chọn có ý nghĩa như sau:*

    * size 150M: Logrotate chỉ chạy nếu kích thước tệp bằng (hoặc lớn hơn) kích thước này.
    * create: Rotate tệp gốc và tạo tệp mới với sự cho phép người dùng và nhóm được chỉ định.
    * rotate: Giới hạn số vòng quay của fle log. Vì vậy, điều này sẽ chỉ giữ lại 1 file log được rotate gần nhất.


## 5. Làm việc với Journald 

* Là một daemon (chạy background trên hệ thống), một bộ phận của systemd, là một system service thực hiện việc thu thập và lưu trữ dữ liệu logging.

* Mặc định log sẽ được chứa trong /run/log/journal/, bởi dữ liệu trong /run sẽ bị mất sau khi reboot, log cũng sẽ bị mất theo (có thể config để thay đổi điều này).

* Journalctl là một công cụ để query (truy vấn).

* Câu lệnh:
    * `journalctl -p err`  Câu lệnh này sẽ chỉ show lỗi (errors)


        ![images](../../images/journalerror.png)

    * câu lệnh nào cho phép xem  journald messages từ lần reboot trước đó trên hệ thống ở journald đóng dấu
    `journalctl -b -number` (number là các lần boot trở về trước)


         ![images](../../images/journalb.png)

    * Câu lệnh nào cho phép xem journald messages  đã được viết ở PID từ 9g sáng - 3 giờ chiều.
    `journalctl _PID=1 --since 9:00:00 --until 15:00:00`

    * Câu lệnh nào cho phép xem journald được tạo ra trên thời gian thực
    `journalctl -f`

        ![images](../../images/journalf.png)

    * `journalctl _SYSTEMD_
    UNIT=sshd.service`
    Câu lệnh để xem chi tiết log của service

* Vì theo mặc định, Journal được lưu trữ ở file /run/log/journal. Nên sau khi reboot journal sẽ bị mất. Để tạo một journal được đóng dấu khi hệ thống khởi động lại, bạn phải chắc chắn thư mục /var/log/journal tồn tại

    * Tạo journal dài hạn:
        
        - Tạo thư mục để lưu `mkdir /var/log/journal`
        - Trước khi journal được viết vào thư mục này thì phải phân quyền ` chown root:systemd-journal /var/log/journal` và    `chmod 2755 /var/log/journal`
        - Giờ có thể reboot hệ thống hoặc dùng lệnh `killall -USR1 systemd-journald`
        - Kiểm tra dùng lệnh `journalctl -b`.

        ![journal](../../images/journal.png)
    

---
Summary Quiz:

Câu 1: File nào dùng để cấu hình rsyslog: `/etc/rsyslog.conf`

Câu 2: File log nào liên quan đến xác thực: `/var/log/auth.log` 

Câu 3: Nếu không cấu hình thì mặc định sau một tuần file log sẽ bị rotate và file rotated sẽ tồn tại trong 4 tuần.

Câu 4: Câu lệnh nào cho phép bạn ghi lại từ Command line đến user facility và notice priority: `logger -p user.notice "User Notice Log"

Câu 5: Câu lệnh đưa tất cả các log có priority là info vào thư mục /var/log/message.info : `*.=info /var/log/messages.info`

Câu 6: File cấu hình nào phép bạn cấu hình Journal được vượt quá size mặc định :`/etc/systemd/journald.conf`

Câu 7: Câu lệnh nào cho phép xem journal được tạo ra ở thời gian thực: `journalctl f`

Câu 8: Câu lệnh nào cho phép xem journal đã được viết ở PID=1 từ 9g sáng - 3g chiều: `journalctl_PID=1 --since 9:00:00 --until 15:00:00`

Câu 9: Câu lệnh nào cho phép xem journal từ lần reboot trước đó khi đã được đóng dấu: `journalctl -b -number` (number là số lần reboot)
