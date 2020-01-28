# Chapter 3: Ad-hoc commands

---

## Một vài ví dụ khi sử dụng Ansible tương tác với server

- [1.Check Basic config](#1)

- [2.Install package](#2)

- [3.Manage service](#3)

- [4.Manage users and groups](#4)

- [5.Manage files and directories](#5)

- [6.Run operations in the background](#6)

- [7.Check log files](#7)

---

<a name = '1'></a>
### 1.Check Basic config

*( Tôi không định nghĩa passwd hoặc ssh key trong inventory nên phải dùng tham số -k để điền password thủ công)*

- **Check hostname:**
	
	- `ansible -i /etc/ansible/hosts node-centos -a "hostname" -u root -k`

- **Free disk:**
	
	- `ansible -i /etc/ansible/hosts node-centos -a "df -h" -u root -k`

- **Memory:**
	
	-  `ansible -i /etc/ansible/hosts node-centos -a "free -m" -u root -k`

- **Date:**

	- `ansible -i /etc/ansible/hosts node-centos -a "date" -u root -k`

<a name = '2'></a>
### 2.Install Package

- **Install NTP package:**
	
	- `ansible -i /etc/ansible/hosts node-centos -m yum -a "name=ntp state=installed" -u root -k`
	
- **Install Mariadb:**

	- `ansible -i /etc/ansible/hosts node-centos -m yum -a "name=mariadb-server state=present" -u root -k"

<a name = '3'></a>
### 3.Manage service 

- **Start service:**

	- `ansible -i /etc/ansible/hosts node-centos -m service -a "name=ntpd state=started enabled=yes" -u root -k`
	*(Giải thích: ở đây tôi thực hiện `start` service `ntpd` và cài đặt khi boot sẽ tự start service)*
	
- **Stop service:**
	
	- `ansible -i /etc/ansible/hosts node-centos -a "service ntpd stop" -u root -k`
	
- **Check service status:**

	- `ansible -i /etc/ansible/hosts node-centos -a "service ntpd status" -u root -k`

- **Restart service trên node chỉ định:**

	- `ansible -i /etc/ansible/hosts node-centos -a "service ntpd restart" --limit "192.168.60.4" -u root -k`

<a name = '4'></a>
### 4.Manage users and groups

- **Add a group:**
	
	- `ansible -i /etc/ansible/hosts node-centos -m group -a "name=madebyansible state=present gid=1708" -u root -k`
	*(Kiểm tra: cat /etc/group)*
	
- **Add a user:**

	- `ansible -i /etc/ansible/hosts node-centos -m user -a "name=vinhansibletest group=madebyansible createhome=yes" -u root -k`
	*(Kiểm tra: cat /etc/passwd)*
- **Delete a user:**

	- `ansible -i /etc/ansible/hosts node-centos -m user -a "name=vinhansibletest state=absent remove=yes" -u root -k`

<a name = '5'></a>
### 5.Manage files and directories

- **Check file's permissions:**

	- `ansible -i /etc/ansible/hosts node-centos -m stat -a "path={your_file_path}" -u root -k

- **Copy a file to the servers:**

	- `ansible -i /etc/ansible/hosts node-centos -m copy -a "src=/root/hosts dest=/tmp/hosts" -u root -k`
	*(src={files in ansible server} dest={client servers})*
	
- **Retrieve a file from the servers:**	

	- `ansible -i /etc/ansible/hosts node-centos -m fetch -a "src={path_client_servers} dest={path_ansible_server}" -u root -k`
	
- **Create directories and files:**

	- `ansible -i /etc/ansible/hosts node-centos -m file -a "dest=/tmp/test mode=644 state=directory" -u root -k`
	
	- Create a symlink : `ansible -i /etc/ansible/hosts node-centos -m file -a "src=/src/symlink dest=/dest/symlink \ owner=root group=root state=link"`

- **Delete directories and files:**

	- `ansible -i /etc/ansible/hosts node-centos -m file -a "dest=/tmp/test state=absent"`

<a name = '6'></a>
### 6.Run operations in the background 

- **Update servers asynchronously:**

	- `ansible -i /etc/ansible/hosts node-centos -B 3600 -a "yum -y update" -u root -k`
	*( -B: thời gian tối đa chạy tác vụ (seconds), -P: thời gian trễ khi 2 server giao tiếp để thực hiện tác vụ)*
	
<a name = '7'></a>
### 7.Check log files

- `ansible -i /etc/ansible/hosts node-centos -a "tail /var/log/{file_log}" -u root -k`
