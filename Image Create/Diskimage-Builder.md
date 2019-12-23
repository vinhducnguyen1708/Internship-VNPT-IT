# Disk image Builder (DIB)

## Mục lục 
- [1. Giới thiệu](#1)
- [2. Thành phần](#2)
- [3. Ví dụ](#3)

---

## 1. Giới thiệu
### 1.1 Khái niệm
- Diskimage-builder là một công cụ dựng OS disk image của Openstack.

- DIB còn cho phép bạn Customise OS disk image cho nhiều các distributions của Linux và có thể sử dụng Disk image đó trên nhiều các cloud provider khác như AWS hoặc Azure.

- Cho phép bạn tạo một Image theo format tùy chọn mà không cần thao tác tạo OS như bình thường.

### 1.2 OS support to build Images

- Distro được support để là host build Image:
    
    -  Centos 6, 7

    - Debian 8 (“jessie”)

    - Fedora 28, 29, 30

    - RHEL 6, 7

    - Ubuntu 14.04 (“trusty”)

    - Gentoo

    - openSUSE Leap 42.3, 15.0, 15.1 and Tumbleweed

- Distro được support tạo thành Image : 
     
    -  Centos 6, 7

    - Debian 8 (“jessie”)

    - Fedora 28, 29, 30

    - RHEL 6, 7

    - Ubuntu 12.04 (“precise”), 14.04 (“trusty”)

    - Gentoo

    - openSUSE Leap 42.3, 15.0, 15.1 and Tumbleweed (opensuse-minimal only)

### 1.3 So sánh với các tools khác 

![ima](ima/DIB.png)
(https://www.virtualization.net/creating-custom-elements-for-diskimage-builder-9798/)

## 2. Thành phần 

*Thành phần chính của Diskimage là command bao gồm các element và các biến môi trường cho mỗi element.*

- Các element được thêm vào qua command. Element là cách quyết định chuyện gì xảy ra với image và những sửa đổi gì sẽ được thực hiện.

- Một image  được tạo ra thì sẽ mặc định formats là `qcow2`. Nếu muốn sử dụng format khác bằng cách chèn `-t <format>` sử dụng cách format được hỗ trợ:
    - qcow2
    - tar
    - tgz
    - squashfs
    - vhd
    - docker
    -raw

- Khi sử dụng `vm` element, phải đi kèm element cung cấp `block-device` 
    - `block-device-*` element cung cấp tất cả các chuẩn phân vùng ổ đĩa bao gồm (mbr, gpt,)
    - Ví dụ : ``` disk-image-create -o output.qcow vm block-device-gpt ubuntu-minimal ```
    
--- 
http://www.rushiagr.com/blog/2016/01/02/build-vm-image-using-diskimage-builder/

https://docs.openstack.org/diskimage-builder/latest/user_guide/index.html