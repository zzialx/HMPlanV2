//
//  WSBaseView.h
//  WinSFA
//
//  Created by winchannel on 15/3/6.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WSInterAction;
//===================================================================================================================================================================

@protocol WSBaseViewDelegate <NSObject>

@optional
- (void)executeSubmit:(NSObject *)submitInfo;
- (void)executeAnyOperationWith:(WSInterAction *)interaction;

@end
//===================================================================================================================================================================

@interface WSBaseView : UIView
{
    __weak  id<WSBaseViewDelegate>   delegate;
}

@property (nonatomic, weak) id<WSBaseViewDelegate> delegate; //代理指针

#pragma mark - 创建显示内容方法
- (void)buildDisplayContent;

#pragma mark - 是否布局方法
- (BOOL)isLayoutSubviews;

@end
//===================================================================================================================================================================
