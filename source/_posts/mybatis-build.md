---
title: mybatis-build
date: 2019-07-18 10:11:41
tags:
---
SqlSessionFactoryBuilder
    build方法
    构造 SqlSessionFactory 类型的默认实现 DefaultSqlSessionFactory(Configuration configuration)
    

// mybatis-config.xml 配置信息
Configuration
    protected Environment environment;

Environment
      // 事务工厂 (JdbcTransactionFactory)
      private final TransactionFactory transactionFactory;
      // 数据源
      private final DataSource dataSource;

DefaultSqlSessionFactory 实现接口 SqlSessionFactory
  
    // DefaultSqlSessionFactory 中只有一个成员变量 configuration
    private final Configuration configuration;    
    

// 创建 SqlSession
SqlSession sqlSession = sqlSessionFactory.openSession()
    // execType 执行器类型，默认是ExecutorType.SIMPLE
    // level 事务隔离级别 null
    // autoCommit 自动提交，默认false
    openSessionFromDataSource(ExecutorType execType, TransactionIsolationLevel level, boolean autoCommit)

        // 从配置中获取环境信息
        final Environment environment = configuration.getEnvironment();

        // 从环境信息中获取事务工厂，这里是 JdbcTransactionFactory
        final TransactionFactory transactionFactory = getTransactionFactoryFromEnvironment(environment);

        // 根据数据源创建事务，这里是 JdbcTransaction
        Transaction tx = transactionFactory.newTransaction(environment.getDataSource(), level, autoCommit);

        // 使用 configuration 创建执行器 这里是 CachingExecutor 托委给 SimpleExecutor
        final Executor executor = configuration.newExecutor(tx, execType);
        
        return new DefaultSqlSession(configuration, executor, autoCommit); 


// Jdbc事务，用于获取连接Connection，管理连接的commit 或 rollback
JdbcTransaction
    protected Connection connection;
    // 数据源
    protected DataSource dataSource;
    // 事务隔离级别
    protected TransactionIsolationLevel level;        
    
    // 获取连接
    @Override
    public Connection getConnection() throws SQLException {
        if (connection == null) {
          openConnection();
        }
        return connection;
    }
    // 打开连接
    protected void openConnection() throws SQLException {
        if (log.isDebugEnabled()) {
          log.debug("Opening JDBC Connection");
        }
        connection = dataSource.getConnection();
        if (level != null) {
          connection.setTransactionIsolation(level.getLevel());
        }
        setDesiredAutoCommit(autoCommmit);
    }



// 简单的执行器
SimpleExecutor
    protected Configuration configuration;
    protected Transaction transaction;

// 默认的 SqlSession
DefaultSqlSession
    private final Configuration configuration;
    private final Executor executor;
    private boolean dirty; // 构造方法中设置默认值为false
    


    
    
    
    
    
    
    
    
    

https://stackoverflow.com/questions/15198319/why-do-we-use-a-datasource-instead-of-a-drivermanager    