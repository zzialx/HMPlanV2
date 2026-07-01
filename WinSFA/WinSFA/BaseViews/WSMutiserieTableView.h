//
//  WSMutiserieTableView.h
//  WinSFA
//
//  Created by winchannel on 16/8/19.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WSMutiserieTableView : UIView

@property (nonatomic,strong) UITableView *dePartmentTableView;
@property (nonatomic,strong) UITableView *doctorTableView;


@property (nonatomic,assign)NSInteger selectedDepartmentIndex;

@property (nonatomic,strong) NSMutableArray *doctorArray;

@property (nonatomic,strong) NSMutableArray *allSelectedDoctors;

- (id)initWithFrame:(CGRect)frame
   withCurrentStore:(WSStoreBean *)aStore
    withCurrentDate:(NSString *)currentDate
         withFilter:(NSString *)filter;

- (void)setSubViews;
- (void)reloadSubViews;

@end
