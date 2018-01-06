//
//  LXDViewController.m
//  LXDTimerManager
//
//  Created by JustkeepRunning on 01/05/2018.
//  Copyright (c) 2018 JustkeepRunning. All rights reserved.
//

#import "LXDViewController.h"
#import <LXDTimerManager/NSObject+PerformTimer.h>

@interface LXDViewController ()

@end

@implementation LXDViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (IBAction)clickedToCountDown: (UIButton *)sender {
    [sender beginCountDown: ^(id receiver, NSInteger leftTime, BOOL *isStop) {
        if (leftTime > 0) {
            [receiver setTitle: [NSString stringWithFormat: @"%lu s", leftTime] forState: UIControlStateNormal];
        } else {
            [receiver setTitle: @"Button" forState: UIControlStateNormal];
        }
    } forSeconds: 15];
}

@end
