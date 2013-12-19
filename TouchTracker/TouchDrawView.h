//
//  TouchDrawView.h
//  TouchTracker
//
//  Created by wangyipu on 13-12-19.
//  Copyright (c) 2013年 stone. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TouchDrawView : UIView
{
    NSMutableDictionary *linesInProcess;
    NSMutableArray *completeLines;
}

- (void)clearAll;
- (void)endTouches:(NSSet *)touches;

@end
