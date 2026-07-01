//
//  JFTakeCountButton.m
//  WinSFA
//
//  Created by dujinfeng481 on 14-11-15.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//

#import "JFTakeCountButton.h"

@interface JFTakeCountButton () {
    BOOL    isRunning;
}

@end

@implementation JFTakeCountButton

+ (id) initWithCount:(int)count
           withTitle:(NSString*)titleStr
      withTitleColor:(UIColor*)titleColor
       withTitleFont:(UIFont*)titleFont
           withBlock:(JFTakeCountButtonCompletion)block
{    return [self initWithCount:count withTitle:titleStr withTitleColor:titleColor withTitleFont:titleFont withTitleFrame:CGRectMake(0, 0, 44, 44) withIsShowTitle:NO withBlock:block];
}

+ (instancetype)initWithCount:(int)count
                    withTitle:(NSString*)titleStr
               withTitleColor:(UIColor*)titleColor
                withTitleFont:(UIFont*)titleFont
               withTitleFrame:(CGRect)titleFrame
              withIsShowTitle:(BOOL)isShowTitle
                    withBlock:(JFTakeCountButtonCompletion)block {
    
    JFTakeCountButton *btn=[JFTakeCountButton buttonWithType:UIButtonTypeCustom];
    btn.frame = titleFrame;
    [btn setTitle:nil forState:UIControlStateNormal];
    
    if (titleColor) {
        [btn setTitleColor:titleColor forState:UIControlStateNormal];
    }
    
    if (titleFont) {
        [btn.titleLabel setFont:titleFont];
    }
    
    btn.isShowTitle = isShowTitle;

    btn.block = block;
    btn.takeCount = count;
    btn.titleStr = titleStr;
    
    return btn;
}

- (void) startTakeCount
{
    if (self.takeCount > 0) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopTime)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(restartTime)
                                                     name:UIApplicationWillEnterForegroundNotification
                                                   object:nil];
        
        isRunning = YES;
        
        [self setTitle];

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(handleShowTimer:) userInfo:nil repeats:YES];
        });
    }else {
        [self completionAction];
    }
}

-(void)handleShowTimer:(NSTimer *)theTimer
{
    if (isRunning) {
        [self setTitle];

        --self.takeCount;
        if (self.takeCount < 0) {
            [theTimer invalidate];
            [self completionAction];
        }
    }
}

- (void)setTitle {
    NSString *title;
    if (!self.isShowTitle) {
        title = [NSString stringWithFormat:@"%d", MAX(self.takeCount, 0)];
    } else {
        title = [NSString stringWithFormat:@"%@(%dS)", self.titleStr, MAX(self.takeCount, 0)];
    }
    [self setTitle:title forState:UIControlStateNormal];
}


-(void) completionAction
{
    [self setTitle:self.titleStr forState:UIControlStateNormal];
    if (self.block) {
        self.block();
    }
    
    isRunning = NO;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
}

#pragma mark - NSNotificationCenter method
- (void)stopTime {
    if (isRunning) {
        self.takeCount++;
    }
    isRunning = NO;
}

- (void)restartTime {
    if (self.takeCount > 0) {
        isRunning = YES;
    }
}

@end
