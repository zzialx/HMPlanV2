//
//  SelectListControl.h
//  SelectList
//
//  Created by Jiepeng Zheng on 12-8-24.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SelectListControl;

@protocol SelectListDelegate <NSObject>

@optional
- (void)selectListChange:(SelectListControl *)aSelectListControl;

@end

@interface SelectListControl : UITableView <UITableViewDelegate, UITableViewDataSource>

//@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) UITableView *titleTable;
@property (nonatomic, strong) UITableView *sourceTable;
@property (nonatomic, strong) NSMutableArray *content;
@property (nonatomic) NSInteger selectedIndex;
@property (nonatomic, strong) UIView *backView;

@property (nonatomic, copy) NSString *title;

@property (nonatomic, strong) id<SelectListDelegate> selectListDelegate;

@end
