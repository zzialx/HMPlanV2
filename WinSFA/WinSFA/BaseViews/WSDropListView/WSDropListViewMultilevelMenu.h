//
//  WSDropListViewCountryAdministrationList.h
//  WinSFA
//
//  Created by sunhf on 2018/1/11.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WSBaseDictsDBService.h"
@class WSDropListView;

@protocol WSDropListViewMultilevelMenuDelegate <NSObject>

- (void)wsDropListViewMultilevelMenuCellDidClickWithParam:(WSDictBean *)dictBean;

@end

@interface WSDropListViewMultilevelMenu : UIView <UITableViewDelegate,UITableViewDataSource>
{
    WSBaseDictsDBService *service;//
    NSMutableArray *currentNeedRefreshLevelDataArray;//主要是为了除了第一次进入以后,点击子集时候 刷新需要刷新层级的数据 点击刷新完置空,不同tableview滑动还是需要根据各自的坐标取对应的数据
    WSDictBean *needDictBean;//最后传出去的数据
}
/*
 放所有层级的数据
 */
@property (nonatomic, strong) NSMutableArray *allDataArray;

/*
 回显的时候 放各个层级默认显示的那条数据
 */
@property (nonatomic, strong) NSMutableArray *backShowLevelDataArray;

/*
 放所有层级视图
 */
@property (nonatomic, strong) NSMutableArray *allTableViewArray;

/*
 菜单层级个数
 */
@property (nonatomic, assign) NSInteger levelNumber;

@property (nonatomic, weak) id<WSDropListViewMultilevelMenuDelegate> delegate;

/*
 Params:
 levelNumber 几级菜单
 allDataArray 所有菜单需要的数据源
 */
- (id)initWithFrame:(CGRect)frame withLevelNumber:(NSInteger)levelNumber withAllData:(NSMutableArray *)allDataArray withBackShowLevelData:(NSMutableArray *)backShowLevelDataArray;
@end
