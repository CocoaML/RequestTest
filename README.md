# RequestTest

考虑到大多数项目中都集成AFN,本工程使用第三方库 AFN 作为网络请求方式。

如果使用了其他的网络请求，可适度修改，思路大致如此：

本iOS 工程是项目主要解决网络中网络请求和界面刷新顺序问题，

1. 根据请求状态判断点击事件是否执行,如果网络请求成功，按钮才可以点击，否则，等待网络请求。

    （1）网络请求。返回一个状态。（这是一个异步处理耗时操作，优化用户体验） 

    （2）人机交互。用户点击一个按钮，比如登录按钮，如果有登录状态，就执行任务3，如果没有，就等待任务1网络请求数据后，再继续执行任务3。 

    （3）通过点击按钮，想要执行的任务。

2. 一个页面有多个网络请求，完成所有请求后，刷新页面  --- 请求过程使用AFN异步操作。

3.
（1）按照顺序执行操作 NSOperationQueue 实现。
    
     例如：
     
            a. 下载图片

            b. 给图片添加水印

            c. 保存图片

            d. 主线程刷新UI界面

（2）GCD实现的生产者、消费者模式。
  
站在巨人的肩膀上造轮子，如有冒犯，请随时联系 ~


