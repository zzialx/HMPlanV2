//
//  DataGridComponent.h
//
//  Created by lee jory on 09-10-22.
//  Copyright 2009 Netgen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WSValidateData.h"
#import "WSSerieLinkHeadView.h"
#import "WSGridLinkPopupView.h"
#import "WSTableItem.h"

@protocol DataGridComponentDelegate;

#define TOUCH_EVENT                     @ "touchEvent"
#define DATAGRID_CELL_HEIGHT_DEFAULT    (INTERFACE_IS_PHONE ? 35.0f : 60.0f)
#define DATAGRID_TITLE_FONTSIZE         (INTERFACE_IS_PHONE ? 15.0 : 17.0)
#define FDATAGRID_TITLE_FONTSIZE        (INTERFACE_IS_PHONE ? 9.0 : 12.0)

typedef enum {
    WSDataGridComponentRightTableDefaultShowType = 0,
    WSDataGridComponentRightTableColumnMaxShowType,
    WSDataGridComponentRightTableRowMaxShowType,
    WSDataGridComponentRightTableAutoresizingMaskShowType,
}
WSDataGridComponentRightTableShowType;
//===============================================================================================================================================================================

@interface DataGridComponentDataSource : NSObject {

    NSMutableArray *titles;
    NSMutableArray *data;
    NSMutableArray *columnWidth;
    CGFloat rowHeight;
}

@property (nonatomic, strong) NSMutableArray *titles;
@property (nonatomic, strong) NSMutableArray *data;
@property (nonatomic, strong) NSMutableArray *columnWidth;
@property (nonatomic, strong) WSTableItem *currentTableItem;
@property (nonatomic, strong) NSMutableArray *addedEditingProds;
@property (nonatomic, assign) CGFloat rowHeight;
@property (nonatomic, assign) BOOL needSelect;
@property (nonatomic, assign) WSDataGridComponentRightTableShowType rightTableShowType;
@property (nonatomic, assign) int rightTableShowColOrRowMaxValue;

- (void)reloadDataSourceWith:(NSArray *)prods changeSerieLinkHeadViewTitleWith:(NSString *)brandSerieName;
- (BOOL)isShowThumbnail;
- (CGFloat)resetCellHeightWithOriginHeight:(CGFloat)height;
- (NSInteger)getCellRowCount;

@end
//===============================================================================================================================================================================

@interface DataGridComponent : UIView <UIScrollViewDelegate, UITableViewDataSource, UITableViewDelegate, WSValidateData, WSSerieLinkHeadViewDelegate, WSGridLinkPopupViewDelegate> {

    DataGridComponentDataSource *dataSource;
    float leftCellWidth;
    float contentWidth;
    float cellOriginHeight;
    float headerHeight;
}

@property (nonatomic, strong) UIView *steadyTableHeadView;
@property (nonatomic, strong) NSMutableArray *checkBoxArray;
@property (nonatomic, strong) NSMutableArray *widthesArray;
@property (nonatomic, strong) UITableView* rightTableView;
@property (nonatomic, strong) UITableView* leftTableView;
@property (nonatomic, strong) DataGridComponentDataSource *dataSource;
@property (nonatomic, strong) NSMutableDictionary *cellHeightDic;
@property (nonatomic, strong) UIButton *expandGridViewButton;
@property (nonatomic, strong) NSMutableSet *mutableSelectionSet;
@property (nonatomic, strong) WSSerieLinkHeadView *serieLinkHeadView;
@property (nonatomic, strong) WSSerieLinkHeadView *steadySerieLinkHeadView;
@property (nonatomic, strong) WSGridLinkPopupView *popupView;
@property (nonatomic, strong) WSFuncsBean *currentFuncs;
@property (nonatomic, strong) NSMutableArray *paramArray;
@property (nonatomic, strong) UIViewController *parentViewController;
@property (nonatomic, assign) float contentWidth;
@property (nonatomic, assign) BOOL isValueChange;
@property (nonatomic, assign, readonly) CGFloat contentHeight;
@property (nonatomic, assign) BOOL isExtendedView;
@property (nonatomic, assign) BOOL isAllowedExtend;
@property (nonatomic, assign) BOOL isUnredo;
@property (nonatomic, assign) BOOL isAllowEdit;
@property (nonatomic, assign) BOOL showSerieLinkHeadView;
@property (nonatomic, assign) BOOL isReadOnly;
@property (nonatomic, assign) WSBrandSerieType brandSerieType;
@property (nonatomic, assign) CGFloat extraHeight;
@property (nonatomic, assign) float headerHeight;
@property (nonatomic, assign) BOOL isSelecting;
@property (nonatomic, weak) id <DataGridComponentDelegate> delegate;

- (id)initWithFrame:(CGRect)aRect data:(DataGridComponentDataSource*)aDataSource;
- (id)initWithFrame:(CGRect)aRect data:(DataGridComponentDataSource*)aDataSource funcs:(WSFuncsBean *)funcs;
- (id)initWithFrame:(CGRect)aRect data:(DataGridComponentDataSource*)aDataSource funcs:(WSFuncsBean *)funcs isAllProducts:(BOOL)isAllProducts;
- (id)initWithFrame:(CGRect)aRect data:(DataGridComponentDataSource *)aDataSource funcs:(WSFuncsBean *)funcs isAllProducts:(BOOL)isAllProducts isDrawSerieLink:(BOOL)isDrawSerieLink;
- (void)reDrawGridViewWithHeight:(CGFloat) newHeight;
- (void)reDrawGridViewWithY:(CGFloat)y;
- (void)redrawGridViewWithHeightForLayout:(CGFloat)newHeight;
- (void)redrawGridViewWithHeightForKeyboardShow:(CGFloat)newHeight;
- (void)redrawGridViewWithHeightForKeyboardHide;
- (void)setHideTableHeader:(BOOL)isHide;
- (void)setCellHeightToDic;
- (void)allowsMultipleSelection:(BOOL)isAllow;
- (void)seletedItems:(NSIndexSet *)selectedItems;
- (void)expendView;
- (void)gridLinkPopupViewBackToAllSelectedProdsView;
- (void)resetTableFrameByIsSelection:(BOOL)isSelection;
- (void)setBackgroundColorWithRowId:(NSString *)rowId col:(NSString *)colName value:(NSString *)params;
- (void)longPressDeletePods:(NSInteger)index;
- (CGFloat) attachedViewsHeight;
- (CGFloat) getOffset;
- (CGFloat) getHeaderHeight;
- (BOOL)isShowOrHideSelection;
- (WSAcvtDataGridComponentDataSource *)getAcvtDataSource;

@end
//===============================================================================================================================================================================

@protocol DataGridComponentDelegate <NSObject>

- (void)dataGridComponent:(DataGridComponent *)dataGridComponent insertHasBeenEditingProds:(BOOL)insert;
- (void)dataGridComponent:(DataGridComponent *)dataGridComponent deleteProds:(NSSet *)prods;
- (void)dataGridComponent:(DataGridComponent *)dataGridComponent ExtendGridView:(BOOL)isExtend;
- (void)dataGridComponent:(DataGridComponent *)dataGridComponent pushIndexPath:(NSIndexPath *)indexPath;

@end
//===============================================================================================================================================================================
