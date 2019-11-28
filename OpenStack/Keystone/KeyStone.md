# Tìm hiểu về Keystone
# Mục lục:

[1. Giới thiệu](#1)

[2. Các thành phần trong Keystone](#2)

[3. Các chức năng trong Keystone](#3)

[4. Cách thức hoạt động với Keystone Token](#4)

[ 5. LAB Cài đặt Keystone](#5)

[ Tham khảo](#tk)

<a name="1"></a>

## 1.  Giới thiệu về Keystone

*Trong môi trường cloud cần một tính năng quan trọng khi cần cung cấp tài nguyên một cách bảo mật, truy cập điều khiển an toàn vào các tài nguyên có giá trị .*

Trong OpenStack (OPS), Keystone là một trong những project core (tức là nếu không có project này thì sẽ không thể dựng được hệ thống). Project này cung cấp sự an toàn tới tất cả các tài nguyên trong môi trường Cloud.

<a name="2"></a>

## 2. Các thành phần trong Keystone


![images](Images/Keystonebe.png)

- Token Backend:  xác nhận và quản lý các Tokens sử dụng cho việc xác thực các yêu cầu sau khi thông tin của các user/project đã được xác thực.

- Catalog Backend: Keystone sẽ cung cấp cho bạn một catalog, danh sách các service, endpoints mà bạn có quyền làm và truy nhập.
( cung cấp danh sách các APIs để giao tiếp với các service)
- Policy Backend: Cung cấp cơ chế ủy quyền rule-based

- Identity Backend: Lưu trữ các AD(windows), LDAP là cơ chế xác thực tập trung. Keystone có thể sử dụng có sẵn các user của hệ thống xác thực tập trung để tích hợp vào hệ thống OpenStack. Khối Identity cung cấp dữ liệu về Users, Projects, Roles cũng như các metadata khác.

    + KVS Backend(hiện tại không còn sử dụng): là giao diện backend đơn giản hỗ trợ tìm kiếm theo khóa chính
    + SQL Backend: cung cấp hệ thống backend bền vững để lưu trữ thông tin
    + PAM Backend: Hệ thống backend mở rộng cung cấp quan hệ 1-1 giữa user và tenants(sử dụng trong các phiên bản cũ như Gzilly ).
    + LDAP Backend: LDAP là hệ thống lưu trữ các user và project trong các subtree tách biệt nhau.
    + Multiple Backend: sử dụng kết hợp nhiều hệ thống Backend, trong đó SQL lưu trữ các service account (tài khoản của các dịch vụ như: nova glance, etc.), còn LDAP sử dụng lưu trữ thông tin người dùng, etc.


<a name="3"></a>

# 3. Các chức năng trong Keystone

Tất cả project đều kết nối đến KeyStone. Các project sau khi nhận được yêu cầu thì để xem yêu cầu có hợp lệ không thì sẽ gửi qua KeyStone để xác thực.

- Keystone sẽ trả lời các câu hỏi :

    - Bạn là ai? (Identity)
    - Bạn có quyền làm gì? (Role)
    - Bạn làm ở đâu ?(Project) đại diện cho tài nguyên mà người dùng có thể sử dụng
    ( ví dụ : được tạo tối đa 10 vcpu thì chỉ tạo được 5 máy ảo mỗi máy 2 vcpu)
    - Domain role : Gom gộp tài nguyên của người dùng
    ( ví dụ :2 công ty dùng chung 1 hệ thống nhưng có user trùng tên thì sẽ phân biệt bằng domain)

- Cung cấp dịch vụ xác thực cho toàn bộ hạ tầng Openstack (ví dụ: kiểm tra tạo xóa vm-> xác thực với nova , tạo xóa volume -> xác thực với cinder ).

- Tạo sự kết nối cho phép user và group được kết nối với các role trên project và domain.

- Catalog - mục lục lưu trữ các các dịch vụ, enpoints, và regions của OPS, cho phép các clients tìm ra dịch vụ hoặc enpoint mà họ cần.

<a name="4"></a>

4. Cách thức hoạt động

- Tất cả các project trong OPS giao tiếp qua APIs .

- Mỗi project khi nhận được token yêu cầu sẽ gửi lại cho Keystone yêu cầu xác thực rồi mới thực hiện service.

![keystone](Images/Keystonetk.png)

- Keystone quản lý các user, project(tenants), roles, chịu trách nhiệm xác thực và ấn định quyền truy cập các tài nguyên trong hệ thống. Có ba khái niệm chính trong tính năng User Management:
    - User: là tải khoản của người sử dụng dịch vụ, bao gồm một số thông tin như: username, password, email
    - Project(tenant): khái niệm liên quan tới việc gộp, cô lập các nguồn tài nguyên. Tự các project không hề có user. Người dùng được gán roles đối với mỗi project, quy định quyền truy cập tài nguyên trong project.
    - Roles: chỉ định các thao tác vận hành hệ thống được phép thực hiện, tài nguyên mà người dùng được phép sử dụng.
- Keystone Service Management: 
    - Keystone cũng cung cấp danh mục các dịch vụ cùng với các API endpoints để truy cập các dịch vụ đó. Có hai khái niệm chính trong tính năng "service management":
    - Services: các dịch vụ khác trong OpenStack sẽ có tài khoản tương ứng (thường có có tên tài khoản trùng code name của dịch vụ như nova, glance, etc.). Các tài khoản này thuộc domain đặc biệt tên là service.
    - Endpoints: điểm đầu mối để truy cập các dịch vụ, thể hiện bằng URL để truy cập các dịch vụ đó.


<a name="5"></a>

# LAB cài đặt Keystone

Trong các bài LAB tôi sử dụng SQL Backend

### Tạo database lưu trữ các thông tin của Keystone

- Bước 1. Truy nhập database với người dùng root:

```
#mysql
```

- Bước 2. Tạo user Database keystone:

```
MariaDB [(none)]> CREAT DATABASE keystone;
```

- Bước 3. Gán quyền truy nhập cho các người dùng trên database keystone:

```MariaDB [(none)]> GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'localhost' \
IDENTIFIED BY 'KEYSTONE_DBPASS';
MariaDB [(none)]> GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'%' \
IDENTIFIED BY 'KEYSTONE_DBPASS';
```

Thay thế KEYSTONE_DBPASS bằng password của bạn.

``` 
exit ;
```

### Cài đặt và cấu hình Keystone cơ bản

- Bước 1: Chạy câu lệnh sau để cài đặt các gói phần mềm của keystone

```
# apt install keystone
```
- Bước 2: Chỉnh sửa file /etc/keystone/keystone.conf 

*Lưu ý : chỉnh sửa Password đúng như cấu hình , các options connection khác trong section [database] phải loại bỏ.

``` 
# vim /etc/keystone/keystone.conf 

[database]
# Chỉnh sửa kết nối tới Database
connection = mysql+pymysql://keystone:KEYSTONE_DBPASS@controller/keystone

[token]
# Sử dụng token Fernet
provider = fernet
```

- Bước 3: Đồng bộ các thông tin của Keystone vào database keystone:

```
su -s /bin/sh -c "keystone-manage db_sync" keystone
```

- Bước 4: Cài đặt thư mục chứa key reposity sinh key cho keystone

```
# keystone-manage fernet_setup --keystone-user keystone --keystone-group keystone
# keystone-manage credential_setup --keystone-user keystone --keystone-group keystone
```

- Bước 5: Sử dụng Bootrap tạo ra một số thành phần cần thiết :
```
keystone-manage bootstrap --bootstrap-password ADMIN_PASS \
  --bootstrap-admin-url http://controller:35357/v3/ \
  --bootstrap-internal-url http://controller:5000/v3/ \
  --bootstrap-public-url http://controller:5000/v3/ \
  --bootstrap-region-id RegionOne
  ```

  ### Cấu hình Apache HTTP server

  - Chỉnh sửa file /etc/apache2/apache2.conf

  cấu hình tùy chọn ServerName , tham chiếu tới controller node:

  ```
  ServerName controller
  ```

  Khởi động lại dịch vụ Apache và xóa đi database mặc định của Keystone ( được thiết lập lúc cài đặt Keystone)

  ```
  # service apache2 restart
  # rm -f /var/lib/keystone/keystone.db
```

Cấu hình token

 ```
[token]
…
expiration = 3600				# xác định thời gian có hiệu lực của token (tính bằng second)
provider = fernet				# xác định kiểu token sử dụng (mặc định là fernet (bản Ocata), có hỗ trợ token pki và uuid)
driver = sql					# backend cho lưu trữ token
caching = true					# thiết lập cho phép cache lại token
cache_time = <None>				# thiết lập thời gian cache lại token
revoke_by_id = true				# thiết lập cho phép đánh dấu token bị revoke bằng id
allow_rescope_scoped_token = true	  # thiết lập cho phép gia hạn lại token sắp hết hạn
```
<a name="6"></a> 

---
## Tham khảo

https://github.com/hocchudong/thuctap032016/blob/master/ThaiPH/OpenStack/Keystone/ThaiPH_Keystone_General_Info.md

https://github.com/TrongTan124/OpenStack-Mitaka-Scripts/blob/master/DOCS-OPS-Mitaka/Caidat-OpenStack-Mitaka.md
