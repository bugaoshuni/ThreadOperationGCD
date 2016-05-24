//
//  PthreadsDemo.m
//  多线程
//
//  Created by jichanghe on 16/5/11.
//  Copyright © 2016年 hjc. All rights reserved.
//

#import "PthreadsDemo.h"
#import <pthread.h>

@implementation PthreadsDemo


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    pthread_t thread;
    //创建一个线程并自动执行
    //你需要手动处理线程的各个状态的转换,即管理生命周期，比如，这段代码虽然创建了一个线程，但并没有销毁。
    pthread_create(&thread, NULL, start, NULL);
}

void *start(void *data) {
    NSLog(@"%@", [NSThread currentThread]);
    
    return NULL;
}


@end
