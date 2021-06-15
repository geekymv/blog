---
title: binary-search
date: 2021-06-15 16:18:01
tags:
---



有序数组，折半查找

下面以升序排序的int数组为例，介绍二分查找过程，待查找的int数组如下

```java
int[] arr = {1, 3, 4, 5, 6, 8, 10};
```

```java

public class BinarySearch {

    public int binarySearch(int[] data, int value) {

        int low = 0;
        int high = data.length - 1;

        while (low <= high) {
//            int mid = (low + high) / 2;
            int mid = low + (high - low) / 2;
            int midVal = data[mid];
            if(midVal == value) {
                return mid;

            } else if (value > midVal) {
                low = mid + 1;
            }else  {
                high = mid - 1;
            }
        }

        // 没有找到，返回索引-1
        return -1;
    }
}
```

首先定义两个变量low 和 high 分别指向有序数组arr[]的第一个元素和最后一个元素的下标；

1、获取low和high中间元素的下标mid = (low + high) / 2；

2、判断要查找的元素值value和arr[mid] 是否相等，如果相等返回下标mid，查找结束；

3、如果不相等，则比较arr[mid]和value的大小；

4、如果value大于arr[mid]，说明要查找的元素值在[mid+1, high]之间，则将low指向mid+1，继续步骤1、2；
5、同样的，如果value小于arr[mid]，说明要查找的元素值在[low, mid-1]之间，则将high指向mid-1，继续步骤1、2；

6、当low > high 的时候，结束查找。

