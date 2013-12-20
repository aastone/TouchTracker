//
//  TouchDrawView.h
//  TouchTracker
//
//  Created by wangyipu on 13-12-19.
//  Copyright (c) 2013年 stone. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Line;

@interface TouchDrawView : UIView <UIGestureRecognizerDelegate>
{
    NSMutableDictionary *linesInProcess;
    NSMutableArray *completeLines;
    
    UIPanGestureRecognizer *moveRecongnizer;
}

- (void)clearAll;
- (void)endTouches:(NSSet *)touches;

@property (nonatomic,weak) Line *selectedLine;

- (Line *) lineAtPoint: (CGPoint)p;

@end
