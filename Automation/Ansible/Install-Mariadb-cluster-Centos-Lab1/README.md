
- Cài đặt `ssh-keygen` cho control_server và các remote_server
- Chỉnh sửa file `/etc/ansible/hosts` như file [tại đây](hosts)
- Thực hiện tạo đường dẫn `/etc/ansible/group_vars/` trong đây ta tạo các file có cùng tên với tên của các hosts như [tại đây](group_vars)
- Vào thư mục chứa file `ansible-mariadbcluster-centos7.yml` và chạy lệnh `ansible-playbook ansible-mariadbcluster-centos7.yml` 
