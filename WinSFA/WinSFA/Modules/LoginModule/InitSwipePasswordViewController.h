//
//  InitSwipePasswordViewController.h
//  Family_ios
//
//  Created by Tmc on 15/5/20.
//  Copyright (c) 2015年 hohistar. All rights reserved.
//

#import "BaseViewController.h"

typedef NS_ENUM(NSInteger, SwipeType) {
    SwipeTypeInit = 0,  //设置手势
    SwipeTypeUnlock     //手势解锁
};

@interface InitSwipePasswordViewController : BaseViewController

@property (nonatomic, assign) SwipeType swipeType;

@property (nonatomic, copy) void (^finishSwipeBlock)(void);
@end
