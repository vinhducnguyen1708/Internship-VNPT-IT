# Sử dụng Crontab 

# Mục lục

* [1. Mục đích sử dụng Crontab](#1)
* [2. Khái niệm và Nguyên lý hoạt động](#2)
* [3. LAB ví dụ](#3)
* [4. Tham khảo](#4)

---
<a name = '1'></a>

## 1. Mục đích để sử dụng Crontab
* Tính năng của Cron trong Linux là một chế độ sắp xếp tự động các chương trình, ứng dụng và kích hoạt chúng tại một thời điểm nhất định trong hệ thống( tương tự với Task Scheduler của Windows).

* Dính năng này rất phù hợp trong quá trình tự động sao lưu dữ liệu, bảo dưỡng hệ thống,...


<a name = '2'></a>
## 2.1. Khái niệm
*Cron là gì?*
*Crontab là gì?*
*Cronjob là gì?*


* Cron là một tiện ích giúp lập lịch chạy những dòng lệnh cho server để thực thi các công việc theo thời gian được lập sẵn.
* Cronjob là các lệnh thực thi hành động đặt trước vào thời điểm nhất định. Crontab là nơi lưu trữ các cronjob.
* Cron là một chương trình deamon, () nó được chạy ngầm mãi mãi một khi nó được khởi động lên). Như các deamon khác thì bạn cần khởi động lại nó nếu như có thay đổi thiết lập gì đó. Chương trình này nhìn vào file thiết lập có tên là crontab để thực thi những task được mô tả ở bên trong.

## 2.2 Nguyên lý hoạt động

* Một cron schedule đơn giản là một text file. Mỗi đường dùng có một cron schedule riêng.
* File này thường nằm ở /var/spool/cron.
* Lệnh thường dùng:
    
    - crontab -e: tạo hoặc chỉnh sửa file crontab
    - crontab -l: Hiển thị file crontab
    - crontab -r: Xóa file crontab.

* Cấu trúc của crontab:

![crontab](../../images/crontab4.png)

<a name = '3'></a>

## 3. LAB ví dụ:

*Ta sẽ thực hiện một tiến trình cron: Mỗi ngày vào lúc 10g25p sẽ khởi động lại máy*

* Dùng câu lệnh `crontab -e` để thiết lập cronjob
    
    ![crontabe](../../images/crontab3.png)

    - vì lệch múi giờ nên phải kiểm tra ở câu lệnh `date`

* Kiểm tra xem crontab đã được tạo chưa `crontab -l`
    
    ![crontabl](../../images/crontab1.png)

* Kết quả :

    ![crontabresult](../../images/crontab2.png)

* Xóa crontab dùng câu lệnh `crontab -r`:

    ![crontabr](../../images/crontab5.png)

---
<a name = 'tk'></a>

## Tài liệu tham khảo

[1] https://www.gocit.vn/bai-viet/crontab-linux/

[2] https://vinahost.vn/crontab-linux-la-gi

[3] https://hocvps.com/tong-quat-ve-crontab/

[4] https://vi.digitalentertainmentnews.com/how-schedule-tasks-linux-an-introduction-crontab-files-940889

