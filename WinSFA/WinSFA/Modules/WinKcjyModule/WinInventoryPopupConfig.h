//
//  WinInventoryPopupConfig.h
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "WSInventoryModel.h"

@class WinInventoryPopupConfig;

typedef enum {
    WinInventoryPopupTypeOne,///单按钮样式
    WinInventoryPopupTypeTwo,///双按钮样式
    WinInventoryPopupTypeMore ///多按钮样式
} WinInventoryPopupType;


// 回调 Block 定义
typedef void(^PopupActionBlock)(void);


@interface WinInventoryPopupConfig : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, strong) NSArray<WSInventoryModel *> *tableData;
@property (nonatomic, copy) NSString *subtotalText;
@property (nonatomic, copy) NSString *buyTotalText;
@property (nonatomic, copy) NSString *jyTotalText;
@property (nonatomic, copy) NSString *cancelButtonTitle;
@property (nonatomic, copy) NSString *confirmButtonTitle;
@property (nonatomic, assign) WinInventoryPopupType popupType;
@property (nonatomic, copy) PopupActionBlock cancelAction;
@property (nonatomic, copy) PopupActionBlock confirmAction;


- (WinInventoryPopupConfig *(^)(NSString *))setTitle;
- (WinInventoryPopupConfig *(^)(NSString *))setSubtitle;
- (WinInventoryPopupConfig *(^)(NSString *))setBuyTotalText;
- (WinInventoryPopupConfig *(^)(NSString *))setJYTotalText;
- (WinInventoryPopupConfig *(^)(NSArray<WSInventoryModel *> *))setTableData;
- (WinInventoryPopupConfig *(^)(NSString *))setSubtotalText;
- (WinInventoryPopupConfig *(^)(NSString *))setCancelButtonTitle;
- (WinInventoryPopupConfig *(^)(NSString *))setConfirmButtonTitle;
- (WinInventoryPopupConfig *(^)(WinInventoryPopupType))setPopupType;
- (WinInventoryPopupConfig *(^)(PopupActionBlock))setCancelAction;
- (WinInventoryPopupConfig *(^)(PopupActionBlock))setConfirmAction;

@end
