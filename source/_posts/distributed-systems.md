---
title: distributed-systems
date: 2019-06-28 10:35:03
tags:
---
[Distributed systems for fun and profit](http://book.mixu.net/distsys/single-page.html)
Introduction
介绍
I wanted a text that would bring together the ideas behind many of the more recent distributed systems 
- systems such as Amazon's Dynamo, Google's BigTable and MapReduce, Apache's Hadoop and so on.
我想要一篇汇集许多最近的分布式系统（如 Amazon 的 Dynamo, Google 的 BigTable 和 MapReduce, Apache 的 Hadoop等系统）背后思想的文章。

In this text I've tried to provide a more accessible introduction to distributed systems. 
在本文中，我尝试提供一个更易于理解的分布式系统介绍。
<!-- more -->
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
独立的事情独立的失败


In other words, that the core of distributed programming is dealing with distance (duh!) and having more than one thing (duh!). 
These constraints define a space of possible system designs, 
and my hope is that after reading this you'll have a better sense of how distance, time and consistency models interact.
换句话说，分布式编程的核销是处理距离和处理多于一件事。这些约束定义了可能的系统设计的空间，
我希望在阅读完之后，你将更好地理解距离、时间和一致性模型的相互作用。

This text is focused on distributed programming and systems concepts you'll need to understand commercial systems in the data center. 
It would be madness to attempt to cover everything. You'll learn many key protocols 
and algorithms (covering, for example, many of the most cited papers in the discipline), 
including some new exciting ways to look at eventual consistency 
that haven't still made it into college textbooks - such as CRDTs and the CALM theorem.
本文的重点是分布式编程和系统概念，你将需要理解数据中心中的商业系统。试图掩盖一切是愚蠢的。
你将学习许多关键协议和算法（例如，涵盖该学科中许多被引用最多的论文），包括研究最终一致性的令人兴奋的新方法，
这还没写进大学教科书，比如CRDTs和CALM定理。

I hope you like it! If you want to say thanks, follow me on Github (or Twitter). 
And if you spot an error, file a pull request on Github.
希望你喜欢！如果你想说谢谢，请在Github(或Twitter)上关注我。
如果你发现一个错误，在Github上提交一个pull request。

1. Basics
The first chapter covers distributed systems at a high level by introducing a number of important terms and concepts. 
It covers high level goals, such as scalability, availability, performance, latency and fault tolerance; 
how those are hard to achieve, and how abstractions and models as well as partitioning and replication come into play.

2. Up and down the level of abstraction
The second chapter dives deeper into abstractions and impossibility results. It starts with a Nietzsche quote, 
and then introduces system models and the many assumptions that are made in a typical system model. 
It then discusses the CAP theorem and summarizes the FLP impossibility result. 
It then turns to the implications of the CAP theorem, one of which is that one ought to explore other consistency models. 
A number of consistency models are then discussed.

3. Time and order
A big part of understanding distributed systems is about understanding time and order. 
To the extent that we fail to understand and model time, our systems will fail. The third chapter discusses time and order, 
and clocks as well as the various uses of time, order and clocks (such as vector clocks and failure detectors).

4. Replication: preventing divergence
The fourth chapter introduces the replication problem, and the two basic ways in which it can be performed. 
It turns out that most of the relevant characteristics can be discussed with just this simple characterization. 
Then, replication methods for maintaining single-copy consistency are discussed from the least fault tolerant (2PC) to Paxos.

5. Replication: accepting divergence
The fifth chapter discussed replication with weak consistency guarantees. 
It introduces a basic reconciliation scenario, where partitioned replicas attempt to reach agreement. 
It then discusses Amazon's Dynamo as an example of a system design with weak consistency guarantees. 
Finally, two perspectives on disorderly programming are discussed: CRDTs and the CALM theorem.