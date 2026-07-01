//
//  WSMainLeftView.h
//  WinSFA
//
//  Created by yang on 14-4-21.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>



#define kLeftViewCellHeight 55.0f

@class WSFuncsBeanArray;

@protocol WSMainLeftViewDelegate <NSObject>

- (BOOL)didSelectFuncsBean:(WSFuncsBean *)funcsBean;

- (void)needRefreshData;

@end

@interface WSMainLeftView : UIView<UITableViewDataSource, UITableViewDelegate,UIScrollViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) WSFuncsBeanArray *funcsBeanArray;

@property (nonatomic, weak) id<WSMainLeftViewDelegate> delegate;

@property (nonatomic,strong) NSMutableDictionary *leftBottombtnDict;

- (void)setEventIdentifer:(NSString *)identifer withFuncsBean:(WSFuncsBean *)funcsBean;

- (void)setValueChanged:(BOOL)changed withFuncsBean:(WSFuncsBean *)funcsBean;

- (void)showFuncsBean:(WSFuncsBean *)funcsBean;

- (void)selectFuncsBean:(WSFuncsBean *)funcsBean;

- (void)setArrowImageView;

- (void)endRefreshData;

@end
