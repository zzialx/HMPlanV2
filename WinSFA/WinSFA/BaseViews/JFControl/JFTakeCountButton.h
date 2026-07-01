//
//  JFTakeCountButton.h
//  WinSFA
//
//  Created by dujinfeng481 on 14-11-15.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^JFTakeCountButtonCompletion)();

@interface JFTakeCountButton : UIButton

@property (nonatomic, strong) NSString  *titleStr;
@property (nonatomic, assign) int       takeCount;
@property (nonatomic, strong) JFTakeCountButtonCompletion block;
@property (nonatomic, assign) BOOL isShowTitle; // 倒计时是否显示标题，否：只显示倒计时时间，是：显示标题（倒计时时间S)

+ (id) initWithCount:(int)count
           withTitle:(NSString*)titleStr
      withTitleColor:(UIColor*)titleColor
       withTitleFont:(UIFont*)titleFont
           withBlock:(JFTakeCountButtonCompletion)block;

+ (instancetype)initWithCount:(int)count
                    withTitle:(NSString*)titleStr
               withTitleColor:(UIColor*)titleColor
                withTitleFont:(UIFont*)titleFont
               withTitleFrame:(CGRect)titleFrame
              withIsShowTitle:(BOOL)isShowTitle
                    withBlock:(JFTakeCountButtonCompletion)block;

- (void) startTakeCount;

@end
