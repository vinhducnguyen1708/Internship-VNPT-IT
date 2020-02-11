# Playbook site.yml


### `Serial`
- Khái niệm:
    - Module này sẽ giúp bạn thực hiện chạy playbook đồng thời trên nhiều node, để ví dụ nếu update các phiên bản sẽ tránh việc các node mất đồng bộ dẫn đến fail service
- Khi Kolla-Ansible sử dụng: 
```
serial: '{{ kolla_serial|default("0") }}'
```
- Chức năng khi sử dụng module này trong kolla-Ansible:
    - Ở đây Kolla-A tự tạo ra một biến là `kolla_serial` nhằm thực hiện tùy chỉnh thông số của module `serial` nếu không muốn mặc định là `0`. Ví dụ:
```
kolla-ansible bootstrap-servers -i INVENTORY -e kolla_serial=3
```
### `Group_by`

- Khái niệm:
    -  Nhằm thực hiện đọc ghi thư mục inventory (trong kolla-ansible là `globals.yml` và `/group_vars/all.yml`) Ansible sinh ra 2 module `add_host` và `group_by`.
- Khi Kolla-Ansible sử dụng: 
```
    - name: Group hosts based on enabled services
      group_by:
        key: "{{ item }}"
      with_items:
        - enable_aodh_{{ enable_aodh | bool }}
        - enable_barbican_{{ enable_barbican | bool }}
       ...
```
- Chức năng khi sử dụng module này trong kolla-Ansible:
    
    - Ở đây, tasks này được gọi ở đầu playbook `site.yml` nhằm mục đích đọc và ghi lại các service nào đã được ta khai báo trong file `/group_vars/all.yml`
    - `bool` ở đây là bộ lọc để xác định biến ta khai báo có phải là `1`,`yes`,`true` không . Nếu đúng thì service ta chỉ định enable sẽ được cài.
    - Ví dụ ta khai báo trong  `/group_vars/all.yml` :
    ```
    ...
    enable_fluentd: "yes"
    enable_grafana: "no"
    ...
    ```


# Role Mariadb

# Cấu trúc: 

- [defaults](#1)
    - [main.yml](#1.1)
- [handlers](#2)
    - [main.yml](#2.1)
- [meta](#3)
    - [main.yml](#3.1)
- [tasks](#4)
- [templates](#5)

<a name='1'></a>
## **Defaults: Mariadb**

- *Tại file `/roles/mariadb/default/main.yml` là nơi chứa các biến sử dụng cho roles `mariadb`*
- Ở đấy khai báo khá nhiều biến và có các biến được khai báo liên kết với nhau  
<a name='1.1'></a>
### Defaults/main.yml : Mariadb


<a name='2'></a>
## **Handlers: Mariadb**
- *Đây là nơi thực hiện khai báo các tác vụ chờ được gọi bằng tasks trong các file trong thư mục `/tasks/...yml`*
<a name='2.1'></a>
### Handlers/main.yml : Mariadb

### `listen`
- Khái niệm:
    - Đây là module được sử dụng trong mục `handlers` nhằm khai báo các task chờ để sau đó gọi bằng `notify` trong tasks chính.
- Khi Kolla-Ansible sử dụng: 

![ima](ima/kolla-mariadb1.png)


### `kolla_toolbox` 
- Khái niệm: 
    - Ở đây kolla-ansible sử dụng một module là `kolla-toolbox` để gọi đến các module của các service đặc thù bằng option `module_name` để gọi tên module và `module_args` là các thành phần trong module được gọi
    ( Dài dòng so với ansible)
- Khi Kolla-Ansible sử dụng: 
    ```
    - name: Creating haproxy mysql user
  become: true
  kolla_toolbox:
    module_name: mysql_user
    module_args:
      login_host: "{{ api_interface_address }}"
      login_port: "{{ mariadb_port }}"
      login_user: "{{ database_user }}"
      login_password: "{{ database_password }}"
      name: "haproxy"
      password: ""
      host: "%"
      priv: "*.*:USAGE"
   ```

- Chức năng khi sử dụng module này trong kolla-Ansible:
    - Đây đơn giản là một thao tác tạo Database user cho Haproxy

### `wait_for`,`delay`,`until`,`retries`

- Khái niệm: 
    - Module này sử dụng để chờ 1 service, host, port được khởi tạo trong một môi trường

- Khi Kolla-Ansible sử dụng: 
  ```
    - name: Wait for first MariaDB service port liveness
  wait_for:
    host: "{{ api_interface_address }}"
    port: "{{ mariadb_port }}"
    connect_timeout: 1
    timeout: 60
    search_regex: "MariaDB"
  register: check_mariadb_port
  until: check_mariadb_port is success
  retries: 10
  delay: 6
  ```
- Chức năng khi sử dụng module này trong kolla-Ansible:

    - Xác định trạng thái của `port` mariadb là mục tiêu chờ
    -  thông số `connect_timeout` : maximum giây đợi tồn tại port mariadb tồn tại hay k trước khi đóng hoặc thử lại
    - thông số `timeout`: số giây tối đa chờ xuất hiện port
    - module `register` ở đây thực hiện gán kết quả của việc kiểm tra port có tồn tại hay không
    - `until: check_mariadb_port is success` cho đến khi port tồn tại thì chạy tiếp còn nếu không thực hiện `retries` 10 lần mỗi lần `delay` 6s rồi failed



