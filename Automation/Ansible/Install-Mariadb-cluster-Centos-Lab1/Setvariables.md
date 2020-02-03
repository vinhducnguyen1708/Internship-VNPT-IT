- Trong thư mục `/etc/ansible` Tạo thư mục `group_vars`
- Trong thư mục `group_vars` tạo 2 file có cùng tên với node đặt ở file `Inventory` 
	- `node-centos-master` có nội dung:
		
		- ```
		  node_ips: 192.168.30.37,192.168.20.29,192.168.30.31
		  node_master: 192.168.30.37
		  node_number: node1
		  ```
	- `node-centos-slave1` có nội dung:
	
		- ```
		  node_ips: 192.168.30.37,192.168.20.29,192.168.30.31
		  node_slave: 192.168.20.29
		  node_number: node2
		  ```