//
//  SecondViewController.m
//  RequestTest
//
//  Created by ml on 2017/9/1.
//  Copyright © 2017年 ml. All rights reserved.
//

#import "SecondViewController.h"
#import "AFNetworking/AFNetworking.h"

@interface SecondViewController ()

@end

@implementation SecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 一个页面有多个网络请求，完成所有请求后，刷新页面  --- 异步
    [self requestCompleteRefreshUI];
}

// 网络请求
/*
 使用 GCD 中的    dispatch_semaphore(信号量)
 处理一个界面多个请求 (把握AFNet网络请求完成的正确时机)
*/

- (void)requestCompleteRefreshUI {
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self request1];
    }) ;
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self request2];
    }) ;
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self request3];
    }) ;
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        NSLog(@"刷新界面");
    });
}


// 真正的网络请求
- (void)request1{
    // 创建信号量并设置计数默认为0
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSString *url = [NSString stringWithFormat:@"%s","http://v3.wufazhuce.com:8000/api/channel/movie/more/0?platform=ios&version=v4.0.1"];
    [manager GET:url parameters:nil progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
      
        
        NSLog(@"请求1---");
        
        // 计数加1
        dispatch_semaphore_signal(semaphore);

    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"shibai...");
        // 计数加1
        dispatch_semaphore_signal(semaphore);
    }];
    // 若计数为0则一直等待
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
}

/*
 
 dispatch_semaphore_t sema = dispatch_semaphore_create(0);
 [网络请求:{
 成功：dispatch_semaphore_signal(sema);
 失败：dispatch_semaphore_signal(sema);
 }];
 
 dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
 
 
 // 强行解释一波
 // 通过使用GCD中的信号量可以解决多个操作共用同一资源时, 造成主线程阻塞的问题.
*/

- (void)request2{
    // 创建信号量并设置计数默认为0
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSString *url1 = [NSString stringWithFormat:@"%s","http://v3.wufazhuce.com:8000/api/channel/movie/more/11380?platform=ios&version=v4.0.1"];
    [manager GET:url1 parameters:nil progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        
        NSLog(@"请求2---");
        
        // 计数加1
        dispatch_semaphore_signal(semaphore);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        // 计数加1
        dispatch_semaphore_signal(semaphore);
    }];
    // 若计数为0则一直等待
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
}
- (void)request3{
    // 创建信号量并设置计数默认为0
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSString *url2 = [NSString stringWithFormat:@"%s","http://v3.wufazhuce.com:8000/api/channel/movie/more/11317?platform=ios&version=v4.0.1"];
    [manager GET:url2 parameters:nil progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
     
        
        NSLog(@"请求3---");
        
        // 计数加1
        dispatch_semaphore_signal(semaphore);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        // 计数加1
        dispatch_semaphore_signal(semaphore);
    }];
    // 若计数为0则一直等待
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
