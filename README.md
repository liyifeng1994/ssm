# SSM
手把手教你整合最优雅SSM框架：SpringMVC + Spring + MyBatis

博客地址：[http://blog.csdn.net/qq598535550/article/details/51703190](http://blog.csdn.net/qq598535550/article/details/51703190)

---------

> 我们看招聘信息的时候，经常会看到这一点，需要具备SSH框架的技能；而且在大部分教学课堂中，也会把SSH作为最核心的教学内容。
> 但是，我们在实际应用中发现，SpringMVC可以完全替代Struts，配合注解的方式，编程非常快捷，而且通过restful风格定义url，让地址看起来非常优雅。
> 另外，MyBatis也可以替换Hibernate，正因为MyBatis的半自动特点，我们程序猿可以完全掌控SQL，这会让有数据库经验的程序猿能开发出高效率的SQL语句，而且XML配置管理起来也非常方便。
> 好了，如果你也认同我的看法，那么下面我们一起来做整合吧！

在写代码之前我们先了解一下这三个框架分别是干什么的？
相信大以前也看过不少这些概念，我这就用大白话来讲，如果之前有了解过可以跳过这一大段，直接看代码！

 1. SpringMVC：它用于web层，相当于controller（等价于传统的servlet和struts的action），用来处理用户请求。举个例子，用户在地址栏输入http://网站域名/login，那么springmvc就会拦截到这个请求，并且调用controller层中相应的方法，（中间可能包含验证用户名和密码的业务逻辑，以及查询数据库操作，但这些都不是springmvc的职责），最终把结果返回给用户，并且返回相应的页面（当然也可以只返回json/xml等格式数据）。springmvc就是做前面和后面过程的活，与用户打交道！！
 
 2. Spring：太强大了，以至于我无法用一个词或一句话来概括它。但与我们平时开发接触最多的估计就是IOC容器，它可以装载bean（也就是我们java中的类，当然也包括service dao里面的），有了这个机制，我们就不用在每次使用这个类的时候为它初始化，很少看到关键字new。另外spring的aop，事务管理等等都是我们经常用到的。

 3. MyBatis：如果你问我它跟鼎鼎大名的Hibernate有什么区别？我只想说，他更符合我的需求。第一，它能自由控制sql，这会让有数据库经验的人（当然不是说我啦~捂脸~）编写的代码能搞提升数据库访问的效率。第二，它可以使用xml的方式来组织管理我们的sql，因为一般程序出错很多情况下是sql出错，别人接手代码后能快速找到出错地方，甚至可以优化原来写的sql。

--------------

## SSM框架整合配置

好了，前面bb那么多，下面我们真正开始敲代码了~

首先我们打开IED，我这里用的是eclipse（你们应该也是用的这个，对吗？），创建一个动态web项目，建立好相应的**目录结构**（重点！）

![项目结构图](http://img.blog.csdn.net/20160618002041099)

（打了马赛克是因为这里还用不到，你们不要那么污好不好？）

我说一下每个目录都有什么用吧（第一次画表格，我发现markdown的表格语法很不友好呀~）
这个目录结构同时也遵循maven的目录规范~

| 文件名 | 作用 |
| --- | --- |
| src | 根目录，没什么好说的，下面有main和test。 |
| main | 主要目录，可以放java代码和一些资源文件。 |
| java | 存放我们的java代码，这个文件夹要使用Build Path -> Use as Source Folder，这样看包结构会方便很多，新建的包就相当于在这里新建文件夹咯。 |
| resources | 存放资源文件，譬如各种的spring，mybatis，log配置文件。 |
| mapper | 存放dao中每个方法对应的sql，在这里配置，无需写daoImpl。
| spring | 这里当然是存放spring相关的配置文件，有dao service web三层。 |
| sql | 其实这个可以没有，但是为了项目完整性还是加上吧。 |
| webapp | 这个貌似是最熟悉的目录了，用来存放我们前端的静态资源，如jsp js css。 |
| resources | 这里的资源是指项目的静态资源，如js css images等。 |
| WEB-INF | 很重要的一个目录，外部浏览器无法访问，只有羡慕内部才能访问，可以把jsp放在这里，另外就是web.xml了。你可能有疑问了，为什么上面java中的resources里面的配置文件不妨在这里，那么是不是会被外部窃取到？你想太多了，部署时候基本上只有webapp里的会直接输出到根目录，其他都会放入WEB-INF里面，项目内部依然可以使用classpath:XXX来访问，好像IDE里可以设置部署输出目录，这里扯远了~ |
| test | 这里是测试分支。 |
| java | 测试java代码，应遵循包名相同的原则，这个文件夹同样要使用Build Path -> Use as Source Folder，这样看包结构会方便很多。 |
| resources | 没什么好说的，好像也很少用到，但这个是maven的规范。 |


---------------

我先新建好几个必要的**包**，并为大家讲解一下每个包的作用，顺便理清一下后台的思路~

![包结构图](http://img.blog.csdn.net/20160618004306660)

| 包名 | 名称 | 作用 |
| --- | --- | --- |
| dao | 数据访问层（接口） | 与数据打交道，可以是数据库操作，也可以是文件读写操作，甚至是redis缓存操作，总之与数据操作有关的都放在这里，也有人叫做dal或者数据持久层都差不多意思。为什么没有daoImpl，因为我们用的是mybatis，所以可以直接在配置文件中实现接口的每个方法。 |
| entity | 实体类 | 一般与数据库的表相对应，封装dao层取出来的数据为一个对象，也就是我们常说的pojo，一般只在dao层与service层之间传输。 |
| dto | 数据传输层 | 刚学框架的人可能不明白这个有什么用，其实就是用于service层与web层之间传输，为什么不直接用entity（pojo）？其实在实际开发中发现，很多时间一个entity并不能满足我们的业务需求，可能呈现给用户的信息十分之多，这时候就有了dto，也相当于vo，记住一定不要把这个混杂在entity里面，答应我好吗？ |
| service | 业务逻辑（接口） | 写我们的业务逻辑，也有人叫bll，在设计业务接口时候应该站在“使用者”的角度。额，不要问我为什么这里没显示！IDE调皮我也拿它没办法~ |
| serviceImpl | 业务逻辑（实现） | 实现我们业务接口，一般事务控制是写在这里，没什么好说的。 |
| web | 控制器 | springmvc就是在这里发挥作用的，一般人叫做controller控制器，相当于struts中的action。 |


-----------

还有最后一步基础工作，导入我们相应的jar包，我使用的是maven来管理我们的jar，所以只需要在`pom.xml`中加入相应的依赖就好了，如果不使用maven的可以自己去官网下载相应的jar，放到项目WEB-INF/lib目录下。关于maven的学习大家可以看[慕课网的视频教程](http://www.imooc.com/learn/443)，这里就不展开了。我把项目用到的jar都写在下面，版本都不是最新的，大家有经验的话可以自己调整版本号。另外，所有jar都会与项目一起打包放到我的[github](https://github.com/liyifeng1994/ssm)上，喜欢的给个star吧~

**pom.xml**
``` xml
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/maven-v4_0_0.xsd">
	<modelVersion>4.0.0</modelVersion>
	<groupId>com.soecode.ssm</groupId>
	<artifactId>ssm</artifactId>
	<packaging>war</packaging>
	<version>0.0.1-SNAPSHOT</version>
	<name>ssm Maven Webapp</name>
	<url>http://github.com/liyifeng1994/ssm</url>
	<dependencies>
		<!-- 单元测试 -->
		<dependency>
			<groupId>junit</groupId>
			<artifactId>junit</artifactId>
			<version>4.11</version>
		</dependency>

		<!-- 1.日志 -->
		<!-- 实现slf4j接口并整合 -->
		<dependency>
			<groupId>ch.qos.logback</groupId>
			<artifactId>logback-classic</artifactId>
			<version>1.1.1</version>
		</dependency>

		<!-- 2.数据库 -->
		<dependency>
			<groupId>mysql</groupId>
			<artifactId>mysql-connector-java</artifactId>
			<version>5.1.37</version>
			<scope>runtime</scope>
		</dependency>
		<dependency>
			<groupId>c3p0</groupId>
			<artifactId>c3p0</artifactId>
			<version>0.9.1.2</version>
		</dependency>

		<!-- DAO: MyBatis -->
		<dependency>
			<groupId>org.mybatis</groupId>
			<artifactId>mybatis</artifactId>
			<version>3.3.0</version>
		</dependency>
		<dependency>
			<groupId>org.mybatis</groupId>
			<artifactId>mybatis-spring</artifactId>
			<version>1.2.3</version>
		</dependency>

		<!-- 3.Servlet web -->
		<dependency>
			<groupId>taglibs</groupId>
			<artifactId>standard</artifactId>
			<version>1.1.2</version>
		</dependency>
		<dependency>
			<groupId>jstl</groupId>
			<artifactId>jstl</artifactId>
			<version>1.2</version>
		</dependency>
		<dependency>
			<groupId>com.fasterxml.jackson.core</groupId>
			<artifactId>jackson-databind</artifactId>
			<version>2.5.4</version>
		</dependency>
		<dependency>
			<groupId>javax.servlet</groupId>
			<artifactId>javax.servlet-api</artifactId>
			<version>3.1.0</version>
		</dependency>

		<!-- 4.Spring -->
		<!-- 1)Spring核心 -->
		<dependency>
			<groupId>org.springframework</groupId>
			<artifactId>spring-core</artifactId>
			<version>4.1.7.RELEASE</version>
		</dependency>
		<dependency>
			<groupId>org.springframework</groupId>
			<artifactId>spring-beans</artifactId>
			<version>4.1.7.RELEASE</version>
		</dependency>
		<dependency>
			<groupId>org.springframework</groupId>
			<artifactId>spring-context</artifactId>
			<version>4.1.7.RELEASE</version>
		</dependency>
		<!-- 2)Spring DAO层 -->
		<dependency>
			<groupId>org.springframework</groupId>
			<artifactId>spring-jdbc</artifactId>
			<version>4.1.7.RELEASE</version>
		</dependency>
		<dependency>
			<groupId>org.springframework</groupId>
			<artifactId>spring-tx</artifactId>
			<version>4.1.7.RELEASE</version>
		</dependency>
		<!-- 3)Spring web -->
		<dependency>
			<groupId>org.springframework</groupId>
			<artifactId>spring-web</artifactId>
			<version>4.1.7.RELEASE</version>
		</dependency>
		<dependency>
			<groupId>org.springframework</groupId>
			<artifactId>spring-webmvc</artifactId>
			<version>4.1.7.RELEASE</version>
		</dependency>
		<!-- 4)Spring test -->
		<dependency>
			<groupId>org.springframework</groupId>
			<artifactId>spring-test</artifactId>
			<version>4.1.7.RELEASE</version>
		</dependency>

		<!-- redis客户端:Jedis -->
		<dependency>
			<groupId>redis.clients</groupId>
			<artifactId>jedis</artifactId>
			<version>2.7.3</version>
		</dependency>
		<dependency>
			<groupId>com.dyuproject.protostuff</groupId>
			<artifactId>protostuff-core</artifactId>
			<version>1.0.8</version>
		</dependency>
		<dependency>
			<groupId>com.dyuproject.protostuff</groupId>
			<artifactId>protostuff-runtime</artifactId>
			<version>1.0.8</version>
		</dependency>

		<!-- Map工具类 -->
		<dependency>
			<groupId>commons-collections</groupId>
			<artifactId>commons-collections</artifactId>
			<version>3.2</version>
		</dependency>
	</dependencies>
	<build>
		<finalName>ssm</finalName>
	</build>
</project>

```

-----------

下面真的要开始进行编码工作了，坚持到这里辛苦大家了~

第一步：我们先在`spring`文件夹里新建`spring-dao.xml`文件，因为spring的配置太多，我们这里分三层，分别是dao service web。

 1. 读入数据库连接相关参数（可选）
 2. 配置数据连接池
  1. 配置连接属性，可以不读配置项文件直接在这里写死
  2. 配置c3p0，只配了几个常用的
 3. 配置SqlSessionFactory对象（mybatis）
 4. 扫描dao层接口，动态实现dao接口，也就是说不需要daoImpl，sql和参数都写在xml文件上

**spring-dao.xml**
``` xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:context="http://www.springframework.org/schema/context"
	xsi:schemaLocation="http://www.springframework.org/schema/beans
	http://www.springframework.org/schema/beans/spring-beans.xsd
	http://www.springframework.org/schema/context
	http://www.springframework.org/schema/context/spring-context.xsd">
	<!-- 配置整合mybatis过程 -->
	<!-- 1.配置数据库相关参数properties的属性：${url} -->
	<context:property-placeholder location="classpath:jdbc.properties" />

	<!-- 2.数据库连接池 -->
	<bean id="dataSource" class="com.mchange.v2.c3p0.ComboPooledDataSource">
		<!-- 配置连接池属性 -->
		<property name="driverClass" value="${jdbc.driver}" />
		<property name="jdbcUrl" value="${jdbc.url}" />
		<property name="user" value="${jdbc.username}" />
		<property name="password" value="${jdbc.password}" />

		<!-- c3p0连接池的私有属性 -->
		<property name="maxPoolSize" value="30" />
		<property name="minPoolSize" value="10" />
		<!-- 关闭连接后不自动commit -->
		<property name="autoCommitOnClose" value="false" />
		<!-- 获取连接超时时间 -->
		<property name="checkoutTimeout" value="10000" />
		<!-- 当获取连接失败重试次数 -->
		<property name="acquireRetryAttempts" value="2" />
	</bean>

	<!-- 3.配置SqlSessionFactory对象 -->
	<bean id="sqlSessionFactory" class="org.mybatis.spring.SqlSessionFactoryBean">
		<!-- 注入数据库连接池 -->
		<property name="dataSource" ref="dataSource" />
		<!-- 配置MyBaties全局配置文件:mybatis-config.xml -->
		<property name="configLocation" value="classpath:mybatis-config.xml" />
		<!-- 扫描entity包 使用别名 -->
		<property name="typeAliasesPackage" value="com.soecode.lyf.entity" />
		<!-- 扫描sql配置文件:mapper需要的xml文件 -->
		<property name="mapperLocations" value="classpath:mapper/*.xml" />
	</bean>

	<!-- 4.配置扫描Dao接口包，动态实现Dao接口，注入到spring容器中 -->
	<bean class="org.mybatis.spring.mapper.MapperScannerConfigurer">
		<!-- 注入sqlSessionFactory -->
		<property name="sqlSessionFactoryBeanName" value="sqlSessionFactory" />
		<!-- 给出需要扫描Dao接口包 -->
		<property name="basePackage" value="com.soecode.lyf.dao" />
	</bean>
</beans>
```
因为数据库配置相关参数是读取配置文件，所以在`resources`文件夹里新建一个`jdbc.properties`文件，存放我们4个最常见的数据库连接属性，这是我本地的，大家记得修改呀~还有喜欢传到github上“大头虾们”记得删掉密码，不然别人就很容易得到你服务器的数据库配置信息，然后干一些羞羞的事情，你懂的！！

**jdbc.properties**
``` properties
jdbc.driver=com.mysql.jdbc.Driver
jdbc.url=jdbc:mysql://localhost:3307/ssm?useUnicode=true&characterEncoding=utf8
jdbc.username=root
jdbc.password=
```
**友情提示**：配置文件中的jdbc.username，如果写成username，可能会与系统环境中的username变量冲突，所以到时候真正连接数据库的时候，用户名就被替换成系统中的用户名（有得可能是administrator），那肯定是连接不成功的，这里有个小坑，我被坑了一晚上！！

因为这里用到了mybatis，所以需要配置mybatis核心文件，在`recources`文件夹里新建`mybatis-config.xml`文件。

 1. 使用自增主键
 2. 使用列别名
 3. 开启驼峰命名转换 create_time -> createTime

**mybatis-config.xml**
``` xml
<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE configuration
  PUBLIC "-//mybatis.org//DTD Config 3.0//EN"
  "http://mybatis.org/dtd/mybatis-3-config.dtd">
<configuration>
	<!-- 配置全局属性 -->
	<settings>
		<!-- 使用jdbc的getGeneratedKeys获取数据库自增主键值 -->
		<setting name="useGeneratedKeys" value="true" />

		<!-- 使用列别名替换列名 默认:true -->
		<setting name="useColumnLabel" value="true" />

		<!-- 开启驼峰命名转换:Table{create_time} -> Entity{createTime} -->
		<setting name="mapUnderscoreToCamelCase" value="true" />
	</settings>
</configuration>
```

第二步：刚弄好dao层，接下来到service层了。在`spring`文件夹里新建`spring-service.xml`文件。

 1. 扫描service包所有注解 @Service
 2. 配置事务管理器，把事务管理交由spring来完成
 3. 配置基于注解的声明式事务，可以直接在方法上@Transaction

**spring-service.xml**
``` xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
	xmlns:context="http://www.springframework.org/schema/context"
	xmlns:tx="http://www.springframework.org/schema/tx"
	xsi:schemaLocation="http://www.springframework.org/schema/beans
	http://www.springframework.org/schema/beans/spring-beans.xsd
	http://www.springframework.org/schema/context
	http://www.springframework.org/schema/context/spring-context.xsd
	http://www.springframework.org/schema/tx
	http://www.springframework.org/schema/tx/spring-tx.xsd">
	<!-- 扫描service包下所有使用注解的类型 -->
	<context:component-scan base-package="com.soecode.lyf.service" />

	<!-- 配置事务管理器 -->
	<bean id="transactionManager"
		class="org.springframework.jdbc.datasource.DataSourceTransactionManager">
		<!-- 注入数据库连接池 -->
		<property name="dataSource" ref="dataSource" />
	</bean>

	<!-- 配置基于注解的声明式事务 -->
	<tx:annotation-driven transaction-manager="transactionManager" />
</beans>
```

-------------

第三步：配置web层，在`spring`文件夹里新建`spring-web.xml`文件。

 1. 开启SpringMVC注解模式，可以使用@RequestMapping，@PathVariable，@ResponseBody等
 2. 对静态资源处理，如js，css，jpg等
 3. 配置jsp 显示ViewResolver，例如在controller中某个方法返回一个string类型的"login"，实际上会返回"/WEB-INF/login.jsp"
 4. 扫描web层 @Controller

**spring-web.xml**
``` xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:context="http://www.springframework.org/schema/context"
	xmlns:mvc="http://www.springframework.org/schema/mvc" 
	xsi:schemaLocation="http://www.springframework.org/schema/beans
	http://www.springframework.org/schema/beans/spring-beans.xsd
	http://www.springframework.org/schema/context
	http://www.springframework.org/schema/context/spring-context.xsd
	http://www.springframework.org/schema/mvc
	http://www.springframework.org/schema/mvc/spring-mvc-3.0.xsd">
	<!-- 配置SpringMVC -->
	<!-- 1.开启SpringMVC注解模式 -->
	<!-- 简化配置： 
		(1)自动注册DefaultAnootationHandlerMapping,AnotationMethodHandlerAdapter 
		(2)提供一些列：数据绑定，数字和日期的format @NumberFormat, @DateTimeFormat, xml,json默认读写支持 
	-->
	<mvc:annotation-driven />
	
	<!-- 2.静态资源默认servlet配置
		(1)加入对静态资源的处理：js,gif,png
		(2)允许使用"/"做整体映射
	 -->
	 <mvc:default-servlet-handler/>
	 
	 <!-- 3.配置jsp 显示ViewResolver -->
	 <bean class="org.springframework.web.servlet.view.InternalResourceViewResolver">
	 	<property name="viewClass" value="org.springframework.web.servlet.view.JstlView" />
	 	<property name="prefix" value="/WEB-INF/jsp/" />
	 	<property name="suffix" value=".jsp" />
	 </bean>
	 
	 <!-- 4.扫描web相关的bean -->
	 <context:component-scan base-package="com.soecode.lyf.web" />
</beans>
```

------------

第四步：最后就是修改`web.xml`文件了，它在`webapp`的`WEB-INF`下。

**web.xml**
``` xml
<web-app xmlns="http://xmlns.jcp.org/xml/ns/javaee" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xsi:schemaLocation="http://xmlns.jcp.org/xml/ns/javaee
                      http://xmlns.jcp.org/xml/ns/javaee/web-app_3_1.xsd"
	version="3.1" metadata-complete="true">
	<!-- 如果是用mvn命令生成的xml，需要修改servlet版本为3.1 -->
	<!-- 配置DispatcherServlet -->
	<servlet>
		<servlet-name>seckill-dispatcher</servlet-name>
		<servlet-class>org.springframework.web.servlet.DispatcherServlet</servlet-class>
		<!-- 配置springMVC需要加载的配置文件
			spring-dao.xml,spring-service.xml,spring-web.xml
			Mybatis - > spring -> springmvc
		 -->
		<init-param>
			<param-name>contextConfigLocation</param-name>
			<param-value>classpath:spring/spring-*.xml</param-value>
		</init-param>
	</servlet>
	<servlet-mapping>
		<servlet-name>seckill-dispatcher</servlet-name>
		<!-- 默认匹配所有的请求 -->
		<url-pattern>/</url-pattern>
	</servlet-mapping>
</web-app>

```

-----------

我们在项目中经常会使用到日志，所以这里还有配置日志xml，在`resources`文件夹里新建`logback.xml`文件，所给出的日志输出格式也是最基本的控制台s呼出，大家有兴趣查看[logback官方文档](http://logback.qos.ch/manual/)。

**logback.xml**
``` xml
<?xml version="1.0" encoding="UTF-8"?>
<configuration debug="true">
	<appender name="STDOUT" class="ch.qos.logback.core.ConsoleAppender">
		<!-- encoders are by default assigned the type ch.qos.logback.classic.encoder.PatternLayoutEncoder -->
		<encoder>
			<pattern>%d{HH:mm:ss.SSS} [%thread] %-5level %logger{36} - %msg%n</pattern>
		</encoder>
	</appender>

	<root level="debug">
		<appender-ref ref="STDOUT" />
	</root>
</configuration>
```

-----------

到目前为止，我们一共写了7个配置文件，我们一起来看下最终的**配置文件结构图**。

![配置文件结构图](http://img.blog.csdn.net/20160618142208354)

----------

## SSM框架应用实例（图书管理系统）

> 一开始想就这样结束教程，但是发现其实很多人都还不会把这个SSM框架用起来，特别是mybatis部分。那我现在就以最常见的“图书管理系统”中【查询图书】和【预约图书】业务来做一个demo吧！

首先新建数据库名为`ssm`，再创建两张表：图书表`book`和预约图书表`appointment`，并且为`book`表初始化一些数据，sql如下。

**schema.sql**
``` sql
-- 创建图书表
CREATE TABLE `book` (
  `book_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '图书ID',
  `name` varchar(100) NOT NULL COMMENT '图书名称',
  `number` int(11) NOT NULL COMMENT '馆藏数量',
  PRIMARY KEY (`book_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1000 DEFAULT CHARSET=utf8 COMMENT='图书表'

-- 初始化图书数据
INSERT INTO `book` (`book_id`, `name`, `number`)
VALUES
	(1000, 'Java程序设计', 10),
	(1001, '数据结构', 10),
	(1002, '设计模式', 10),
	(1003, '编译原理', 10)

-- 创建预约图书表
CREATE TABLE `appointment` (
  `book_id` bigint(20) NOT NULL COMMENT '图书ID',
  `student_id` bigint(20) NOT NULL COMMENT '学号',
  `appoint_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '预约时间' ,
  PRIMARY KEY (`book_id`, `student_id`),
  INDEX `idx_appoint_time` (`appoint_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='预约图书表'
```

------------

在`entity`包中添加两个对应的实体，图书实体`Book.java`和预约图书实体`Appointment.java`。

**Book.java**
```java
package com.soecode.lyf.entity;

public class Book {

	private long bookId;// 图书ID

	private String name;// 图书名称

	private int number;// 馆藏数量

	// 省略构造方法，getter和setter方法，toString方法

}
```

**Appointment.java**
``` java
package com.soecode.lyf.entity;

import java.util.Date;

/**
 * 预约图书实体
 */
public class Appointment {

	private long bookId;// 图书ID

	private long studentId;// 学号

	private Date appointTime;// 预约时间

	// 多对一的复合属性
	private Book book;// 图书实体
	
	// 省略构造方法，getter和setter方法，toString方法

}
```

------------

在`dao`包新建接口`BookDao.java`和`Appointment.java`

**BookDao.java**
``` java
package com.soecode.lyf.dao;

import java.util.List;

import com.soecode.lyf.entity.Book;

public interface BookDao {

	/**
	 * 通过ID查询单本图书
	 * 
	 * @param id
	 * @return
	 */
	Book queryById(long id);

	/**
	 * 查询所有图书
	 * 
	 * @param offset 查询起始位置
	 * @param limit 查询条数
	 * @return
	 */
	List<Book> queryAll(@Param("offset") int offset, @Param("limit") int limit);

	/**
	 * 减少馆藏数量
	 * 
	 * @param bookId
	 * @return 如果影响行数等于>1，表示更新的记录行数
	 */
	int reduceNumber(long bookId);
}

```

**AppointmentDao.java**
```java
package com.soecode.lyf.dao;

import org.apache.ibatis.annotations.Param;

import com.soecode.lyf.entity.Appointment;

public interface AppointmentDao {

	/**
	 * 插入预约图书记录
	 * 
	 * @param bookId
	 * @param studentId
	 * @return 插入的行数
	 */
	int insertAppointment(@Param("bookId") long bookId, @Param("studentId") long studentId);

	/**
	 * 通过主键查询预约图书记录，并且携带图书实体
	 * 
	 * @param bookId
	 * @param studentId
	 * @return
	 */
	Appointment queryByKeyWithBook(@Param("bookId") long bookId, @Param("studentId") long studentId);

}
```
**提示**：这里为什么要给方法的参数添加`@Param`注解呢？是因为该方法有两个或以上的参数，一定要加，不然mybatis识别不了。上面的`BookDao`接口的`queryById`方法和`reduceNumber`方法只有一个参数`book_id`，所以可以不用加 `@Param`注解，当然加了也无所谓~

---------------

注意，这里不需要实现dao接口不用编写daoImpl， mybatis会给我们动态实现，但是我们需要编写相应的mapper。
在`mapper`目录里新建两个文件`BookDao.xml`和`AppointmentDao.xml`，分别对应上面两个dao接口，代码如下。

**BookDao.xml**
``` xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE mapper
    PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN"
    "http://mybatis.org/dtd/mybatis-3-mapper.dtd">
<mapper namespace="com.soecode.lyf.dao.BookDao">
	<!-- 目的：为dao接口方法提供sql语句配置 -->
	<select id="queryById" resultType="Book" parameterType="long">
		<!-- 具体的sql -->
		SELECT
			book_id,
			name,
			number
		FROM
			book
		WHERE
			book_id = #{bookId}
	</select>
	
	<select id="queryAll" resultType="Book">
		SELECT
			book_id,
			name,
			number
		FROM
			book
		ORDER BY
			book_id
		LIMIT #{offset}, #{limit}
	</select>
	
	<update id="reduceNumber">
		UPDATE book
		SET number = number - 1
		WHERE
			book_id = #{bookId}
		AND number > 0
	</update>
</mapper>
```

**AppointmentDao.xml**
``` xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE mapper
    PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN"
    "http://mybatis.org/dtd/mybatis-3-mapper.dtd">
<mapper namespace="com.soecode.lyf.dao.AppointmentDao">
	<insert id="insertAppointment">
		<!-- ignore 主键冲突，报错 -->
		INSERT ignore INTO appointment (book_id, student_id)
		VALUES (#{bookId}, #{studentId})
	</insert>
	
	<select id="queryByKeyWithBook" resultType="Appointment">
		<!-- 如何告诉MyBatis把结果映射到Appointment同时映射book属性 -->
		<!-- 可以自由控制SQL -->
		SELECT
			a.book_id,
			a.student_id,
			a.appoint_time,
			b.book_id "book.book_id",
			b.`name` "book.name",
			b.number "book.number"
		FROM
			appointment a
		INNER JOIN book b ON a.book_id = b.book_id
		WHERE
			a.book_id = #{bookId}
		AND a.student_id = #{studentId}
	</select>
</mapper>
```

**mapper总结**：`namespace`是该xml对应的接口全名，`select`和`update`中的`id`对应方法名，`resultType`是返回值类型，`parameterType`是参数类型（这个其实可选），最后`#{...}`中填写的是方法的参数，看懂了是不是很简单！！我也这么觉得~ 还有一个小技巧要交给大家，就是在返回`Appointment`对象包含了一个属性名为`book`的Book对象，那么可以使用`"book.属性名"`的方式来取值，看上面`queryByKeyWithBook`方法的sql。

------------

`dao`层写完了，接下来`test`对应的`package`写我们测试方法吧。
因为我们之后会写很多测试方法，在测试前需要让程序读入spring-dao和mybatis等配置文件，所以我这里就抽离出来一个`BaseTest`类，只要是测试方法就继承它，这样那些繁琐的重复的代码就不用写那么多了~

**BaseTest.java**
``` java
package com.soecode.lyf;

import org.junit.runner.RunWith;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;

/**
 * 配置spring和junit整合，junit启动时加载springIOC容器 spring-test,junit
 */
@RunWith(SpringJUnit4ClassRunner.class)
// 告诉junit spring配置文件
@ContextConfiguration({ "classpath:spring/spring-dao.xml", "classpath:spring/spring-service.xml" })
public class BaseTest {

}

```
因为`spring-service`在`service`层的测试中会时候到，这里也一起引入算了！

新建`BookDaoTest.java`和`AppointmentDaoTest.java`两个dao测试文件。

**BookDaoTest.java**
``` java
package com.soecode.lyf.dao;

import java.util.List;

import org.junit.Test;
import org.springframework.beans.factory.annotation.Autowired;

import com.soecode.lyf.BaseTest;
import com.soecode.lyf.entity.Book;

public class BookDaoTest extends BaseTest {

	@Autowired
	private BookDao bookDao;

	@Test
	public void testQueryById() throws Exception {
		long bookId = 1000;
		Book book = bookDao.queryById(bookId);
		System.out.println(book);
	}

	@Test
	public void testQueryAll() throws Exception {
		List<Book> books = bookDao.queryAll(0, 4);
		for (Book book : books) {
			System.out.println(book);
		}
	}

	@Test
	public void testReduceNumber() throws Exception {
		long bookId = 1000;
		int update = bookDao.reduceNumber(bookId);
		System.out.println("update=" + update);
	}

}
```
#### BookDaoTest测试结果

***testQueryById***
![testQueryById](http://img.bbs.csdn.net/upload/201606/18/1466255160_717902.png)

***testQueryAll***
![testQueryAll](http://img.bbs.csdn.net/upload/201606/18/1466255452_743822.png)

***testReduceNumber***
![testReduceNumber](http://img.bbs.csdn.net/upload/201606/18/1466255505_256048.png)


**AppointmentDaoTest.java**
``` java
package com.soecode.lyf.dao;

import org.junit.Test;
import org.springframework.beans.factory.annotation.Autowired;

import com.soecode.lyf.BaseTest;
import com.soecode.lyf.entity.Appointment;

public class AppointmentDaoTest extends BaseTest {

	@Autowired
	private AppointmentDao appointmentDao;

	@Test
	public void testInsertAppointment() throws Exception {
		long bookId = 1000;
		long studentId = 12345678910L;
		int insert = appointmentDao.insertAppointment(bookId, studentId);
		System.out.println("insert=" + insert);
	}

	@Test
	public void testQueryByKeyWithBook() throws Exception {
		long bookId = 1000;
		long studentId = 12345678910L;
		Appointment appointment = appointmentDao.queryByKeyWithBook(bookId, studentId);
		System.out.println(appointment);
		System.out.println(appointment.getBook());
	}

}
```
####AppointmentDaoTest测试结果

***testInsertAppointment***
![testInsertAppointment](http://img.bbs.csdn.net/upload/201606/18/1466255520_227298.png)

***testQueryByKeyWithBook***
![testQueryByKeyWithBook](http://img.bbs.csdn.net/upload/201606/18/1466255537_831651.png)

-------------

嗯，到这里一切到很顺利~那么我们继续service层的编码吧~可能下面开始信息里比较大，大家要做好心理准备~

首先，在写我们的业务之前，我们先定义几个预约图书操作返回码的数据字典，也就是我们要返回给客户端的信息。我们这类使用枚举类，没听过的小伙伴要好好恶补一下了（我也是最近才学到的= =）

**预约业务操作返回码说明**

| 返回码 | 说明 |
| --- | --- |
| 1 | 预约成功 |
| 0 | 库存不足 |
| -1 | 重复预约 |
| -2 | 系统异常 |

新建一个包叫`enums`，在里面新建一个枚举类`AppointStateEnum.java`，用来定义预约业务的数据字典，没听懂没关系，我们直接看代码吧~是不是感觉有模有样了！

**AppointStateEnum.java**
```java
package com.soecode.lyf.enums;

/**
 * 使用枚举表述常量数据字典
 */
public enum AppointStateEnum {

	SUCCESS(1, "预约成功"), NO_NUMBER(0, "库存不足"), REPEAT_APPOINT(-1, "重复预约"), INNER_ERROR(-2, "系统异常");

	private int state;

	private String stateInfo;

	private AppointStateEnum(int state, String stateInfo) {
		this.state = state;
		this.stateInfo = stateInfo;
	}

	public int getState() {
		return state;
	}

	public String getStateInfo() {
		return stateInfo;
	}

	public static AppointStateEnum stateOf(int index) {
		for (AppointStateEnum state : values()) {
			if (state.getState() == index) {
				return state;
			}
		}
		return null;
	}

}
```
-------------

接下来，在`dto`包下新建`AppointExecution.java`用来存储我们执行预约操作的返回结果。

**AppointExecution.java**
```java
package com.soecode.lyf.dto;

import com.soecode.lyf.entity.Appointment;
import com.soecode.lyf.enums.AppointStateEnum;

/**
 * 封装预约执行后结果
 */
public class AppointExecution {

	// 图书ID
	private long bookId;

	// 秒杀预约结果状态
	private int state;

	// 状态标识
	private String stateInfo;

	// 预约成功对象
	private Appointment appointment;

	public AppointExecution() {
	}

	// 预约失败的构造器
	public AppointExecution(long bookId, AppointStateEnum stateEnum) {
		this.bookId = bookId;
		this.state = stateEnum.getState();
		this.stateInfo = stateEnum.getStateInfo();
	}

	// 预约成功的构造器
	public AppointExecution(long bookId, AppointStateEnum stateEnum, Appointment appointment) {
		this.bookId = bookId;
		this.state = stateEnum.getState();
		this.stateInfo = stateEnum.getStateInfo();
		this.appointment = appointment;
	}
	
	// 省略getter和setter方法，toString方法

}

```

-------------

接着，在`exception`包下新建三个文件
`NoNumberException.java`
`RepeatAppointException.java`
`AppointException.java`
预约业务异常类（都需要继承RuntimeException），分别是无库存异常、重复预约异常、预约未知错误异常，用于业务层非成功情况下的返回（即成功返回结果，失败抛出异常）。

**NoNumberException.java**
``` java
package com.soecode.lyf.exception;

/**
 * 库存不足异常
 */
public class NoNumberException extends RuntimeException {

	public NoNumberException(String message) {
		super(message);
	}

	public NoNumberException(String message, Throwable cause) {
		super(message, cause);
	}

}

```

**RepeatAppointException.java**
``` java
package com.soecode.lyf.exception;

/**
 * 重复预约异常
 */
public class RepeatAppointException extends RuntimeException {

	public RepeatAppointException(String message) {
		super(message);
	}

	public RepeatAppointException(String message, Throwable cause) {
		super(message, cause);
	}

}

```

**AppointException.java**
``` java
package com.soecode.lyf.exception;

/**
 * 预约业务异常
 */
public class AppointException extends RuntimeException {

	public AppointException(String message) {
		super(message);
	}

	public AppointException(String message, Throwable cause) {
		super(message, cause);
	}

}

```

-------------

咱们终于可以编写业务代码了，在`service`包下新建`BookService.java`图书业务接口。

**BookService.java**
``` java
package com.soecode.lyf.service;

import java.util.List;

import com.soecode.lyf.dto.AppointExecution;
import com.soecode.lyf.entity.Book;

/**
 * 业务接口：站在"使用者"角度设计接口 三个方面：方法定义粒度，参数，返回类型（return 类型/异常）
 */
public interface BookService {

	/**
	 * 查询一本图书
	 * 
	 * @param bookId
	 * @return
	 */
	Book getById(long bookId);

	/**
	 * 查询所有图书
	 * 
	 * @return
	 */
	List<Book> getList();

	/**
	 * 预约图书
	 * 
	 * @param bookId
	 * @param studentId
	 * @return
	 */
	AppointExecution appoint(long bookId, long studentId);

}
```

在`service.impl`包下新建`BookServiceImpl.java`使用`BookService`接口，并实现里面的方法。

**BookServiceImpl**
``` java
package com.soecode.lyf.service.impl;

import java.util.List;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.soecode.lyf.dao.AppointmentDao;
import com.soecode.lyf.dao.BookDao;
import com.soecode.lyf.dto.AppointExecution;
import com.soecode.lyf.entity.Appointment;
import com.soecode.lyf.entity.Book;
import com.soecode.lyf.enums.AppointStateEnum;
import com.soecode.lyf.exception.AppointException;
import com.soecode.lyf.exception.NoNumberException;
import com.soecode.lyf.exception.RepeatAppointException;
import com.soecode.lyf.service.BookService;

@Service
public class BookServiceImpl implements BookService {

	private Logger logger = LoggerFactory.getLogger(this.getClass());

	// 注入Service依赖
	@Autowired
	private BookDao bookDao;

	@Autowired
	private AppointmentDao appointmentDao;


	@Override
	public Book getById(long bookId) {
		return bookDao.queryById(bookId);
	}

	@Override
	public List<Book> getList() {
		return bookDao.queryAll(0, 1000);
	}

	@Override
	@Transactional
	/**
	 * 使用注解控制事务方法的优点： 1.开发团队达成一致约定，明确标注事务方法的编程风格
	 * 2.保证事务方法的执行时间尽可能短，不要穿插其他网络操作，RPC/HTTP请求或者剥离到事务方法外部
	 * 3.不是所有的方法都需要事务，如只有一条修改操作，只读操作不需要事务控制
	 */
	public AppointExecution appoint(long bookId, long studentId) {
		try {
			// 减库存
			int update = bookDao.reduceNumber(bookId);
			if (update <= 0) {// 库存不足
				//return new AppointExecution(bookId, AppointStateEnum.NO_NUMBER);//错误写法				
				throw new NoNumberException("no number");
			} else {
				// 执行预约操作
				int insert = appointmentDao.insertAppointment(bookId, studentId);
				if (insert <= 0) {// 重复预约
					//return new AppointExecution(bookId, AppointStateEnum.REPEAT_APPOINT);//错误写法
					throw new RepeatAppointException("repeat appoint");
				} else {// 预约成功
					Appointment appointment = appointmentDao.queryByKeyWithBook(bookId, studentId);
					return new AppointExecution(bookId, AppointStateEnum.SUCCESS, appointment);
				}
			}
		// 要先于catch Exception异常前先catch住再抛出，不然自定义的异常也会被转换为AppointException，导致控制层无法具体识别是哪个异常
		} catch (NoNumberException e1) {
			throw e1;
		} catch (RepeatAppointException e2) {
			throw e2;
		} catch (Exception e) {
			logger.error(e.getMessage(), e);
			// 所有编译期异常转换为运行期异常
			//return new AppointExecution(bookId, AppointStateEnum.INNER_ERROR);//错误写法
			throw new AppointException("appoint inner error:" + e.getMessage());
		}
	}

}

```

--------------

下面我们来测试一下我们的业务代码吧~因为查询图书的业务不复杂，所以这里只演示我们最重要的预约图书业务！！

**BookServiceImplTest.java**
``` java
package com.soecode.lyf.service.impl;

import static org.junit.Assert.fail;

import org.junit.Test;
import org.springframework.beans.factory.annotation.Autowired;

import com.soecode.lyf.BaseTest;
import com.soecode.lyf.dto.AppointExecution;
import com.soecode.lyf.service.BookService;

public class BookServiceImplTest extends BaseTest {

	@Autowired
	private BookService bookService;

	@Test
	public void testAppoint() throws Exception {
		long bookId = 1001;
		long studentId = 12345678910L;
		AppointExecution execution = bookService.appoint(bookId, studentId);
		System.out.println(execution);
	}

}

```

#### BookServiceImplTest测试结果

***testAppoint***
![testAppoint](http://img.bbs.csdn.net/upload/201606/19/1466270053_292015.png)

首次执行是“预约成功”，如果再次执行的话，应该会出现“重复预约”，哈哈，我们所有的后台代码都通过单元测试啦~~是不是很开心~

-------------

咱们还需要在`dto`包里新建一个封装json返回结果的类`Result.java`，设计成泛型。

**Result.java**
``` java
package com.soecode.lyf.dto;

/**
 * 封装json对象，所有返回结果都使用它
 */
public class Result<T> {

	private boolean success;// 是否成功标志

	private T data;// 成功时返回的数据

	private String error;// 错误信息

	public Result() {
	}

	// 成功时的构造器
	public Result(boolean success, T data) {
		this.success = success;
		this.data = data;
	}

	// 错误时的构造器
	public Result(boolean success, String error) {
		this.success = success;
		this.error = error;
	}

	// 省略getter和setter方法
}

```

------------

最后，我们写web层，也就是controller，我们在`web`包下新建`BookController.java`文件。

**BookController.java**
``` java
package com.soecode.lyf.web;

import java.util.List;

import org.apache.ibatis.annotations.Param;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;

import com.soecode.lyf.dto.AppointExecution;
import com.soecode.lyf.dto.Result;
import com.soecode.lyf.entity.Book;
import com.soecode.lyf.enums.AppointStateEnum;
import com.soecode.lyf.exception.NoNumberException;
import com.soecode.lyf.exception.RepeatAppointException;
import com.soecode.lyf.service.BookService;

@Controller
@RequestMapping("/book") // url:/模块/资源/{id}/细分 /seckill/list
public class BookController {

	private Logger logger = LoggerFactory.getLogger(this.getClass());

	@Autowired
	private BookService bookService;

	@RequestMapping(value = "/list", method = RequestMethod.GET)
	private String list(Model model) {
		List<Book> list = bookService.getList();
		model.addAttribute("list", list);
		// list.jsp + model = ModelAndView
		return "list";// WEB-INF/jsp/"list".jsp
	}

	@RequestMapping(value = "/{bookId}/detail", method = RequestMethod.GET)
	private String detail(@PathVariable("bookId") Long bookId, Model model) {
		if (bookId == null) {
			return "redirect:/book/list";
		}
		Book book = bookService.getById(bookId);
		if (book == null) {
			return "forward:/book/list";
		}
		model.addAttribute("book", book);
		return "detail";
	}

	//ajax json
	@RequestMapping(value = "/{bookId}/appoint", method = RequestMethod.POST, produces = {
			"application/json; charset=utf-8" })
	@ResponseBody
	private Result<AppointExecution> appoint(@PathVariable("bookId") Long bookId, @RequestParam("studentId") Long studentId) {
		if (studentId == null || studentId.equals("")) {
			return new Result<>(false, "学号不能为空");
		}
		//AppointExecution execution = bookService.appoint(bookId, studentId);//错误写法，不能统一返回，要处理异常（失败）情况
		AppointExecution execution = null;
		try {
			execution = bookService.appoint(bookId, studentId);
		} catch (NoNumberException e1) {
			execution = new AppointExecution(bookId, AppointStateEnum.NO_NUMBER);
		} catch (RepeatAppointException e2) {
			execution = new AppointExecution(bookId, AppointStateEnum.REPEAT_APPOINT);
		} catch (Exception e) {
			execution = new AppointExecution(bookId, AppointStateEnum.INNER_ERROR);
		}
		return new Result<AppointExecution>(true, execution);
	}

}

```

因为我比较懒，所以我们就不测试controller了,好讨厌写前端，呜呜呜~

到此，我们的SSM框架整合配置，与应用实例部分已经结束了，我把所有源码和jar包一起打包放在了我的GitHub上，需要的可以去下载，喜欢就给个star吧，这篇东西写了两个晚上也不容易啊。

----------

2017-02-28更新（感谢网友EchoXml发现）：
修改预约业务代码，失败时抛异常，成功时才返回结果，控制层根据捕获的异常返回相应信息给客户端，而不是业务层直接返回错误结果。上面的代码已经作了修改，而且错误示范也注释保留着，之前误人子弟了，还好有位网友前几天提出质疑，我也及时做了修改。

2017-03-30更新（感谢网友ergeerge1建议）：
修改BookController几处错误
1.detail方法不是返回json的，故不用加@ResponseBody注解
2.appoint方法应该加上@ResponseBody注解
3.另外studentId参数注解应该是@RequestParam
4.至于controller测试，测试appoint方法可不必写jsp，用curl就行，比如
curl -H "Accept: application/json; charset=utf-8" -d "studentId=1234567890" localhost:8080/book/1003/appoint
