# Tìm hiểu về lệnh Netstat trong Linux để kiểm tra kết nối



## Các lệnh netstat:

1. Hiển thị các port 
    
    `netstat -a` 

    ![netstat](../../images/netstata.png)

2. Hiển thị các port dạng kết nối TCP 

    `netstat -at`

    ![netstat](../../images/netstattcp.png)

3. Hiển thị các port dạng kết nối UDP

    `netstat -au`

    ![nestatudp](../../images/netstatudp.png)

4. Hiển thị tất cả các port ở trạng thái Listening

    `netstat -l` hoặc `netstat -lx` 

    ![netstat](../../images/netstatlx.png)

5.  Thống kê giao thức

    * Thống kê tất cả giao thức:  `netstat -s`

    ![netstats](../../images/netstats.png)

    * Thống kê giao thức TCP hoặc UDP:
    TCP : `netstat -st`

        UDP : `netstat -su`

    ![thongke](../../images/netstatsu.png)

6. Hiển thị tên service và PID:

    `netstat -tp`

    ![netstattp](../../images/netstattp.png)

7. Hiển thị thông tin bảng định tuyến

    `netstat -r`

    ![netstat](../../images/netstatr.png)

8. Hiển thị thôn tin hoạt động của các Network Interface 

    `netstat -i` 

    ![netstat](../../images/netstati.png)

9. Hiển thị Kernel Interface Table

    * Hiển thị thông tin IP, giống với lệnh ifconfig.
    
    `netstat -ie`

    ![netstat](../../images/netstatie.png)


10. Tìm các chương trình ở trạng thái Listening 

    (Đang hoạt động kết nối với hệ thống)

    ` netstat -ap | grep *process* `

    ![Process](../../images/netstatssh.png)