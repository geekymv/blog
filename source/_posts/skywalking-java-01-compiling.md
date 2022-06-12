#### Apache SkyWalking Java Agent 源码编译

- 编译环境

  ```text
  Git 2.21.0
  JDK 1.8.0_201
  Maven 3.6.0
  ```

  **注意：Maven 版本需要3.6+。**

- Fork skywalking-java 到自己的GitHub仓库

  skywalking-java GitHub地址 https://github.com/apache/skywalking-java 点击fork到自己的GitHub仓库。

- Clone 源码到本地

  ```shell
  git clone --recurse-submodules git@github.com:geekymv/skywalking-java.git
  或
  git clone git@github.com:geekymv/skywalking-java.git
  git submodule init
  git submodule update
  ```

- 编译源码

  ```shell
  cd skywalking-java
  
  mvn clean package -Dmaven.test.skip=true
  或
  ./mvnw clean package -Dmaven.test.skip=true
  ```

- 导入IntelliJ IDEA

- 设置 **Generated Source Codes**

  `grpc-java` and `java` folders in **apm-protocol/apm-network/target/generated-sources/protobuf**

  

- 参考资料

  官方文档 https://skywalking.apache.org/docs/skywalking-java/v8.8.0/en/contribution/compiling/

  官方文档 https://skywalking.apache.org/docs/main/v8.8.1/en/guides/how-to-build/

  SkyWalking 作者给出的编译视频教程 https://www.bilibili.com/video/BV1HA411q7Md

  关于mvnw https://www.liaoxuefeng.com/wiki/1252599548343744/1305148057976866

  Maven skip test https://maven.apache.org/surefire/maven-surefire-plugin/examples/skipping-tests.html

