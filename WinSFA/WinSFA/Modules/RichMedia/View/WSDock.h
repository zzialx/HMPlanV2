//
//  WSDock.h
//  WinSFA
//
//  Created by huzepei on 16/7/22.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger,WSDockType){
    
     WSDockTypeVertical,     // 水平布局
     WSDockTypeHorizontal    // 竖直布局

};

@class WSDock;

@protocol WSDockDelegate <NSObject>
- (void)dock:(WSDock *)dock didSelectButtonFrom:(int)from to:(int)to;
@end

@interface WSDock : UIView
@property (nonatomic , strong) NSArray * dictArray;

@property(nonatomic,weak) id<WSDockDelegate> delegate;
-(instancetype)initWithFrame:(CGRect)frame with:(WSDockType)layoutType;
-(void)setUpOptions;

@end
