---
title: ArrayList类执行remove操作竟然抛出了ConcurrentModificationException 异常
date: 2021-03-11 17:23:57
tags:
---
我们一般会有这么一个场景，比如从数据库中查询出一些数据，放入了ArrayList中。现在要对这些数据进行过滤，删除部分那些不满足条件的元素。
为了简化，我这里就不从数据库中查询了，而是模拟一些数据，ArrayList中存放了5个用户信息，现在要求将年龄小于18的用户从ArrayList中移除。

```java

public class User {

    // id
    private int id;
    // 姓名
    private String name;
    // 年龄
    private int age;

    public User() {
    }

    public User(int id, String name, int age) {
        this.id = id;
        this.name = name;
        this.age = age;
    }

    // 省略 getter setter 方法
}
```

```java
List<User> list = new ArrayList<>();

// 模拟数据
list.add(new User(1000, "张三", 22));
list.add(new User(1001, "李四", 27));
list.add(new User(1002, "王五", 16));
list.add(new User(1003, "赵六", 18));
list.add(new User(1004, "孙七", 22));

Iterator<User> iterator = list.iterator();

while (iterator.hasNext()) {
    User user = iterator.next();

    // 删除不满足条件的用户
    if(user.getAge() < 18) {
        list.remove(user);
    }
}
```

执行会抛出如下异常信息
```java
java.util.ConcurrentModificationException
	at java.util.ArrayList$Itr.checkForComodification(ArrayList.java:909)
	at java.util.ArrayList$Itr.next(ArrayList.java:859)
```

从异常信息可以看出是ArrayList内部类Itr的checkForComodification方法内部抛出了异常。


