---
title: distributed-systems
date: 2019-06-28 10:35:03
tags:
---
Introduction
介绍
I wanted a text that would bring together the ideas behind many of the more recent distributed systems 
- systems such as Amazon's Dynamo, Google's BigTable and MapReduce, Apache's Hadoop and so on.
我想要一篇汇集许多最近的分布式系统（如 Amazon 的 Dynamo, Google 的 BigTable 和 MapReduce, Apache 的 Hadoop等系统）背后思想的文章。

In this text I've tried to provide a more accessible introduction to distributed systems. 
在本文中，我尝试提供一个更易于理解的分布式系统介绍。

To me, that means two things: introducing the key concepts that you will need in order to 
have a good time reading more serious texts, and providing a narrative that covers things in enough detail 
that you get a gist of what's going on without getting stuck on details. 
对我而言，这意味着两件事：介绍你需要的核心概念，为了能愉快的读更重要的文章，并提供足够详细的叙述，
让你了解正在发生的事情，而不必拘泥于细节。

It's 2013, you've got the Internet, and you can selectively read more about the topics you find most interesting.
这是2013年，你已经拥有了互联网，你可以选择读更多你觉得最有趣的话题。

In my view, much of distributed programming is about dealing with the implications of two consequences of distribution:
that information travels at the speed of light
that independent things fail independently*
在我看来，许多分布式编程是关于处理分布式两个后果的影响：
信息以光速传输




In other words, that the core of distributed programming is dealing with distance (duh!) and having more than one thing (duh!). 
These constraints define a space of possible system designs, 
and my hope is that after reading this you'll have a better sense of how distance, time and consistency models interact.

This text is focused on distributed programming and systems concepts you'll need to understand commercial systems in the data center. 
It would be madness to attempt to cover everything. You'll learn many key protocols 
and algorithms (covering, for example, many of the most cited papers in the discipline), 
including some new exciting ways to look at eventual consistency 
that haven't still made it into college textbooks - such as CRDTs and the CALM theorem.

I hope you like it! If you want to say thanks, follow me on Github (or Twitter). 
And if you spot an error, file a pull request on Github.

