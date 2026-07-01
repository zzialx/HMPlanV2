//
//  WSScanListPanel.m
//  WinSFA
//
//  Created by winchannel on 15/11/16.
//  Copyright © 2015年 WinChannel. All rights reserved.
//

#import "WSScanListPanel.h"
#import "I_W_BuildInfo.h"
#import "WidgetConstant.h"
#import "WSQRModule.h"
#import "I_W_DisplayValue.h"
#import "WSScanListViewController.h"
#import "WSAddPhotosController.h"
#import "WSInterAction.h"
#import "WSAcvtModel.h"
#import "WSDataSourceManager.h"
#import "WSJSONBuilder.h"
#import "WSStringValueChangeChecker.h"
#import "WSApplicationWindowsRelationManager.h"
#import "WSLuaExecutorManager.h"



#define SCAN_ADD_PHOTOS_CONTROLLER     @"WSAddPhotosController"
#define SCAN_LIST_CONTROLLER           @"WSScanListViewController"

#define kBackController @"backController"

#define kDefaultHeight  40

@interface WSScanListPanel ()
{
    WSFuncsBean_Param *_aParam;
}

@property (nonatomic, weak) WSScanListViewController *currentScanController;

@end

@implementation WSScanListPanel

-(id)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if (self) {
        self.xvalueChangeChecker = [[WSStringValueChangeChecker alloc] init];
        self.addPhotoDict =[[NSMutableDictionary alloc]init];
        self.imeiImageIndexDict =[[NSMutableDictionary alloc]init];
        return self;
    }
    return nil;
}

-(id)initWithFrame:(CGRect)frame andParam:(WSFuncsBean_Param *)aParam
{
    
    self = [super initWithFrame:frame];
    if (self) {
        self.xvalueChangeChecker = [[WSStringValueChangeChecker alloc] init];
        self.addPhotoDict =[[NSMutableDictionary alloc]init];
        self.imeiImageIndexDict =[[NSMutableDictionary alloc]init];
        _aParam = aParam;
        return self;
    }
    return nil;
}


