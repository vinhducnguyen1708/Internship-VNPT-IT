# Chapter 5: Ansible Playbook: Beyond the basic

## Mục lục:

- [1. Sử dụng handlers](#1)
- [2. Variables ](#2)
    - [2.1 - Playbook variables](#2.1)
    - [2.2 - Inventory variables](#2.2)
- [3. Register, when, ignore_errors, pause](#3)


<a name = '1'></a>
## 1. Sử dụng handlers
- Đây là nơi thực hiện các tác vụ với service khi chạy một playbook, `handlers` sẽ được định nghĩa ở file riêng hoặc ngay trong `playbook` và sử dụng bằng cách gọi option `notify` trong `tasks`.

- Việc này sẽ tránh gây nhầm lẫn và dài dòng khi viết `task`

- Đặc điểm: 
    - `Handlers` sẽ chỉ chạy khi được gọi.
    - `Handlers` chỉ chạy duy nhất một lần.
    - Nếu quá trình chạy playbook trên một host fail thì Handlers sẽ không chạy 
- Ví dụ 1: Dùng Handlers
    - ``` 
        handlers:
            - name: restart apache
              service: name=apache2 state=restarted
        tasks:
            - name: Enable Apache rewrite module.
              apache2_module: name=rewrite state=present
              notify:
                - restart apache
                - ...
        ```
- Ví dụ 2: Xích handlers này với handlers khác
    - ```
       handlers:
            - name: restart apache
              service: name=apache2 state=restarted
              notify: restart memcached
            - name: restart memcached
              service: name=memcached state=restarted
        ```
<a name = '2'></a>
## 2. Variables
- Cách gán biến không hợp lệ:  `_foo, foo-bar, 5_foo_bar, foo.bar and foo bar.` 
- Trong file inventory : `foo=bar`
- Trong file playbook hoặc file tự định nghĩa: `foo: bar` 
<a name = '2.1'></a>
### 2.1 - Playbook variables
- Cách gán biến trên command: 
``` 
ansible-playbook example.yml --extra-vars "foo=bar"
```
- Gán biến trong file playbook:
```
---
- hosts: node-centos
  vars:
    foo: bar
  tasks:
    - debug: msg="Variable 'foo' is set to {{ foo }}"
```
- Gán biến dựa trên file chỉ định : Sử dụng option `vars_files`
```
# Trong file vars.yml
---
foo: bar
# Trong file playbook
---
- hosts: node-centos
  vars_files:
    vars.yml
  tasks:
    - debug: msg="Variable 'foo' is set to {{ foo }}"
```

<a name = '2.2'></a>
### 2.2 Inventory variables
- Ví dụ: 
```
[node-centos]
192.168.30.37
...
[node-centos:vars]
foo=bar
```
- Nhưng nếu bạn muốn set nhiều biến thì tạo thêm thư mục `host_vars` (đối với 1 host) `group_vars`(ưu tiên vì dùng với 1 hoặc nhiều host) trong thư mục tạo thêm file tên của `host` hoặc `group` , ví dụ: `/etc/ansible/group_vars/node-centos`. Trong file `node-centos` định nghĩa các biến như file `vars.yml`
```
foo: value
```
<a name = '3'></a>
## 3. Register, when, ignore_errors, pause
### Register

- Trong Ansible, mọi kết quả của 1 tác vụ có thể `register` thành một biến và sau khi `register` biến đó có thể sẵn sàng được sử dụng cho các tác vụ tiếp theo.

- Các biến được `register` hoạt động như biến thông thường 
- Sử dụng nhận output như (stout hoặc stderr) của lệnh shell
- Ví dụ: 
```
- command: service status mysql
  register: mysql_result
```
### When
- Là một optin kiểm tra trước khi chạy của một tác vụ

- Thường sử dụng `register` đi kèm với `when` để gán biến tác vụ rồi dùng `when` để kiểm tra.
- Ví dụ 1: Thực hiện xóa một file .  
```
# Gán hostname của server (node1) vào 1 biến
- command: cat /etc/hostname
  register: hostname_result
# Thực hiện xóa file nếu đúng node1
- command: rm -rf abc.txt
  when: "'node1' in hostname_result.stdout"
```
- Ví dụ 2: Thực hiện copy 1 file từ server remote sang server client nếu tồn tại
```
# Kiểm tra thông số file
- stat: /root/testmysqlansible.yml
  register: yaml_file
- copy: src=/root/testmysqlansible dest=/root/{custom_name}
  when: yaml_file.stat.exists == false
```
- Ví dụ 3: Thực hiệp update nếu version php là 7.0
```
- shell: php --version
  register: php_version
- shell: yum -y update 
  when: "'7.0' in php_version.stdout
```