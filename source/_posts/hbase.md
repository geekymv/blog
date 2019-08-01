---
title: hbase
date: 2019-07-03 15:47:22
tags:
---
https://mirrors.tuna.tsinghua.edu.cn/apache/hbase/

vim conf/hbase-site.xml
```text
<configuration>
    <property>
        <name>hbase.rootdir</name>
        <value>file:///opt/data/hbase</value>
    </property>
</configuration>
```

启动
bin/start-hbase.sh
<!-- more -->
进入shell
bin/hbase shell
创建表
create 'test','colfam1'

查看表
list 'testtable'

插入数据
put 'test', 'myrow-1', 'colfam1:q1', 'v1'
put 'test', 'myrow-2', 'colfam1:q1', 'v1'
put 'test', 'myrow-2', 'colfam1:q2', 'v2'

查询表
scan 'test'

查询一行
get 'test', 'myrow-1'

删除一个单元格
delete 'test', 'myrow-2', 'colfam1:q1'

禁用表
disable 'test'

删除表
drop 'test'

退出shell
exit

关闭hbase
bin/stop-hbase.sh



