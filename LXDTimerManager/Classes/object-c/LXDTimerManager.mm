//
//  LXDTimerManager.m
//  LXDTimerManager
//
//  Created by didi on 2018/1/5.
//  Copyright © 2018年 didi. All rights reserved.
//

#import "LXDTimerManager.h"
#import "LXDReceiverHashmap.h"
#import <UIKit/UIKit.h>

using namespace std;

#ifndef lxd_unusally
#define lxd_unusally(exp) ((typeof(exp))__builtin_expect((long)(exp), 0l))
#endif

#define lxd_signal(sema) dispatch_semaphore_signal(sema);
#define lxd_wait(sema) dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);


@interface LXDTimerManager ()

@property (nonatomic, strong) dispatch_source_t timer;
@property (nonatomic, strong) dispatch_semaphore_t lock;
@property (nonatomic, strong) dispatch_queue_t timerQueue;
@property (nonatomic, strong) NSDate *enterBackgroundTime;

@property (nonatomic, assign) LXDReceiverHashmap *receives;

@end


@implementation LXDTimerManager


#pragma mark - Life
- (instancetype)init {
    if (self = [super init]) {
        self.receives = new LXDReceiverHashmap();
        self.lock = dispatch_semaphore_create(1);
        self.timerQueue = dispatch_queue_create("com.sindrilin.timer.queue", DISPATCH_QUEUE_SERIAL);
        [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(applicationDidBecameActive:) name: UIApplicationDidBecomeActiveNotification object: nil];
        [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(applicationDidEnterBackground:) name: UIApplicationDidEnterBackgroundNotification object: nil];
    }
    return self;
}

- (void)dealloc {
    delete self.receives;
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}


#pragma mark - Public
+ (instancetype)timerManager {
    static LXDTimerManager *timerManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        timerManager = [LXDTimerManager new];
    });
    return timerManager;
}

- (void)registerCountDown: (LXDTimerCallback)countDown
               forSeconds: (NSUInteger)seconds
             withReceiver: (id)receiver {
    if (countDown == nil || seconds <= 0 || receiver == nil) { return; }
    
    lxd_wait(self.lock);
    self.receives->insertReceiver((__bridge void *)receiver, countDown, seconds);
    [self _startupTimer];
    lxd_signal(self.lock);
}

- (void)unregisterCountDownTaskWithReceiver: (id)receiver {
    void *obj = (__bridge void *)receiver;
    if (obj == NULL) {
        return;
    }
    lxd_wait(self.lock);
    __weak typeof(self) weakself = self;
    [self _foreachNodeWithHandle: ^(LXDReceiverNode *node) {
        if (weakself.receives->compare(node, obj) == true) {
            weakself.receives->destoryNode(node);
        }
    }];
    lxd_signal(self.lock);
}


#pragma mark - Notification
- (void)applicationDidBecameActive: (NSNotification *)notif {
    if (self.enterBackgroundTime && self.timer) {
        long delay = [[NSDate date] timeIntervalSinceDate: self.enterBackgroundTime];
        
        dispatch_suspend(self.timer);
        [self _countDownWithInterval: delay];
        dispatch_resume(self.timer);
    }
}

- (void)applicationDidEnterBackground: (NSNotification *)notif {
    self.enterBackgroundTime = [NSDate date];
}


#pragma mark - Private
- (void)_startupTimer {
    if (self.timer != nil) { return; }
    self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, self.timerQueue);
    dispatch_source_set_timer(self.timer, DISPATCH_TIME_NOW + 1.0 * NSEC_PER_SEC, 1.0 * NSEC_PER_SEC, 0);
    dispatch_source_set_event_handler(self.timer, ^{
        [[LXDTimerManager timerManager] _countDownWithInterval: 1];
    });
    dispatch_resume(self.timer);
}

- (void)_countDownWithInterval: (unsigned long)interval {
    __block unsigned long count = 0;
    lxd_wait(self.lock);
    [self _foreachNodeWithHandle: ^(LXDReceiverNode *node) {
        if (node->receiver->lefttime < interval) {
            node->receiver->lefttime = 0;
        } else {
            node->receiver->lefttime -= interval;
        }
        count++;
    }];
    lxd_signal(self.lock);
    
    if (count == 0) {
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self _foreachNodeWithHandle: ^(LXDReceiverNode *node) {
            bool isStop = false;
            node->receiver->callback(node->receiver->lefttime, &isStop);
            
            if (lxd_unusally((isStop == true))) {
                lxd_wait(self.lock);
                node->receiver->lefttime = 0;
                lxd_signal(self.lock);
            }
        }];
        
        __weak typeof(self) weakself = self;
        dispatch_async(_timerQueue, ^{
            lxd_wait(weakself.lock);
            [self _foreachNodeWithHandle: ^(LXDReceiverNode *node) {
                if (node->receiver->lefttime == 0) {
                    weakself.receives->destoryNode(node);
                }
            }];
            lxd_signal(self.lock);
        });
    });
}

- (void)_foreachNodeWithHandle: (void(^)(LXDReceiverNode *node))handle {
    if (handle == nil) { return; }
    for (unsigned int offset = 0; offset < _receives->entries_count; offset++) {
        hash_entry_t *entry = _receives->hash_entries + offset;
        LXDReceiverNode *header = (LXDReceiverNode *)entry->entry;
        LXDReceiverNode *node = header->next;
        
        while (node != NULL) {
            handle(node);
            node = node->next;
        }
    }
}


@end

