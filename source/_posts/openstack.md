##### 虚拟化

https://blog.csdn.net/dianxin113/article/details/73864341

https://juejin.im/post/5d5b9c1d5188255db76c022a

https://zhangchenchen.github.io/2016/08/15/openstack-network-virtualization/

KVM（Kernel-Based Virtual Machine） 管理虚拟CPU和内存；

Libvirt 是KVM的管理工具；



VMware vSphere 可以独立安装和运行在裸机上的系统。

- ESXi 虚拟机管理程序，用于创建并运行虚拟机和虚拟设备的虚拟化平台；

- vCenter Server是一项服务，用于管理网络中连接的多个主机，并将主机资源池化；

https://zhuanlan.zhihu.com/p/69214067 关于VMware vSphere



nova compute 运行在计算节点，通过libvirt 管理KVM，通过调用 Hypervisor API 实现虚机生命周期管理。

Hypervisor 计算节点上运行的虚拟化管理程序，虚拟管理最底层的程序， 不同虚拟化技术提供自己的 Hypervisor。常用的 Hypervisor 有 KVM，Xen， VMWare 等。 



VMware 与 OpenStack 集成方案

http://www.dataguru.cn/article-5299-1.html

https://www.cnblogs.com/kevingrace/p/5707003.html

![image-20200722160000768](openstack.assets/image-20200722160000768.png)



#### openstack

教程 https://www.bilibili.com/video/BV13W411m7LA?p=10

组件介绍 https://www.cnblogs.com/davidshen/p/9892162.html

https://www.cnblogs.com/linuxk/category/1248282.html

