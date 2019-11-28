# Bài viết các thao tác làm việc với keystone

## *Mục lục*

- [1. Sử dụng với giao diện dòng lệnh](#1)

    - [1.1 Get Token](#1.1)
    - [1.2 Listing user](#1.2)
    - [1.3 Listing project](#1.3)
    - [1.4 Listing role](#1.4)
    - [1.5 Listing domain](#1.5)
    - [1.6 Listing group](#1.6)
    - [1.7 Tạo Domain](#1.7)
    - [1.8 Tạo một Project trong domain](#1.8)
    - [1.9 Tạo user trong Domain](#1.9)
    - [1.10 Gán role cho user cho 1 project](#1.10) 
    - [1.11 Xác thực người dùng mới](#1.11)

- [2. Sử dụng Keystone với Horizon](#2)

 - [Tham khảo](#tk)


---

<a name="1.1"></a>

### 1.1 Get Token

Vì đã thiết lập dữ liệu xác thực như biến môi trường cho hệ thống nên chúng ta có thể đơn giản xin cấp phát token như sau:

```
openstack token issue
```
![images](images/lenhkeystone1.png)

<a name="1.2"></a>
### 1.2 Listing Users

- Sau khi chạy OPS, một số người dùng có thể tự động được tạo, thông thường đó là những tài khoản dịch vụ của OPS (Cinder, Glance và Nova), một tài khoản quản trị (admin) và tài khoản người dùng demo đại diện cho khách hàng.
```
openstack user list
```
![images]images/(lenhkeystone2.png)

<a name="1.3"></a>
### 1.3 Listing projects

- Giống như user, OPS cũng mặc định tạo một số project. Chúng có thể liệt kê sử dụng câu lệnh sau:

```
openstack project list
```

![images](images/lenhkeystone3.png)

<a name="1.4"></a>
### 1.4 Listing roles

Cũng giống như các câu lệnh trên, OPS cũng tạo một số role mặc định và gán chúng với một số user trên project

```
openstack role list
```
![images](images/lenhkeystone4.png)

<a name="1.5"></a>
### 1.5 Listing domains

- Keystone tự động có một domain luôn trong trạng thái up, để xử lý các khả năng tương thích ngược giữa các versions Identity API

```
openstack domain list
```
![images](images/lenhkeystone5.png)
<a name="1.6"></a>
### 1.6 Listing groups

- Giống như user, OPS cũng mặc định tạo một số group. Lưu ý là các user có thể là thành phần của group hoặc không.

<a name="1.7"></a>
### 1.7 Tạo một Domain khác

```
openstack domain create vinhcompany
```
![images](images/lenhkeystone7.png)

<a name="1.8"></a>
### 1.8 Tạo một Project trong Domain

- Để tạo một project trong Domain, cần xác định domain và chúng ta đã tạo ở bước trước và có thể thêm mô tả để phân biệt.

```
openstack project create vinhtest --domain vinhcompany --description "vinh dang test"

```
![images](images/lenhkeystone8.png)

<a name="1.9"></a>
### 1.9 Tạo User trong Domain

- Tạo user trong domain, cần xác định domain đã tạo trước, thiết lập password và email cho user là nên tùy chọn, nhưng nên làm.

```
openstack user create vinh178 --email vinh178@gmail.com \
--domain vinhcompany --description "vinh178 openstack user account" \
--password vinh178
```

![images](images/lenhkeystone9.png)

<a name="1.10"></a>
### 1.10 Gán role user truy nhập vào project

- Để gán một role tới user mới trên project mới có thể dùng lệnh, nhưng tất cả user và project phải được xác định trong cùng domain, hoặc Openstack client sẽ sử dụng domain default nếu không xác định thông số domain.

```
openstack role add member --project vinhtest --project-domain vinhcompany --user vinh178 --user-domain vinhcompany
```

![images](images/lenhkeystone10.png)
<a name="1.11"></a>
### 1.11 Xác thực người dùng

- Để xác thực như một user mới tạo, tốt nhất là dùng terminal và thiết lập lại biến môi trường. trong trường hợp này, thông tin user name, pasword, project và domain phải được đặt như dưới đây

```
$ export OS_PASSWORD=vinh178
$ export OS_IDENTITY_API_VERSION=3
$ export OS_AUTH_URL=http://controller:5000/v3
$ export OS_USERNAME=vinh178
$ export OS_PROJECT_NAME=vinhtest
$ export OS_USER_DOMAIN_NAME=vinhcompany
$ export OS_PROJECT_DOMAIN_NAME=vinhcompany
```
![images](images/lenhkeystone11.png)


--- 
<a name="1.2"></a>
## Tham khảo

https://github.com/thaihust/Thuc-tap-thang-03-2016/blob/master/ThaiPH/OpenStack/Keystone/Identity_Authentication_Access-Management_in_OpenStack/ThaiPH_Chap-2-Using-KeyStone.md