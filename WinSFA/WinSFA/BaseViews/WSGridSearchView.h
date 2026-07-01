//
//  WSGridSearchTableView.h
//  WinSFA
//
//  Created by heju on 15/2/12.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol   WSGridSearchViewDelegate;

@interface WSGridSearchView : UIView <UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate>

@property (nonatomic ,assign) NSUInteger selectedIndex;
@property (nonatomic,weak)id<WSGridSearchViewDelegate> delegate;
@property (nonatomic,strong) NSMutableArray *allSeriesProds;
@property (nonatomic, strong)NSMutableArray *uploadedEditedProds; // 已编辑且已经上传的产品
@property (nonatomic, copy) NSString *drid; // 按安卓的逻辑加入分销规则过滤条件

- (id)initWithFrame:(CGRect)frame funcs:(WSFuncsBean *)funcs md5:(NSString *)superGridMd5;

// 重新展现当前视图
- (void)redisPlayWith:(NSMutableArray *)allAddedProds;


- (void)scrollToRowSelectIndexPath:(NSIndexPath *)indexPath;
@end

@protocol WSGridSearchViewDelegate <NSObject>
- (void)willSelectedgridSearchView:(WSGridSearchView *)gridSearchView  heightChange:(CGFloat)changedHeight;
- (void)gridSearchView:(WSGridSearchView *)gridSearchView  selectProds:(NSArray *)prods atIndex:(NSInteger)selecIndex heightChange:(CGFloat)changedHeight;
- (void)selectedFilledProdsGridSearchView:(WSGridSearchView *)gridSearchView  heightChange:(CGFloat)changedHeight;
@end
