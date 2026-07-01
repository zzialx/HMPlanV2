//
//  WinInventoryPopupConfig.m
//

#import "WinInventoryPopupConfig.h"


@implementation WinInventoryPopupConfig

- (instancetype)init {
    self = [super init];
    if (self) {
        // 设置默认值
        _cancelButtonTitle = @"取消";
        _confirmButtonTitle = @"确定";
        _tableData = @[];
    }
    return self;
}

#pragma mark - 链式配置方法

- (WinInventoryPopupConfig *(^)(NSString *))setTitle {
    return ^WinInventoryPopupConfig *(NSString *title) {
        self.title = title;
        return self;
    };
}

- (WinInventoryPopupConfig *(^)(NSString *))setSubtitle {
    return ^WinInventoryPopupConfig *(NSString *subtitle) {
        self.subtitle = subtitle;
        return self;
    };
}

- (WinInventoryPopupConfig *(^)(NSArray<WSInventoryModel *> *))setTableData {
    return ^WinInventoryPopupConfig *(NSArray<WSInventoryModel *> *tableData) {
        self.tableData = tableData;
        return self;
    };
}

- (WinInventoryPopupConfig *(^)(NSString *))setSubtotalText {
    return ^WinInventoryPopupConfig *(NSString *subtotalText) {
        self.subtotalText = subtotalText;
        return self;
    };
}
- (WinInventoryPopupConfig *(^)(NSString *))setBuyTotalText{
    return ^WinInventoryPopupConfig *(NSString *buyTotalText) {
        self.buyTotalText = buyTotalText;
        return self;
    };
}
- (WinInventoryPopupConfig *(^)(NSString *))setJYTotalText{
    return ^WinInventoryPopupConfig *(NSString *jyTotalText) {
        self.jyTotalText = jyTotalText;
        return self;
    };
}

- (WinInventoryPopupConfig *(^)(NSString *))setCancelButtonTitle {
    return ^WinInventoryPopupConfig *(NSString *cancelButtonTitle) {
        self.cancelButtonTitle = cancelButtonTitle;
        return self;
    };
}

- (WinInventoryPopupConfig *(^)(WinInventoryPopupType))setPopupType{
    return ^WinInventoryPopupConfig *(WinInventoryPopupType popupType) {
        self.popupType = popupType;
        return self;
    };
}

- (WinInventoryPopupConfig *(^)(NSString *))setConfirmButtonTitle {
    return ^WinInventoryPopupConfig *(NSString *confirmButtonTitle) {
        self.confirmButtonTitle = confirmButtonTitle;
        return self;
    };
}

- (WinInventoryPopupConfig *(^)(PopupActionBlock))setCancelAction {
    return ^WinInventoryPopupConfig *(PopupActionBlock cancelAction) {
        self.cancelAction = cancelAction;
        return self;
    };
}

- (WinInventoryPopupConfig *(^)(PopupActionBlock))setConfirmAction {
    return ^WinInventoryPopupConfig *(PopupActionBlock confirmAction) {
        self.confirmAction = confirmAction;
        return self;
    };
}

@end
