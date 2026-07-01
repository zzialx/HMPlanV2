//
//  WSQRTypeView.h
//  WinSFA
//
//  Created by mac on 16/12/9.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WSQRTypeView,WSScanListViewController;

typedef BOOL (^QRTypeViewClick)(WSQRTypeView *qrTypeView);
typedef BOOL (^QRTypeViewRunScript)(WSScanListViewController *scanVc , NSString *result);

@interface WSQRTypeView : UIButton <WSValidateData, WSGettingValues>

@property (nonatomic, copy)NSString *iNotificationPrefix;

//行号
@property (nonatomic, assign)unsigned int iRow;

//列号
@property (nonatomic, assign)unsigned int iColumn;

//是否是被依赖体
@property (nonatomic, assign)WSValidateDataDependType iDataType;

@property (nonatomic, assign) BOOL isScanQRCode; // 是否可以扫描 二维码

@property (nonatomic, copy) QRTypeViewClick qrTypeViewClick;

@property (nonatomic, copy) QRTypeViewRunScript qrTypeViewRunScript;

- (void)setNotificationPrefix:(NSString *)aNotificationPrefix
                       andRow:(unsigned int)aRow
                    andColumn:(unsigned int)aColumn
                  andDataType:(WSValidateDataDependType)aDataType;

- (void)startObservingEntity;


- (BOOL)entityIsEnable;

- (BOOL)isValueLegal; //SFA-15772 2018-1-3

- (void)startScanAction;

- (BOOL)runScript:(WSScanListViewController *)scan result:(NSString *)result;

@end
