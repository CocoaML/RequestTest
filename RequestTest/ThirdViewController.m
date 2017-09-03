//
//  ThirdViewController.m
//  RequestTest
//
//  Created by ml on 2017/9/1.
//  Copyright © 2017年 ml. All rights reserved.
//

#import "ThirdViewController.h"
#import "AFNetworking/AFNetworking.h"

@interface ThirdViewController ()

@end

@implementation ThirdViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // 生产者、消费者模式
//    [self producersAndConsumersMode];
    
    // 按照顺序执行操作 NSOperationQueue 实现
    [self operationBlockTest];
}

// 真正的网络请求
- (void)request:(NSString *)requestName {
    
    // 创建信号量并设置计数默认为0
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSString *url = [NSString stringWithFormat:@"%s","http://v3.wufazhuce.com:8000/api/channel/movie/more/0?platform=ios&version=v4.0.1"];
    [manager GET:url parameters:nil progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
     
        NSLog(@"网络请求--- %@ -- 成功", requestName);
        
        //计数加1
        dispatch_semaphore_signal(semaphore);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        NSLog(@"请求失败。。。...");
        
        //计数加1
        dispatch_semaphore_signal(semaphore);
    }];
    // 若计数为0则一直等待
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
}


#pragma mark - 操作依赖  模拟流程： 下载图片-添加水印-刷新界面
- (void)operationBlockTest {
    
    // 处理图片的耗时操作在子线程中执行
    NSBlockOperation *blockOp = [NSBlockOperation blockOperationWithBlock:^{

        NSLog(@"blockOp 下载图片 thread = %@",[NSThread currentThread]);
        [self request:@"下载图片"];
    }];
    
    NSBlockOperation *blockOp1 = [NSBlockOperation blockOperationWithBlock:^{
        
        NSLog(@"blockOp1 给图片添加水印 thread = %@",[NSThread currentThread]);
        [self request:@"给图片添加水印"];
    }];
    
    NSBlockOperation *blockOp2 = [NSBlockOperation blockOperationWithBlock:^{
        
        [NSThread sleepForTimeInterval:2.0];
        NSLog(@"blockOp2 保存图片 thread = %@",[NSThread currentThread]);
        [self request:@" 保存图片"];
    }];
    
    // 给blockOp1添加依赖关系，使blockOp1在blcokOp执行结束后执行
    [blockOp1 addDependency:blockOp];//也就是下载结束之后再给图片添加水印，然后保存图片。一种依赖关系
    [blockOp2 addDependency:blockOp1];
    
    // 创建队列（把上面要干的事情丢到队列中同时执行－－有点类似GCD中的异步，并发，开启了多个线程）
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
    
    // 添加到队列
    [queue addOperation:blockOp];
    [queue addOperation:blockOp1];
    [queue addOperation:blockOp2];
    

    // 设置队列中操作同时执行的最大数目，也就是说当前队列中呢最多由几个线程在同时执行，一般情况下允许最大的并发数2或者3
    [queue setMaxConcurrentOperationCount:3];
    
    // 队列中可以添加其他的 BlockOperation
    for (int i = 0; i<50; i++) {
        
        NSBlockOperation *blockOpp = [NSBlockOperation blockOperationWithBlock:^{
            
            NSLog(@"blockOpp i = %d thread = %@",i,[NSThread currentThread]);
        }];
        
        [queue addOperation:blockOpp];
    }

    // 刷新UI的操作依赖关系必须在主线程中执行
    NSBlockOperation *blocOpMain = [NSBlockOperation blockOperationWithBlock:^{
        
        NSLog(@"blockOpMain 刷新UI 显示图片,thread = %@",[NSThread currentThread]);
    }];
    
    // 这两个操作的依赖关系，跨队列
    [blocOpMain addDependency:blockOp2];

    // 主队列
    [[NSOperationQueue mainQueue] addOperation:blocOpMain];
}




#pragma mark - 生产者、消费者模式
/*
 信号量实现生产者、消费者模式  GCD-信号量-实现方式
 */
- (void)producersAndConsumersMode{
    
    __block int product = 0;
    dispatch_semaphore_t sem = dispatch_semaphore_create(0);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{ //消费者队列
        
        while (1) {
            if(!dispatch_semaphore_wait(sem, dispatch_time(DISPATCH_TIME_NOW, DISPATCH_TIME_FOREVER))){
                ////非 0的时候,就是成功的timeout了,这里判断就是没有timeout   成功的时候是 0
                
                NSLog(@"消费%d产品",product);
                product--;
            };
        }
    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{ //生产者队列
        while (1) {
            
            sleep(1); //wait for a while
            product++;
            NSLog(@"生产%d产品",product);
            dispatch_semaphore_signal(sem);
        }
        
    });
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 知识点总结
/*
 
 1.
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        //处理耗时操作的代码块...
        
        //通知主线程刷新
        dispatch_async(dispatch_get_main_queue(), ^{
            
            //回调或者说是通知主线程刷新，
            
        });
    });
    
 
 2.
    // 死锁， 只打印 1
    
    NSLog(@"1"); // 任务1
    dispatch_sync(dispatch_get_main_queue(), ^{
        NSLog(@"2"); // 任务2
    });
    NSLog(@"3"); // 任务3
    
 
 3.
    // 打印 1 2 3
    
    NSLog(@"1"); // 任务1
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSLog(@"2"); // 任务2
    });
    NSLog(@"3"); // 任务3
    
 4.
    系统主线程串行队列
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    系统全局并行队列
    dispatch_queue_t globelQueue = dispatch_get_global_queue(0, 0);
    自定义串行队列
    dispatch_queue_t serialQueue = dispatch_queue_create("SERIAL_Queue", DISPATCH_QUEUE_SERIAL);
    自定义并行队列
    dispatch_queue_t concurrentQueue = dispatch_queue_create("CONCURRENT_Queue", DISPATCH_QUEUE_CONCURRENT);
    
    
    
    主线程队列
    NSOperationQueue * queue = [NSOperationQueue mainQueue]
    
    自定义并行队列
    NSOperationQueue * queue = [[NSOperationQueue alloc]init];
    
    自定义串行队列
    NSOperationQueue * queue = [[NSOperationQueue alloc]init];
    queue.maxConcurrentOperationCount = 1;

 */

@end