-(void)buildDisplayContent{
    
    [super buildDisplayContent];

    if (self.titleString && self.titleString.length > 0) {
        [super resetTitle:self.titleString];
    }
    
    BOOL orientition = NO;
    
    BOOL isShowTextfield = YES;
    
    NSString *displayValue = @"";
    NSString *codeType = @"";
    NSString *isPhotoRequire = @"";
    
    NSInteger buttonTag = 0;
    
    if (_aParam) {
        displayValue = self.displayString;
    }else{
        if ([xbuildInfo getOrientation] && [[xbuildInfo getOrientation] isEqualToString:@"1"]) {
            orientition = YES;
        }
        
        
        if ([[xbuildInfo getIsHideQstOptName] isEqualToString:@"1"]) {
            isShowTextfield = NO;
        }
        
        buttonTag = [[xbuildInfo getAcvtQstId] integerValue] + kScanButtonBaseTag;
        displayValue = (NSString *)[xdisplayValue getDisplayValueFor:xbuildInfo];
        
        codeType = [xbuildInfo getWidgetId];
        isPhotoRequire = [xbuildInfo getQstDescription];
        
    }
    
    UIImage *scanBtnImage = [[UIImage imageNamed:@"scan_icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    CGFloat scanBtnWidth = scanBtnImage.size.width;
    CGFloat scanBtnHeight = scanBtnImage.size.height;
    
    UIFont *font = [UIFont systemFontOfSize:UI_Font];
    
    
    if (isShowTextfield) {
        if (self.titleLabel.text && self.titleLabel.text.length > 0) {
            
        }
        
        self.textField  =[[WSHTextField alloc]initWithFrame:CGRectMake(MAIN_CELL_PADDING,self.titleLabel.text && self.titleLabel.text.length > 0 ? self.titleLabel.bottom : MAIN_PADDING, self.width -  scanBtnWidth - MAIN_CELL_PADDING * 2 - MAIN_PADDING, MAIN_TEXTFIELD_HEIGHT)];
        [self.textField setBorderStyle:UITextBorderStyleRoundedRect];
        NSString *placeholder ;
        self.textField.placeholder = placeholder;
        self.textField.font = font;
        self.textField.m_type =  COL_TYPTEXT;
        //SFA 项目 SFA-8361
//        self.textField.m_isGride = YES;
        self.textField.backgroundColor = [UIColor clearColor];
        self.textField.textAlignment = NSTextAlignmentLeft;
        self.textField.contentMode= UIViewContentModeLeft;
        self.textField.delegate = self;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(textChange)
                                                     name:UITextFieldTextDidChangeNotification
                                                   object:self.textField];
        
        [self addSubview:self.textField];
    }
    
    
    //条码扫描按钮
    CGFloat i_button_x = self.bounds.size.width - scanBtnWidth - MAIN_CELL_PADDING;
    CGFloat i_button_y = isShowTextfield ? (self.textField.origin.y + ((self.textField.size.height - scanBtnHeight)/2)): (MAIN_CELL_HEIGHT - scanBtnHeight)/2;
    
    self.i_button = [UIButton buttonWithType:UIButtonTypeCustom];
    self.i_button.frame =CGRectMake(i_button_x, i_button_y, scanBtnWidth, scanBtnHeight);
    [self.i_button addTarget:self action:@selector(startScan:) forControlEvents:UIControlEventTouchUpInside];
    [self.i_button setImage:scanBtnImage forState:UIControlStateNormal];
    [self.i_button setTintColor:MAIN_TINT_COLOR];
    
    if (orientition) {
        self.i_button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    } else {
        self.i_button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    }
    self.i_button.tag = buttonTag;
    [self addSubview:self.i_button];
    
    //确定按钮
    self.confirButton =[UIButton buttonWithType:UIButtonTypeCustom];
    self.confirButton.titleLabel.font = [UIFont systemFontOfSize: 14.0];
    [self.confirButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.confirButton.frame = CGRectZero;
    [self.confirButton addTarget:self action:@selector(confirmCompletion:) forControlEvents:UIControlEventTouchUpInside];
    UIImage *confirmImg = [[UIImage imageNamed:@"queding_button"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.confirButton setBackgroundImage:confirmImg forState:UIControlStateNormal];
    [self.confirButton setTintColor:MAIN_TINT_COLOR];
    self.confirButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    
    self.confirButton.tag = buttonTag+1;
    [self insertSubview:self.i_button belowSubview:self.confirButton];
    
    
    
    //结果清单
    NSMutableArray *menuArray = [[NSMutableArray alloc]initWithObjects:NSLocalizedString(@"delete_label", nil), nil];
    //回显值
    
    _originalValue = displayValue;
    
    NSArray *resultArray = [displayValue componentsSeparatedByString:@","];
    
    CGFloat scan_width = (self.bounds.size.width - MAIN_CELL_PADDING * 2);
    
    CGFloat scanY = isShowTextfield ? self.textField.origin.y + self.textField.size.height : kDefaultHeight;
    
    WSScanListView *scanListView = [[WSScanListView alloc]initWithFrame:CGRectMake(MAIN_CELL_PADDING , scanY, scan_width, _aParam?self.frame.size.height - scanY:resultArray.count * MAIN_CELL_HEIGHT)
                                                          withDataArray:resultArray.mutableCopy
                                                          withMenuArray:menuArray
                                                              withQstId:_aParam?nil:[xbuildInfo getAcvtQstId]
                                                          withBtnTitile:nil];
    
    scanListView.codeType = codeType;
    scanListView.isPhotoRequire = isPhotoRequire;
    
    
    _scanListView = scanListView;
    scanListView.delegate = self;
    
    if (_isNotChangePanelHeight) {
        
    }else
        [self setFrame:CGRectMake(self.frame.origin.x,self.frame.origin.y, self.frame.size.width,self.scanListView.origin.y + scanListView.frame.size.height + MAIN_CELL_PADDING)];
    
    if (!isShowTextfield) {
        CGRect labelFrame = self.titleLabel.frame;
        [self.titleLabel setFrame:CGRectMake(labelFrame.origin.x, (self.frame.size.height - labelFrame.size.height)/2 , labelFrame.size.width, labelFrame.size.height)];
    }
    
    [self addSubview:scanListView];
    
    [self verifyResultCount];
    
}

- (void)widgetDidLoadFinish {
    
    WSAcvtModel *model = (WSAcvtModel *)[WSDataSourceManager sharedInstance].currentActiveModel;
    if (model.currentAcvtBean.qsts.count == 1) {
        WSAcvtBean_qst *qst = [model.currentAcvtBean.qsts firstObject];
        if ([qst.acvtQstId isEqualToString:[xbuildInfo getAcvtQstId]]) {
            
            [self performSelector:@selector(startScan:) withObject:@{kBackController:model.ownAcvtViewController} afterDelay:0.01];
            
        }
    }
}

-(NSObject *)getResultDirectly{
    
     NSMutableArray *uploadObj =[[NSMutableArray alloc]init];
    if (_scanListView.resultArray != nil &&_scanListView.resultArray.count > 0 )  {
       
        
        for (NSString *code in _scanListView.resultArray) {
            NSString *result = nil;

            if ([self.imeiImageIndexDict objectForKey:code]) {
                NSString *imageIndex  = [self.imeiImageIndexDict objectForKey:code];
                result = [NSString stringWithFormat:@"%@@%@",code,imageIndex];
                
            }
            else{
                result = [NSString stringWithFormat:@"%@",code];
            }
            
            [uploadObj addObject:result];
        }
        return [uploadObj componentsJoinedByString:@","];
    }
    return nil;
    
    
}

//特殊处理lua脚本提示方法 tip:提示
- (BOOL)specialHandleLuaTip:(NSString *)tip {
    
    if ([tip containsString:@"setResult@"]) {
        NSArray *array = [tip componentsSeparatedByString:@"setResult@"];
        if (self.currentScanController) {
            [self.currentScanController getReturnDataFromLuaTip:[array lastObject]];
        } else {
            [self setValueForCurrentObject:[array lastObject]];
        }
        return YES;
    }
    return NO;
}

//是否扫描结果需要lua脚本处理方法 scanResult:扫描结果 SFA-24449
- (BOOL)isScanResultLuaHandleWithScanResult:(NSString *)scanResult {
    
    NSString *luaScript = [xbuildInfo getLuaScript];
    if (luaScript && luaScript.length > 0) {
        if ([self.delegate respondsToSelector:@selector(executeLuaScript:widget:)]) {
            self.resultCheck = scanResult;
            [self.delegate executeLuaScript:xbuildInfo widget:self];
            return YES;
        }
    }
    return NO;
}

-(void)startScan:(id)sender
{
    WSStoreBean *currentStore = nil;
    WSAcvtModel *acvtModel = nil;
    WSBaseModel *model = [WSDataSourceManager sharedInstance].currentActiveModel;
    if ([model isKindOfClass:[WSAcvtModel class]]) {
        acvtModel = (WSAcvtModel *)model;
        currentStore = acvtModel.currentStore;
    }

    NSString *acvtMemo = [xbuildInfo getAcvtMemo] ;
    NSString *subViewAlertTitle = acvtMemo.length > 0 ? acvtMemo : _aParam.paramDescript;
    WSScanListViewController *list =[[WSScanListViewController alloc]initWithScanQrCode:YES withDescStr:subViewAlertTitle];
    
    if ([sender isKindOfClass:[NSDictionary class]]) {
        list.backController = ((NSDictionary *) sender)[kBackController];
    }
    
    if ([[xbuildInfo getIsHideQstOptName] isEqualToString:@"1"]) {
        [list setIsShowModifyButton:NO];
    }
    
    NSInteger maxCount = [[xbuildInfo getMumx] integerValue];
    if (maxCount) {
        list.maxCount = maxCount;
    }
    
    if (currentStore && acvtModel.currentFuncs) {
        list.currentStore = currentStore;
        list.currentFuncs = acvtModel.currentFuncs;
    }
    self.currentScanController = list;
    
    list.dependentWidget = self;
    
//    __weak WSScanListPanel *scanpanel = self;
    
    __weak WSScanListView *scanListView = _scanListView;
    [list setVisibleProducts:_scanListView.resultArray andAllProducts:nil];
    
    // scanpanel.superview.viewController
    [list showQRViewControllerToViewController:[[WSApplicationWindowsRelationManager sharedManager] getCurrentVC] WithBlock:^(NSArray *aQRlist) {
        
        for (NSString *code in aQRlist) {
           
             [scanListView.resultArray insertObject:code atIndex:0];
        }
        [self reSetScanListViewFrameWithSelectStr:aQRlist withSendMode:AddMesss];
        [_scanListView reloadScanList];
        [self checkValueChange];
        
        [self verifyResultCount];
        [self executeCompleteScript]; //SFA-28767 暂时处理方案 如果还出现脚本方法嵌套脚本方法 就要在做处理 后续需要时在开发
    }];
}

#pragma mark - 执行完成脚本方法
- (void)executeCompleteScript {
    
    NSString *luaScript = [self.xbuildInfo getLuaScript];
    NSArray *notRunFuncNameArray = @[@"excuseAction"];
    NSArray *scriptArray = [WSLuaExecutorManager getFilterArrayScriptWith:luaScript filterFuncNameArray:notRunFuncNameArray];
    if (scriptArray && scriptArray.count > 0) {
        _resultCheck = [self getResultDirectly];
        for (NSString *script in scriptArray) {
            if ([self.delegate respondsToSelector:@selector(executeLuaScript:script:widget:)]) {
                [self.delegate executeLuaScript:self.xbuildInfo script:script widget:self];
            }
        }
    }
}

-(void)executeScript{
    NSString *luaScript = [self.xbuildInfo getLuaScript];
    if ([self.delegate respondsToSelector:@selector(executeLuaScript:widget:)]
        && luaScript && ![luaScript isEqualToString:@""]) {
        _resultCheck = [self getResultDirectly];
        [self.delegate executeLuaScript:self.xbuildInfo widget:self];
    }
}


- (void)setValueForCurrentObject:(NSObject *)objvalue {
    LogInfo(@"returnData:%@", objvalue);
    
    NSString *checkeResult = (NSString *)objvalue;
    
    //手动输入执行校验成功刷新imei列表
    if (self.textField.text.length > 0) {
        
        if (checkeResult.length >0) {
            //[_scanListView.resultArray addObject:self.textField.text];
            
            NSString * regString = [xbuildInfo getRegularExpression];
            // 如果配了正则表达式，则在点击确定的时候校验是否加入到条码的答案中
            if (regString && regString.length > 0) {
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regString];
                BOOL isValid = [predicate evaluateWithObject:checkeResult];
                if (isValid) {
                    
                    [self setScanListViewResult];

                }else{
                    
                    [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:NSLocalizedString(@"illegal_barcode", nil) tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
                }
                
            }else{
                
                [self setScanListViewResult];
            }
           
        }else{
            
            [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:NSLocalizedString(@"illegal_barcode", nil) tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
        }

    }
   
    [self.currentScanController getReturnDataFromLua:checkeResult];
}

// 设置扫描答案
-(void)setScanListViewResult{
    
    [_scanListView.resultArray insertObject:self.textField.text atIndex:0];
    NSArray *resultArray = [self.textField.text componentsSeparatedByString:@","];
    [self reSetScanListViewFrameWithSelectStr:resultArray withSendMode:AddMesss];
    [_scanListView reloadScanList];
    
    [self verifyResultCount];

    self.textField.text = nil;

    [self.superview setNeedsLayout];
}

- (void)setCurrentValueWithPresentation:(NSString *)valuePresentation{
    
    
    [self reSetScanListViewFrameWithSelectStr:self.scanListView.resultArray withSendMode:DeleteMessage];
    [self.scanListView.resultArray removeAllObjects];
    [self.scanListView.photosDict removeAllObjects];
    [self.addPhotoDict removeAllObjects];
    [self.imeiImageIndexDict removeAllObjects];
    
    [self.scanListView reloadScanList];
    
    [self verifyResultCount];
}

- (void)confirmCompletion:(id)sender{
    
    if (![_scanListView.resultArray containsObject:self.textField.text] && self.textField.text.length>0) {
        
        NSString *luaScript = [self.xbuildInfo getLuaScript];
        if ([self.delegate respondsToSelector:@selector(executeLuaScript:widget:)]
            && luaScript && ![luaScript isEqualToString:@""]) {
            _resultCheck = self.textField.text ;
           [self.delegate executeLuaScript:self.xbuildInfo widget:self];
        }else {
            [self setValueForCurrentObject:self.textField.text];
            [self checkValueChange];
            
        }
    }else if ([_scanListView.resultArray containsObject:self.textField.text] && self.textField.text.length>0){
        NSString *message = [NSString stringWithFormat:NSLocalizedString(@"already_filled",nil),self.textField.text];
        
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:message tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
        self.textField.text = nil;
    }
    
    if ( self.textField.text.length == 0) {

        self.i_button.frame = self.confirButton.frame;
        self.confirButton.frame = CGRectZero;
        [self insertSubview:self.i_button belowSubview:self.confirButton];
    }
    
    [self.textField clearTextOldValue];
    
    [self.textField resignFirstResponder];
    
}

- (void)addPhotosWithCellIndex:(NSIndexPath *)cellIndex{
    
   
    NSString *imeiStr = [_scanListView.resultArray objectAtIndex:cellIndex.row];
    if (![self.imeiImageIndexDict objectForKey:imeiStr]) {
         NSString *imageIndex = [[[WSJSONBuilder gen_uuid] md5] lowercaseString];
        [self.imeiImageIndexDict setObject:imageIndex forKey:imeiStr];
    }
   
    WSInterAction *interaction =[[WSInterAction alloc]init];
    [interaction setAcvt_qust_id:[xbuildInfo getAcvtQstId]];
    [interaction setExecute_class:SCAN_ADD_PHOTOS_CONTROLLER];
    [interaction setDirect_type:DIRECT_TYPE_PRESENT];
    
    NSMutableDictionary *dic =[[NSMutableDictionary alloc]init];
    
    if ([self.addPhotoDict objectForKey:imeiStr]) {
        NSArray *cellPhotos =[self.addPhotoDict objectForKey:imeiStr];
        [dic setObject:cellPhotos forKey:@"cellPhotos"];
    }
    [dic setObject:imeiStr forKey:@"imei"];
    [interaction setExecute_class_param:dic];
    [delegate executeInterAction:interaction];

}

- (void)loadComputeResult:(WSInterAction *)interAction{
    
    if ([[interAction execute_class] isEqualToString:SCAN_ADD_PHOTOS_CONTROLLER]) {
        
        if ([[interAction execute_result] isKindOfClass:[NSArray class]]) {
            
            NSArray *controPhotoArray =(NSArray *)[interAction execute_result];
            
            NSDictionary *dic = (NSDictionary *)[interAction execute_class_param];
            
            NSString *imeiStr = [dic objectForKey:@"imei"];
            

            [self.addPhotoDict setObject:controPhotoArray forKey:imeiStr];
             _scanListView.photosDict = self.addPhotoDict;
        }
    }
    
    [_scanListView reloadScanList];
}


- (void)verifyResultCount {
    NSInteger maxCount = [[xbuildInfo getMumx] integerValue];
    if (maxCount) {
        CGRect frame = self.frame;
        CGRect scanListFrame = self.scanListView.frame;
        
        if (self.scanListView.resultArray.count >= maxCount) {
            if (![self.i_button isHidden]) {
                [self.i_button setHidden:YES];
                if (self.textField) {
                    [self.textField setHidden:YES];
                }
                frame.size.height -= self.textField.height;
                scanListFrame.origin.y -= self.textField.height;
            }
        } else {
            if ([self.i_button isHidden]) {
                [self.i_button setHidden:NO];
                if (self.textField) {
                    [self.textField setHidden:NO];
                }
                frame.size.height += self.textField.height;
                scanListFrame.origin.y += self.textField.height;
            }
        }
        
        [self setFrame:frame];
        [self.scanListView setFrame:scanListFrame];
        [self.superview setNeedsLayout];
    }
}

#pragma Mark - WSScanListViewDelegate
- (void)deletScanCodeWithSendeMode:(SendMesMode)sendMode withCellIndexNum:(NSIndexPath *)cellIndex{
    
    
    NSString *deletCode = [_scanListView.resultArray objectAtIndex:cellIndex.row];
    
    [_scanListView.resultArray removeObjectAtIndex:cellIndex.row];
    if (self.addPhotoDict.count >0 && [self.addPhotoDict objectForKey:deletCode]) {
        [self.addPhotoDict removeObjectForKey:deletCode];
        _scanListView.photosDict = self.addPhotoDict;
       
    }
    NSArray *deletCodes =[[NSArray alloc]initWithObjects:deletCode, nil];
    
    [self reSetScanListViewFrameWithSelectStr:deletCodes withSendMode:sendMode];
    [_scanListView reloadScanList];
    [self checkValueChange];
    
    [self verifyResultCount];
    [self executeScript];

    [self.superview setNeedsLayout];
}

#pragma Mark - UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    
//    if (self.i_button.frame.size.width != 0.0) {
//        self.confirButton.frame = self.i_button.frame;
//        self.i_button.frame = CGRectZero;
//        [self insertSubview:self.confirButton belowSubview:self.i_button];
//    }


}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    
//    if ([self.textField textCheck]) {
//        self.i_button.frame = self.confirButton.frame;
//        self.confirButton.frame = CGRectZero;
//        [self insertSubview:self.i_button belowSubview:self.confirButton];
//        
//    }

}
- (void)textChange{
    
    if (self.textField.text.length >0  && self.confirButton.size.width == 0.0) {

        self.confirButton.frame = self.i_button.frame;
        self.i_button.frame = CGRectZero;
         [self insertSubview:self.confirButton belowSubview:self.i_button];
    }else if ((self.textField.text.length == 0)  && (self.i_button.frame.size.width == 0.0)){
        self.i_button.frame = self.confirButton.frame;
        self.confirButton.frame = CGRectZero;
        [self insertSubview:self.i_button belowSubview:self.confirButton];
    }
}

#pragma Mark - privateMethod
//重置因删除或者增加cell的变化而引起的frame变化
- (void)reSetScanListViewFrameWithSelectStr:(NSArray *)aQRList withSendMode:(SendMesMode )sendMode {
    
    //更新scanlistView frame
    CGRect rect = self.scanListView.frame;
    CGFloat height = 0.f;
    
    NSInteger scanCount = _scanListView.resultArray.count - aQRList.count;
    for (NSString *code in aQRList) {
        
        NSString *imeiAndNumber = [NSString stringWithFormat:@"%ld. %@",(long)scanCount,code];
        CGFloat codeCellHeight =[WSScanListMenuCell heightWithMainTitle:imeiAndNumber withSubTitle:nil withCellFrame:rect];
        
        height+= codeCellHeight;
        scanCount ++;
    }
    
    if (sendMode != AddMesss) {
        height = -height;
    }
    
    //更新panel frame
    if (_isNotChangePanelHeight) {
        if (height > 0 && rect.size.height + height < self.frame.size.height - self.scanListView.frame.origin.y) {
            //重置scanResultList的Frame
            self.scanListView.frame =CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height + height);
            self.scanListView.scanResultList.frame = CGRectMake(0, 0, rect.size.width, rect.size.height + height);
        }else if (height < 0 && rect.size.height + height > self.frame.size.height - self.scanListView.frame.origin.y){
            self.scanListView.frame =CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height + height);
            self.scanListView.scanResultList.frame = CGRectMake(0, 0, rect.size.width, rect.size.height + height);
        }
    }else{
        //重置scanResultList的Frame
        self.scanListView.frame =CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height + height);
        self.scanListView.scanResultList.frame = CGRectMake(0, 0, rect.size.width, rect.size.height + height);
        [self setFrame:CGRectMake(self.frame.origin.x,self.frame.origin.y, self.frame.size.width , self.frame.size.height +height)];
    }
}

- (NSString *)getAcvtQstId{
    if (xbuildInfo) {
        return [xbuildInfo getAcvtQstId];
    }
    return nil;
}

- (void)setReadonly:(NSString *)isReadonly
{
    [super setReadonly:isReadonly];
    
    if ([[xbuildInfo getReadOnly] isEqualToString:@"1"]) {
        self.userInteractionEnabled = NO;
    }
    
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:self.textField];
    self.scanListView.delegate = nil;
}


@end
