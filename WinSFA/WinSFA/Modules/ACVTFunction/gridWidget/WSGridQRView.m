//
//  WSGridQRView.m
//  WinSFA
//
//  Created by Alicia on 2018/6/8.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import "WSGridQRView.h"
#import "WSQRMTypeView.h"
#import "WSScanListViewController.h"
#import "WSDataSourceManager.h"
#import "WSSetResultExecutor.h"

#define GRID_BEFORE_JUMP_LUA_FUNCTION       @"function beforeJump("
#define GRID_EXCUSE_ACTION_FUNCTION      @"function excuseAction("

@interface WSGridQRView()

@property (nonatomic, strong) WSQRTypeView *qrTypeView;

@property (nonatomic, strong) WSScanListViewController *scanListVc;

@property (nonatomic, strong) WSAcvtModel *model;

@end

@implementation WSGridQRView

- (void)setupView {
    WSQRTypeView *qrTypeView;
    if (self.param.isSupportEdit) {
        qrTypeView = [[WSQRMTypeView alloc] initWithParam:self.param];
    } else {
       qrTypeView = [[WSQRTypeView alloc]init];
        if ([self.param.filter isEqualToString:SCAN_BARCODE]) {
            qrTypeView.isScanQRCode = NO;
        }
        
        __weak typeof(self) weakself = self;
        [qrTypeView setQrTypeViewClick:^BOOL(WSQRTypeView *qrTypeView) {
            [weakself scanButtonClickExecuteLuaScriptWithLuaFunctionName:GRID_BEFORE_JUMP_LUA_FUNCTION result:nil];
            if (![WSLuaExecutorManager shareInstance].isErrorFromScript) {
                [qrTypeView startScanAction];
            }
            return [WSLuaExecutorManager shareInstance].isErrorFromScript;
        }];
        
        
        [qrTypeView setQrTypeViewRunScript:^BOOL(WSScanListViewController *scanVc, NSString *result) {
            if (![WSDataSourceManager sharedInstance].currentActiveModel) {
                WSAcvtModel *model = [[WSAcvtModel alloc] init];
                [WSDataSourceManager sharedInstance].currentActiveModel = model;
            }
            NSString *luaScript = [WSSetResultExecutor sharedInstance].luaScript;
            if (luaScript && luaScript.length > 0) {
                if (self.delegate) {
                    self.scanListVc = scanVc;
                    [weakself scanButtonClickExecuteLuaScriptWithLuaFunctionName:GRID_EXCUSE_ACTION_FUNCTION result:result];
                    return YES;
                }
            }
            return NO;
        }];
    }

    self.qrTypeView = qrTypeView;
}

- (UIView *)getView {
    return self.qrTypeView;
}

- (NSString *)getUploadValue {
    NSString *value = [[self.qrTypeView titleLabel] text];
    if (!value) {
        value = @"";
    }
    return value;
}

- (void)setValue:(NSString *)value {
    if ([self.qrTypeView isKindOfClass:[WSQRMTypeView class]]) {
        ((WSQRMTypeView *)self.qrTypeView).displayString = value;
    }
    
    if (value.length > 0) {
        [self.qrTypeView setImage:nil forState:UIControlStateNormal];
    } else {
        [self.qrTypeView setImage:[UIImage imageNamed:@"qr_code"] forState:UIControlStateNormal];
    }
    
    [self.qrTypeView setTitle:value forState:UIControlStateNormal];
}
- (NSString *)getValue {
    
    NSString *value = nil;
    if ([self.qrTypeView isKindOfClass:[WSQRMTypeView class]]) {
        value = ((WSQRMTypeView *)self.qrTypeView).displayString;
    } else {
        value = self.qrTypeView.titleLabel.text;
    }
    return value;
}

#pragma mark-WSQRTypeViewDelegate
//扫描按钮点击执行脚本
- (void)scanButtonClickExecuteLuaScriptWithLuaFunctionName:(NSString *)luaFunctionName result:(NSString *)result  {
    /*执行列的脚本*/
    if (self.delegate) {
        [self.delegate dataSourceRunScriptWithParam:self.param WidgetKey:self.widgetKey luaFunctionName:luaFunctionName result:result scanListViewController:self.scanListVc];
    }
}

@end
