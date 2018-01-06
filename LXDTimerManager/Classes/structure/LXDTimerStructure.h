//
//  LXDReceiverNode.h
//  LXDTimerManager
//
//  Created by didi on 2018/1/5.
//  Copyright © 2018年 didi. All rights reserved.
//

#import <stdio.h>
#import <stdlib.h>

/*!
 *  @block  LXDReceiverCallback
 *  回调block
 *
 *  @params leftTime    倒计时剩余秒数
 *  @params isStop      等同于enum的isStop，修改为YES后定时任务结束
 */
typedef void(^LXDReceiverCallback)(long leftTime, bool *isStop);


/*!
 *  @structure  LXDReceiver
 *  存储回调结构体
 *
 *  @var    lefttime    倒计时时长
 *  @var    callback    回调block
 */
typedef struct LXDReceiver {
    long lefttime;
    uintptr_t objaddr;
    LXDReceiverCallback callback;
} LXDReceiver;


/*!
 *  @structure  LXDReceiverNode
 *  存储结构双向链表节点
 *
 *  @var    count       链表有效长度
 *  @var    receiver    回调结构
 *  @var    next        下个节点
 *  @var    previous    上个节点
 */
typedef struct LXDReceiverNode {
    unsigned int count;
    LXDReceiver *receiver;
    LXDReceiverNode *next;
    LXDReceiverNode *previous;
    
    LXDReceiverNode(LXDReceiver *receiver = NULL, LXDReceiverNode *previous = NULL) {
        this->count = 0;
        this->next = NULL;
        this->previous = previous;
        this->receiver = receiver;
    }
} LXDReceiverNode;


