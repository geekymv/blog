---
title: arts-week-1
date: 2019-07-17 10:27:54
tags:
---
每周完成一个ARTS： 
- 每周至少做一个 leetcode 的算法题
- 阅读并点评至少一篇英文技术文章
- 学习至少一个技术技巧
- 分享一篇有观点和思考的技术文章。

（也就是 Algorithm、Review、Tip、Share 简称ARTS）

# Algorithm

## LeetCode算法题
[two-sum](https://leetcode.com/problems/two-sum/)
1. Two Sum

Given an array of integers, return `indices` of the two numbers such that they add up to a specific target.

You may assume that each input would have `exactly` one solution, and you may not use the same element twice.
Example:
```text
Given nums = [2, 7, 11, 15], target = 9,

Because nums[0] + nums[1] = 2 + 7 = 9,
return [0, 1].
```
两数之和

给定一个整型数组nums和一个目标值target，在数组中找出两个数相加之和等于目标值，返回它们的下标。
可以假设每个目标值只有一个对应的答案，但是你不能使用这个数组中同样的元素两次。


思路：
将数组中每个数和它后面的元素依次相加之和与目标值比较，如果相等就返回这两个值的下标。

## Java 程序实现
```text
class Solution {
    public int[] twoSum(int[] nums, int target) {
        int[] result = new int[2];

        for(int i = 0, len = nums.length; i < len - 1; i++) {
            // j 从i 后面的一个元素开始
            for(int j = i + 1;  j < len; j++) {
                if(nums[i] + nums[j] == target) {
                    result[0] = i;
                    result[1] = j;
                    return result;
                }
            }
        }

        return result;
    }
}
```
复杂度分析：
- 时间复杂度O(n^2)
- 空间复杂度O(1)

LeetCode提供了时间复杂度是O(n)的解决方法，https://leetcode.com/problems/two-sum/solution/

LeetCode 给出的第一种解决方法是类似我上面写的方法，也叫做 Brute Force Approach。
注意，LeetCode 给出的这种方法并没有直接将两个int 值相加，而是使用减法`if (nums[j] == target - nums[i])`，为什么这么做呢？
这样可以防止整型溢出！本周ARTS的Share部分分享了一篇关于整型溢出问题，请移步->。


# Review
[Elasticsearch Getting Started](https://www.elastic.co/guide/en/elasticsearch/reference/6.5/getting-started.html)
总结：
Elasticsearch 是一个高扩展的开源的全文搜索和分析引擎，它可以近实时地存储、搜索、分析大量的数据。

Elasticsearch 使用场景
- 网上商城，提供用户搜索产品
- 分析挖掘收集到的日志或交易数据
- 商业智能BI

# Tip
[使用 Optional 摆脱 NullPointException 的折磨](https://mp.weixin.qq.com/s/iPr1VAbw4sDAHTppebNEYQ)
[案例代码](https://github.com/geekymv/java-design-patterns/blob/master/src/test/java/com/geekymv/optional/OptionalTest.java)
```text
import org.junit.Test;

import java.util.Optional;

/**
 * Optional 使用示例
 * @see <a href="https://mp.weixin.qq.com/s/iPr1VAbw4sDAHTppebNEYQ"></a>
 */
public class OptionalTest {

    /**
     * 可以用ofNullable 方法将一个可能为null的对象封装成Optional对象
     * 获取值的时候用orElse 方法提供默认值
     */
    @Test
    public void test01() {
        Car cat = null;
        // 将指定指用Optional封装之后返回，如果该值为null，则返回空的Optional对象。
        Optional<Car> op = Optional.ofNullable(cat);
        // 使用map 方法获取封装对象的字段值
        Optional<String> opName = op.map(Car::getName);
        // 如果有值则返回，否则返回指定的默认值
        String name = opName.orElse("");

        System.out.println("name = " + name);
    }


    @Test
    public void test02() {
        Person person = new Person();
        Car car = new Car();
        car.setName("BM");
        person.setCar(car);

        Insurance insurance =  new Insurance();
        insurance.setName("Insurance01");
        car.setInsurance(insurance);

        Optional<Person> op = Optional.ofNullable(person);
        // flatMap 与 map类似， 区别是flatMap的mapper 需要是一个Optional 对象
        String insuranceName = op.flatMap(Person::getCarAsOptional)
                                .map(Car::getInsurance)
                                .map(Insurance::getName)
                                .orElse("Unknown");

        System.out.println("insuranceName = " + insuranceName);
    }

}


class Person {

    private Car car;

    public Optional<Car> getCarAsOptional() {
        return Optional.ofNullable(car);
    }

    public Car getCar() {
        return car;
    }

    public void setCar(Car car) {
        this.car = car;
    }
}

class Car {

    private String name;

    private Insurance insurance;

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public Insurance getInsurance() {
        return insurance;
    }

    public void setInsurance(Insurance insurance) {
        this.insurance = insurance;
    }
}

class Insurance {
    private String name;

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }
}
```
# Share
分享coolshell上的一篇文章
[C语言的整型溢出问题](https://coolshell.cn/articles/11466.html)
虽然文章标题是C语言，其中提供的思路不仅限于C语言，文章中提到如何防止整型溢出，值得一读。