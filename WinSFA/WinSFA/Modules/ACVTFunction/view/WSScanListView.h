//
//  WSScanListView.h
//  WinSFA
//
//  Created by winchannel on 15/10/14.
//  Copyright © 2015年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WSScanListMenuCell.h"
#import "WSOverLayView.h"
#import "WSQRModule.h"

typedef enum {
    TableIsScroll = 0,
    TableIsForbiddenScroll

}IsAllowScroll;

typedef enum {
    AddMesss = 0,
    DeleteMessage
}SendMesMode;


#define kScanButtonBaseTag 10000

@class WSScanListView;

@protocol WSScanListViewDelegate <NSObject>

- (void)deletScanCodeWithSendeMode:(SendMesMode )sendMode withCellIndexNum:(NSIndexPath *)cellIndex;

- (void)addPhotosWithCellIndex:(NSIndexPath *)cellIndex;
@end

@interface WSScanListView : UIView<UITableViewDataSource,UITableViewDelegate,WSScanListMenuCellDelegate,WSOverLayViewDelegate>

@property (nonatomic, strong) UITableView *scanResultList;
@property (nonatomic, strong) UIButton *i_button;
@property (nonatomic, strong) NSString *i_buttonTitle;
@property (nonatomic, strong) NSMutableArray *resultArray;
@property (nonatomic, strong) NSMutableArray *menuArray;
@property (nonatomic, strong) NSString *codeType;//判断问题类型（二维码，条形码）
@property (nonatomic, assign) IsAllowScroll isAllowScroll;
@property (nonatomic, assign) NSInteger editingCellNum;
@property (nonatomic, strong) NSMutableDictionary *photosDict;
@property (nonatomic, strong) NSString *isPhotoRequire;


@property (nonatomic, weak)id<WSScanListViewDelegate>delegate;


- (id)initWithFrame:(CGRect)frame withDataArray:(NSMutableArray *)dataArray withMenuArray:(NSMutableArray *)menuArray withQstId:(NSString *)qstId withBtnTitile:(NSString *)btnTitle;
- (void)reloadScanList;
- (void)reSetScanResultListFrame;
@end
