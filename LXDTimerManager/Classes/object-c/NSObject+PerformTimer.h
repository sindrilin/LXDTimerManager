//
//  NSObject+PerformTimer.h
//  LXDTimerManager
//
//  Created by didi on 2018/1/5.
//  Copyright © 2018年 didi. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 *  @block  LXDObjectCountDown
 *  对象倒计时回调block
 *
 *  @params receiver    注册回调的对象，引用安全处理
 *  @params leftTime    倒计时剩余时间
 *  @params isStop      等同于enum的作用，如果设置成YES，倒计时任务结束
 */
typedef void(^LXDObjectCountDown)(id receiver, NSInteger leftTime, BOOL *isStop);


/*!
 *  @category   NSObject+PerformTimer
 *  对象倒计时扩展
 */
@interface NSObject (PerformTimer)

/*!
 *  @method beginCountDown:forSeconds:
 *  启动倒计时任务
 *
 *  @params countDown   倒计时回调block
 *  @params seconds     倒计时长
 */
- (void)beginCountDown: (LXDObjectCountDown)countDown forSeconds: (NSInteger)seconds;

@end
