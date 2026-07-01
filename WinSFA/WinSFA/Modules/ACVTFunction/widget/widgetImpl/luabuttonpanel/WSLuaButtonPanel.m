//
//  WSLuaButtonPanel.m
//  WinSFA
//
//  Created by xiajl on 15/3/30.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSLuaButtonPanel.h"
#import "WidgetConstant.h"
#import "I_W_BuildInfo.h"
#import "WSLuaScriptEnter.h"
#import "WSMappingObject.h"
#import "WSInoutStoreTable.h"
#import "WSInterAction.h"
#import "WSBaseModel.h"
#import "WSDataSourceManager.h"
#import "I_Lua_Target_Operator.h"
#import "UIButton+WebCache.h"
#import "WSRequestHelper.h"
#import "I_W_DisplayValue.h"
#import "WSFuncsBeanArray.h"
#import "WSAcvtModel.h"
#import "WSStatisticsManager.h"
#import "UIColor+Additions.h"

#define kAcvtQstDeleteButtonWidth       (INTERFACE_IS_PAD ? 300.0f : SCREEN_WIDTH - MAIN_PADDING*2)
#define kAcvtQstDeleteButtonHeight      (INTERFACE_IS_PAD ?  40.0f : 40.0f)
#define KButtonTitleColor               ([UIColor colorForKey:@"LuaButtonTitleColor"] ? [UIColor colorForKey:@"LuaButtonTitleColor"] :[UIColor blackColor])
#define kTopGap                         5
#define kUIAlertViewTag                 100
#define kShareModelWidth                35
#define kShareAcvtQstDeleteButtonHeight 80
//===================================================================================================================================================================

@interface WSLuaButtonPanel ()

@property (nonatomic, strong) WSLuaScriptContext *luaParserObj;
@property (nonatomic, strong) UIButton *luaButton;
@property (nonatomic, copy) NSString *luaButtonValue;           //luabutton不提供值 如果需要用luaButton的值 则使用luaButtonValue

@end
//===================================================================================================================================================================

@interface WSLuaButtonPanel (Tools)

- (void)autoJumpNextShowPage; //自动跳转下一个展示页面方法

@end
//===================================================================================================================================================================

@implementation WSLuaButtonPanel

#pragma mark - 重写loadBuildInfo:方法
- (void)loadBuildInfo:(NSObject<I_W_BuildInfo> *)buildInfo {
    
    [super loadBuildInfo:buildInfo];
}

