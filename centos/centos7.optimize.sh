#!/bin/bash
if [ `id -u` != 0 ]; then
  echo "需要用root用户执行. 使用 'sudo su' 或 'su -' 切换到root."
  exit 1;
fi

yum install git curl wget zsh vim -y

# 添加login_show
curl -o /usr/local/bin/login_show.sh https://raw.githubusercontent.com/HaroldHoo/public/master/centos/login_show.sh
chmod +x /usr/local/bin/login_show.sh
echo "/usr/local/bin/login_show.sh" >> /etc/bashrc
echo "/usr/local/bin/login_show.sh" >> /etc/zshrc

# 时区与时间同步
cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
yum install ntp ntpdate -y
systemctl enable ntpd
systemctl start ntpd
ntpdate cn.pool.ntp.org

# yum源
yum install -y epel-release
sed -e 's!^mirrorlist=!#mirrorlist=!g' \
         -e 's!^#baseurl=!baseurl=!g' \
         -e 's!//download\.fedoraproject\.org/pub!//mirrors.ustc.edu.cn!g' \
         -e 's!http://mirrors\.ustc!https://mirrors.ustc!g' \
         -i /etc/yum.repos.d/epel.repo /etc/yum.repos.d/epel-testing.repo

curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
yum clean all && yum makecache
yum update -y

# 加速ssh登录
sed -i 's/#UseDNS yes/UseDNS no/g' /etc/ssh/sshd_config
sed -i 's/GSSAPIAuthentication yes/GSSAPIAuthentication no/g' /etc/ssh/sshd_config
sudo systemctl restart sshd

# 关闭selinux
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux

# 内核调整
cat >/etc/sysctl.conf <<EOF
# sysctl settings are defined through files in
# /usr/lib/sysctl.d/, /run/sysctl.d/, and /etc/sysctl.d/.
#
# Vendors settings live in /usr/lib/sysctl.d/.
# To override a whole file, create a new file with the same in
# /etc/sysctl.d/ and put new settings there. To override
# only specific settings, add a file with a lexically later
# name in /etc/sysctl.d/ and put new settings there.
#
# For more information, see sysctl.conf(5) and sysctl.d(5).

#关闭ipv6
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1

# 避免放大攻击
net.ipv4.icmp_echo_ignore_broadcasts = 1

# 开启恶意icmp错误消息保护
net.ipv4.icmp_ignore_bogus_error_responses = 1

#路由转发
net.ipv4.ip_forward = 1
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0

#开启反向路径过滤
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1

#处理无源路由的包
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.default.accept_source_route = 0

#关闭sysrq功能
kernel.sysrq = 0

#core文件名中添加pid作为扩展名
kernel.core_uses_pid = 1

# 开启SYN洪水攻击保护
net.ipv4.tcp_syncookies = 1

#修改消息队列长度
kernel.msgmnb = 65536
kernel.msgmax = 65536

#设置最大内存共享段大小bytes
kernel.shmmax = 68719476736
kernel.shmall = 4294967296

#timewait的数量，默认180000
net.ipv4.tcp_max_tw_buckets = 6000
net.ipv4.tcp_sack = 1
net.ipv4.tcp_window_scaling = 1
#net.ipv4.tcp_rmem = 4096        87380   4194304
#net.ipv4.tcp_wmem = 4096        16384   4194304
net.core.wmem_default = 8388608
net.core.rmem_default = 8388608

net.core.rmem_max = 16777216
net.core.wmem_max = 16777216

#每个网络接口接收数据包的速率比内核处理这些包的速率快时，允许送到队列的数据包的最大数目
net.core.netdev_max_backlog = 262144

#限制仅仅是为了防止简单的DoS 攻击
net.ipv4.tcp_max_orphans = 3276800

#未收到客户端确认信息的连接请求的最大值
net.ipv4.tcp_max_syn_backlog = 262144
net.ipv4.tcp_timestamps = 0

#内核放弃建立连接之前发送SYNACK 包的数量
net.ipv4.tcp_synack_retries = 1

#内核放弃建立连接之前发送SYN 包的数量
net.ipv4.tcp_syn_retries = 1

#启用timewait 快速回收
net.ipv4.tcp_tw_recycle = 1

#开启重用。允许将TIME-WAIT sockets 重新用于新的TCP 连接
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_mem = 94500000 915000000 927000000
net.ipv4.tcp_fin_timeout = 1

#当keepalive 起用的时候，TCP 发送keepalive 消息的频度。缺省是2 小时
net.ipv4.tcp_keepalive_time = 30

#允许系统打开的端口范围
#net.ipv4.ip_local_port_range = 1024    65000

#修改防火墙表大小，默认65536
#net.netfilter.nf_conntrack_max=655350
#net.netfilter.nf_conntrack_tcp_timeout_established=1200

# 确保无人能修改路由表
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.all.secure_redirects = 0
net.ipv4.conf.default.secure_redirects = 0
EOF

echo 1 > /proc/sys/net/ipv4/ip_forward
sysctl -p

# 调优
/bin/echo "* soft nproc 65500" >>/etc/security/limits.conf
/bin/echo "* hard nproc 65500" >>/etc/security/limits.conf
/bin/echo "* soft nofile 65500" >>/etc/security/limits.conf
/bin/echo "* hard nofile 65500" >>/etc/security/limits.conf

# 安装ohzsh
sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

