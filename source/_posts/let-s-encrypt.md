---
title: let's-encrypt
date: 2019-09-10 13:53:48
tags:
---
https://certbot.eff.org/

```text
$ wget https://dl.eff.org/certbot-auto
$ sudo mv certbot-auto /usr/local/bin/certbot-auto
$ sudo chown root /usr/local/bin/certbot-auto
$ sudo chmod 0755 /usr/local/bin/certbot-auto
```
```text
$ sudo /usr/local/bin/certbot-auto --nginx
```

```text
Could not choose appropriate plugin: The nginx plugin is not working; there may be problems with your existing configuration.
The error was: NoInstallationError("Could not find a usable 'nginx' binary. Ensure nginx exists, the binary is executable, and your PATH is set correctly.",)
```
由于没有将nginx放到环境变量中，设置nginx软连接
```text
$ ln -s /usr/local/nginx/sbin/nginx /usr/bin/nginx
$ ln -s /usr/local/nginx/conf/ /etc/nginx
```

```text
$ sudo /usr/local/bin/certbot-auto --nginx
Saving debug log to /var/log/letsencrypt/letsencrypt.log
The nginx plugin is not working; there may be problems with your existing configuration.
The error was: PluginError('Nginx build is missing SSL module (--with-http_ssl_module).',)
```
https://blog.csdn.net/guangcaiwudong/article/details/98858337

通过nginx -V查看nginxconfigure arguments没有安装ssl模板，在nginx目录中重新构建
cd /opt/nginx-1.14.0
./configure --with-http_ssl_module
执行 make
这里不要进行make install，否则就是覆盖安装。

[Nginx安装后增加SSL模块](http://hacksteven.com/?p=183)

使用`sudo certbot certonly --nginx`生成证书，中间需要填写email和域名，生成成功后会提示证书存放路径：

```text
$ sudo /usr/local/bin/certbot-auto --nginx
Saving debug log to /var/log/letsencrypt/letsencrypt.log
Plugins selected: Authenticator nginx, Installer nginx
Enter email address (used for urgent renewal and security notices) (Enter 'c' to
cancel): c
An e-mail address or --register-unsafely-without-email must be provided.
[root@VM_0_13_centos nginx]# sudo /usr/local/bin/certbot-auto --nginx
Saving debug log to /var/log/letsencrypt/letsencrypt.log
Plugins selected: Authenticator nginx, Installer nginx
Enter email address (used for urgent renewal and security notices) (Enter 'c' to
cancel): ym2011678@foxmail.com

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Please read the Terms of Service at
https://letsencrypt.org/documents/LE-SA-v1.2-November-15-2017.pdf. You must
agree in order to register with the ACME server at
https://acme-v02.api.letsencrypt.org/directory
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
(A)gree/(C)ancel: A

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Would you be willing to share your email address with the Electronic Frontier
Foundation, a founding partner of the Let's Encrypt project and the non-profit
organization that develops Certbot? We'd like to send you email about our work
encrypting the web, EFF news, campaigns, and ways to support digital freedom.
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
(Y)es/(N)o: N
No names were found in your configuration files. Please enter in your domain
name(s) (comma and/or space separated)  (Enter 'c' to cancel): npe4j.com
Obtaining a new certificate
Performing the following challenges:
http-01 challenge for npe4j.com
Using default address 80 for authentication.
Waiting for verification...
Cleaning up challenges
Could not automatically find a matching server block for npe4j.com. Set the `server_name` directive to use the Nginx installer.

IMPORTANT NOTES:
 - Unable to install the certificate
 - Congratulations! Your certificate and chain have been saved at:
   /etc/letsencrypt/live/npe4j.com/fullchain.pem
   Your key file has been saved at:
   /etc/letsencrypt/live/npe4j.com/privkey.pem
   Your cert will expire on 2019-12-09. To obtain a new or tweaked
   version of this certificate in the future, simply run certbot-auto
   again with the "certonly" option. To non-interactively renew *all*
   of your certificates, run "certbot-auto renew"
 - Your account credentials have been saved in your Certbot
   configuration directory at /etc/letsencrypt. You should make a
   secure backup of this folder now. This configuration directory will
   also contain certificates and private keys obtained by Certbot so
   making regular backups of this folder is ideal.

```

nginx从http跳转到https
https://www.cnblogs.com/nuccch/p/7681592.html


##### CentOS 7 下 安装 Let's Encrypt 的通配符证书

sudo yum install epel-release
sudo yum install certbot

certbot --server https://acme-v02.api.letsencrypt.org/directory -d npe4j.com -d *.npe4j.com --manual --preferred-challenges dns-01 certonly

https://qizhanming.com/blog/2019/04/23/how-to-install-let-s-encrypt-wildcards-certificate-on-centos-7
https://www.infoq.cn/article/2018/03/lets-encrypt-wildcard-https
https://www.jianshu.com/p/c5c9d071e395

删除弃用的Let’s encrypt安全证书的域名
https://www.vmvps.com/how-to-delete-unused-lets-encrypt-ssl-domain.html



#### Let's Encrypt 续期
crontab -e

0 1 * * * /usr/local/bin/certbot-auto renew --no-self-upgrade
5 1 * * * /usr/sbin/nginx -s reload

强制更新
--force-renew

查看日志
tail -F /var/log/letsencrypt/letsencrypt.log

查看crontab 日志
tail -30f /var/log/cron


报错
Could not find a usable 'nginx' binary. Ensure nginx exists, the binary is executable, and your PATH is set correctly

https://www.jianshu.com/p/1ce5f1bc8f0d