#pragma mark - 重写buildDisplayContent方法
- (void)buildDisplayContent {
    
    [super buildDisplayContent];
    CGFloat buttonWidth = kAcvtQstDeleteButtonWidth;
    if (buttonWidth > self.width) {
        buttonWidth = self.width;
    }
    
    CGFloat luaBtnHeight = kAcvtQstDeleteButtonHeight;
    if ([[xbuildInfo getDisplayMode] isEqualToString:@"share"]) {
        luaBtnHeight = kShareAcvtQstDeleteButtonHeight;
    }
    
    UIButton *luaButton = [UIButton buttonWithType:UIButtonTypeCustom];
    luaButton.frame = CGRectMake((CGRectGetWidth(self.bounds) - buttonWidth) / 2, kTopGap, buttonWidth, luaBtnHeight);
    [luaButton setBackgroundColor:[UIColor clearColor]];
    [luaButton setBackgroundImage:[UIImage imageNamed:@"lua_button_icon"] forState:UIControlStateNormal];
    [luaButton setAdjustsImageWhenHighlighted:NO];
    [luaButton  setTitleColor:KButtonTitleColor forState:UIControlStateNormal];
    [luaButton setTitleColor:MAIN_TEXT_DISABLE_COLOR forState:UIControlStateDisabled];
    luaButton.titleLabel.font = [UIFont systemFontOfSize:UI_Font];
    [luaButton addTarget:self action:@selector(luaButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [luaButton setTitle:[xbuildInfo getQuestName] forState:UIControlStateNormal];
    luaButton.tag = [[xbuildInfo getAcvtQstId] integerValue];
    if ([[xbuildInfo getDefaultValue] isEqualToString:@"1"]) {
        luaButton.selected = YES;
    }
    NSString *displayValue = (NSString *)[xdisplayValue getDisplayValueFor:xbuildInfo];
    if (displayValue) {
        luaButton.selected = [[NSNumber numberWithInteger:[displayValue integerValue]] boolValue];
        self.luaButtonValue = displayValue;
    }
    if ([[xbuildInfo getReadOnly] isEqualToString:@"1"]) {
        luaButton.enabled = NO;
    }
    [self addSubview:luaButton];
    self.luaButton = luaButton;
    
    CGFloat buttonImgWidth = 15.f;
    CGFloat sHeight = kTopGap + kAcvtQstDeleteButtonHeight + kTopGap;
    if ([[xbuildInfo getDisplayMode] isEqualToString:@"share"]) {
        buttonImgWidth = kShareModelWidth;
        sHeight = kTopGap + 80 + kTopGap;
    }
    else {
        luaButton.imageEdgeInsets = UIEdgeInsetsMake(luaButton.imageView.top, luaButton.imageView.left, luaButton.imageView.bottom, kTopGap);
    }
    
    if ([[xbuildInfo getQuestIconURL] length] > 0) {
        [[WSRequestHelper shareInstance] downloadImageWithUrl:[WSHttpURLHelper getImageCompleteURL:[xbuildInfo getQuestIconURL]] imageView:luaButton.imageView
                                                    completed:^(UIImage *image, NSError *error, NSURL *imageURL) {
            UIImage *scaleImage = [UIImage scaleToSize:image size:CGSizeMake(buttonImgWidth, buttonImgWidth)];
            [luaButton setImage:scaleImage forState:UIControlStateNormal];
        }];
    }
    
    if ([[xbuildInfo getDisplayMode] isEqualToString:@"share"]) {
        
        self.backgroundColor = [UIColor colorFromHexCode:@"#ecebeb"];
        luaButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        [luaButton setTitleEdgeInsets:UIEdgeInsetsMake(buttonImgWidth ,-buttonImgWidth, 0.0,0.0)];
        [luaButton setImageEdgeInsets:UIEdgeInsetsMake(0.0, 0.0,luaButton.titleLabel.bounds.size.height + kTopGap, -luaButton.titleLabel.bounds.size.width)];
        luaButton.height = sHeight;
        [luaButton setBackgroundImage:nil forState:UIControlStateNormal];
    }
    
    if ([[xbuildInfo getDisplayMode] isEqualToString:@"full"]) {
        
        if ([xbuildInfo getBgColor] && [xbuildInfo getBgColor].length == 8) {
            
            NSString *str1 = [[xbuildInfo getBgColor] substringFromIndex:2];
            [luaButton setBackgroundColor:[UIColor colorFromHexCode:str1]];
            [luaButton setBackgroundImage:nil forState:UIControlStateNormal];
        }
  
        if ([xbuildInfo getTextColor] && [xbuildInfo getTextColor].length == 8) {
            
            NSString *str1 = [[xbuildInfo getTextColor] substringFromIndex:2];
            [luaButton setTitleColor:[UIColor colorFromHexCode:str1] forState:UIControlStateNormal];
        }
    }

    [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, CGRectGetWidth(self.frame), sHeight)];
}

#pragma mark - 设置frame方法
- (void)setFrame:(CGRect)frame {
    
    [super setFrame:frame];
    
    CGFloat buttonWidth = kAcvtQstDeleteButtonWidth;
    if (frame.size.width<buttonWidth) {
        buttonWidth = frame.size.width;
    }
    CGFloat luaBtnHeight = kAcvtQstDeleteButtonHeight;
    if ([[xbuildInfo getDisplayMode] isEqualToString:@"share"]) {
        luaBtnHeight = kShareAcvtQstDeleteButtonHeight;
    }
    
    [self.luaButton setFrame:CGRectMake((CGRectGetWidth(self.bounds) - buttonWidth) / 2, kTopGap, buttonWidth, luaBtnHeight)];
}

#pragma mark - 重写setCurrentValueWithPresentation:方法
- (void)setCurrentValueWithPresentation:(NSString *)param {
    
    if ([param length] > 0) {
        self.luaButtonValue = param;
    }
}

#pragma mark - 重写setReadonly:方法
- (void)setReadonly:(NSString *)isReadonly {
    
    [super setReadonly:isReadonly];
    
    if ([[xbuildInfo getReadOnly] isEqualToString:@"1"]) {
        self.luaButton.enabled = NO;
    }
    else {
        [self.luaButton setBackgroundColor:[UIColor clearColor]];
        self.luaButton.enabled = YES;
    }
}

#pragma mark - 重写getOtherLuaExecuteParams方法
- (NSObject *)getOtherLuaExecuteParams {
    
    return nil;
}

#pragma mark - 重写performClickButton:方法
- (void)performClickButton:(id)sender {
   
    self.resultCheck = sender;
    if (self.luaButton) {
        [self luaButtonAction:self.luaButton];
    }
}

#pragma mark - 重写getResultDirectly方法
- (NSObject *)getResultDirectly {
    
    NSString *luaScript = [xbuildInfo getLuaScript];
    if (luaScript && [luaScript length] > 0) {
        return self.luaButtonValue;
    }
    return nil;
}

#pragma mark - 重写getCurrentValuePresentation方法
- (NSObject *)getCurrentValuePresentation {
    
    return [self getResultDirectly];
}

#pragma mark - 重写getDisplayValuePresentation方法
- (NSObject *)getDisplayValuePresentation {
    
    return [self getResultDirectly];
}

#pragma mark - 获取指定脚本方法
- (NSString *)getFunctionName:(NSString *)luaScript {
    
    NSString *functionName = nil;
    NSRange funcRange = [luaScript rangeOfString:@"function "];
    if (funcRange.location != NSNotFound) {
        NSInteger begin = funcRange.location + funcRange.length;
        NSInteger end = [luaScript indexOfString:@"("];
        NSRange endRange =  NSMakeRange(begin, end - begin);
        functionName = [luaScript substringWithRange:endRange];
    }
    functionName = [functionName stringByTrimmingWhitespace];
    
    return functionName;
}

#pragma mark - 设置按键高亮方法
- (void)setLuaBtnHighted:(BOOL)highlighted {
    
    if (highlighted) {
        [self.luaButton setBackgroundImage:[UIImage imageNamed:@"lua_button_icon_down"] forState:UIControlStateNormal];
    }
    else {
        [self.luaButton setBackgroundImage:[UIImage imageNamed:@"lua_button_icon"] forState:UIControlStateNormal];
    }
}

#pragma mark - 重写showConfirmDialog方法
- (void)showConfirmDialog:(NSString*)dialog {
    
    __weak __typeof(self)weakSelf = self;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:@"无法拍摄,审批通过请填写原因:" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        UITextField *userNameTextField = alertController.textFields.firstObject;
        if (!userNameTextField.text || [userNameTextField.text isEqualToString:@""]) {
            NSString *title = NSLocalizedString(@"请输入原因", nil);
            [MBProgressHUD showHUDAddedTo:strongSelf.viewController.view withText:title tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
            return;
        }
        
        if (strongSelf.luaButton.selected) {
            strongSelf.luaButtonValue = @"1";
        }
        
        strongSelf.resultCheck = userNameTextField.text;
        NSString *luaScript = [xbuildInfo getLuaScript];
        if (luaScript && [luaScript length] > 0) {
            if ([self.delegate respondsToSelector:@selector(executeLuaScript:script:funcName:widget:)]) {
                [self.delegate executeLuaScript:xbuildInfo script:luaScript funcName:@"function onSubmitConfirm(" widget:self];
            }
        }
    }]];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *_NonnulltextField) {
        _NonnulltextField.placeholder = @"请输入审批通过原因";
        _NonnulltextField.keyboardType = UIKeyboardTypeDefault;
    }];
    
    [self.viewController presentViewController:alertController animated:YES completion:nil];
}
- (void)showAlertDialog:(NSString*)dialog {
    
    @weakify_self;
    
    BlockAlertView *alert = [BlockAlertView alertWithTitle:NSLocalizedString(@"js_alert_title", nil)
                                                  message:(dialog.length > 0 ? dialog : @"")];
    
    [alert addButtonWithTitle:NSLocalizedString(@"cancel_label", nil) block:^{
        
        WSInterAction  *interaction =[[WSInterAction alloc] init];
        [interaction setAcvt_qust_id:[xbuildInfo  getAcvtQstId]];
        [interaction setDirect_type:DIRECT_TYPE_METHOD_WITH_SINGLEPARAM];
        [interaction setExecute_method:@selector(backButtonClick)];

        if ([self.delegate respondsToSelector:@selector(executeInterAction:)]) {
            [self.delegate executeInterAction:interaction];
        }
        
    }];
    
    [alert addButtonWithTitle:NSLocalizedString(@"confirm_label", nil) block:^{
        
        @strongify_self;
        self.resultCheck = @"confirm";
        NSString *luaScript = [xbuildInfo getLuaScript];
        if (luaScript && [luaScript length] > 0) {
            if ([self.delegate respondsToSelector:@selector(executeLuaScript:script:funcName:widget:)]) {
                [self.delegate executeLuaScript:xbuildInfo script:luaScript funcName:@"function confirm(" widget:self];
            }
        }
        self.resultCheck = @"";
     
    }];
    
    [alert show];
}

