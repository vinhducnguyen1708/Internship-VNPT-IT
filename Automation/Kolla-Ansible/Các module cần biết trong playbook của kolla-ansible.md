# Playbook site.yml

#### `Serial`
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
#### `Group_by`

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
#### `set_fact`
- Khái niệm:
    - Module bản chất là một module cho phép đặt thêm các giá trị 
---
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
- Đây là một file chứa biến của 1 role, các biến này được sử dụng rất nhiều lần nên khai báo khá rối, thậm chí trong 1 `tasks` của `mariadb` còn kéo 1 role tên là `haproxy-config` về để chạy các biến ở role `mariadb` này. 
- Nên tôi chỉ ra một vài biến được khai báo trong file `/group_vars/all.yml` để custom cho role này.
- **Ví dụ** Ở đoạn này: 
    ```
    mariadb_services:
    mariadb:
        container_name: mariadb
        group: mariadb
        enabled: true
        image: "{{ mariadb_image_full }}"
        volumes: "{{ mariadb_default_volumes + mariadb_extra_volumes }}"
        dimensions: "{{ mariadb_dimensions }}"
    ....

    mariadb_default_volumes:
    - "{{ node_config_directory }}/mariadb/:{{ container_config_directory }}/:ro"
    - "/etc/localtime:/etc/localtime:ro"
    - "mariadb:/var/lib/mysql"
    - "kolla_logs:/var/log/kolla/"
    mariadb_extra_volumes: "{{ default_extra_volumes }}"
    ....

    ```
    
    - Đoạn đầu Ta nhìn thấy như 1 cây thư mục @@ bởi vì các biến này sẽ được gọi bằng cách gọi đến biến `{{ mariadb_services }}` nhưng thêm tham số khai báo service con như đây :

    ![ima](ima/kolla-mariadb2.png)

    - Phía dưới là các khai báo biến thông thường và lấy từ file `/group_vars/all.yml` như là các biến `{{ default_extra_volumes }}`, `{{ node_config_directory }}`, `{{ container_config_directory }}` 
    - Nếu bạn thắc mắc các dấu "-" kia và khi khai báo biến `volumes: "{{ mariadb_default_volumes + mariadb_extra_volumes }}"` sẽ có kết quả như thế nào.
    ```
    #đây là kết quả tôi đã viết thử playbook ansible và test
    image: 
        - "{{ node_config_directory }}/mariadb/:{{ container_config_directory }}/:ro"
        - "/etc/localtime:/etc/localtime:ro"
        - "mariadb:/var/lib/mysql"
        - "kolla_logs:/var/log/kolla/"
        - "{{ default_extra_volumes }}"
    # Tức là lại khai báo thêm biến con `image` có giá trị phía dưới
- Ví dụ 2:
    ```
    ...
    mariadb_backup_host: "{{ groups['mariadb'][0] }}"
    ...
    ```
    - Ở đây tức là lấy tên host hoặc địa chỉ ip được khai báo ở group `[mariadb]` trong file `/iventory/all-in-one` hoặc `/inventory/multinode` và thông số `[0]` là lấy thông tin dòng đầu tiên(host ở dòng đầu)

---
<a name='2'></a>
## **Handlers: Mariadb**
- *Đây là nơi thực hiện khai báo các tác vụ chờ được gọi bằng tasks trong các file trong thư mục `/tasks/...yml`*
<a name='2.1'></a>
### Handlers/main.yml : Mariadb

#### `listen`
- Khái niệm:
    - Đây là module được sử dụng trong mục `handlers` nhằm khai báo các task chờ để sau đó gọi bằng `notify` trong tasks chính.
- Khi Kolla-Ansible sử dụng: 

![ima](ima/kolla-mariadb1.png)


#### `kolla_toolbox` 
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

#### `wait_for`,`delay`,`until`,`retries`

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



