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
