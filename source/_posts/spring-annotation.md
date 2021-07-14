---
title: spring-annotation
date: 2021-07-14 12:12:33
tags:
---



```java
import org.springframework.context.annotation.AnnotationConfigApplicationContext;

public class SpringAnnotationApplication {

    public static void main(String[] args) {
        AnnotationConfigApplicationContext ctx = new AnnotationConfigApplicationContext(AppConfig.class);
        
        MyBean bean = ctx.getBean(MyBean.class);
        System.out.println(bean.getName());
    }
}
```
AppConfig 配置类
```java
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class AppConfig {

    @Bean
    public MyBean myBean() {
        return new MyBean("tom");
    }
}
```

MyBean类
```java
public class MyBean {

    private String name;

    public MyBean() {
        System.out.println("my bean");
    }
    public MyBean(String name) {
        this.name = name;
    }
    public String getName() {
        return name;
    }
    public void setName(String name) {
        this.name = name;
    }
}
```

AnnotationConfigApplicationContext 类的构造方法
```java
/**
 * Create a new AnnotationConfigApplicationContext, deriving bean definitions
 * from the given annotated classes and automatically refreshing the context.
 * @param annotatedClasses one or more annotated classes,
 * e.g. {@link Configuration @Configuration} classes
 */
public AnnotationConfigApplicationContext(Class<?>... annotatedClasses) {
    // 调用默认构造方法
    this();
    // 注册注解配置类
    register(annotatedClasses);
    // 刷新
    refresh();
}

/**
 * Create a new AnnotationConfigApplicationContext that needs to be populated
 * through {@link #register} calls and then manually {@linkplain #refresh refreshed}.
 */
public AnnotationConfigApplicationContext() {
    this.reader = new AnnotatedBeanDefinitionReader(this);
    this.scanner = new ClassPathBeanDefinitionScanner(this);
}
```

AnnotatedBeanDefinitionReader 类
```java
/**
 * Create a new {@code AnnotatedBeanDefinitionReader} for the given registry.
 * If the registry is {@link EnvironmentCapable}, e.g. is an {@code ApplicationContext},
 * the {@link Environment} will be inherited, otherwise a new
 * {@link StandardEnvironment} will be created and used.
 * @param registry the {@code BeanFactory} to load bean definitions into,
 * in the form of a {@code BeanDefinitionRegistry}
 * @see #AnnotatedBeanDefinitionReader(BeanDefinitionRegistry, Environment)
 * @see #setEnvironment(Environment)
 */
public AnnotatedBeanDefinitionReader(BeanDefinitionRegistry registry) {
    this(registry, getOrCreateEnvironment(registry));
}

/**
 * Create a new {@code AnnotatedBeanDefinitionReader} for the given registry and using
 * the given {@link Environment}.
 * @param registry the {@code BeanFactory} to load bean definitions into,
 * in the form of a {@code BeanDefinitionRegistry}
 * @param environment the {@code Environment} to use when evaluating bean definition
 * profiles.
 * @since 3.1
 */
public AnnotatedBeanDefinitionReader(BeanDefinitionRegistry registry, Environment environment) {
    Assert.notNull(registry, "BeanDefinitionRegistry must not be null");
    Assert.notNull(environment, "Environment must not be null");
    this.registry = registry;
    this.conditionEvaluator = new ConditionEvaluator(registry, environment, null);
    // 注册Processor
    AnnotationConfigUtils.registerAnnotationConfigProcessors(this.registry);
}
```

ClassPathBeanDefinitionScanner 类的构造方法
```java
/**
 * Create a new {@code ClassPathBeanDefinitionScanner} for the given bean factory.
 * @param registry the {@code BeanFactory} to load bean definitions into, in the form
 * of a {@code BeanDefinitionRegistry}
 */
public ClassPathBeanDefinitionScanner(BeanDefinitionRegistry registry) {
    this(registry, true);
}

public ClassPathBeanDefinitionScanner(BeanDefinitionRegistry registry, boolean useDefaultFilters) {
    this(registry, useDefaultFilters, getOrCreateEnvironment(registry));
}

public ClassPathBeanDefinitionScanner(BeanDefinitionRegistry registry, boolean useDefaultFilters,
			Environment environment) {

    this(registry, useDefaultFilters, environment,
            (registry instanceof ResourceLoader ? (ResourceLoader) registry : null));
}


public ClassPathBeanDefinitionScanner(BeanDefinitionRegistry registry, boolean useDefaultFilters,
			Environment environment, ResourceLoader resourceLoader) {

    Assert.notNull(registry, "BeanDefinitionRegistry must not be null");
    this.registry = registry;

    if (useDefaultFilters) {
        // 注册默认过滤器
        registerDefaultFilters();
    }
    setEnvironment(environment);
    setResourceLoader(resourceLoader);
}
```

