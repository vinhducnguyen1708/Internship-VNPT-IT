# Quản lý User và Group trên Linux



## Root

* su : Đây là môi trường có thể hoạt động như người dùng ( mở một subshell mới)
* sudo : Cho phép cài đặt các lệnh với quyền người dùng ngay trên subshell đó mà không cần phải chuyển sang chế độ root

## Quản lý tài khoản User
* Mỗi user thường có đặc điểm như sau :
    - Tên tài khoản user là duy nhất , có thể đặt tên chữ thường , chữ hoa .
    - Mỗi user có 1 mã định danh duy nhất ( uid ) .
    - Mỗi user có thể thuộc về nhiều group .
    - Tài khoản super user có uid=gid=0


* File /etc/passwd:
    - Là file văn bản chứa thông tin về các tài khoản user trên máy. Mọi user đều có thể đọc tập tin này nhưng chỉ có root mới có quyền thay đổi.
    - Để xem nội dung của file ta dùng lệnh:
        `#cat /etc/passwd`
    ![images](usergroup.png)

* File /etc/shadown
    - Là tập tin văn bản chứa thông tin về mật khẩu của các tài khoản user trên máy.
    - Chỉ có root mới có quyền đọc tập tin này. User root có quyền reset mật khẩu của bất kỳ user nào trên máy.

         ![images](usergroup2.png)

## Tạo User

*Khi làm việc với các công cụ như useradd, một số giá trị mặc định được giả sử. Những
giá trị mặc định được đặt trong hai tệp cấu hình: /etc/login.defs và / etc / default /
người dùng*

* Lệnh useradd: Tạo tài khoản user
    - Cấu trúc lệnh:

        - `useradd [Options] login_name`

        - -c: comment, tạo bí danh.
        - -u: set user ID. Mặc định sẽ lấy số ID tiếp theo để gán cho user.
        - -d: chỉ định thư mục home.
        - -g: chỉ định nhóm chính.
        - -G: chỉ định nhóm phụ (nhóm mở rộng).
        - -s: chỉ định shell cho user sử dụng.

    - Ví dụ:


* Lệnh usermod: Sửa thông tin tài khoản
    - Cấu trúc lệnh:

        - `usermod [Options] login_name`
        - -c: comment, tạo bí danh.
        - -l -d: thay đổi thư mục home.
        - -g: chỉ định nhóm chính.
        - -G: chỉ định nhóm phụ (nhóm mở rộng).
        - -s: chỉ định shell cho user sử dụng.
        - -L: Lock account

* Lệnh passwd: Đổi password
    - Cấu trúc lệnh:
        - `passwd [login_name]`

         passwd -n 30 -w 3 -x 90 
        
        - Cài password cho người dùng trong khoảng thời gian tối thiểu 30 ngày, hết hạn sau 90 ngày và có 3 ngày cảnh cáo trước khi hết hạn.

* Lệnh Userdel: Xóa User.
    - Cấu trúc lệnh
        - `userdel [Options] login_name`
        - -r: xóa thư mục home của user

  - dòng mô tả tương ứng của user trong tập tin /etc/passwd và /etc/shadow cũng bị xóa.

* Lệnh chage : Dùng để thiết lập chính sách cho user
    
    - Cấu trúc lệnh:
        - `chage [options] login_name`
        - -l : xem chính sách của 1 user
        - -E: thiết lập ngày hết hạn cho account. Vd: `chage -E 08/17/2020 vdn178`
        - -I: thiết lập số ngày bị khóa sau khi hết hạn mật khẩu
        - -m: thiết lập số ngày tối thiểu được phép thay đổi password
        - -M: thiết lập số ngày tối đa được phép thay đổi password
        - -W: Thiết lập số ngày cảnh báo trước khi hết hạn mật khẩu.

    - Ví dụ: `chage -E 2019-11-20 -m 3 -M 90 -I 10 -W 3 vnd178`
    
    *Lệnh trên sẽ thiết lập mật khẩu cho user vdn178 hết hạn vào ngày 20/11/2029. Số ngày tối thiểu phải có thể đổi mật khẩu là 5 số ngày tối đa là 90 ,Tài khoản sẽ bị khóa 10 ngày nếu hết hạn, sẽ có tin nhắn cảnh bảo trước 3 ngày trước khi hết hạn.



## Tạo group:

- Nhóm là tập hợp của nhiều user. Mỗi nhóm có tên duy nhất, và có một mã định danh duy nhất (gid). Khi tạo một user (không dùng option -g) thì mặc định một group được tạo ra

- File /etc/group: Là file chứa thông tin về group user trên máy. Mọi user đều có thể đọc nhưng chỉ có root mới có quyền thay đổi.

    ![images](usergroup3.png)

- Lệnh groupadd:
        
    Cấu trúc: `groupadd [Options] Group`

    - -g GID: Định nghĩa nhóm với mã nhóm GID
    - Group: Tên nhóm định nghĩa

    - Ví dụ: Tạo nhóm users

        *Tạo nhóm accounting với GID = 200*

        `groupadd –g 200 accounting`

- Lệnh groupmod: Sửa thông tin nhóm
        
     * Cấu trúc lệnh: `groupmod [options] group`

    - -g GID: Sửa mã nhóm thành GID
    - -n group_name: Sửa tên nhóm thành group_name
    - Group: Tên nhóm cần chỉnh sửa.
        
    - Ví dụ: *Sửa gid của nhóm users thành 201*

        `groupmod –g 201 users`

        *Đổi tên nhóm accounting thành accountant*

        `groupmod –n accountant accounting`
- Lệnh groupdel: dùng để xóa nhóm

    - Ví dụ: xóa nhóm testgroup

        `groupdel testgroup`


---
## Review Quiz

* UID của root =0
* Tập tin cấu hình của sudo: /etc/sudoers
* Sử dụng câu lệnh nào để sửa đổi cấu hình sudo :`visudo`
* File chứa các cài đặt khi tạo hay sửa user: `/etc/default/useradd` và `/etc/login.defs`
* Add user vào group nào để các user đó đều được dùng quyền sudo: `wheel`
*  Câu lệnh dùng để sửa đổi file /etc/group: vigr
* Câu lệnh dùng để đổi pass cho user: `passwd` và `chage`
* File chứa thông tin password của user: `/etc/shadow`
* File chứa thông tin của group: `/etc/group`