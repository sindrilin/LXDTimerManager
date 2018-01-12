//
//  NSObject+PerformTimer.m
//  LXDTimerManager
//
//  Created by didi on 2018/1/5.
//  Copyright © 2018年 didi. All rights reserved.
//

#import "NSObject+PerformTimer.h"
#import "LXDTimerManager.h"


@implementation NSObject (PerformTimer)


- (void)beginCountDown: (LXDObjectCountDown)countDown forSeconds: (NSInteger)seconds {
    if (countDown == nil || seconds <= 0) { return; }
    
    __weak typeof(self) weakself = self;
    [[LXDTimerManager timerManager] registerCountDown: ^(long leftTime, bool *isStop) {
        if (weakself) {
            countDown(weakself, leftTime, (BOOL *)isStop);
        } else {
            *isStop = true;
        }
    } forSeconds: seconds withReceiver: self];
}


@end
