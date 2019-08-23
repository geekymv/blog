---
title: csrf
date: 2019-08-14 11:13:33
tags:
---
https://segmentfault.com/a/1190000006944760

浏览器安全
同源策略（Same Origin Policy）
影响因素有：host（域名或IP地址，如果是IP地址则看做一个根域名）、子域名、端口、协议。
在浏览器中，<script>、<img>、<iframe>、<link> 等标签都可以跨域加载资源，而不受同源策略的限制。

XMLHttpRequest 受到同源策略的约束，不能跨域访问资源，在AJAX应用的开发中需要注意这一点。

跨站脚本攻击（Cross Site Script）XSS，通常指黑客通过“html注入”篡改了网页，插入了恶意脚本，
从而在用户浏览网页时，控制用户浏览器的一种攻击。

跨站点请求伪造（Cross Site Request Forgery）CSRF，
