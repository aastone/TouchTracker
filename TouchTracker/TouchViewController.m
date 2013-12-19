//
//  TouchViewController.m
//  TouchTracker
//
//  Created by wangyipu on 13-12-19.
//  Copyright (c) 2013年 stone. All rights reserved.
//

#import "TouchViewController.h"
#import "TouchDrawView.h"

@implementation TouchViewController

- (void)loadView
{
    [self setView:[[TouchDrawView alloc] initWithFrame:CGRectZero]];
}

@end
