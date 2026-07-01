//
//  WSWorkbenchView.h
//  WinSFA
//
//  Created by yang on 16/12/28.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WSWorkbenchView;

@protocol WSWorkbenchViewDelegate <NSObject>

- (void)workbenchView:(WSWorkbenchView *)workbenchView didSelectItem:(WSFuncsBean *)funcBean;

//- (VisitActionStatus)visitActionStatusForFuncBean:(WSFuncsBean *)funcBean;

@end

@interface WSWorkbenchView : UIView


@property (nonatomic, weak) id<WSWorkbenchViewDelegate> delegate;

@property (nonatomic, strong) WSStoreBean *currentStore;

@property (nonatomic, strong) WSVisitStoreActionObject *currentVisitAction;

@property (nonatomic, assign) BOOL isGridHomeStyle;//蒙牛首页样式

- (instancetype)initWithFrame:(CGRect)frame withColNumber:(NSInteger)colNumber;

- (void)setDataSource:(NSArray *)dataSourceArray andDicts:(NSArray *)dictsArray;

- (CGFloat)contentHeight;

@end
