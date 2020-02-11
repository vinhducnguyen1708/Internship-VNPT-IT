|Modules | Khái niệm| Sử dụng trong Kolla-A  |Chức năng trong K-A|
|--------|----------|------------------------|-------------------|
| `serial`| module này sẽ giúp bạn thực hiện chạy playbook đồng thời trên nhiều node, để ví dụ nếu update các phiên bản sẽ tránh việc các node mất đồng bộ dẫn đến fail service | `serial: '{{ kolla_serial|default("0") }}'` |Ở đây Kolla-A tự tạo ra một biến là `kolla_serial` nhằm thực hiện tùy chỉnh thông số của module `serial` nếu không muốn mặc định là `0`. Ví dụ: `kolla-ansible bootstrap-servers -i INVENTORY -e kolla_serial=3`| 
| col 2 is      | centered      |   $12 ||
| zebra stripes | are neat      |    $1 ||