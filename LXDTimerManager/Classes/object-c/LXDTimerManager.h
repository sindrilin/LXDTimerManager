//
//  LXDTimerManager.h
//  LXDTimerManager
//
//  Created by didi on 2018/1/5.
//  Copyright © 2018年 didi. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 *  @block  LXDTimerCallback
 *  回调block
 *
 *  @params leftTime    倒计时剩余秒数
 *  @params isStop      等同于enum的isStop，修改为YES后定时任务结束
 */
typedef void(^LXDTimerCallback)(long leftTime, bool *isStop);

/*!
 *  @class  LXDTimerManager
 *  定时器管理
 */
@interface LXDTimerManager : NSObject

/*!
 *  @method timerManager
 *  获取定时器管理对象
 */
+ (instancetype)timerManager;

/*!
 *  @method registerCountDown:forSeconds:withReceiver:
 *  注册倒计时回调
 *
 *  @params countDown   回调block
 *  @params seconds     倒计时长
 *  @params receiver    注册的对象
 */
- (void)registerCountDown: (LXDTimerCallback)countDown
               forSeconds: (NSUInteger)seconds
             withReceiver: (id)receiver;

@end