#pragma mark - lua按键响应方法
- (void)luaButtonAction:(UIButton *)sender {
    
    LogTrace();
    
    self.luaButton.selected = YES;
    
    if ([[xbuildInfo getAcvtMemo] isEqualToString:@"refuse"]) {

        __weak __typeof(self)weakSelf = self;
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:@"拒绝原因" preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
        [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            UITextField *userNameTextField = alertController.textFields.firstObject;
            if (!userNameTextField.text || [userNameTextField.text isEqualToString:@""]) {
                NSString *title = NSLocalizedString(@"请输入拒绝原因", nil);
                [MBProgressHUD showHUDAddedTo:strongSelf.viewController.view withText:title tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
                return;
            }
            
            if (strongSelf.luaButton.selected) {
                strongSelf.luaButtonValue = @"1";
            }
            
            strongSelf.resultCheck = userNameTextField.text;
            NSString *luaScript = [xbuildInfo getLuaScript];
            if (luaScript && [luaScript length] > 0) {
                if ([strongSelf.delegate respondsToSelector:@selector(executeLuaScript:widget:)]) {
                    [strongSelf.delegate executeLuaScript:xbuildInfo widget:strongSelf];
                }
            }
        }]];
        [alertController addTextFieldWithConfigurationHandler:^(UITextField *_NonnulltextField) {
            _NonnulltextField.placeholder = @"请输入拒绝原因";
            _NonnulltextField.keyboardType = UIKeyboardTypeDefault;
        }];
        
        [self.viewController presentViewController:alertController animated:YES completion:nil];
        return;
    }
    
    NSString *luaScript = [xbuildInfo getLuaScript];
    NSString *scriptFunctionName = [self getFunctionName:luaScript];
    
    if ([scriptFunctionName isEqualToString:@"excuseScript"]) {
        if (luaScript && [luaScript length] > 0) {
            if ([self.delegate respondsToSelector:@selector(executeLuaScript:script:funcName:widget:)]) {
                [self.delegate executeLuaScript:xbuildInfo script:luaScript funcName:@"function excuseScript(" widget:self];
            }
        }
        return;
    }
    
    [self setLuaBtnHighted:YES];
    
    if ([scriptFunctionName isEqualToString:@"delete"]) {

        NSString *alertTitle = [xbuildInfo getQstDescription];
        if (!alertTitle || alertTitle.length <= 0) {
            alertTitle = NSLocalizedString(@"confirm_delete_dialog_title", nil);
        }
        
        __weak __typeof(self)weakSelf = self;
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:alertTitle message:@"" preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"cancel_label", nil) style:UIAlertActionStyleCancel handler:nil]];
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"confirm", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            if (luaScript && [luaScript length] > 0) {
                if ([strongSelf.delegate respondsToSelector:@selector(executeLuaScript:widget:)]) {
                    [strongSelf.delegate executeLuaScript:xbuildInfo widget:strongSelf];
                }
            }
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [strongSelf setLuaBtnHighted:NO];
            });
        }]];
        
        [self.viewController presentViewController:alertController animated:YES completion:nil];
        return;
    }
    
    if (luaScript && [luaScript length] > 0) {
        if ([self.delegate respondsToSelector:@selector(executeLuaScript:widget:)]) {
            [self.delegate executeLuaScript:xbuildInfo widget:self];
        }
    }
    
    __weak __typeof(self)weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf setLuaBtnHighted:NO];
    });
    
    if (self.luaButton.selected) {
        self.luaButtonValue = @"1";
    }

    if (![WSLuaExecutorManager shareInstance].isErrorFromScript) {
        [self autoJumpNextShowPage];
    }

    self.resultCheck = @"";
    [[WSStatisticsManager sharedInstance] insertStoreInfoSenceEventWithID:EVENT_BUTTON_CLICK
                                                           parentFuncBean:self.funcsBean.iParentFuncsBean
                                                          currentFuncBean:self.funcsBean
                                                                    store:self.store
                                                                  senceId:SCENE_ACVT
                                                               eventValue:[xbuildInfo getQuestName]
                                                                startTime:[WSCurrentTime getTimeMillisStringForDevice]
                                                                  endTime:nil
                                                                    genId:[WSStatisticsManager getGenId]];
}

@end
//===================================================================================================================================================================

#pragma mark - WSLuaButtonPanel 延展(工具)
@implementation WSLuaButtonPanel (Tools)

#pragma mark - 自动跳转下一个展示页面方法
- (void)autoJumpNextShowPage {
    
    NSString *ds = [self.xbuildInfo getDataSource];
    NSString *filter = [self.xbuildInfo getFilterCondition];
    if ([ds isEqualToString:ACVT] && filter.length > 0) {
        
        WSFuncsBeanArray *funcsArray = [WSAppData getObjectbyKey:FUNCS];
        WSFuncsBean *fb = [funcsArray getHideFuncsBeanWithFC:filter];
        if (fb != nil) {
            
            WSAcvtModel *model = (WSAcvtModel *)[WSDataSourceManager sharedInstance].currentActiveModel;
            NSString *className = [WSPlistHelper valueForKey:fb.fv withPlistName:kControllerMappingFileName];
            BaseViewController *vc = [[NSClassFromString(className) alloc] initWithFuncs:fb];
            vc.currentStore = model.currentStore;
            vc.hidesBottomBarWhenPushed = YES;
            [self.viewController.navigationController pushViewController:vc animated:YES];
        }
    }
}

@end
//===================================================================================================================================================================
