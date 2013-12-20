//
//  TouchDrawView.m
//  TouchTracker
//
//  Created by wangyipu on 13-12-19.
//  Copyright (c) 2013年 stone. All rights reserved.
//

#import "TouchDrawView.h"
#import "Line.h"

@implementation TouchDrawView

@synthesize selectedLine;

- (id)initWithFrame:(CGRect)r
{
    self = [super initWithFrame:r];
    if (self) {
        linesInProcess = [[NSMutableDictionary alloc] init];
        completeLines = [[NSMutableArray alloc] init];
        
        [self setBackgroundColor:[UIColor whiteColor]];
        [self setMultipleTouchEnabled:YES];
        
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
        [self addGestureRecognizer:tapGestureRecognizer];
        
        UILongPressGestureRecognizer *pressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
        [self addGestureRecognizer:pressRecognizer];
        
        moveRecongnizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveLine:)];
        [moveRecongnizer setDelegate:self];
        [moveRecongnizer setCancelsTouchesInView:NO];
        [self addGestureRecognizer:moveRecongnizer];
    }
    return self;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if (gestureRecognizer == moveRecongnizer) {
        return YES;
    }
    return NO;
}

#pragma mark - pressRecongnizer

- (void)moveLine:(UIPanGestureRecognizer *)gr
{
    if (![self selectedLine]) {
        return;
    }
    
    if ([gr state] == UIGestureRecognizerStateChanged) {
        CGPoint translation = [gr translationInView:self];
        
        CGPoint begin = [[self selectedLine] begin];
        CGPoint end = [[self selectedLine] end];
        
        begin.x += translation.x;
        begin.y += translation.y;
        end.x += translation.x;
        end.y += translation.y;
        
        [[self selectedLine] setBegin:begin];
        [[self selectedLine] setEnd:end];
        
        [self setNeedsDisplay];
        [gr setTranslation:CGPointZero inView:self];
    }
}

- (void)longPress:(UIGestureRecognizer *)gr
{
    if([gr state] == UIGestureRecognizerStateBegan){
        CGPoint point = [gr locationInView:self];
        [self setSelectedLine:[self lineAtPoint:point]];
        if([self selectedLine]){
            [linesInProcess removeAllObjects];
        }
    }else if([gr state] == UIGestureRecognizerStateEnded){
        [self setSelectedLine:nil];
    }
    [self setNeedsDisplay];
}


#pragma mark - tapGesture

- (void)tap:(UIGestureRecognizer *)gr
{
    NSLog(@"Recognized tap.");
    
    CGPoint point = [gr locationInView:self];
    [self setSelectedLine:[self lineAtPoint:point]];
    
    [linesInProcess removeAllObjects];
    
    if ([self selectedLine]) {
        [self becomeFirstResponder];
        
        UIMenuController *menu = [UIMenuController sharedMenuController];
        UIMenuItem *deleteItem = [[UIMenuItem alloc] initWithTitle:@"Delete" action:@selector(deleteLine:)];
        [menu setMenuItems:[NSArray arrayWithObject:deleteItem]];
        
        [menu setTargetRect:CGRectMake(point.x, point.y, 2, 2) inView:self];
        [menu setMenuVisible:YES animated:YES];
    } else{
        [[UIMenuController sharedMenuController] setMenuVisible:NO animated:YES];
    }
    
    [self setNeedsDisplay];
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (void)deleteLine:(id)sender
{
    [completeLines removeObject:[self selectedLine]];
    [self setNeedsDisplay];
}

- (Line *)lineAtPoint:(CGPoint)p
{
    for (Line *l in completeLines) {
        CGPoint start = [l begin];
        CGPoint end = [l end];
        
        for (float t = 0.0; t < 1.0; t +=0.05) {
            float x = start.x + t * (end.x - start.x);
            float y = start.y + t * (end.y - start.y);
            
            if (hypot(x - p.x, y - p.y)) {
                return l;
            }
        }
    }
    return nil;
}

#pragma mark - drawRect

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 10.0);
    CGContextSetLineCap(context, kCGLineCapRound);
    
    [[UIColor blackColor] set];
    for (Line *line in completeLines) {
        CGContextMoveToPoint(context, [line begin].x, [line begin].y);
        CGContextAddLineToPoint(context, [line end].x, [line end].y);
        CGContextStrokePath(context);
    }
    
    [[UIColor redColor] set];
    for (NSValue *v in linesInProcess) {
        Line *line = [linesInProcess objectForKey:v];
        CGContextMoveToPoint(context, [line begin].x, [line begin].y);
        CGContextAddLineToPoint(context, [line end].x, [line end].y);
        CGContextStrokePath(context);
    }
    
    if ([self selectedLine]) {
        [[UIColor greenColor] set];
        CGContextMoveToPoint(context, [[self selectedLine] begin].x, [[self selectedLine] begin].y);
        CGContextAddLineToPoint(context, [[self selectedLine] end].x, [[self selectedLine] end].y);
        
        CGContextStrokePath(context);
    }
}

- (void)clearAll
{
    [linesInProcess removeAllObjects];
    [completeLines removeAllObjects];
    
    [self setNeedsDisplay];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *t in touches) {
        //连接?
        if ([t tapCount] > 1) {
            [self clearAll];
            return;
        }
        
        NSValue *key = [NSValue valueWithNonretainedObject:t];
        CGPoint loc = [t locationInView:self];
        Line *newLine = [[Line alloc] init];
        [newLine setEnd:loc];
        [linesInProcess setObject:newLine forKey:key];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *t in touches) {
        NSValue *key = [NSValue valueWithNonretainedObject:t];
        
        Line *line = [linesInProcess objectForKey:key];
        CGPoint loc = [t locationInView:self];
        [line setEnd:loc];
    }
    [self setNeedsDisplay];
}

- (void)endTouches:(NSSet *)touches
{
    for (UITouch *t in touches) {
        NSValue *key = [NSValue valueWithNonretainedObject:t];
        Line *line = [linesInProcess objectForKey:key];
        
        if (line) {
            [completeLines addObject:line];
            [linesInProcess removeObjectForKey:key];
        }
    }
    
    [self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self endTouches:touches];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self endTouches:touches];
}




@end
