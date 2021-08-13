---
title: tcpdump排查线上接口请求问题
date: 2021-08-13 10:14:25
tags:
---
{% asset_img log.png 错误日志 %}
是的，线上环境出问题了，调用第三方的接口出现服务端响应状态码401，于是赶紧查询HTTP Code 401代表啥意思，于是找到了这篇文章

[http常见的状态码，400,401,403状态码分别代表什么？](https://blog.csdn.net/liouswll/article/details/80698619)

```text
401 unauthorized，表示发送的请求需要有通过 HTTP 认证的认证信息
```

401是服务端响应的状态码，根据接口文档在请求header中添加 X_API_KEY用于接口验证，代码中也确实这么实现的。

{% asset_img code.png 项目代码 %}

而且同样的接口本地发送请求没有问题，这里是使用Hutool（3.3.2版本）工具包发送HTTP请求，调用第三方接口抓取数据。

于是想到了抓包看看，项目代码是部署在Linux服务器（IP是192.168.0.211）上的，无法使用Wireshark之类图形化工具，于是使用tcpdump命令去抓包。

```shell
tcpdump -i eth0 tcp port 80 and host 192.168.67.206 -w /tmp/httptool-206.pcap

-i eth0 指定网卡
tcp 指定协议
port 80 指定端口
host 192.168.67.206 指定ip，表示抓取192.168.67.206的主机收到和发出的数据包
-w 将抓包信息写入文件
```



将抓的数据包传输到本地使用Wireshark打开如下

{% asset_img cookie.png wireshark分析数据包 %}

第4行就是发出的HTTP GET请求，注意下这里发出的请求header中携带了cookie信息，而代码中并没有去设置cookie，那么这个cookie是怎么来的呢？于是先将这个cookie在本地代码中显示设置，在本地调试下，果然出现了 401 Unauthorized 异常，可能就是这个cookie导致的问题。

决定看下Hutool工具包中HttpRequest类实现源码是如何自动设置cookie的。

我们的业务代码

```java
  String result = HttpRequest.get(url) // 设置请求url
      .header(X_API_KEY, apiKey) // 设置header
      .timeout(TIME_OUT) // 设置超时时间
      .execute().body();
```

上面都是设置请求需要的参数，看下HttpRequest中的execute() 方法

```java
/**
 * 执行Reuqest请求
 * 
 * @return this
 */
public HttpResponse execute() {
    return this.execute(false);
}
```

继续跟踪

```java
/**
 * 执行Reuqest请求
 * 
 * @param isAsync 是否异步
 * @return this
 */
public HttpResponse execute(boolean isAsync) {
    //初始化URL
    urlWithParamIfGet();
    // 初始化 connection
    initConnecton();

    // 发送请求
    send();

    //手动实现重定向
    HttpResponse httpResponse = sendRedirectIfPosible();

    // 获取响应
    if(null == httpResponse){
        httpResponse = new HttpResponse(this.httpConnection, this.charset, isAsync, isIgnoreResponseBody());
    }
    return httpResponse;
}
```

进入到 initConnecton() 方法

```java
/**
 * 初始化网络连接
 */
private void initConnecton(){
    // 初始化 connection
    this.httpConnection = HttpConnection
        .create(this.url, this.method, this.hostnameVerifier, this.ssf, this.timeout, this.proxy)
        .header(this.headers, true); // 覆盖默认Header

    //自定义Cookie
    if(null != this.cookie){
        this.httpConnection.setCookie(this.cookie);
    }

    //是否禁用缓存
    if(this.isDisableCache){
        this.httpConnection.disableCache();
    }

    //定义转发
    this.httpConnection.setInstanceFollowRedirects(maxRedirectCount > 0 ? true : false);
}
```

this.httpConnection.setCookie(this.cookie); 可以看到如果我们显示指定了cookie，这里会通过 HttpConnection 中的 setCookie 方法进行设置

```java
/**
 * 设置Cookie
 * 
 * @param cookie Cookie
 * @return this
 */
public HttpConnection setCookie(String cookie) {
    if (cookie != null) {
        log.debug("Cookie: {}", cookie);
        header(Header.COOKIE, cookie, true);
    }
    return this;
}
```

这里我们在代码中并没有指定cookie，那么代码中是否在其他地方调动了这个方法呢。

于是在setCookie 方法中打个断点，运行代码调试下看看，从IDEA中的Frames窗口中可以定位到调用setCookie 方法的地方，果然在 HttpConnection 的 initConn 方法中会调用setCookie 方法，从 CookiePool 中根据url里的host获取cookie。

{% asset_img init.png Hutool设置cookie %}


我们看下 CookiePool 这个类，该类内部为了一个静态的Map，key是host, value是cookies字符串，CookiePool 用于模拟浏览器的Cookie，当访问后站点，记录Cookie，下次再访问这个站点时，一并提交Cookie到站点。也就是说以后的请求都会携带这个cookie。

```java
package com.xiaoleilu.hutool.http;

import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

/**
 *Cookie池。此池针对所有HTTP请求可用。<br>
 *此Cookie池用于模拟浏览器的Cookie，当访问后站点，记录Cookie，下次再访问这个站点时，一并提交Cookie到站点。
 * @author Looly
 *
 */
public class CookiePool {
	
	//key: host, value: cookies字符串
	private static Map<String, String> cookies = new ConcurrentHashMap<String, String>();
	
	/**
	 * 获得某个网站的Cookie信息
	 * @param host 网站Host
	 * @return Cookie字符串
	 */
	public static String get(String host) {
		return cookies.get(host);
	}
	
	/**
	 * 将某个网站的Cookie放入Cookie池
	 * @param host 网站Host
	 * @param cookie Cookie字符串
	 */
	public static void put(String host, String cookie) {
		cookies.put(host, cookie);
	}
	
	/**
	 * 清空Cookie
	 * @since 3.0.7
	 */
	public static void clear(){
		cookies.clear();
	}
}

```

那么这个cookie是从哪里来的呢？继续看下 CookiePool 中的 put 方法在哪些地方被调用了，在 HttpConnection 类中找到了 storeCookie 方法

```java
/**
 * 存储服务器返回的Cookie到本地
 */
private void storeCookie() {
    final String setCookie = header(Header.SET_COOKIE);
    if (StrUtil.isBlank(setCookie) == false) {
        log.debug("Set cookie: [{}]", setCookie);
        CookiePool.put(url.getHost(), setCookie);
    }
}
```

在HttpRequest中的 execute() 方法发送请求之后，获取响应数据的时候会调用 httpConnection.getInputStream()，获取服务端返回的信息时，从响应头中提取Set-Cookie字段的值，保存到CookiePool中。

原来是我们大部分的接口都是根据第三方接口，通过在请求header中添加 X_API_KEY用于接口验证，而有一个接口第三方并没有提供，于是我们通过模拟登录的方式登录到网站来抓取数据，就是在调动登录接口的时候，第三方服务端在响应中返回了 Set-Cookie 信息，而Hutool工具会从响应中提取 Set-Cookie信息保存在CookiePool 中，并在后续请求中携带这个cookie。

第三方网站登录接口返回的cookie

{% asset_img login.png 第三方登录接口 %}


至此，问题已经定位到了，既然我们不想要这个cookie，那么可以在模拟登录调用第三方接口之后，调用CookiePool 中的put方法将host对应的cookie重置为null，这样同一个host的其他请求就不会携带cookie了。

```java
// 清除cookie
CookiePool.put(ip, null);
```

总结，本文通过tcpdump抓包工具，查看完整的HTTP请求，分析了Hutool工具发送HTTP请求过程的源码，最终定位并解决了问题。

