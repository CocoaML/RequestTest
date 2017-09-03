//
//  FirstViewController.m
//  RequestTest
//
//  Created by ml on 2017/9/1.
//  Copyright © 2017年 ml. All rights reserved.
//

#import "FirstViewController.h"

@interface FirstViewController ()

@property (strong, nonatomic) dispatch_semaphore_t    lock;
@property (copy, nonatomic)   dispatch_block_t        block;
@property (copy, nonatomic)   NSString                *states;

@end

@implementation FirstViewController

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // 网络请求，根据请求状态判断点击事件是否执行
    [self checkStates];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // GCD 信号
    self.lock = dispatch_semaphore_create(1);
}

- (void)checkStates {
    NSLog(@"准备执行任务 1");
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSLog(@"任务1 正在执行中 ...");
        
        sleep(4);
        
        _states = @"Logon";
        
        dispatch_semaphore_signal(self.lock);
        
        NSLog(@"任务1 执行完成");
        
        if (self.block) {
            self.block();
        }  
    });  
}

#pragma mark - 按钮点击事件
- (IBAction)clickLogonButton:(id)sender {
 
    NSLog(@"执行任务2 ...");
    
    __weak __typeof__(self) weakSelf = self;
    self.block = ^() {
        [weakSelf doSomething];
    };
    
    if (_states && [_states isEqualToString:@"Logon"]) {
        NSLog(@"状态正常");
        self.block();
    } else {
        NSLog(@"状态异常");
        dispatch_semaphore_wait(self.lock, DISPATCH_TIME_FOREVER);
        NSLog(@"等待状态修复 ...");
    }
}

- (void)doSomething {
    NSLog(@"执行任务3: states = %@", self.states);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
