
- Cài đặt `ssh-keygen` cho control_server và các remote_server
- Chỉnh sửa file `/etc/ansible/hosts` như file [tại đây](hosts)
- Vào thư mục chứa file `install_zabbix.yml` và chạy lệnh `ansible-playbook install_zabbix.yml` 
- Chỉnh sửa các khai báo về biến [tại đây](ansible-centos-zabbix/zabbix/vars/main.yml)