ClassPathBeanDefinitionScanner 继承自 ClassPathScanningCandidateComponentProvider

```java
/**
 * Register the default filter for {@link Component @Component}.
 * <p>This will implicitly register all annotations that have the
 * {@link Component @Component} meta-annotation including the
 * {@link Repository @Repository}, {@link Service @Service}, and
 * {@link Controller @Controller} stereotype annotations.
 * <p>Also supports Java EE 6's {@link javax.annotation.ManagedBean} and
 * JSR-330's {@link javax.inject.Named} annotations, if available.
 *
 */
@SuppressWarnings("unchecked")
protected void registerDefaultFilters() {
    this.includeFilters.add(new AnnotationTypeFilter(Component.class));
    ClassLoader cl = ClassPathScanningCandidateComponentProvider.class.getClassLoader();
    try {
        this.includeFilters.add(new AnnotationTypeFilter(
                ((Class<? extends Annotation>) ClassUtils.forName("javax.annotation.ManagedBean", cl)), false));
        logger.debug("JSR-250 'javax.annotation.ManagedBean' found and supported for component scanning");
    }
    catch (ClassNotFoundException ex) {
        // JSR-250 1.1 API (as included in Java EE 6) not available - simply skip.
    }
    try {
        this.includeFilters.add(new AnnotationTypeFilter(
                ((Class<? extends Annotation>) ClassUtils.forName("javax.inject.Named", cl)), false));
        logger.debug("JSR-330 'javax.inject.Named' annotation found and supported for component scanning");
    }
    catch (ClassNotFoundException ex) {
        // JSR-330 API not available - simply skip.
    }
}
```



AnnotationConfigApplicationContext 类 register方法
```java
/**
 * Register one or more annotated classes to be processed.
 * <p>Note that {@link #refresh()} must be called in order for the context
 * to fully process the new classes.
 * @param annotatedClasses one or more annotated classes,
 * e.g. {@link Configuration @Configuration} classes
 * @see #scan(String...)
 * @see #refresh()
 */
public void register(Class<?>... annotatedClasses) {
    Assert.notEmpty(annotatedClasses, "At least one annotated class must be specified");
    this.reader.register(annotatedClasses);
}
```
调用 AnnotatedBeanDefinitionReader 类的 register 方法
```java
/**
 * Register one or more annotated classes to be processed.
 * <p>Calls to {@code register} are idempotent; adding the same
 * annotated class more than once has no additional effect.
 * @param annotatedClasses one or more annotated classes,
 * e.g. {@link Configuration @Configuration} classes
 */
public void register(Class<?>... annotatedClasses) {
    for (Class<?> annotatedClass : annotatedClasses) {
        registerBean(annotatedClass);
    }
}

/**
 * Register a bean from the given bean class, deriving its metadata from
 * class-declared annotations.
 * @param annotatedClass the class of the bean
 */
@SuppressWarnings("unchecked")
public void registerBean(Class<?> annotatedClass) {
    registerBean(annotatedClass, null, (Class<? extends Annotation>[]) null);
}


/**
 * Register a bean from the given bean class, deriving its metadata from
 * class-declared annotations.
 * @param annotatedClass the class of the bean
 * @param name an explicit name for the bean
 * @param qualifiers specific qualifier annotations to consider,
 * in addition to qualifiers at the bean class level
 */
@SuppressWarnings("unchecked")
public void registerBean(Class<?> annotatedClass, String name, Class<? extends Annotation>... qualifiers) {
    AnnotatedGenericBeanDefinition abd = new AnnotatedGenericBeanDefinition(annotatedClass);
    if (this.conditionEvaluator.shouldSkip(abd.getMetadata())) {
        return;
    }

    ScopeMetadata scopeMetadata = this.scopeMetadataResolver.resolveScopeMetadata(abd);
    abd.setScope(scopeMetadata.getScopeName());
    String beanName = (name != null ? name : this.beanNameGenerator.generateBeanName(abd, this.registry));
    AnnotationConfigUtils.processCommonDefinitionAnnotations(abd);
    if (qualifiers != null) {
        for (Class<? extends Annotation> qualifier : qualifiers) {
            if (Primary.class == qualifier) {
                abd.setPrimary(true);
            }
            else if (Lazy.class == qualifier) {
                abd.setLazyInit(true);
            }
            else {
                abd.addQualifier(new AutowireCandidateQualifier(qualifier));
            }
        }
    }

    BeanDefinitionHolder definitionHolder = new BeanDefinitionHolder(abd, beanName);
    definitionHolder = AnnotationConfigUtils.applyScopedProxyMode(scopeMetadata, definitionHolder, this.registry);
    BeanDefinitionReaderUtils.registerBeanDefinition(definitionHolder, this.registry);
}

```
BeanDefinitionReaderUtils 工具类的registerBeanDefinition 方法将bean注册到registry。