[OpenStack Rocky(R版) 部署手册 - 控制节点](https://www.haxi.cc/archives/OpenStack-Rocky-R版-部署手册---控制节点.html)

https://www.cnblogs.com/tssc/category/1295295.html

[手动构建Openstack镜像]([https://www.lijiawang.org/posts/%E6%89%8B%E5%8A%A8%E6%9E%84%E5%BB%BAOpenstack%E9%95%9C%E5%83%8F.html](https://www.lijiawang.org/posts/手动构建Openstack镜像.html))

网络配置

https://blog.csdn.net/akipa11/article/details/81414875

```shell
vi /etc/sysconfig/network-scripts/ifcfg-ens33 

TYPE=Ethernet
PROXY_METHOD=none
BROWSER_ONLY=no
BOOTPROTO=static
DEFROUTE=yes
IPV4_FAILURE_FATAL=no
IPV6INIT=yes
IPV6_AUTOCONF=yes
IPV6_DEFROUTE=yes
IPV6_FAILURE_FATAL=no
IPV6_ADDR_GEN_MODE=stable-privacy
NAME=ens33
UUID=ab6e711d-f8e9-4fee-8cd3-a09af2c8c16e
DEVICE=ens33
ONBOOT=yes
IPADDR=192.168.159.220
NETMASK=255.255.255.0
GATEWAY=192.168.159.2
DNS1=192.168.159.2
DNS1=114.114.114.114
DNS2=8.8.8.8

重启网络服务
systemctl restart network
```



##### 基础服务配置

修改hostname

```shell
hostnamectl --static set-hostname controller
```

修改hosts

```shell
vi /etc/hosts
192.168.159.220 controller
192.168.159.221 computer1
```



##### 关闭防火墙

```shell
systemctl stop firewalld
systemctl disable firewalld
systemctl status firewalld

关闭 SELinux
setenforce 0
sed -i 's/^SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
```



##### 时间同步

```shell
yum install chrony -y

vi /etc/chrony.conf
server ntp1.aliyun.com iburst
server ntp2.aliyun.com iburst
allow 192.168.159.0/24

systemctl restart chronyd.service
systemctl status chronyd.service
systemctl enable chronyd.service
systemctl list-unit-files |grep chronyd.service

```



##### 设置时区，同步时间

```shell
timedatectl set-timezone Asia/Shanghai
chronyc sources
timedatectl status
```



##### 配置相关yum源 

```shell
配置阿里云的base和epel源

mv -f /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup
wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo

mv /etc/yum.repos.d/epel.repo /etc/yum.repos.d/epel.repo.backup
wget -O /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo

安装openstack-rocky的仓库
yum install centos-release-openstack-rocky -y
yum clean all
yum makecache
```



##### 更新软件包

```shell
yum update -y
```



##### 安装openstack客户端相关软件

```shell
yum install python-openstackclient openstack-selinux -y
```



##### MySQL

```she
yum install -y mariadb mariadb-server python2-PyMySQL

修改配置
vi /etc/my.cnf.d/openstack.cnf 
[mysqld]
bind-address = 192.168.159.220

default-storage-engine = innodb
innodb_file_per_table = on
max_connections = 4096
collation-server = utf8_general_ci
character-set-server = utf8

启动MySQL
systemctl enable mariadb.service
systemctl start mariadb.service

mysql_secure_installation
依次输入：
n
y
y
y
y

```





##### RabbitMQ

在控制节点上安装

```
安装软件包
yum install -y rabbitmq-server

启动消息队列服务
systemctl enable rabbitmq-server.service
systemctl start rabbitmq-server.service

添加openstack用户：
rabbitmqctl add_user openstack RABBIT_PASS

允许用户配置，写入和读取访问权限 openstack：
rabbitmqctl set_permissions openstack ".*" ".*" ".*"

rabbitmq-plugins enable rabbitmq_management

管控台
http://192.168.159.201:15672
guest/guest
```



##### Memcached

在控制节点上安装

```
yum install -y memcached python-memcached
vi /etc/sysconfig/memcached
修改成 OPTIONS="-l 192.168.159.201,::1"

systemctl enable memcached.service
systemctl start memcached.service
```



##### Keystone 认证服务

在控制节点上安装

```
mysql -u root -p
CREATE DATABASE keystone;
GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'localhost' \
IDENTIFIED BY 'KEYSTONE_DBPASS';
GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'%' \
IDENTIFIED BY 'KEYSTONE_DBPASS';

yum install -y openstack-keystone httpd mod_wsgi
yum install -y python-keystoneclient openstack-utils

```



```shell
修改配置
openstack-config --set /etc/keystone/keystone.conf database connection mysql+pymysql://keystone:KEYSTONE_DBPASS@controller/keystone
openstack-config --set /etc/keystone/keystone.conf token provider fernet


```

```
export OS_USERNAME=admin
export OS_PASSWORD=ADMIN_PASS
export OS_PROJECT_NAME=admin
export OS_USER_DOMAIN_NAME=Default
export OS_PROJECT_DOMAIN_NAME=Default
export OS_AUTH_URL=http://controller:5000/v3
export OS_IDENTITY_API_VERSION=3
```





```shell
openstack token issue
openstack user list
openstack service list
openstack endpoint list

```

```shell
openstack-config --set  /etc/nova/nova.conf DEFAULT my_ip 192.168.159.221


```

##### Glance 镜像服务

https://www.cnblogs.com/tssc/p/9858964.html

```shell
修改配置

openstack-config --set  /etc/glance/glance-api.conf database connection  mysql+pymysql://glance:GLANCE_DBPASS@controller/glance
openstack-config --set  /etc/glance/glance-api.conf keystone_authtoken www_authenticate_uri http://controller:5000
openstack-config --set  /etc/glance/glance-api.conf keystone_authtoken auth_url http://controller:5000
openstack-config --set  /etc/glance/glance-api.conf keystone_authtoken memcached_servers  controller:11211
openstack-config --set  /etc/glance/glance-api.conf keystone_authtoken auth_type password
openstack-config --set  /etc/glance/glance-api.conf keystone_authtoken project_domain_name Default
openstack-config --set  /etc/glance/glance-api.conf keystone_authtoken user_domain_name Default
openstack-config --set  /etc/glance/glance-api.conf keystone_authtoken project_name service 
openstack-config --set  /etc/glance/glance-api.conf keystone_authtoken username glance
openstack-config --set  /etc/glance/glance-api.conf keystone_authtoken password glance
openstack-config --set  /etc/glance/glance-api.conf paste_deploy flavor keystone
openstack-config --set  /etc/glance/glance-api.conf glance_store stores  file,http
openstack-config --set  /etc/glance/glance-api.conf glance_store default_store file
openstack-config --set  /etc/glance/glance-api.conf glance_store filesystem_store_datadir /var/lib/glance/images/


openstack-config --set  /etc/glance/glance-registry.conf database connection mysql+pymysql://glance:GLANCE_DBPASS@controller/glance
openstack-config --set  /etc/glance/glance-registry.conf keystone_authtoken www_authenticate_uri http://controller:5000
openstack-config --set  /etc/glance/glance-registry.conf keystone_authtoken auth_url http://controller:5000
openstack-config --set  /etc/glance/glance-registry.conf keystone_authtoken memcached_servers controller:11211
openstack-config --set  /etc/glance/glance-registry.conf keystone_authtoken auth_type password
openstack-config --set  /etc/glance/glance-registry.conf keystone_authtoken project_domain_name Default
openstack-config --set  /etc/glance/glance-registry.conf keystone_authtoken user_domain_name Default
openstack-config --set  /etc/glance/glance-registry.conf keystone_authtoken project_name service
openstack-config --set  /etc/glance/glance-registry.conf keystone_authtoken username glance
openstack-config --set  /etc/glance/glance-registry.conf keystone_authtoken password glance
openstack-config --set  /etc/glance/glance-registry.conf paste_deploy flavor keystone

```

查看镜像 `openstack image list`





##### Nova 计算服务

```shell
openstack-config --set  /etc/nova/nova.conf DEFAULT enabled_apis  osapi_compute,metadata
openstack-config --set  /etc/nova/nova.conf DEFAULT my_ip 192.168.159.220
openstack-config --set  /etc/nova/nova.conf DEFAULT use_neutron  true 
openstack-config --set  /etc/nova/nova.conf DEFAULT firewall_driver  nova.virt.firewall.NoopFirewallDriver
openstack-config --set  /etc/nova/nova.conf DEFAULT transport_url  rabbit://openstack:RABBIT_PASS@controller
openstack-config --set  /etc/nova/nova.conf api_database connection  mysql+pymysql://nova:NOVA_DBPASS@controller/nova_api
openstack-config --set  /etc/nova/nova.conf database connection  mysql+pymysql://nova:NOVA_DBPASS@controller/nova
openstack-config --set  /etc/nova/nova.conf placement_database connection  mysql+pymysql://placement:PLACEMENT_DBPASS@controller/placement
openstack-config --set  /etc/nova/nova.conf api auth_strategy  keystone 
openstack-config --set  /etc/nova/nova.conf keystone_authtoken auth_url  http://controller:5000/v3
openstack-config --set  /etc/nova/nova.conf keystone_authtoken memcached_servers  controller:11211
openstack-config --set  /etc/nova/nova.conf keystone_authtoken auth_type  password
openstack-config --set  /etc/nova/nova.conf keystone_authtoken project_domain_name  default 
openstack-config --set  /etc/nova/nova.conf keystone_authtoken user_domain_name  default
openstack-config --set  /etc/nova/nova.conf keystone_authtoken project_name  service 
openstack-config --set  /etc/nova/nova.conf keystone_authtoken username  nova 
openstack-config --set  /etc/nova/nova.conf keystone_authtoken password  nova
openstack-config --set  /etc/nova/nova.conf vnc enabled true
openstack-config --set  /etc/nova/nova.conf vnc server_listen '$my_ip'
openstack-config --set  /etc/nova/nova.conf vnc server_proxyclient_address '$my_ip'
openstack-config --set  /etc/nova/nova.conf glance api_servers  http://controller:9292
openstack-config --set  /etc/nova/nova.conf oslo_concurrency lock_path  /var/lib/nova/tmp 
openstack-config --set  /etc/nova/nova.conf placement region_name RegionOne
openstack-config --set  /etc/nova/nova.conf placement project_domain_name Default
openstack-config --set  /etc/nova/nova.conf placement project_name service
openstack-config --set  /etc/nova/nova.conf placement auth_type password
openstack-config --set  /etc/nova/nova.conf placement user_domain_name Default
openstack-config --set  /etc/nova/nova.conf placement auth_url http://controller:5000/v3
openstack-config --set  /etc/nova/nova.conf placement username placement
openstack-config --set  /etc/nova/nova.conf placement password placement
openstack-config --set  /etc/nova/nova.conf scheduler discover_hosts_in_cells_interval 300




```





##### computer1 Nova

```shell
修改配置

openstack-config --set  /etc/nova/nova.conf DEFAULT my_ip 192.168.159.221
openstack-config --set  /etc/nova/nova.conf DEFAULT use_neutron True
openstack-config --set  /etc/nova/nova.conf DEFAULT firewall_driver nova.virt.firewall.NoopFirewallDriver
openstack-config --set  /etc/nova/nova.conf DEFAULT enabled_apis  osapi_compute,metadata
openstack-config --set  /etc/nova/nova.conf DEFAULT transport_url  rabbit://openstack:RABBIT_PASS@controller
openstack-config --set  /etc/nova/nova.conf api auth_strategy  keystone 
openstack-config --set  /etc/nova/nova.conf keystone_authtoken auth_url http://controller:5000/v3
openstack-config --set  /etc/nova/nova.conf keystone_authtoken memcached_servers controller:11211
openstack-config --set  /etc/nova/nova.conf keystone_authtoken auth_type password
openstack-config --set  /etc/nova/nova.conf keystone_authtoken project_domain_name default
openstack-config --set  /etc/nova/nova.conf keystone_authtoken user_domain_name default
openstack-config --set  /etc/nova/nova.conf keystone_authtoken project_name  service
openstack-config --set  /etc/nova/nova.conf keystone_authtoken username nova
openstack-config --set  /etc/nova/nova.conf keystone_authtoken password nova
openstack-config --set  /etc/nova/nova.conf vnc enabled True
openstack-config --set  /etc/nova/nova.conf vnc server_listen 0.0.0.0
openstack-config --set  /etc/nova/nova.conf vnc server_proxyclient_address  '$my_ip'
openstack-config --set  /etc/nova/nova.conf vnc novncproxy_base_url  http://controller:6080/vnc_auto.html
openstack-config --set  /etc/nova/nova.conf glance api_servers http://controller:9292
openstack-config --set  /etc/nova/nova.conf oslo_concurrency lock_path /var/lib/nova/tmp
openstack-config --set  /etc/nova/nova.conf placement region_name RegionOne
openstack-config --set  /etc/nova/nova.conf placement project_domain_name Default
openstack-config --set  /etc/nova/nova.conf placement project_name service
openstack-config --set  /etc/nova/nova.conf placement auth_type password
openstack-config --set  /etc/nova/nova.conf placement user_domain_name Default
openstack-config --set  /etc/nova/nova.conf placement auth_url http://controller:5000/v3
openstack-config --set  /etc/nova/nova.conf placement username placement
openstack-config --set  /etc/nova/nova.conf placement password placement




```



##### neutron 网络服务

https://www.cnblogs.com/tssc/p/9873713.html

在控制节点上配置

```shell
openstack-config --set  /etc/neutron/neutron.conf database connection  mysql+pymysql://neutron:NEUTRON_DBPASS@controller/neutron 
openstack-config --set  /etc/neutron/neutron.conf DEFAULT core_plugin  ml2  
openstack-config --set  /etc/neutron/neutron.conf DEFAULT service_plugins 
openstack-config --set  /etc/neutron/neutron.conf DEFAULT transport_url rabbit://openstack:RABBIT_PASS@controller
openstack-config --set  /etc/neutron/neutron.conf DEFAULT auth_strategy  keystone  
openstack-config --set  /etc/neutron/neutron.conf keystone_authtoken www_authenticate_uri  http://controller:5000
openstack-config --set  /etc/neutron/neutron.conf keystone_authtoken auth_url  http://controller:5000
openstack-config --set  /etc/neutron/neutron.conf keystone_authtoken memcached_servers  controller:11211
openstack-config --set  /etc/neutron/neutron.conf keystone_authtoken auth_type  password  
openstack-config --set  /etc/neutron/neutron.conf keystone_authtoken project_domain_name default  
openstack-config --set  /etc/neutron/neutron.conf keystone_authtoken user_domain_name  default  
openstack-config --set  /etc/neutron/neutron.conf keystone_authtoken project_name  service  
openstack-config --set  /etc/neutron/neutron.conf keystone_authtoken username  neutron  
openstack-config --set  /etc/neutron/neutron.conf keystone_authtoken password  neutron  
openstack-config --set  /etc/neutron/neutron.conf DEFAULT notify_nova_on_port_status_changes  True  
openstack-config --set  /etc/neutron/neutron.conf DEFAULT notify_nova_on_port_data_changes  True  
openstack-config --set  /etc/neutron/neutron.conf nova auth_url  http://controller:5000
openstack-config --set  /etc/neutron/neutron.conf nova auth_type  password 
openstack-config --set  /etc/neutron/neutron.conf nova project_domain_name  default  
openstack-config --set  /etc/neutron/neutron.conf nova user_domain_name  default  
openstack-config --set  /etc/neutron/neutron.conf nova region_name  RegionOne  
openstack-config --set  /etc/neutron/neutron.conf nova project_name  service  
openstack-config --set  /etc/neutron/neutron.conf nova username  nova  
openstack-config --set  /etc/neutron/neutron.conf nova password  nova  
openstack-config --set  /etc/neutron/neutron.conf oslo_concurrency lock_path  /var/lib/neutron/tmp  

```



```shell
openstack-config --set  /etc/neutron/plugins/ml2/ml2_conf.ini ml2 type_drivers  flat,vlan
openstack-config --set  /etc/neutron/plugins/ml2/ml2_conf.ini ml2 tenant_network_types 
openstack-config --set  /etc/neutron/plugins/ml2/ml2_conf.ini ml2 mechanism_drivers  linuxbridge
openstack-config --set  /etc/neutron/plugins/ml2/ml2_conf.ini ml2 extension_drivers  port_security
openstack-config --set  /etc/neutron/plugins/ml2/ml2_conf.ini ml2_type_flat flat_networks  provider 
openstack-config --set  /etc/neutron/plugins/ml2/ml2_conf.ini securitygroup enable_ipset  True 

```



```shell
openstack-config --set   /etc/neutron/plugins/ml2/linuxbridge_agent.ini linux_bridge physical_interface_mappings  provider:ens33
openstack-config --set   /etc/neutron/plugins/ml2/linuxbridge_agent.ini vxlan  enable_vxlan  False
openstack-config --set   /etc/neutron/plugins/ml2/linuxbridge_agent.ini securitygroup  enable_security_group  True 
openstack-config --set   /etc/neutron/plugins/ml2/linuxbridge_agent.ini securitygroup  firewall_driver neutron.agent.linux.iptables_firewall.IptablesFirewallDriver
```

```shell
openstack-config --set   /etc/neutron/dhcp_agent.ini DEFAULT  interface_driver  linuxbridge
openstack-config --set   /etc/neutron/dhcp_agent.ini DEFAULT  dhcp_driver  neutron.agent.linux.dhcp.Dnsmasq
openstack-config --set   /etc/neutron/dhcp_agent.ini DEFAULT  enable_isolated_metadata  True 


```



```shell
openstack-config --set /etc/neutron/metadata_agent.ini DEFAULT nova_metadata_host controller
openstack-config --set /etc/neutron/metadata_agent.ini DEFAULT metadata_proxy_shared_secret neutron
```



```shell
openstack-config --set  /etc/nova/nova.conf  neutron url http://controller:9696
openstack-config --set  /etc/nova/nova.conf  neutron auth_url http://controller:5000
openstack-config --set  /etc/nova/nova.conf  neutron auth_type password
openstack-config --set  /etc/nova/nova.conf  neutron project_domain_name default
openstack-config --set  /etc/nova/nova.conf  neutron user_domain_name default
openstack-config --set  /etc/nova/nova.conf  neutron region_name RegionOne
openstack-config --set  /etc/nova/nova.conf  neutron project_name service
openstack-config --set  /etc/nova/nova.conf  neutron username neutron
openstack-config --set  /etc/nova/nova.conf  neutron password neutron
openstack-config --set  /etc/nova/nova.conf  neutron service_metadata_proxy true
openstack-config --set  /etc/nova/nova.conf  neutron metadata_proxy_shared_secret neutron

```



在计算节点上配置

```
openstack-config --set /etc/neutron/neutron.conf DEFAULT transport_url  rabbit://openstack:RABBIT_PASS@controller
openstack-config --set /etc/neutron/neutron.conf DEFAULT auth_strategy keystone
openstack-config --set /etc/neutron/neutron.conf keystone_authtoken www_authenticate_uri  http://controller:5000
openstack-config --set /etc/neutron/neutron.conf keystone_authtoken auth_url http://controller:5000
openstack-config --set /etc/neutron/neutron.conf keystone_authtoken memcached_servers controller:11211
openstack-config --set /etc/neutron/neutron.conf keystone_authtoken auth_type password
openstack-config --set /etc/neutron/neutron.conf keystone_authtoken project_domain_name default
openstack-config --set /etc/neutron/neutron.conf keystone_authtoken user_domain_name default
openstack-config --set /etc/neutron/neutron.conf keystone_authtoken project_name service
openstack-config --set /etc/neutron/neutron.conf keystone_authtoken username neutron
openstack-config --set /etc/neutron/neutron.conf keystone_authtoken password neutron
openstack-config --set /etc/neutron/neutron.conf oslo_concurrency lock_path /var/lib/neutron/tmp
```

```shell
openstack-config --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini linux_bridge physical_interface_mappings  provider:ens33
openstack-config --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini vxlan enable_vxlan false
openstack-config --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini securitygroup enable_security_group true
openstack-config --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini securitygroup firewall_driver neutron.agent.linux.iptables_firewall.IptablesFirewallDriver
```

```shell
openstack-config --set /etc/nova/nova.conf neutron url http://controller:9696
openstack-config --set /etc/nova/nova.conf neutron auth_url http://controller:5000
openstack-config --set /etc/nova/nova.conf neutron auth_type password
openstack-config --set /etc/nova/nova.conf neutron project_domain_name default
openstack-config --set /etc/nova/nova.conf neutron user_domain_name default
openstack-config --set /etc/nova/nova.conf neutron region_name RegionOne
openstack-config --set /etc/nova/nova.conf neutron project_name service 
openstack-config --set /etc/nova/nova.conf neutron username neutron
openstack-config --set /etc/nova/nova.conf neutron password neutron
```



##### dashboard

https://blog.csdn.net/qq_28513801/article/details/90269044



##### 创建实例

在控制节点上执行

https://docs.openstack.org/install-guide/launch-instance-networks-provider.html

```shell
创建网络
openstack network create  --share --external \
  --provider-physical-network provider \
  --provider-network-type flat provider
  
查看网络
openstack network list

创建子网
openstack subnet create --network provider \
  --allocation-pool start=192.168.159.101,end=192.168.159.250 \
  --dns-nameserver 114.114.114.114 --gateway 192.168.159.2 \
  --subnet-range 192.168.159.0/24 provider


创建硬件配置规格
openstack flavor create --id 0 --vcpus 1 --ram 64 --disk 1 m1.nano

openstack flavor list

创建密钥对
ssh-keygen -q -N "" -f ~/.ssh/id_rsa
openstack keypair create --public-key ~/.ssh/id_rsa.pub mykey

openstack keypair list


添加安全组规则
openstack security group rule create --proto icmp default
openstack security group rule create --proto tcp --dst-port 22 default

启动实例
https://docs.openstack.org/install-guide/launch-instance-provider.html
openstack flavor list
openstack image list
openstack network list
openstack security group list

openstack server create --flavor m1.nano --image cirros \
  --nic net-id=e39440a8-b626-41f0-807e-db0c266cde5e --security-group default \
  --key-name mykey provider-instance


openstack server list

```

启动一个虚拟机实例

https://www.cnblogs.com/tssc/p/9902641.html

创建多规格

https://www.cnblogs.com/shhnwangjian/p/6363612.html

```text
openstack flavor create --id 0 --vcpus 1 --ram 64 --disk 1 m1.nano
openstack flavor create --id 1 --vcpus 1 --ram 1024 --disk 50 m1.tiny
openstack flavor create --id 2 --vcpus 1 --ram 2048 --disk 500 m1.small
openstack flavor create --id 3 --vcpus 2 --ram 4096 --disk 500 m1.medium
openstack flavor create --id 4 --vcpus 4 --ram 8192 --disk 500 m1.large
openstack flavor create --id 5 --vcpus 8 --ram 16384 --disk 500 m1.xlarge
openstack flavor list
```

删除flavor

nova flavor-delete id



https://www.cnblogs.com/tssc/p/9902641.html

允许 ICMP (ping)、允许安全 shell (SSH) 的访问

![image-20200722154116138](openstack.assets/image-20200722154116138.png)

##### cinder 块存储





##### Public IP

https://www.mirantis.com/blog/configuring-floating-ip-addresses-networking-openstack-public-private-clouds/

float ip（浮动ip），虚拟机实例可以绑定的公网IP

https://www.cnblogs.com/linuxk/p/9455558.html

http://www.ruijie.com.cn/fw/qdwd/57112/



https://blog.csdn.net/CloudMan6/article/list/9



##### Pass

https://dbaplus.cn/news-72-1494-1.html

数据库即服务

http://yunxin.163.com/blog/视频私有云实战：基于docker构建点播私有云平台



网易云容器服务研发实践分享

https://mp.weixin.qq.com/s/mzICGPhvLLQfTZsxVBQEhQ



容器编排 k8s

容器	docker

基础设施 openstack





































