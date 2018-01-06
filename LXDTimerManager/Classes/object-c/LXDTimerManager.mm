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


#pragma mark - Notification
- (void)applicationDidBecameActive: (NSNotification *)notif {
    if (self.enterBackgroundTime && self.timer) {
        long delay = [[NSDate date] timeIntervalSinceDate: self.enterBackgroundTime];
        
        dispatch_suspend(self.timer);
        for (unsigned int offset = 0; offset < _receives->entries_count; offset++) {
            hash_entry_t *entry = _receives->hash_entries + offset;
            LXDReceiverNode *header = (LXDReceiverNode *)entry->entry;
            __block LXDReceiverNode *node = header->next;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                lxd_wait(self.lock);
                while (node != NULL) {
                    LXDReceiver *receiver = node->receiver;
                    LXDReceiverNode *next = node->next;
                    receiver->lefttime -= delay;
                    
                    bool isStop = false;
                    receiver->callback(receiver->lefttime < 0 ? 0 : receiver->lefttime, &isStop);
                    if (receiver->lefttime <= 0 || isStop) {
                        _receives->destoryNode(node);
                        header->count--;
                    }
                    node = next;
                }
                lxd_signal(self.lock);
            });
        }
        dispatch_resume(self.timer);
    }
}

- (void)applicationDidEnterBackground: (NSNotification *)notif {
    self.enterBackgroundTime = [NSDate date];
}


#pragma mark - Private
- (void)_countDown {
    unsigned int receiversCount = 0;
    for (unsigned int offset = 0; offset < _receives->entries_count; offset++) {
        hash_entry_t *entry = _receives->hash_entries + offset;
        LXDReceiverNode *header = (LXDReceiverNode *)entry->entry;
        __block LXDReceiverNode *node = header->next;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            lxd_wait(self.lock);
            while (node != NULL) {
                LXDReceiver *receiver = node->receiver;
                LXDReceiverNode *next = node->next;
                receiver->lefttime--;
                
                bool isStop = false;
                receiver->callback(receiver->lefttime, &isStop);
                if (receiver->lefttime <= 0 || isStop) {
                    _receives->destoryNode(node);
                    header->count--;
                }
                node = next;
            }
            lxd_signal(self.lock);
        });
        receiversCount += header->count;
    }
    
    if (receiversCount == 0 && self.timer != nil) {
        lxd_wait(self.lock);
        dispatch_cancel(self.timer);
        self.timer = nil;
        lxd_signal(self.lock);
    }
}

- (void)_startupTimer {
    if (self.timer != nil) { return; }
    self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, self.timerQueue);
    dispatch_source_set_timer(self.timer, DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC, 0);
    dispatch_source_set_event_handler(self.timer, ^{
        [[LXDTimerManager timerManager] _countDown];
    });
    dispatch_resume(self.timer);
}


@end
