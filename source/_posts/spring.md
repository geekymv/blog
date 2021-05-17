---
title: spring
date: 2019-02-18 12:12:33
tags:
---
HandlerMethodArgumentResolver

https://www.cnblogs.com/yangzhilong/p/7605889.html
```text
package com.btg.core.config;

import com.btg.core.Constants;
import com.btg.core.support.Token;
import com.btg.core.util.TokenUtil;
import org.springframework.core.MethodParameter;
import org.springframework.util.CollectionUtils;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.support.WebDataBinderFactory;
import org.springframework.web.context.request.NativeWebRequest;
import org.springframework.web.method.support.HandlerMethodArgumentResolver;
import org.springframework.web.method.support.ModelAndViewContainer;

import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServletRequest;
import java.util.Arrays;
import java.util.List;

public class CurrentUserMethodArgumentResolver implements HandlerMethodArgumentResolver {

    @Override
    public boolean supportsParameter(MethodParameter parameter) {
        return parameter.getParameterType() == Token.class;
    }

    @Override
    public Object resolveArgument(MethodParameter parameter, ModelAndViewContainer mavContainer, NativeWebRequest webRequest,
                                  WebDataBinderFactory binderFactory) throws Exception {
        String token = webRequest.getHeader(Constants.TOKEN);
        if(StringUtils.isEmpty(token)) {
            token = webRequest.getParameter(Constants.TOKEN);
        }
        if(StringUtils.isEmpty(token)) {
            token = getTokenFromCookie(webRequest);
        }
        if(StringUtils.isEmpty(token)) {
            return null;
        }
        return TokenUtil.getTokenInfo(token);
    }

    private String getTokenFromCookie(NativeWebRequest webRequest) {
        String token = null;
        HttpServletRequest request = webRequest.getNativeRequest(HttpServletRequest.class);
        List<Cookie> cookies = Arrays.asList(request.getCookies());
        if(!CollectionUtils.isEmpty(cookies)) {
            for(Cookie cookie : cookies) {
                String name = cookie.getName();
                if(Constants.TOKEN.equals(name)) {
                    token = cookie.getValue();
                    break;
                }
            }
        }
        return token;
    }


}



```

spring循环引用问题及解决方式
https://blog.csdn.net/chejinqiang/article/details/80003868


Spring IOC Bean 生成过程

DefaultBeanDefinitionDocumentReader 类

// Process the given bean element, parsing the bean definition 
// and registering it with the registry.
processBeanDefinition();方法


DefaultListableBeanFactory 类
registerBeanDefinition()

成员变量
/** Map of bean definition objects, keyed by bean name */
private final Map<String, BeanDefinition> beanDefinitionMap = new ConcurrentHashMap<String, BeanDefinition>(256);

/** List of bean definition names, in registration order */
private volatile List<String> beanDefinitionNames = new ArrayList<String>(256);




Spring MVC 框架主要角色
DispatcherServlet
HandlerMapping 负责查找相应的Handler以处理Web请求
Controller
ModelAndView
ViewResolver
View


HandlerInterceptor



Bean 生命周期
Bean factory implementations should support the standard bean lifecycle interfaces as far as possible. The full set of initialization methods and their standard order is:

1.BeanNameAware's setBeanName
2.BeanClassLoaderAware's setBeanClassLoader
3.BeanFactoryAware's setBeanFactory
4.EnvironmentAware's setEnvironment
5.EmbeddedValueResolverAware's setEmbeddedValueResolver
6.ResourceLoaderAware's setResourceLoader (only applicable when running in an application context)
7.ApplicationEventPublisherAware's setApplicationEventPublisher (only applicable when running in an application context)
8.MessageSourceAware's setMessageSource (only applicable when running in an application context)
9.ApplicationContextAware's setApplicationContext (only applicable when running in an application context)
10.ServletContextAware's setServletContext (only applicable when running in a web application context)
前面10个都是XxxAware接口的方法

11.postProcessBeforeInitialization methods of BeanPostProcessors
12.InitializingBean's afterPropertiesSet
13.a custom init-method definition
14.postProcessAfterInitialization methods of BeanPostProcessors


On shutdown of a bean factory, the following lifecycle methods apply:

1.postProcessBeforeDestruction methods of DestructionAwareBeanPostProcessors
2.DisposableBean's destroy
3.a custom destroy-method definition







































