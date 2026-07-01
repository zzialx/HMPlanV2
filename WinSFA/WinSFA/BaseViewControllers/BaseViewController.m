//
//  BaseViewController.m
//  WinChannelFrameWork
//
//  Created by winchannel on 11-12-7.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "WinSFA.h"
#import "BaseViewController.h"
#import "WSFuncsBean.h"
#import "WSFuncsBean_opt.h"
#import "WSFuncsBean_Param.h"
#import "WSAppData.h"
#import "WSDictBean.h"
#import "WSProdBean.h"
#import "WSProdBeanArray.h"
#import "WSDictBrand.h"
#import "WSAcvtViewController.h"
#import "WSAcvtBean.h"
#import "WSCurrentTime.h"
#import "WSProdGrideViewController.h"
#import "DataGridComponent.h"
#import "FileManager.h"
//add by wangdongyan 03-21 for label的layer.maskstobounds属性
#import <QuartzCore/QuartzCore.h>
#import "WSFuncsBean_other.h"
#import "WSPhotoGalleryViewController.h"
#import "WSAppData.h"
#import "WSVisitStoreActionTable.h"
#import "UIDevice+Addtional.h"
#import "WSJSONBuilder.h"
#import "WSImagePathTable.h"
#import "WSFdtTable.h"
#import "WSFptTable.h"
#import "WSProdGrideViewController.h"
#import "WSDictGrideViewController.h"
#import "WSPhotoTypeItem.h"
#import "WSPhotoTypeView.h"
#import "WSPhotoTypeArrayItem.h"
#import "WSAppDelegate.h"
#import "WSPhotoBrowseView.h"
#import "FUISingleSelectionListView.h"
#import "WSNavigationBar.h"
#import "WSAppSettingViewController.h"
#import "WSUpKeyBoardView.h"
#import "WSBaseModel.h"
#import "WSDataSourceManager.h"
#import "WidgetConstant.h"
#import "WSInterAction.h"
#import "WSWidget.h"
#import "WSEnvrionment.h"
#import "WSWorkFlowViewController.h"
#import "WSCustomerVistViewController.h"
#import "WSStoreInfoMapViewController.h"
#import "WSSplitViewController.h"
#import "WSVisitStoreStatusTable.h"
#import "WSValidateTextView.h"
#import "NSString+Additions.h"
#import "WSBaseDictsDBService.h"
#import "WSInsetLabel.h"
#import "WSNextStepFuncsViewController.h"
#import "WSBaseStoreOtherDataDBService.h"
#import <objc/runtime.h>
#import "WSMV_LISTViewController.h"
#import "WSStoreInfoBeanArray.h"
#import "WSNewAddAcvtViewController.h"
#import "WSAcvtVCManager.h"
#import "WSBaseNewAcvtListViewController.h"
#import "WSReportFormController.h"
#import "WSNewAddProdsWithSeriesViewController.h"
#import "WSInoutStoreTable.h"
#import "WSSpecialAcvtListViewController.h"
#import "WSLeaveStoreAcvtViewController.h"
#define NODELLWITH              -1

#define CANCELLBREWBUTTONTAG    501
//add by wangdongyan 03-21 for 主管拜访的技巧评估内的label的tag
#define LABELTAG            599
#define SPACEHEIGTH         ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 10.0f : 15.0f)
#define k_GPSViewHeight  ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 50.0f : 50.0f)
#define k_GPSViewXOffset  ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 0.0f : 250.0f)
#define kFuncsOtherTextFieldHeight  ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 35.0f : 35.0f)
#define k_PhotoViewYOffset ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? -42 : 0)
#define k_RadioButtonHeight ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 30.0f : 30.0f)
#define k_RadioButtonWidth ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 60.0f : 60.0f)
#define k_RadioViewHeight ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 100.0f : 160.0f)
#define k_RadioLabelHeight ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 30.0f : 30.0f)
#define k_LabelMargin  ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 30.0f : 40.0f)
// 自适应计算出高度的额外补充
#define k_AdjustHeight ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 8.0f:15.0f)
#define k_subViewYOffset  ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 6.0f:15.0f)




@interface BaseViewController () {
    CGFloat differentModalYOffset;
    BOOL isUsingSysCamera;
    CGFloat editingOffsetY;
    CGFloat editChangeHeight;
}

@property (nonatomic,strong) UILabel* gpsLabel;

@end

@implementation BaseViewController

@synthesize currentFuncs = _currentFuncs;
@synthesize mImagePicker = _mImagePicker;
@synthesize memoData = _memoData;
@synthesize y_point;
@synthesize titles = _titles;
@synthesize colWidth = _colWidth;
@synthesize datas = _datas;
@synthesize currentStore = _currentStore;
@synthesize alert;
@synthesize photo;
@synthesize md5;
@synthesize m_CurrentInputView = _m_CurrentInputView;
@synthesize m_GPSView;
@synthesize m_ParentViewController;
@synthesize m_viewHeight;

@synthesize requireTag;

@synthesize photoDataDic = _photoDataDic;

// 与照片类型有关的属性
@synthesize photoTypeArray = _photoTypeArray;

@synthesize isGpsReady = _isGpsReady;
@synthesize popController = _popController;
@synthesize originalViewYPosition = _originalViewYPosition;
@synthesize radioViewArray = _radioViewArray;
@synthesize locationDescribe = _locationDescribe;

#pragma mark 私有方法

-(void)setCurrentStore:(WSStoreBean *)currentStore{
    _currentStore = currentStore;
}

-(NSString*)getMD5Time
{
    NSString* l_dateStr;
    const char* l_MD5Type = [self.currentFuncs.dateTyp UTF8String];
    if(l_MD5Type == NULL)
    {
        l_dateStr = [WSCurrentTime getDateString];
        return l_dateStr;
    }
    switch (*l_MD5Type) 
    {
        case 'Y':
        {
            l_dateStr = [WSCurrentTime getYearString];
        }
            break;
        case 'M':
        {
            l_dateStr = [WSCurrentTime getMonthString];
            
        }
            break;
        case 'W':
        {
            l_dateStr = [WSCurrentTime getWeekString];
            
        }
            break;
        case 'E':
        {
            l_dateStr = [WSCurrentTime getDateTime];
        }
            break;
        case 'L': //永远覆盖前一条
        {
            l_dateStr = @"L";
            break;
        }
        case 'D': {
            l_dateStr = [WSCurrentTime getDateString];
        }
            break;
        default:
        {
            l_dateStr = [WSCurrentTime getDateTime];
        }
            break;
    }
    
    return l_dateStr;
}

/**
 *  必须定位功能，并且当前没有开启定位权限，则提示用户去设置打开定位功能。
 *
 *  @return YES，显示alert。NO，定位以及开启。
 */

-(BOOL) showGPSOpenAlertIfNeed
{
    if ([self.currentFuncs.opt.isGps isEqualToString:@"R"] && ![[WSLocationManager getInstance] currentLocationServicesEnabled]) {
      
        NSString *uploadLocationString = NSLocalizedString(@"need_open_gps", nil);

        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:uploadLocationString tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];

        return YES;
    }
    
    return NO;
}

/**
 *  检测上传数据是否必须GPS，如果没有展现GPS则返回NO。
 *
 *  @return NO,标识当前没有GPS信息，不允许提交信息。
 */
-(BOOL)checkMustUploadGPS
{
    WSFuncsBean_opt *fb_opt = self.currentFuncs.opt;
    
    if (fb_opt.isGps != nil && [fb_opt.isGps isEqualToString:REQUIRED_R] && !self.isGpsReady) {
        
 
        NSString *uploadLocationString = NSLocalizedString(@"must_upload_gps", nil);
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:uploadLocationString tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];

        return NO;
    }
    
    return YES;
}


- (BOOL)validateMemo {
    WSFuncsBean_opt *fb_opt = self.currentFuncs.opt;
    
    if (fb_opt.isMemo != nil && [fb_opt.isMemo isEqualToString:REQUIRED_R] && fb_opt.isMemo.length>0) {
        
        WSHTextField *textField = (WSHTextField *)[self.contentScrollView viewWithTag:MEMOTAG];
        if ([textField.text length] == 0) {
            NSString *TakePhotoString = NSLocalizedString(@"备注:未填写!",nil);
            [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:TakePhotoString tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
            return NO;
        }
        
    }
    
    return YES;
}


-(void)adOptions
{
    
}



- (BOOL)textFielLimtedKindOfNumber:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    
    if(![textField isKindOfClass:[WSHTextField class]])
        return YES;
    
    WSHTextField* wtf = (WSHTextField*)textField;
    if(wtf.tag == MEMOTAG)
        return YES;
    
    //小数点只能有一个
    NSRange l_range = [wtf.text rangeOfString:@"."];
    if (l_range.location != NSNotFound && [string isEqualToString:@"."]) {
        return NO;
    }
    
    if(wtf.m_type != nil&&[wtf.m_type isEqualToString:COL_TYPNUM]/*&&![string isEqualToString:@"."]*/)
    {
        return YES;
    }
    //add 异常原因判断输入字数 by 严国帅 at 2012－03－23
    if (wtf.m_type != nil&&[wtf.m_type isEqualToString:COL_TYPCHT]) {
        if (range.location>=[wtf.m_max intValue]) {
            return NO;
        }
        return YES;
    }
    return NODELLWITH;
}

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize { 
    UIGraphicsBeginImageContext(newSize); 
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)]; 
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();     
    UIGraphicsEndImageContext(); 
    return newImage; 
}

- (BOOL)readonlyAfterUpload
{
    if ([self.currentFuncs.dateTyp isEqualToString:@"D"]) {
        return NO;
    }
    return YES;
}

// MN-1590 新增订单添加完产品直接回跳两级，中间的添加页面只出现一次
- (void)newAddAcvtBackTo2LevelUpViewController
{
    WSNewAddAcvtViewController *currentNeedShowNewAddAcvtVC = (WSNewAddAcvtViewController *)[[WSAcvtVCManager sharedInstance] getAcvtViewController];
    BOOL condition1 = ([self isKindOfClass:[WSNewAddProdsWithSeriesViewController class]] && currentNeedShowNewAddAcvtVC);
    BOOL condition2 = ([self isKindOfClass:[MoreProductViewController class]] && currentNeedShowNewAddAcvtVC);
    BOOL condition3 = [self isEqual:currentNeedShowNewAddAcvtVC];
    if (condition1 || condition2 || condition3) {
        [[WSAcvtVCManager sharedInstance] deleteAll];
    }
    
    if (condition3) {
        NSArray *navVCArray = nil;
        if(self.m_ParentViewController != nil) {
            navVCArray = self.m_ParentViewController.navigationController.viewControllers;
            if (navVCArray.count > 2) {
                UIViewController *needPopToVC = [navVCArray objectAtIndex:(navVCArray.count - 3)];
                [self.m_ParentViewController.navigationController popToViewController:needPopToVC animated:YES];
            }
        }
        else {
            navVCArray = self.navigationController.viewControllers;
            if (navVCArray.count > 2) {
                UIViewController *needPopToVC = [navVCArray objectAtIndex:(navVCArray.count - 3)];
                [self.navigationController popToViewController:needPopToVC animated:YES];
            }
        }
    }
}

-(BOOL)backToParent
{
    LogTrace();
    
    [self newAddAcvtBackTo2LevelUpViewController];

    if ([self.m_ParentViewController isKindOfClass:[WSNextStepFuncsViewController class]]) {
        return [((WSNextStepFuncsViewController *)self.m_ParentViewController) backToParent];
    } else if ([self.m_ParentViewController isKindOfClass:[WSMV_LISTViewController class]]) {
        WSMV_LISTViewController *mvListVC = (WSMV_LISTViewController *)self.m_ParentViewController;
        if (![mvListVC isBatchUpload]) {
            // 238,137 SFA-10275 和 YIHAIKERRY-2361 联合利华上的二次修改
            return YES;
        }else{
            if (mvListVC.isBatchUploadFirstBack) {
                return YES;
            }
            mvListVC.isBatchUploadFirstBack = YES;
        }
    }
    
    
    NSInteger l_count = self.m_ParentViewController != nil ? [self.m_ParentViewController.navigationController.viewControllers count ]:[self.navigationController.viewControllers count];
    
    // SFA-24615 【SFA泸州老窖】【iOS】上传考勤后，没有跳转到tab工作日历 donghong

    if (l_count>1) {
        //SFA-23120 【泸州老窖-ios】考勤打卡成功后跳转考勤历史->工作日历 2018/9/3
        //上传完成后跳到下一个菜单
        if ([self.m_ParentViewController isKindOfClass:[SuperBarViewController class]]) {
            
            BOOL isJump = [(SuperBarViewController *)self.m_ParentViewController JumpToNext];
            
            if (isJump) {
                return NO;
            }
        }
    }

    if (self.isTabMode) {
        return YES;
    }

    WSSplitViewController *splitController = self.wsSplitController;
    if (splitController && [splitController.leftViewController isKindOfClass:[WCNavigationController class]])
    {
        WCNavigationController *nav = (WCNavigationController *)splitController.leftViewController;
        if ([[nav.viewControllers firstObject] isKindOfClass:[WSWorkFlowViewController class]])
        {
            WSWorkFlowViewController *con = (WSWorkFlowViewController *)[nav.viewControllers firstObject];
            [con reloadView];
        }
    }

    if (l_count <= 1) {
        
        if (self.wsSplitController) {
            
            if ([self.wsSplitController.leftViewController isKindOfClass:[WCNavigationController class]])
            {
                WCNavigationController *nav = (WCNavigationController *)self.wsSplitController.leftViewController;
                if ([[nav.viewControllers firstObject] isKindOfClass:[WSWorkFlowViewController class]])
                {
                    WSWorkFlowViewController *con = (WSWorkFlowViewController *)[nav.viewControllers firstObject];
                    [con reloadView];
                    [con removeSelection];
                }
            }
            
            WSStoreInfoMapViewController *mapCon = [[WSStoreInfoMapViewController alloc] init];
            WCNavigationController *nav = [[WCNavigationController alloc] initWithRootViewController:mapCon];
            [self.wsSplitController showRightController:nav];
            
            
            return YES;
        }
        
        if (self.presentingViewController) {
            
            if ([self.wcBaseViewdelegate respondsToSelector:@selector(controllerNeedDismiss)]) {
                [self.wcBaseViewdelegate controllerNeedDismiss];
            }else {
                [self dismissViewControllerAnimated:YES completion:nil];
            }
            
            return YES;
        }
        
        return NO;
    }
    else
    {
       
        [self clearMapData];
        
        if(self.m_ParentViewController != nil)
        {
            id l_parentController = [self.m_ParentViewController.navigationController.viewControllers objectAtIndex:l_count - 2];
            if ([l_parentController isKindOfClass:[WSWorkFlowViewController class]] && l_count >= 3 &&
                [self.currentFuncs.opt.isCheckEnterStore isEqualToString:@"1"]) {
                
                UIViewController *vc = [self.navigationController.viewControllers objectAtIndex:l_count - 3];
                if ([vc isKindOfClass:[WSCustomerVistViewController class]]) {
                    l_parentController = [self.navigationController.viewControllers objectAtIndex:l_count - 3];
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:ENTER_OR_LEAVESTORE_RELOAD_STORE_LIST object:nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:END_STORE object:nil userInfo:nil];
            }
            
            [self.m_ParentViewController.navigationController popToViewController:l_parentController animated:YES];
            self.m_ParentViewController.navigationController.toolbarHidden = YES;

        }else
        {
            id l_parentController = [self.navigationController.viewControllers objectAtIndex:l_count-2];
            if ([l_parentController isKindOfClass:[WSWorkFlowViewController class]] && [self.currentFuncs.fv isEqualToString:@"V20S99"] && l_count >= 3 && _isBackAccrossParent) {
                
                if ([[self.navigationController.viewControllers objectAtIndex:l_count-3] isKindOfClass:[WSCustomerVistViewController class]]) {
                    l_parentController = [self.navigationController.viewControllers objectAtIndex:l_count-3];
                }else if (((WSBaseWorkFlowViewController *)l_parentController).backVC) {
                    l_parentController = ((WSBaseWorkFlowViewController *)l_parentController).backVC;
                } else if ([l_parentController isKindOfClass:[WSReportFormController class]]  && l_count >= 3 && _isBackAccrossParent) {
                    //                董宏  YIHAIKERRY-4686
                    l_parentController = [self.navigationController.viewControllers objectAtIndex:l_count-3];
                }else if ([[self.navigationController.viewControllers objectAtIndex:l_count-3] isKindOfClass:[WSSpecialAcvtListViewController class]]) {
                    //重新采集完成拜访跳转
                    l_parentController = [self.navigationController.viewControllers objectAtIndex:l_count-3];
                }
            }
            if([l_parentController isKindOfClass:[WSLeaveStoreAcvtViewController class]]&& [self.currentFuncs.fv isEqualToString:@"V20S99"] && l_count == 4){
                l_parentController = [self.navigationController.viewControllers objectAtIndex:l_count-3];

            }
            //MN-310 2018-02-05 isBackClick逻辑后期优化
            BOOL isNextJump = ([self isKindOfClass:[WSAcvtViewController class]] && !self.isBackClick) ? YES : NO;
            
            //MENGNIU-579 蒙牛项目需要去除 动画 yes 变为 no 2017-10-23-又改回原逻辑(需要演示 等后续碰方案修改)
            [self.navigationController popToViewController:l_parentController animated:YES];
            self.navigationController.toolbarHidden = YES;
            
            //MN-310 2018-02-05
            if ([l_parentController isKindOfClass:[WSNextStepFuncsViewController class]] && isNextJump) {
                
                // MN-998 此处加入对WSNextStepFuncsViewController的childVC是list类型的页面的判断逻辑，这种类型下不需要进行自动返回跳转，后期可扩展判断逻辑
                WSNextStepFuncsViewController *nextStepFuncsVC = (WSNextStepFuncsViewController *)l_parentController;
                
                BOOL isParentVCNeedBack = YES;
                
                for (UIViewController *vc in nextStepFuncsVC.childViewControllers) {
                    if ([vc isKindOfClass:[WSMV_LISTViewController class]]) {
                        isParentVCNeedBack = NO;
                        break;
                    }
                }
                if (isParentVCNeedBack)
                    [(WSNextStepFuncsViewController *)l_parentController backToParent];
            }
        }
        
        return YES;
    }
}


-(BOOL) insertUploadData:(NSString*)aPostDate
                     URL:(NSString*)aUrl 
                     MD5:(NSString*)aMd5 
                 IsPhoto:(BOOL)aIsPhoto
              NotifyName:(NSString*)aNotifyName

{
    
    return [[WSOffLineUploadTable sharedTable] insertUploadData:aPostDate URL:aUrl MD5:aMd5 IsPhoto:aIsPhoto NotifyName:aNotifyName];
    
}

-(BOOL) insertUploadMedia:(NSString *)aPostDate
                     Type:(NSString *)type
                      URL:(NSString *)aUrl
                      MD5:(NSString *)aMd5
                  IsPhoto:(BOOL)aIsPhoto
               NotifyName:(NSString *)aNotifyName
            photoFileName:(NSString *)photoFileName
{
    return [[WSOffLineUploadTable sharedTable] insertUploadMedia:aPostDate Type:type URL:aUrl MD5:aMd5 IsPhoto:aIsPhoto NotifyName:aNotifyName photoFileName:photoFileName];
    
}

- (void) disappearKeyBord
{
    if(self.m_CurrentInputView)
    {
        self.isModifyData = YES;
        
        if ([self.m_CurrentInputView respondsToSelector:@selector(resignFirstResponder)]) {
            [self.m_CurrentInputView performSelector:@selector(resignFirstResponder)];
        }
        
         WSFuncsBean_opt *funcs = self.currentFuncs.opt;
        if ([self.m_CurrentInputView isKindOfClass:[UITextField class]]) {
            
            UITextField *textField = self.m_CurrentInputView;
            
            if (textField.tag == MEMOTAG && textField.text.length > funcs.numMemo) {
                
                textField.text = [textField.text substringToIndex:funcs.numMemo];
                
                [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:[NSString stringWithFormat:@"%@:%ld", NSLocalizedString(@"input_digits_max", nil), (long)funcs.numMemo] tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
                
            }
            
        }

    }
}


-(void) addCancellOKButton:(id)aView
{
    if([aView isKindOfClass:[UITextField class]])
    {
        UITextField* l_tf = (UITextField*)aView;
        l_tf.inputAccessoryView = self.upKeyBoardView;
    }
    
    if([aView isKindOfClass:[UITextView class]])
    {
        UITextView* l_tv = (UITextView*)aView;
        l_tv.inputAccessoryView = self.upKeyBoardView;
    }
}

-(void)textWatcher:(id)sender
{
    self.m_CurrentInputView = sender;
}
//未测试
-(void)saveImageWithFileName:(NSString*)fileName Image:(NSData*)image
{
    [image writeToFile:[FileManager setPath:fileName] atomically:YES];
}


//未测试
-(NSData*)getImagebyImageName:(NSString*)fileName
{
    NSData* image = [NSData dataWithContentsOfFile:[FileManager setPath:fileName]];
    return image;    
}


- (void)showAlert:(NSString *)message{
//    NSString *UploadFailString = NSLocalizedString(@"fail_upload",nil);
    NSString *UploadFailString = NSLocalizedString(@"js_alert_title", nil);
    NSString *OkString = NSLocalizedString(@"confirm",nil);
    NSString *TryString = NSLocalizedString(@"retry", nil);
    
    BlockAlertView *l_alert = [BlockAlertView alertWithTitle:UploadFailString message:message];
    [l_alert setCancelButtonWithTitle:OkString block:nil];
    [l_alert addButtonWithTitle:TryString block:^{
        
    }];
    
    [l_alert show];
}


- (void)locationMe {
    
    DDLogInfo(@"使用通知方式获取定位回调");
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationFinished:) name:locationAddressManagerDidUpdatedFinishedNotification object:nil];
    [[WSLocationManager getInstance] startUpdatingLocationWithActive:YES];
}

- (void)locationFinished:(NSNotification *)sender
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:locationAddressManagerDidUpdatedFinishedNotification object:nil];
    
    NSDictionary *userInfo = [sender userInfo];
    NSError *error = [userInfo objectForKey:locationAddressManagerDidUpdatedFinishedNotificationErrorKey];
    WSLocationDescribe *tmpLocationDescribe = [userInfo objectForKey:locationAddressManagerDidUpdatedFinishedKey];
    
    if (error) {
        LogError(@"定位失败");
    }else{
        LogInfo(@"定位成功：aLocationDescribe=====%@",tmpLocationDescribe);
        if (tmpLocationDescribe.location && (tmpLocationDescribe.location.coordinate.longitude != 0 && tmpLocationDescribe.location.coordinate.latitude != 0)) {
            self.locationDescribe = tmpLocationDescribe;
            self.location = tmpLocationDescribe.location;
            self.isGpsReady = YES;
            
        }
    }
    
}

- (void)secondUpdateLocaiton {
    [[WSLocationManager getInstance] startUpdateUserLocationWithBlock:^(WSLocationDescribe *aLocationDescribe, NSError *error) {
        if (aLocationDescribe.location
            && (aLocationDescribe.location.coordinate.longitude != 0
                && aLocationDescribe.location.coordinate.latitude != 0)) {
                self.locationDescribe = aLocationDescribe;
                self.location = aLocationDescribe.location;
                self.isGpsReady = YES;
            }
    }];
}



-(BOOL)uploadVisitAction
{
    if (![self.currentFuncs.value isEqualToString:@"hideVisitedFlag"]) {
        
        LogInfo(@" %@,%@ uploadVisitAction ",self.currentVisitAction.title, self.currentFuncs.fc);
    
        if ([self parentForceToDone] == YES) {
            [self updateStoreVisitStaus:VisitStoreDone];
            [[WSInoutStoreTable sharedTable] forceUpdateLeaveStoreWithStore:self.currentStore
                                                              andOtherParam:self.model.md5 andParamType:EParameterType_VisitId];
            if([self.currentFuncs.opt.leaveModify isEqualToString:@"N"])
            {
                [[WSInoutStoreTable sharedTable] setForceLeaveStoreWithStore:self.currentStore];
            }
        }
        if (self.currentVisitAction) {
            
            return [self manageActionStatus:self.currentVisitAction];
        }
        
    }
    
    return YES;
}

- (void)loadStoreNameLabel {
    NSString *storeName = [self.currentStore getDisplayNameAndCode];
    if ([storeName length] > 0 && !self.isTabMode && ![self.currentFuncs.opt.isNeedShowStoreName isEqualToString:REQUIRED_N]) {
        
        UILabel *storeNameLabel=[[WSInsetLabel alloc]initWithFrame:CGRectMake(0, self.y_point, self.contentScrollView.width  , 44) andInsets:UIEdgeInsetsMake(0, 15, 0, 15)];
        storeNameLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        //    storeNameLabel.textAlignment = NSTextAlignmentCenter;
        storeNameLabel.textColor=[UIColor blackColor];
       
        UIColor *titleBgColor = self.currentFuncs.opt.subTitleBgColor ? [UIColor colorWithHexString:self.currentFuncs.opt.subTitleBgColor]: [UIColor colorForKey:@"GridHeaderBackgroundColor"];
        if (!titleBgColor) {
            titleBgColor = [UIColor colorWithRed:238.0/255.0 green:238.0/255.0 blue:238.0/255.0 alpha:1.0];
        }
        
        storeNameLabel.textColor = [UIColor colorWithHexString:@"7d7c7c"];
        storeNameLabel.backgroundColor =  titleBgColor;
        
        storeNameLabel.text = storeName;
        UIFont *storeNameFont = [UIFont fontWithName:@"PingFangSC-Medium" size:14];
        storeNameLabel.font = storeNameFont;
        storeNameLabel.numberOfLines=0;
        CGSize size = [storeName ws_sizeWithFont:storeNameFont constrainedToWidth:self.contentScrollView.width - 2 * k_LabelXOffset lineBreakMode:NSLineBreakByCharWrapping];
        if (size.height > 36 || size.height == 0) {
            storeNameLabel.frame = CGRectMake(0, self.y_point, self.contentScrollView.width - 2 , size.height);
            
        }
        self.storeNameLabel = storeNameLabel;
        [self.contentScrollView addSubview:storeNameLabel];
        self.y_point = self.storeNameLabel.height + self.y_point;
    }

}


-(void)addToolBar
{
    LogTrace();
    if (self.currentFuncs && !self.currentFuncs.readonly) {
        
        
        if (self.uploadButton == nil) {
            
            self.uploadButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageForName:@"icon_upload"] style:UIBarButtonItemStylePlain target:self action:@selector(upload)];
            
        }
    
        //上传按钮移至右上角
        NSMutableArray *barButtonArray = [NSMutableArray array];
        if(self.m_ParentViewController != nil)
        {
            
            NSArray *originBarButtonArray = self.m_ParentViewController.navigationItem.rightBarButtonItems;
            
            UIBarButtonItem* replaceButton=nil;
            for(UIBarButtonItem* barbutton in originBarButtonArray){
                if([barbutton.title isEqualToString:self.uploadButton.title]){
                    replaceButton=barbutton;
                    break;
                }
            }
            if (![originBarButtonArray containsObject:self.uploadButton]) {
                [barButtonArray addObject:self.uploadButton];
            }
            if (originBarButtonArray && [originBarButtonArray count] > 0) {
                [barButtonArray addObjectsFromArray:originBarButtonArray];
            }
            [barButtonArray removeObject:replaceButton];
            self.m_ParentViewController.navigationItem.rightBarButtonItems = barButtonArray;
            
        }
        else
        {
            NSArray *originBarButtonArray = self.navigationItem.rightBarButtonItems;
            UIBarButtonItem  *buttonItem = self.uploadButton;
            if (![originBarButtonArray containsObject:buttonItem]) {
                [barButtonArray addObject:buttonItem];
            }
            if (originBarButtonArray && [originBarButtonArray count] > 0) {
                [barButtonArray addObjectsFromArray:originBarButtonArray];
            }
            self.navigationItem.rightBarButtonItems = barButtonArray;
        }
        

    }
}

- (void)addFullScreenButton
{
    UIBarButtonItem *fullScreenButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageForName:@"fullscreen_btn.png"]
                                                                         style:UIBarButtonItemStylePlain
                                                                        target:self
                                                                        action:@selector(fullScreen)];
    NSMutableArray *barButtonArray = [NSMutableArray arrayWithObject:fullScreenButton];
    if(self.m_ParentViewController != nil)
    {
        NSArray *originBarButtonArray = self.m_ParentViewController.navigationItem.rightBarButtonItems;
        if (originBarButtonArray && [originBarButtonArray count] > 0) {
            [barButtonArray addObjectsFromArray:originBarButtonArray];
        }
        self.m_ParentViewController.navigationItem.rightBarButtonItems = barButtonArray;
    }
    else
    {
        NSArray *originBarButtonArray = self.navigationItem.rightBarButtonItems;
        if (originBarButtonArray && [originBarButtonArray count] > 0) {
            [barButtonArray addObjectsFromArray:originBarButtonArray];
        }
        self.navigationItem.rightBarButtonItems = barButtonArray;
    }
}

- (void)fullScreen
{
    self.isFullScreenMode = YES;
    self.originFrame = self.view.frame;
    self.originParentView = self.view.superview;
    self.originParentViewController = self.parentViewController;
    
    WSAppDelegate *delegate = (WSAppDelegate *)[UIApplication sharedApplication].delegate;
    UIViewController *rootViewController = delegate.window.rootViewController;
    
    if (rootViewController.presentedViewController) {
        rootViewController = rootViewController.presentedViewController;
    }
    
    self.tempBgView = [[UIView alloc] initWithFrame:rootViewController.view.bounds];
    self.tempBgView.backgroundColor = [UIColor clearColor];
    self.tempBgView.layer.zPosition = 200;
    [rootViewController.view addSubview:self.tempBgView];
    CGRect frame = [self.view.superview convertRect:self.view.frame toView:self.tempBgView];
    self.view.frame = frame;
//    self.view.layer.zPosition = 200;
    [self.tempBgView addSubview:self.view];
    [UIView animateWithDuration:0.5 animations:^{
        float y = IOS7_OR_LATER ? 20 : 0;
        self.view.frame = CGRectMake(0, y, self.tempBgView.width, self.tempBgView.height - y);
        [self.tempBgView setBackgroundColor:[UIColor whiteColor]];
    } completion:^(BOOL finished) {
        
        if (self.exitFullScreenButton == nil) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
            [button setTitle:NSLocalizedString(@"exit_full_screen", nil) forState:UIControlStateNormal];
            [button addTarget:self action:@selector(exitFullScreen) forControlEvents:UIControlEventTouchUpInside];
            UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
            [button addGestureRecognizer:panGesture];
            self.exitFullScreenButton = button;
        }
        
        [self setExitFullScreenBtnBgColor];
        [self setExitFullScreenBtnTransparent];
        self.exitFullScreenButton.frame = CGRectMake(self.view.width - 100, 0, 100, 50);
        [self.view addSubview:self.exitFullScreenButton];
    }];
}

- (void)exitFullScreen
{
    if (self.isFullScreenMode == NO) {
        return;
    }
    self.isFullScreenMode = NO;
    WSAppDelegate *delegate = (WSAppDelegate *)[UIApplication sharedApplication].delegate;
    UIViewController *rootViewController = delegate.window.rootViewController;
    CGRect frame = [self.originParentView convertRect:self.originFrame toView:rootViewController.view];
    
    [UIView animateWithDuration:0.5 animations:^{
        self.view.frame = frame;
        self.tempBgView.backgroundColor = [UIColor clearColor];
    } completion:^(BOOL finished) {
        [self.exitFullScreenButton removeFromSuperview];
        self.view.frame = self.originFrame;
        [self.originParentView addSubview:self.view];
        [self.originParentViewController addChildViewController:self];
        [self.tempBgView removeFromSuperview];
    }];
}

- (void)handlePan:(UIPanGestureRecognizer *)recognizer {
    CGPoint center = recognizer.view.center;
    CGPoint translation = [recognizer translationInView:self.view];
 
    recognizer.view.center = CGPointMake(center.x + translation.x, center.y + translation.y);
    
    [recognizer setTranslation:CGPointMake(0, 0) inView:self.view];
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        [self setExitFullScreenBtnBgColor];
    } else if (recognizer.state == UIGestureRecognizerStateEnded) {
        [self setExitFullScreenBtnTransparent];
    }
}


- (void)setExitFullScreenBtnBgColor {
    [self.exitFullScreenButton setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.5]];
}

- (void)setExitFullScreenBtnTransparent {
    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 3ull * NSEC_PER_SEC);
    dispatch_after(time, dispatch_get_main_queue(), ^{
        [self.exitFullScreenButton setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.3]];
    });
}

- (BOOL) isSupperChangedLocalPhoto
{
    if (self.currentStore && self.currentStore.Id)
    {
        //玛氏日本修改，原来的补录功能查询只需storeID，后来不知为何加入了md5,影响玛氏的功能，因为上传页面存的md5和acvt页面的md5肯定不一样，所以不可能查询出门店是否补录，故而先去掉md5。
        NSString *enterDateStr = [[WSCustomTimeTable sharedTable] queueCustomEnterDateWithStoreId:self.currentStore.Id withVisitId:nil];
        if (enterDateStr) {
            return YES;
        }
    }
    
    return NO;
}

-(void)addPictureWithSupperLocalPicture:(BOOL)isSupperLocalPicture
                    withMaxPhotoNnumber:(NSInteger)maxPhoto
{
    //拍照放在页面里面
    if (self.photoBrowseView == nil) {
        NSArray *imagePathArray = [self getImagePathFromDataBase];
        
        if (isSupperLocalPicture) {
            isSupperLocalPicture = [self isSupperChangedLocalPhoto];
        }
        
        WSPhotoBrowseView *photoView = [[WSPhotoBrowseView alloc]initWithFrame:CGRectMake(0, self.y_point, self.view.frame.size.width, PHOTO_PANEL_HEIGHT)
                                                                          funs:self.currentFuncs 
                                                                      withImageIDArray:imagePathArray
                                                                    withSupperLocalPic:isSupperLocalPicture
                                                                     withSupperHttpPic:NO
                                                                       withMaxPhotoNum:maxPhoto
                                                                        delegate:nil  
                                                                            align:nil
                                                                            withDisPlayMode:nil];

        photoView.delegate = self;
        photoView.viewController = self.m_ParentViewController ? self.m_ParentViewController : self;
        photoView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        photoView.currentStore = self.currentStore;
        self.photoBrowseView = photoView;
    }else {
        [self.photoBrowseView removeFromSuperview];
        CGRect rect = self.photoBrowseView.frame;
        rect.origin.y = self.y_point;
        self.photoBrowseView.frame = rect;
    }
    
    [self.contentScrollView addSubview:self.photoBrowseView];
    self.y_point += PHOTO_PANEL_HEIGHT + 15;
    
    self.contentScrollView.contentSize = CGSizeMake(self.view.bounds.size.width, self.y_point);
    
}

- (NSArray *)getImagePathFromDataBase
{
    return nil;
}

-(void)addGpsView
{
//    // 当前门店的经纬度
//    if (self.optMapViewY == 0) {
//        if (self.y_point == 0) {
//            self.y_point += SPACEHEIGTH;
//        }
//        self.optMapViewY = self.y_point;
//    }
//
//
//    if(self.mapView){
//        self.mapView = nil;
//    }
//
//    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(self.currentStore.latitude, self.currentStore.longitude);
//    self.mapView = [[WSMapView alloc] initWithFrame:CGRectMake(k_MapViewXOffset, self.optMapViewY, self.contentScrollView.width - 2*k_MapViewXOffset, k_MapViewHeight) storeCoordinate:coordinate storeId:self.currentStore.Id storeName:self.currentStore.name isCenterForStoreLocation:NO isShowAddress:YES];
//    self.mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
//    self.mapView.delegate = self;
//    [self.contentScrollView addSubview:self.mapView];
//
//    if (!self.isInitMapView) {
//        self.isInitMapView = YES;
//        self.y_point += k_MapViewHeight + SPACEHEIGTH;
//    }
//    self.contentScrollView.contentSize = CGSizeMake(self.view.bounds.size.width, self.optMapViewY + k_MapViewHeight + SPACEHEIGTH);
//    [self.mapView   locateCurrentLocation];
}

- (void)memoData:(id)sender
{
    [self.memoData setString:((UITextField*)sender).text];
}

-(BOOL)isPrepareShowOptView
{
    WSFuncsBean_opt* fb_opt = self.currentFuncs.opt;
    if (fb_opt.isGps!=nil && [fb_opt.isGps isEqualToString:REQUIRED_R]) {
        [self checkNetWorkStateAndAlert];
    }
    
    //显示的gps
    if(fb_opt.isGps != nil && ![fb_opt.isGps isEqualToString:REQUIRED_N]&&![fb_opt.isGps isEqualToString:REQUIRED_G])
    {
        return YES;
        
    }
    
    if(fb_opt.isPic != nil&&![fb_opt.isPic isEqualToString:REQUIRED_N])
    {
        return YES;
    }
    
    if( fb_opt.isMemo != nil && ![fb_opt.isMemo isEqualToString:REQUIRED_N] )
    {
        return YES;
    }
    
    //add by wangdongyan 03-21 for 在主管拜访内的技巧评估显示界面有label控件
    if (fb_opt.label != nil) {
        return YES;
    }
    
    if (self.currentFuncs.otherArray
        && [self.currentFuncs.otherArray count] > 0 ) {
        return  YES;
    }
    
    return NO;
}

-(void)addOptView
{
    WSFuncsBean_opt* fb_opt = self.currentFuncs.opt;
    /*
     GPS参数    
     G:隐藏
     O:显示
     R:显示并强制获取
     N:没有
     V:先隐藏拍照，获取GPS，如果30秒内取到了GPS，则无需拍照；否则，显示拍照按钮，并拍照
     */

    // 若 fb_opt.isGps为R，则检查网络
    if (fb_opt.isGps!=nil && [fb_opt.isGps isEqualToString:REQUIRED_R]) {
        [self checkNetWorkStateAndAlert];
    }
    
    // 若fb_opt.isGps为D，则检测当前位置与门店位置距离是否在500米范围内
    if (fb_opt.isGps  && [fb_opt.isGps isEqualToString:REQUIRED_D]) {
        /*先定位 上传时候检测*/
        [self locationMe];
    }
    

    //显示的gps
    if(fb_opt.isGps != nil && ![fb_opt.isGps isEqualToString:REQUIRED_N]&&![fb_opt.isGps isEqualToString:REQUIRED_G])
    {
        [self addGpsView];

    }
    //不显示的gps
    if(fb_opt.isGps != nil && [fb_opt.isGps isEqualToString:REQUIRED_G] && [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways)
    {
        [self locationMe];
    }
    
    
    if(fb_opt.isPic != nil&&![fb_opt.isPic isEqualToString:REQUIRED_N])
    {
        if (self.y_point == 0) {
            self.y_point = MAIN_CELL_PADDING;
        }
        if (![fb_opt.isGps isEqualToString:REQUIRED_V]) {
            [self addPictureWithSupperLocalPicture:fb_opt.isSupperLocalPhoto == 1
                               withMaxPhotoNnumber:fb_opt.maxPhoto];
        }
        else
        {
            if ([self respondsToSelector:@selector(addPhotoButtonWhenGPSNotReady)]) {
                [self performSelector:@selector(addPhotoButtonWhenGPSNotReady) withObject:nil afterDelay:30];
            }
        }
    }

    if( fb_opt.isMemo != nil && ![fb_opt.isMemo isEqualToString:REQUIRED_N] && fb_opt.isMemo.length>0)
    {
        id object=nil;
        if ([self isKindOfClass:[WSProdGrideViewController class]]) {
            
            NSString *srid = nil;
            if (self.currentStore
                && self.currentStore.storeAccessMode == WSStoreAccessModeSubEmp
                && self.currentStore.srid
                && [self.currentStore.srid length] > 0) {
                
                srid = [self.currentStore.srid copy];
            }
            
            NSArray* array= [[WSFptTable sharedTable] queryFptWithStoreId:self.currentStore.Id fc:self.currentFuncs.fc title:nil andSrid:srid];
            if(array.count>0){
                object=[array firstObject];
            }
        }else if ([self isKindOfClass:[WSDictGrideViewController class]]){
            NSArray* array= [[WSFdtTable sharedTable] queryFdtWithStoreId:self.currentStore.Id fc:self.currentFuncs.fc srid:self.currentStore.srid];
            if(array.count>0){
                object=[array firstObject];
            }
        }

        //        SFA-18168
        //        工作提醒备注回显上次拜访小结内容
        WSStoreInfoBeanArray *storeinfoBeans = [WSAppData getObjectbyKey:STOREINFOS];
        
        NSArray *pTypArray = nil;
        if (self.currentFuncs.filter && [self.currentFuncs.filter length] > 0) {
            pTypArray = [self.currentFuncs.filter componentsSeparatedByString:@","];
        }
        NSString *storeId = self.currentStore.Id ? self.currentStore.Id : self.currentSubEmpStore.Id;
       for (WSStoreInfoBean* f_storeInfo in storeinfoBeans.storeinfoArray) {
            if ([f_storeInfo.storeId isEqualToString:storeId] &&
               (pTypArray && [pTypArray containsObject:f_storeInfo.typ]))
            {
                //                SFA-18625 防止在本地修改的时候 本地填写被覆盖
                if(!object)
                {
                    object = f_storeInfo;
                }
                break;
            }
        }
        
        self.y_point = (self.y_point == 0) ? (self.y_point+SPACEHEIGTH) : self.y_point;
        _memoData = [[NSMutableString alloc]init ];
        
        WSHTextField* memo = [[WSHTextField alloc] initWithFrame:CGRectMake(k_LabelXOffset, self.y_point+10,  self.view.bounds.size.width - 2 * k_LabelXOffset, 35)];
//        memo.currentFuncs=self.currentFuncs;
        memo.m_isGride = NO;
        memo.tag = MEMOTAG;
        memo.returnKeyType = UIReturnKeyDone;
        memo.backgroundColor = [UIColor clearColor];
        [memo addTarget:self action:@selector(memoData:) forControlEvents:UIControlEventEditingDidEnd];
        NSString *photoString = NSLocalizedString(@"memo_max_length",nil);
        NSString* placeHolder = [NSString stringWithFormat:photoString,fb_opt.numMemo];
        memo.placeholder = placeHolder;
        [memo setBorderStyle:UITextBorderStyleRoundedRect];
        memo.delegate = self;
        memo.textAlignment=NSTextAlignmentLeft;
        memo.m_length=[NSString stringWithFormat:@"%d",fb_opt.numMemo];
        memo.m_type=COL_TYPTEXT;
        memo.font = [UIFont systemFontOfSize:UI_Font];
        
        if (object!=nil) {
            // 如果输入框的内容没有做修改 memoData将没有机会赋值 因此在此处给个默认值 此值未后台的数据 目的是 当没有做修改时  上传的事后台的原数据
            NSString *textStr = [object valueForKey:@"memo"];
            if (![textStr isEqualToString:@"null"] && textStr) {
                memo.text = textStr;
                if (self.memoData) {
                    self.memoData = [NSMutableString stringWithString:textStr];
                }
            }
        }
        
        [self.contentScrollView addSubview:memo];
        y_point += memo.frame.size.height +  SPACEHEIGTH;
    }
    
    //add by wangdongyan 03-21 for 在主管拜访内的技巧评估显示界面有label控件
    if (fb_opt.label != nil) {
        
        self.y_point = (self.y_point == 0) ? (self.y_point+SPACEHEIGTH) : self.y_point;
        UILabel *label=[[UILabel alloc]initWithFrame:CGRectMake(k_LabelXOffset, self.y_point,  self.view.bounds.size.width - 2 * k_LabelXOffset, 40)];
        label.tag=LABELTAG;
        label.backgroundColor=[UIColor clearColor];
        label.textAlignment=NSTextAlignmentLeft;
        label.textColor=[UIColor blackColor];
        label.layer.masksToBounds=YES;
        NSString *text = [fb_opt.label stringByReplacingOccurrencesOfString:@"\\n" withString:@"\r\n"];
        label.text= text;
        label.font = [UIFont systemFontOfSize:UI_Font];
        label.numberOfLines = 0;
        label.lineBreakMode = NSLineBreakByCharWrapping;
        CGSize size = [fb_opt.label ws_sizeWithFont:[UIFont systemFontOfSize:UI_Font] constrainedToWidth:self.view.bounds.size.width - 2 * k_LabelXOffset lineBreakMode:NSLineBreakByCharWrapping];
        label.frame = CGRectMake(k_LabelXOffset, self.y_point, size.width, size.height);
        
        
        CGFloat labelHeight = size.height;
        if ([fb_opt.label rangeOfString:@"\\n"].location != NSNotFound) {
            NSArray *sperates = [fb_opt.label componentsSeparatedByString:@"\\n"];
            for (NSInteger i = 0; i < [sperates count]; i++) {
                NSString *tmpStr = sperates[i];
                 CGSize size = [tmpStr ws_sizeWithFont:[UIFont systemFontOfSize:UI_Font] constrainedToWidth:self.view.bounds.size.width - 2 * k_LabelXOffset lineBreakMode:NSLineBreakByCharWrapping];
                
                labelHeight += size.height;
            }
            label.frame = CGRectMake(k_LabelXOffset, self.y_point, self.view.bounds.size.width - 2* k_LabelXOffset, labelHeight);
        }
        
        
        [self.contentScrollView addSubview:label];
        self.y_point+=labelHeight+SPACEHEIGTH;
    }
    
    // Add valide button
    if (fb_opt.isMore != nil && [fb_opt.isMore isKindOfClass:[NSString class]] && [fb_opt.isMore isEqualToString:@"R"]) {
        
        NSString *checkString = NSLocalizedString(@"cofco_check", nil);
        UIBarButtonItem *checkButton = [[UIBarButtonItem alloc] initWithTitle:checkString style:UIBarButtonItemStyleDone target:self action:@selector(checkDataComplete)];
        
        NSMutableArray *barArray = [[NSMutableArray alloc] initWithCapacity:8];
        if (self.toolbarItems) {
            [barArray addObjectsFromArray:self.toolbarItems];
        }
        [barArray addObject:checkButton];
        self.toolbarItems = barArray;
        
        
    }
}


//#pragma mark system method
-(id)initWithFuncs:(WSFuncsBean*)funcs
{
    // SFA-22331 后台会下发调查问卷信息，没有菜单 所以去掉空判断
    if(!funcs) {
        LogError(@"菜单为空，可能是个错误");
//        return nil;
    }
    
    self = [super init];
    if(self != nil)
    {
        [self createModel];
        self.model.currentFuncs = funcs;
        self.currentFuncs = funcs;
        self.y_point = 0;
        self.title = funcs.name;
        _datas = [[NSMutableArray alloc]init];
        _titles = [[NSMutableArray alloc]init];
        _colWidth = [[NSMutableArray alloc]init];
        _selectedDataDic = [[NSMutableDictionary alloc] init];
        _isExchangeAcvtModel = YES;
        
        return self;
    }
    return nil;
}
-(id)initWithFuncs:(WSFuncsBean *)funcs Store:(WSStoreBean*)store
{
    if(funcs==nil || store == nil)
        return nil;
    
    self = [self initWithFuncs:funcs];
    if(self != nil)
    {
        self.currentStore = store;
        
//        if (DEBUG_FOR_ACVT) {
            self.model.currentStore = store;
//        }
        
        return self;
    }
    return nil;
}

-(id)initWithFuncs:(WSFuncsBean *)funcs subEmpStore:(WSSubempstoreBean*)store
{
    if(funcs==nil || store == nil)
        return nil;
    
    self = [self initWithFuncs:funcs];
    if(self != nil)
    {
        self.currentSubEmpStore = store;
        
//        if (DEBUG_FOR_ACVT) {
            self.model.currentSubEmpStore = store;
//        }
        
        return self;
    }
    return nil;
}

-(id)initWithFuncs:(WSFuncsBean*)funcs Store:(WSStoreBean*)store subEmpStore:(WSSubempstoreBean *)subEmpStore {
    self = [self initWithFuncs:funcs Store:store];
    if (self != nil) {
        self.currentSubEmpStore = subEmpStore;
        return self;
    }
    return nil;
}

- (instancetype)initWithFuncs:(WSFuncsBean *)funcs Store:(WSStoreBean*)store acvtNewStore:(WSStoreBean *)acvtNewStore {
    self = [self initWithFuncs:funcs Store:store];
    if (self != nil) {
        self.acvtNewStore = acvtNewStore;
        if (acvtNewStore) {
            self.currentStore = acvtNewStore;
        }
        return self;
    }
    return nil;
}

- (void)createModel
{
    self.model = [[WSBaseModel alloc] init];
}


-(void)createMD5With:(NSDictionary*)param
{
    NSString* acvtId=nil;
    NSString* memo=nil;
    NSString* fc=nil;
    NSString* l_dateStr=nil;

    if([param objectForKey:ACVT_ID]){
        acvtId=[param objectForKey:ACVT_ID];
    }else if([self isKindOfClass:[WSAcvtViewController class]]){
        WSAcvtViewController* vc=(WSAcvtViewController*)self;
        acvtId=vc.m_currentAcvt.acvtId;
    }
    
    if([param objectForKey:FUNCS_FC]){
        fc=[param objectForKey:FUNCS_FC];
    }else{
        fc = [self.currentFuncs.submenu length] > 0 ? self.currentFuncs.submenu: self.currentFuncs.fc;
    }
    
    if([param objectForKey:@"memo"]){
        memo=[param objectForKey:@"memo"];
    }
    
    
    if([param objectForKey:@"l_dateStr"]){
        l_dateStr=[param objectForKey:@"l_dateStr"];
    }else{
        l_dateStr = [self getMD5Time];
    }
    
    NSString *tmpStoreId = self.currentStore.Id;
    if (self.currentStore && [self.currentStore isKindOfClass:[WSStoreBean class]] && self.currentStore.iStoreIdentify && self.currentStore.iStoreIdentify.length > 0) {
        tmpStoreId = self.currentStore.iStoreIdentify;
    }
    
    NSString *empId = [WSAppData getObjectbyKey:APPDATA_EMPID];
    
    if ([self isKindOfClass:[WSAcvtViewController class]]) {
        
        WSAcvtViewController *currentAcvt  = (WSAcvtViewController *)self;
        NSString *acvtNewStoreId = currentAcvt.currentNewStore.Id;
        if ([acvtNewStoreId isKindOfClass:[NSString class]] && [acvtNewStoreId length] > 0) {
            tmpStoreId = acvtNewStoreId;
        }
        // MSTD-7485 跟安卓统一调查问卷的 empId 用以下方式拼
        if (currentAcvt.submitempid) {
            NSString *appendEmpId = [NSString stringWithFormat:@"@%@", currentAcvt.submitempid];
            empId  = [empId stringByAppendingString:appendEmpId];
        }
    }
    
   
    if (self.currentSubEmpStore) {
        NSString *appendEmpId = [NSString stringWithFormat:@"@%@", self.currentSubEmpStore.Id];
        empId  = [empId stringByAppendingString:appendEmpId];
    }
    NSString *date = [WSCurrentTime getDateString];
    //    YIHAIKERRY-2947
    //    益海嘉里-深圳：门店拜访模块：竞品提报：输入信息后，点击返回按钮，提示保存，保存后所有产线竞品提报都显示刚输入的信息
    BOOL isSubAcvt = NO;
    WSAcvtModel *model = nil;
    if ( [self.model isKindOfClass:[WSAcvtModel class]]) {
        model = (WSAcvtModel *)self.model;
        isSubAcvt = model.isSubAcvt;
    }
//    MSTD-7880
//    调查问卷返回时嵌套问卷的问题md5保存方式优化
    NSString *parentQstCode = model.currentAcvtBean.parentQstCode;
    if (isSubAcvt && parentQstCode.length > 0 ) {
        fc = parentQstCode;
    }
    WSBaseStoreOtherDataObject *otherObject = [WSBaseStoreOtherDataDBService queryAcvtGenIdWithStoreId:self.currentStore.Id withFc:fc withAcvtId:acvtId withBizDate:date withEmpId:self.currentSubEmpStore.Id];
    
    if (self.currentFuncs.opt.isSaveData_back && otherObject.item3) {
        self.md5 = otherObject.item3;
    }else{
        self.md5 = [Md5Manager getMd5ByEmpId:empId
                                     sotreId:tmpStoreId
                                     bizDate:l_dateStr
                                    funcCode:fc
                                      acvtId:acvtId
                                        memo:memo];
    }

}


#pragma mark - View lifecycle

-(void)addFuncsOtherBeanView
{
    if(self.currentFuncs.otherArray == nil)
        return;
    int i = 0;
    
    for(WSFuncsBean_other* f_otherBean in self.currentFuncs.otherArray) {
        if([f_otherBean.tpy isEqualToString:OTHER_TPY_L])
        {
            UILabel* lable = [[UILabel alloc]initWithFrame:CGRectMake(k_LabelXOffset, self.y_point + 5, self.view.bounds.size.width - 2 * k_LabelXOffset, 30)];
            lable.backgroundColor=[UIColor clearColor];
            lable.textAlignment=NSTextAlignmentLeft;
            lable.font = [UIFont systemFontOfSize:UI_Font];
            lable.text =f_otherBean.name;
            lable.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            
            [self.contentScrollView addSubview:lable];
            self.y_point += kFuncsOtherTextFieldHeight + 15;
        }
        else if ([f_otherBean.tpy isEqualToString:OTHER_TPY_CHT]){
            UIFont *font = [UIFont systemFontOfSize:UI_Font];
            // WSValidateTextView 不能先 alloc 再设置frame 和 Qst，所以先用临时 TextView 计算文本框在不同字体下应当设置的高度 iPad iPhone 字体不同，高度应当不同
            UITextView *tempViewForGetHeight = [[UITextView alloc] init];
            tempViewForGetHeight.font = font;
            CGFloat twidth = self.view.bounds.size.width - 2 * k_LabelXOffset;
            CGSize fitSize =  [tempViewForGetHeight sizeThatFits:CGSizeMake(twidth, CGFLOAT_MAX)];
            CGFloat theight = fitSize.height;
            
            WSValidateTextView* i_textView = [[WSValidateTextView alloc] initWithFrame:CGRectMake(k_LabelXOffset, self.y_point + 5, twidth, theight) FuncsOther:f_otherBean];
            
            // add by xiajunling for MSTD-943 支持 memo1 - memo10 的 readonly 属性

            i_textView.m_length = f_otherBean.max;
            i_textView.currentFuncs=self.currentFuncs;
            i_textView.m_isGride = NO;
            i_textView.font = font;
            i_textView.tag = OTHER_TEXTFIELD_TAG+i;
            i_textView.returnKeyType = UIReturnKeyDone;
            i_textView.backgroundColor = [UIColor whiteColor];
//            [i_textView setBorderStyle:UITextBorderStyleRoundedRect];
            i_textView.layer.borderWidth = 1;
            i_textView.layer.borderColor = DETAIL_SEPERATE_LINE_COLOR.CGColor;
            i_textView.layer.cornerRadius = 3;
            i_textView.placeholder = f_otherBean.name;
            i_textView.textAlignment = NSTextAlignmentLeft;
            i_textView.delegate = self;
//            [i_textView addTarget:self
//                            action:@selector(textWatcher:)
//                  forControlEvents:UIControlEventEditingDidBegin];
            i_textView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            //            [self addCancellOKButton:i_textfield];
            [self.contentScrollView addSubview:i_textView];
            self.y_point += kFuncsOtherTextFieldHeight + 15;
        }
        else if ([f_otherBean.tpy isEqualToString:OTHER_TPY_T]) {
            UIFont *font = [UIFont systemFontOfSize:UI_Font];
          
            // WSValidateTextView 不能先 alloc 再设置frame 和 Qst，所以先用临时 TextView 计算文本框在不同字体下应当设置的高度 iPad iPhone 字体不同，高度应当不同
            UITextView *tempViewForGetHeight = [[UITextView alloc] init];
            tempViewForGetHeight.font = font;
            CGFloat twidth = self.view.bounds.size.width - 2 * k_LabelXOffset;
            CGSize fitSize =  [tempViewForGetHeight sizeThatFits:CGSizeMake(twidth, CGFLOAT_MAX)];
            CGFloat theight = fitSize.height;
            
            WSValidateTextView* i_textView = [[WSValidateTextView alloc] initWithFrame:CGRectMake(k_LabelXOffset, self.y_point + 5, twidth, theight) FuncsOther:f_otherBean];
            
            // add by xiajunling for MSTD-943 支持 memo1 - memo10 的 readonly 属性
            NSString * regex = @"^memo([1-9]|10)$";
            NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
            if(f_otherBean.col
               && [f_otherBean.col length] > 0
               && [pred evaluateWithObject:f_otherBean.col]
               && f_otherBean.readonly > 0){
                
                i_textView.userInteractionEnabled = NO;
            }
            i_textView.m_length = f_otherBean.max;
            i_textView.currentFuncs=self.currentFuncs;
            i_textView.m_isGride = NO;
            i_textView.font = [UIFont systemFontOfSize:UI_Font];
            i_textView.tag = OTHER_TEXTFIELD_TAG+i;
            i_textView.returnKeyType = UIReturnKeyDone;
            i_textView.backgroundColor = [UIColor whiteColor];
//            [i_textView setBorderStyle:UITextBorderStyleRoundedRect];
            i_textView.layer.borderWidth = 1;
            i_textView.layer.borderColor = DETAIL_SEPERATE_LINE_COLOR.CGColor;
            i_textView.layer.cornerRadius = 3;
            i_textView.placeholder = f_otherBean.name;
            i_textView.textAlignment = NSTextAlignmentLeft;
            i_textView.delegate = self;
//            [i_textView addTarget:self
//                            action:@selector(textWatcher:)
//                  forControlEvents:UIControlEventEditingDidBegin];
            
            i_textView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
//            [self addCancellOKButton:i_textfield];
            [self.contentScrollView addSubview:i_textView];
            self.y_point += kFuncsOtherTextFieldHeight + 15;
        }
        else if ([f_otherBean.tpy isEqualToString:OTHER_TPY_N]) {
            UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(k_LabelXOffset, self.y_point + 5, self.view.bounds.size.width - 2 * k_LabelXOffset, 30)];
            titleLabel.font = [UIFont systemFontOfSize:UI_Font];
            titleLabel.text = f_otherBean.name;
            [self.contentScrollView addSubview:titleLabel];
            self.y_point += titleLabel.height + 5;
            
            WSHTextField* i_textfield = [[WSHTextField alloc] initWithFrame:CGRectMake(k_LabelXOffset, self.y_point + 5, self.view.bounds.size.width - 2 * k_LabelXOffset, kFuncsOtherTextFieldHeight) FuncsOther:(f_otherBean) ];
        
            // add by xiajunling for MSTD-943 支持 memo1 - memo10 的 readonly 属性
            NSString * regex = @"^memo([1-9]|10)$";
            NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
            if(f_otherBean.col
               && [f_otherBean.col length] > 0
               && [pred evaluateWithObject:f_otherBean.col]
               && f_otherBean.readonly > 0){
                
                i_textfield.enabled = NO;
                i_textfield.placeholder = f_otherBean.name;
            }
            
            if (f_otherBean.value && [f_otherBean.value length] > 0) {
                i_textfield.m_value = f_otherBean.value;
                [self.expressionDictionary setObject:i_textfield forKey:i_textfield.m_value];
            }

//            i_textfield.currentFuncs=self.currentFuncs;
            i_textfield.font = [UIFont systemFontOfSize:UI_Font];
            i_textfield.tag = OTHER_TEXTFIELD_TAG+i;
            i_textfield.keyboardType = UIKeyboardTypeNumberPad;
            i_textfield.returnKeyType = UIReturnKeyDone;
            i_textfield.backgroundColor = [UIColor whiteColor];
            i_textfield.textAlignment = NSTextAlignmentLeft;
            [i_textfield setBorderStyle:UITextBorderStyleRoundedRect];
            i_textfield.delegate = self;
            [i_textfield addTarget:self
                            action:@selector(textWatcher:)
                  forControlEvents:UIControlEventEditingDidBegin];
            i_textfield.autoresizingMask = UIViewAutoresizingFlexibleWidth;
//            [self addCancellOKButton:i_textfield];
            [self.contentScrollView addSubview:i_textfield];
            self.y_point += kFuncsOtherTextFieldHeight + 15;
            
            if(f_otherBean.mdefault){
                i_textfield.text = f_otherBean.mdefault;
            }
        }
        else if([f_otherBean.tpy isEqualToString:OTHER_TPY_D])
        {
            UIButton* l_button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            [l_button setTitle:[WSCurrentTime getDateTime] forState:UIControlStateNormal];
            l_button.frame = CGRectMake(k_LabelXOffset, self.y_point, CGRectGetWidth(self.view.bounds) - k_LabelXOffset * 2, 40);
            l_button.tag = OTHER_BUTTON_TAG+i;
            [l_button addTarget:self action:@selector(selectTime) forControlEvents:UIControlEventTouchUpInside];
            l_button.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            [self.contentScrollView addSubview:l_button];
            self.y_point += 40;
        }
        else if([f_otherBean.tpy isEqualToString:OTHER_TPY_CS])
        {
            UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(k_LabelXOffset, self.y_point + 10, 20, 30)];
            titleLabel.font = [UIFont systemFontOfSize:UI_Font];
            titleLabel.text = f_otherBean.name;
            [titleLabel sizeToFit];
            [self.contentScrollView addSubview:titleLabel];
            
            UIButton    *option_btn = [UIButton buttonWithType:UIButtonTypeCustom];
            option_btn.tag = OTHER_BUTTON_TAG+i;
            [option_btn addTarget:self action:@selector(option_btn_clicked:) forControlEvents:UIControlEventTouchUpInside];
            
            // 根据qstType设置不同的图片 分为多选和单选
            UIImage *normal_img = [UIImage scaledImageForName:@"icn_nocheck" ofType:@"png"];
            [option_btn setImage:normal_img forState:UIControlStateNormal];
            [option_btn setImage:[UIImage scaledImageForName:@"icn_check" ofType:@"png"]forState:UIControlStateSelected];
            
            option_btn.frame = CGRectMake(titleLabel.right, titleLabel.top + (titleLabel.height - normal_img.size.height)/2.0   , normal_img.size.width, normal_img.size.height);
            
            [self.contentScrollView addSubview:option_btn];
            self.y_point += (titleLabel.frame.size.height +20.0f);

        }
        
        else if([f_otherBean.tpy isEqualToString:OTHER_TPY_C])
        {
            UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(k_LabelXOffset, self.y_point + 5, k_LabelXWidth, 30)];
            titleLabel.font = [UIFont systemFontOfSize:UI_Font];
            titleLabel.text = f_otherBean.name;
            [self.contentScrollView addSubview:titleLabel];
            
            self.y_point += (titleLabel.frame.size.height +20.0f);
            
            
            WSBaseDictsDBService *service = [[WSBaseDictsDBService alloc] init];
            NSArray* dictBeanArray = [service queryDictsForAcvtGridWithFilter:f_otherBean.filter];
            
            
            for (NSInteger optionIndex = 0; optionIndex < dictBeanArray.count; optionIndex++ )
            {
                // 选项名字 ...   TODO 这些代码应该封装  先完成测试后在重构    - Nemo
                WSDictBean* option_temp = [dictBeanArray objectAtIndex:optionIndex];
                NSString *optName = [NSString stringWithFormat:@"%@",option_temp.name];
                
                UILabel *optionNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(k_LabelXOffset, self.y_point, self.view.frame.size.width-k_LabelXOffset*4, 30)];
                optionNameLabel.font = [UIFont systemFontOfSize:UI_Font];
                optionNameLabel.adjustsFontSizeToFitWidth = YES;
                [optionNameLabel setTextColor:[UIColor blackColor]];
                [optionNameLabel setBackgroundColor:[UIColor clearColor]];
                [optionNameLabel setText:optName];
                optionNameLabel.numberOfLines=0;
                optionNameLabel.lineBreakMode=NSLineBreakByWordWrapping;
                [optionNameLabel sizeToFit];
                
                
                // 选项按钮 ...
                UIButton    *option_btn = [UIButton buttonWithType:UIButtonTypeCustom];
                [option_btn setTag:5000+optionIndex*10];
                [option_btn addTarget:self action:@selector(option_btn_clicked:) forControlEvents:UIControlEventTouchUpInside];
                
                // 根据qstType设置不同的图片 分为多选和单选
                NSString    *normal_img_name = [f_otherBean.tpy isEqualToString:QST_TYPE_C] ? @"icn_nocheck" : @"selected_no_radio";
                NSString    *seleted_img_name = [f_otherBean.tpy isEqualToString:QST_TYPE_C] ? @"icn_check" : @"selected_yes_radio";
                
                
                // 此处只保留一个图片的对象指针 因为下面要用其获取尺寸
                UIImage *normal_img = [UIImage scaledImageForName:normal_img_name ofType:@"png"];
                
                [option_btn setImage:normal_img forState:UIControlStateNormal];
                [option_btn setImage:[UIImage scaledImageForName:seleted_img_name ofType:@"png"] forState:UIControlStateSelected];
                float y_offset;
                float buttonLeft=60.0f;
                if( [[UIDevice currentDevice] userInterfaceIdiom]==UIUserInterfaceIdiomPad){
                    buttonLeft=80.0f;
                }
                y_offset = 4;
                option_btn.frame = CGRectMake((CGRectGetWidth(self.view.bounds))-buttonLeft, 40/2-normal_img.size.height/2+self.y_point + y_offset, normal_img.size.width, normal_img.size.height);
                
                option_btn.centerY=self.y_point+optionNameLabel.frame.size.height/2;
                
                option_btn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
                
                [self.contentScrollView addSubview:optionNameLabel];
                [self.contentScrollView addSubview:option_btn];
                self.y_point += 40;
                
            }
        }
        else if ([f_otherBean.tpy isEqualToString:OTHER_TPY_S]) {
            NSMutableArray *titleArray = [NSMutableArray arrayWithCapacity:[self.currentFuncs.otherArray count]];
            
            WSBaseDictsDBService *service = [[WSBaseDictsDBService alloc] init];
            NSArray *filterArray = [service queryDictsForAcvtGridWithFilter:f_otherBean.filter];
            for (WSDictBean *dict in filterArray) {
                [titleArray addObject: [[FUISingleSelectionSource alloc] initWithName:dict.name withId:dict.Id]];
            }
            
            if (titleArray && [titleArray count] > 0 ) {
                UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(k_LabelXOffset, self.y_point + 5, self.view.bounds.size.width - 2 * k_LabelXOffset, 30)];
                titleLabel.font = [UIFont systemFontOfSize:UI_Font];
                titleLabel.text = f_otherBean.name;
                [self.contentScrollView addSubview:titleLabel];
                self.y_point += titleLabel.height + 5;
                
                FUISingleSelectionListView *singleSListView = [[FUISingleSelectionListView alloc] initWithFrame:CGRectMake(k_LabelXOffset, self.y_point, self.view.bounds.size.width - 2 * k_LabelXOffset, 35)
                                                                                                     withKeyStr:f_otherBean.col
                                                                                            withListSourceArray:titleArray
                                                                                                withSelectedStr:f_otherBean.mdefault
                                                                                                      withBlock:^(NSString *key, NSInteger selectIndex, FUISingleSelectionSource *selectObject) {
                                                                                                          [self.selectedDataDic setObject:selectObject.sId forKey:key];
                                                                                                      }];
                if (f_otherBean.mdefault) {
                    [self.selectedDataDic setObject:f_otherBean.mdefault forKey:f_otherBean.col];
                }
                [self.contentScrollView addSubview:singleSListView];
                self.y_point += 40;
            }
        }
        else if ([f_otherBean.tpy isEqualToString:OTHER_TPY_R])
        {
            if (!self.radioViewArray) {
                self.radioViewArray = [NSMutableArray array];
            }
            [self addRadioElement:f_otherBean atIndex:[NSString stringWithFormat:@"%d",i]];
        }
        else if ([f_otherBean.tpy isEqualToString:OTHER_TPY_P])
        {
            if (self.photoTypeArray == nil)
            {
                self.photoTypeArray = [[NSMutableArray alloc] init];
            }
            if (f_otherBean.ds)
            {
                
                WSBaseDictsDBService *service = [[WSBaseDictsDBService alloc] init];
                NSArray *filterArray = [service queryDictsForAcvtGridWithFilter:f_otherBean.filter];
                
                WSPhotoTypeArrayItem *arrayItem = [[WSPhotoTypeArrayItem alloc] init];
                arrayItem.arrayID = f_otherBean.col;
                
                for (WSDictBean *db in filterArray)
                {
                    
                    WSPhotoTypeItem *item = [[WSPhotoTypeItem alloc] init];
                    item.typeID = db.Id;
                    item.typeName = db.name;
                    [arrayItem.photoTypeItemArray addObject:item];
                }
                
                [self.photoTypeArray addObject:arrayItem];
                
                WSFuncsBean_opt* fb_opt = self.currentFuncs.opt;
                if(fb_opt.isPic != nil&&![fb_opt.isPic isEqualToString:REQUIRED_N])
                {
                    self.navigationItem.rightBarButtonItem = nil;
                }
                
                CGFloat photoTypeViewHeight = [WSPhotoTypeView getViewHeightWithItemCount:[self.photoTypeArray count]];
                
                WSPhotoTypeView *photoTypeView = [[WSPhotoTypeView alloc] initWithFrame:CGRectMake(0, self.y_point, self.view.bounds.size.width, photoTypeViewHeight) andPhotoTypeArrayItem:arrayItem];
                photoTypeView.delegate = self;
                
                [self.contentScrollView addSubview:photoTypeView];
                
                self.y_point += photoTypeViewHeight;
                
            }
        }
        
        i++;
    }
    self.y_point += 5;
}

- (void)option_btn_clicked:(UIButton*)optionBtn
{
    // 反选
    [optionBtn setSelected:!optionBtn.isSelected];
}

-(void)selectTime
{
    WSPickerViewType pickerViewType = WSPickerViewTypeDate;
    
    WSPickerView *pickerView = [WSPickerView showPickerViewInWindowWithType:pickerViewType];
    
    __weak typeof(self) weakSelf = self;
    [pickerView setDidSelectBlock:^(NSObject *data, BOOL isOK) {
        if (!isOK) {
            return;
        }
        NSDate *date = (NSDate *)data;
        [weakSelf setDateContent:date];
    }];
}

// 此处index参数无用 为了兼容辉瑞商务的个性化（辉瑞商务重载了此方法）
- (void)addRadioElement:(id)sender atIndex:(NSString *)index {
    
    UIView *radioView = [[UIView alloc] initWithFrame:CGRectMake(0, self.y_point, self.view.bounds.size.width, k_RadioViewHeight)];
    [self.contentScrollView addSubview:radioView];
    // 标题
    WSFuncsBean_other * f_otherBean = (WSFuncsBean_other *)sender;
    UILabel *lable = [[UILabel alloc]initWithFrame:CGRectMake(k_LabelXOffset,5, self.view.bounds.size.width - 2 * k_LabelXOffset, 30)];
    lable.backgroundColor=[UIColor clearColor];
    lable.textAlignment=NSTextAlignmentLeft;
    lable.font = [UIFont systemFontOfSize:UI_Font];
    if (f_otherBean.name && [f_otherBean.name isKindOfClass:[NSString class]]) {
        lable.text =f_otherBean.name;
    }
    [radioView addSubview:lable];
    

    WSBaseDictsDBService *service = [[WSBaseDictsDBService alloc] init];
    NSArray *dictBeanArray = [service queryDictsForAcvtGridWithFilter:f_otherBean.filter];
    
    CGFloat labelYoffset= 40;
    NSMutableArray *optArray = [NSMutableArray array];
    
    if (dictBeanArray && [dictBeanArray count]>0) {
        
        for (NSInteger i = 0; i<[dictBeanArray count]; i++) {
            WSDictBean *currentBean = [dictBeanArray objectAtIndex:i];
            
            UILabel *yesLable = [[UILabel alloc]initWithFrame:CGRectMake(2*k_LabelXOffset,labelYoffset, radioView.frame.size.width/2, k_RadioLabelHeight)];
            yesLable.textAlignment=NSTextAlignmentLeft;
            yesLable.font = [UIFont systemFontOfSize:UI_Font];
            yesLable.text = currentBean.name;
            [radioView addSubview:yesLable];
            
            CGRect yesRect= CGRectMake(radioView.frame.size.width - k_RadioButtonWidth, labelYoffset +3, k_RadioButtonWidth, k_RadioButtonHeight);
            NSInteger tag = [currentBean.Id integerValue];
            WSRadioButton *radioButton = [self creatRadionButtonWithFrame:yesRect tag:tag];
            [radioView addSubview:radioButton];
            [optArray addObject:radioButton];
            labelYoffset +=k_LabelMargin;
        }
    }
    if ([optArray count] > 0) {
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithObject:optArray forKey:[NSString stringNotNilWithValue:f_otherBean.col]];
        [self.radioViewArray addObject:dictionary];
    }
    self.y_point += k_RadioViewHeight;
}

- (WSRadioButton *)creatRadionButtonWithFrame:(CGRect)rect tag:(NSInteger)rTag {
    WSRadioButton *radioButton = [WSRadioButton buttonWithType:UIButtonTypeCustom];
    radioButton.frame = rect;
    radioButton.tag = rTag;
    [radioButton addTarget:self action:@selector(radioButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [radioButton setImage:[UIImage scaledImageForName:@"selected_yes_radio" ofType:@"png"] forState:UIControlStateSelected];
    [radioButton setImage:[UIImage scaledImageForName:@"selected_yes_radio" ofType:@"png"]forState:UIControlStateHighlighted];
    [radioButton setImage:[UIImage scaledImageForName:@"selected_no_radio" ofType:@"png"] forState:UIControlStateNormal];
    return radioButton;
}



- (void)radioButtonPressed:(id)sender{
    WSRadioButton *clickRadio = (WSRadioButton *)sender;
    __block NSMutableDictionary *clickOptDic = nil;
    for (NSInteger i=0; i < [self.radioViewArray count]; i++) {
        NSMutableDictionary *tmpOptDic = [self.radioViewArray objectAtIndex:i];
        [tmpOptDic enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            NSMutableArray *radionOptArray = (NSMutableArray *)obj;
            if ([radionOptArray containsObject: clickRadio]) {
                clickOptDic = tmpOptDic;
            }
        }];
    }
    
    [clickOptDic enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSMutableArray *radioOptArray = (NSMutableArray *)obj;
        for (NSInteger i = 0; i < [radioOptArray count]; i++) {
            WSRadioButton *tmpRadio = [radioOptArray objectAtIndex:i];
            if ([tmpRadio isEqual:clickRadio]) {
                tmpRadio.selected = YES;
            } else {
                tmpRadio.selected = NO;
            }
        }
    }];

 }

- (void) resetMd5WithCustomDataStr:(NSString*) dataStr
{
    NSDictionary* md5Param=nil;
    if ([self respondsToSelector:@selector(md5Param)]) {
        md5Param = [self performSelector:@selector(md5Param)];
    }
    
    if (dataStr && dataStr.length > 0) {
        LogInfo(@"补录数据:%@", dataStr);
        if (md5Param) {
            NSMutableDictionary *tmp = [NSMutableDictionary dictionaryWithDictionary:md5Param];
            [tmp setObject:dataStr forKey:@"l_dateStr"];
            md5Param = tmp;
        }else {
            md5Param = [NSDictionary dictionaryWithObject:dataStr forKey:@"l_dateStr"];
        }
    }
    
    [self createMD5With:md5Param];
    
//    if (DEBUG_FOR_ACVT) {
        [self.model createMD5With:[self.model md5Param]];
//    }
}

-(NSDictionary*)md5Param
{
    NSMutableDictionary* md5Param = [NSMutableDictionary dictionary];
    
    if (self.currentVisitAction
        && self.currentVisitAction.module_fc
        && [self.currentVisitAction.module_fc length] > 0) {
        
        //module_fc 在门店拜访的列表中赋值并层层传递的，其他模块赋值最上层TB的fc。(门店列表赋值依据门店的类型是否计划内、计划外、新门店、动态搜索计划外）
        
//        if ([self.realParentFuncsCode length] > 0) {
//            [md5Param setValue:self.realParentFuncsCode  forKey:@"memo"];
//        }else {
//            [md5Param setValue:self.currentVisitAction.module_fc  forKey:@"memo"];
//        }
        
        // 补录数据查询需要传递module_fc
        NSString *enterDateStr = [[WSCustomTimeTable sharedTable] queueCustomEnterDateWithStoreId:self.currentStore.Id withParentFc:self.currentVisitAction.module_fc];
        if (enterDateStr) {
            LogInfo(@"补录数据:%@", enterDateStr);
            [md5Param setObject:enterDateStr forKey:@"l_dateStr"];
        }
    }
    

    
    return md5Param;
}


-(void)generateMd5 {
    if(!self.md5){
        NSDictionary* md5Param=nil;
        if ([self respondsToSelector:@selector(md5Param)]) {
            md5Param = [self performSelector:@selector(md5Param)];
        }
        [self createMD5With:md5Param];
        
    }
    (self.model).currentVisitAction = self.currentVisitAction;

    if (!self.model.md5) {
        [self.model createMD5With:[self.model md5Param]];
    }
}
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    [self generateMd5];
    self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    
    _expressionDictionary = [[NSMutableDictionary alloc] init];
    isUsingSysCamera = YES;
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.m_ParentViewController.navigationItem.rightBarButtonItem = nil;
    self.m_ParentViewController.toolbarItems = nil;

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1)
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
#endif
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    
    _photoDataDic = [[NSMutableDictionary alloc] init];
    self.contentScrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    self.contentScrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.contentScrollView.delegate = self;
    [self.view addSubview:self.contentScrollView];
    self.contentScrollView.clipsToBounds=NO;
    
    
//    self.upKeyBoardView=[[WSUpKeyBoardView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, UI_KEYBOARD_VIEW_HEIGHT)];
//    
//    UIButton* cButton=(UIButton*)[self.upKeyBoardView viewWithTag:98];
//    [cButton addTarget:self action:@selector(cancelButton:) forControlEvents:UIControlEventTouchUpInside];
//    UIButton* oButton=(UIButton*)[self.upKeyBoardView viewWithTag:100];
//    [oButton addTarget:self action:@selector(okButton:) forControlEvents:UIControlEventTouchUpInside];
//
//    
//    for(UIButton* button in self.upKeyBoardView.subviews){
//        switch (button.tag) {
//            case 99:
//                [button setTitle:NSLocalizedString(@"zoom_in", nil) forState:UIControlStateNormal];
//                break;
//            case 100:
//                [button setTitle:NSLocalizedString(@"complete", nil) forState:UIControlStateNormal];
//                break;
//            default:
//                break;
//        }
//    }
}

-(void)initializationBackItemAction
{
    if (self.currentFuncs && self.currentFuncs.isHomePageWillShow) {
        NSDictionary *mobileHomeDic = [WSAppData getObjectbyKey:MOBILEHOMEPAGE];
        if (mobileHomeDic) {
            NSString *readTimeStr = [mobileHomeDic objectForKey:MobileHomePageReadingTimeKey];
            [self backItemAction:nil target:nil withDelay:[readTimeStr intValue]];
            self.currentFuncs.isHomePageWillShow = NO;
        }
    }else {
        [self backItemAction:@selector(backAction) target:self];
    }
}

- (void)backAction
{
    [self backToParent];
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initializationBackItemAction];

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


-(void)dealloc
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(addPhotoButtonWhenGPSNotReady) object:nil];
}

- (void)addPhotoButtonWhenGPSNotReady
{
    if (!self.isGpsReady) {
        WSFuncsBean_opt* fb_opt = self.currentFuncs.opt;
        [self addPictureWithSupperLocalPicture:fb_opt.isSupperLocalPhoto == 1
                           withMaxPhotoNnumber:fb_opt.maxPhoto];
    }
}

- (void)addPhotoButtonWhenDistanceIsInvalid {
    WSFuncsBean_opt* fb_opt = self.currentFuncs.opt;
    [self addPictureWithSupperLocalPicture:fb_opt.isSupperLocalPhoto == 1
                       withMaxPhotoNnumber:fb_opt.maxPhoto];

}

#pragma mark NotificationHandler

- (void)applicationDidBecomeActive
{
}

//  收回键盘
- (void)makeKeybordDown
{
    
}

#pragma mark uitextfield delegate
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    
    [textField performSelector:@selector(selectAll:) withObject:nil afterDelay:0.0];
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    // 文件编辑结束 保留 <= m_length的字符串
    if ([textField isKindOfClass:[WSHTextField class]]) {
        WSHTextField *tempTextField = (WSHTextField *)textField;
        if ([tempTextField.m_type isEqualToString:COL_TYPTEXT]
            && tempTextField.m_length != nil){
            //去掉前后多余空格
             tempTextField.text = [tempTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            if ([tempTextField.text length] > [tempTextField.m_length intValue]) {
                tempTextField.text = [tempTextField.text substringToIndex:[tempTextField.m_length intValue]];
                
            }
        }
    }
    if (textField.text.length > 0) {
        _isValueChange = YES;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)limitedInputLength:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    
    if([textField isKindOfClass:[WSHTextField class]])
    {
        WSHTextField* i_tf = (WSHTextField*)textField;
        return [i_tf shouldReplacementString:string inRange:range];
    }
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    
    _isValueChange = YES;
    
    //删除符号
    if ([string length] == 0) {
        return YES;
    }
    
    if ([textField isKindOfClass:[WSHTextField class]]) {
        WSHTextField *view = (WSHTextField *)textField;
        return [view shouldReplacementString:string inRange:range];
    }
    
    BOOL l_isDellWith = [self textFielLimtedKindOfNumber:textField shouldChangeCharactersInRange:range replacementString:string];
    if(!l_isDellWith)
        return l_isDellWith;
    
    return YES;
    
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    if ( (!textField.text) || (![textField.text length]) ) {
        return YES;
    }
    
    if ([textField isKindOfClass:[WSHTextField class]]) {
        
        WSHTextField *wchTextField = (WSHTextField *)textField;
        if(wchTextField.m_type != nil && [wchTextField.m_type isEqualToString:COL_TYPNUM]) 
        {
            NSString *lastStr = [textField.text substringFromIndex:[textField.text length]-1];
            if ([lastStr isEqualToString:@"."] || [lastStr isEqualToString:@"-"]) {
                textField.text = [textField.text substringToIndex:[textField.text length]-1];
            }
        }
        if(wchTextField.m_type != nil && [wchTextField.m_type isEqualToString:COL_TYPNUM]) 
        {
            if ([wchTextField.text length] > 1) {
                NSString *firstStr=[textField.text substringToIndex:1];
                if ([firstStr isEqualToString:@"."]) {
                    NSString *string=[[NSString alloc]init ];
                    textField.text=[string stringByAppendingFormat:@"0%@",textField.text ];
                }
            }
        }
    }
        
    return YES;
}

#pragma mark  WSPhotoBrowserViewDelegate Methods
- (void)photoBrowseView:(WSPhotoBrowseView *)photoBrowseView didSelectImageId:(NSString *)imageId {
    if (!photoBrowseView.imageIDArray || !imageId) {
        return;
    }
    WSPhotoBrowserViewController *photoBrowser = nil;
//    if (photoBrowseView.isSupperHttpPhoto) {
//       photoBrowser = [[WSPhotoBrowserViewController alloc] initWithImageIDs:photoBrowseView.imageArray];
//    }
//    else {
        photoBrowser = [[WSPhotoBrowserViewController alloc] initWithImageIDs:photoBrowseView.imageIDArray];
    //}
  
    photoBrowser.delegate = photoBrowseView;
//    if (photoBrowseView.isSupperHttpPhoto) {
//         [photoBrowser gotoPage: [imageId intValue]];
//    }
//    else {
         [photoBrowser gotoPage:[photoBrowseView.imageIDArray indexOfObject:imageId]];
    
    photoBrowser.enableEdit=photoBrowseView.enableEdit;
    photoBrowser.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:photoBrowser animated:YES completion:nil];
}
        
#pragma mark - location manager delegate

- (void)cancelButton:(id)sender{
        [self disappearKeyBord];
}

- (void)okButton:(id)sender{
    
        [self disappearKeyBord];
}
        
//add By wangdongyan 2012-02-29 for 当点击更多按钮时隐藏图片
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if(self.m_ParentViewController != nil) {
        self.m_ParentViewController.navigationController.toolbarHidden = YES;
    }
    else {
        self.navigationController.toolbarHidden = YES;
    }

    [self exitFullScreen];
//    if (DEBUG_FOR_ACVT) {
        if ([WSDataSourceManager sharedInstance].currentActiveModel == self.model) {
            [WSDataSourceManager sharedInstance].currentActiveModel = nil;
        }
//    }
}

//add By wangdongyan 2012-02-29 for 当返回时显示已经拍过的图片
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.originalViewYPosition = [NSNumber numberWithFloat:self.view.frame.origin.y];
    
    if (self.isExchangeAcvtModel == YES) {
        [WSDataSourceManager sharedInstance].currentActiveModel = self.model;
    }
    
    [self showGPSOpenAlertIfNeed];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.isExchangeAcvtModel == YES) {
        [WSDataSourceManager sharedInstance].currentActiveModel = self.model;
    }
    if (!IOS11_OR_LATER) {
        if (self.isExchangeAcvtModel == YES) {
            [WSDataSourceManager sharedInstance].currentActiveModel = self.model;
        }
    }
    
    
    self.contentScrollView.contentSize = CGSizeMake(self.view.width, self.contentScrollView.contentSize.height);
    
    self.originalViewYPosition = [NSNumber numberWithFloat:self.view.frame.origin.y];
}

- (void)showDBErrorTipAndHidAllHud {

    [MBProgressHUD hideAllHUDsForView:kApplicationWinddow animated:YES];
    [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:NSLocalizedString(@"页面数据插入数据库失败，请重新上传", nil) tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
}


- (NSMutableDictionary *)getNetWorkStatus {
    NSMutableDictionary *newWorkDic = [NSMutableDictionary dictionary];
    NetworkStatus status = [[Reachability reachabilityForInternetConnection] currentReachabilityStatus];
    switch (status) {
        case NotReachable:
        {
            [newWorkDic setObject:@"0" forKey:NETWORK_VALID];
            [newWorkDic setObject:@"0" forKey:NETWORK_ENABLE_MOBILE];
            [newWorkDic setObject:@"0" forKey:NETWORK_ENABLE_WIFI];
            [newWorkDic setObject:@"" forKey:NETWORK_TYPE];
        }
            break;
            
        case ReachableViaWiFi:
        {
            [newWorkDic setObject:@"1" forKey:NETWORK_VALID];
            [newWorkDic setObject:@"0" forKey:NETWORK_ENABLE_MOBILE];
            [newWorkDic setObject:@"1" forKey:NETWORK_ENABLE_WIFI];
            [newWorkDic setObject:@"WIFI" forKey:NETWORK_TYPE];
        }
            break;
            
        case ReachableViaWWAN:
        {
            [newWorkDic setObject:@"1" forKey:NETWORK_VALID];
            [newWorkDic setObject:@"1" forKey:NETWORK_ENABLE_MOBILE];
            [newWorkDic setObject:@"0" forKey:NETWORK_ENABLE_WIFI];
            [newWorkDic setObject:@"MOBILE" forKey:NETWORK_TYPE];
        }
            break;
            
        default:
            break;
    }
    return newWorkDic;
}

- (void)setDateContent:(NSDate *)date {
    NSDateFormatter *formatter = [NSDateFormatter standardDateFormatter];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    UIButton* button = (UIButton*)[self.view viewWithTag:OTHER_BUTTON_TAG];
    [button setTitle:[NSString stringNotNilWithValue:[formatter stringFromDate:date]]
            forState:UIControlStateNormal];
}

#pragma mark path delegate
- (void)checkNetWorkStateAndAlert {
    Reachability *r =[Reachability reachabilityWithHostname:@"www.baidu.com"];
    switch ([r currentReachabilityStatus]) {
        case NotReachable:
        {
            NSString *title = NSLocalizedString(@"network_failure", nil);
            [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:title tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
        }
            break;
        case ReachableViaWWAN: {
            
        }
            break;
        case ReachableViaWiFi: {
        }
            break;
        default:
            break;
    }
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView;
{


}

#pragma mark WSMapViewDelegate Methods
- (void)mapView:(WSMapView *)mapView locationDescribe:(WSLocationDescribe *)locationDescribe {
    if (locationDescribe.location) {
        self.locationDescribe = locationDescribe;
        self.location = locationDescribe.location;
        self.isGpsReady = YES;
        self.gpsLabel.text=locationDescribe.detailAddress;
        
    } else {
        // 定位失败log
        LogInfo(@"locationDescribe.locationError---%@",locationDescribe.locationError);
    }
}

#pragma mark - 

- (BOOL)serverRedisWithOtherBean:(WSFuncsBean_other *)otherBean {
    BOOL serverRedis = YES;
    if (!otherBean.redis
        || (otherBean.redis && [otherBean.redis isEqualToString:@"0"])
        || (otherBean.redis && [otherBean.redis length] < 1)) {
        serverRedis = NO;
    }
    return serverRedis;
}

- (void) resetMapView
{
//    if (self.mapView) {
//        self.mapView.userInteractionEnabled = NO;
//        [self.mapView removeFromSuperview];
//        self.mapView = nil;
//        [self addGpsView];
//    }
}

- (void)clearMapData
{
//    if (self.mapView) {
//        [self.mapView removeFromSuperview];
//        self.mapView = nil;
//    }
}



- (BOOL)getVariableWithClass:(Class) myClass varName:(NSString *)name{
    if (name == nil) {
        return NO;
    }
    unsigned int outCount, i;
    Ivar *ivars = class_copyIvarList(myClass, &outCount);
    for (i = 0; i < outCount; i++) {
        Ivar property = ivars[i];
        NSString *keyName = [NSString stringWithCString:ivar_getName(property) encoding:NSUTF8StringEncoding];
        keyName = [keyName stringByReplacingOccurrencesOfString:@"_" withString:@""];
        if ([keyName isEqualToString:name]) {
            free(ivars);
            return YES;
        }
    }
    free(ivars);
    return NO;
}


///*新的插入数据库*/
//- (void)insertStoreVisitStatusToDb {
//    
//    NSString *func_code= nil;
//    if (self.moduleFC) {
//        func_code = self.moduleFC;
//    }
//    if(self.relate_sub_menu_code){
//        if (![func_code isEqualToString:self.relate_sub_menu_code]) {
//            func_code = self.relate_sub_menu_code;
//        }
//    }
//    
//    NSString *currentEmpdId = [WSAppData getObjectbyKey:APPDATA_EMPID];
//    NSString *subEmpId = self.currentSubEmpStore.Id;
//    NSString *empId = subEmpId?:currentEmpdId;
//    [[WSVisitStoreStatusTable shareInstance] insertStatusWithStore:self.currentStore funcCode:func_code empId:empId];
//}
//
//
//- (void)updateStoreVisitStaus {
//    /*用于记录门店拜访状态*/
//    NSString *func_code= nil;
//    if (self.moduleFC) {
//        func_code = self.moduleFC;
//    }
//    if(self.relate_sub_menu_code){
//        if (![func_code isEqualToString:self.relate_sub_menu_code]) {
//            func_code = self.relate_sub_menu_code;
//        }
//    }
//    
//    NSString *currentEmpdId = [WSAppData getObjectbyKey:APPDATA_EMPID];
//    NSString *subEmpId = self.currentSubEmpStore.Id;
//    NSString *empId = subEmpId?:currentEmpdId;
//    [[WSVisitStoreStatusTable shareInstance] updateStatusWithStoreId:self.currentStore.Id funcCode:self.moduleFC empId:empId];
//}

- (void)updateStoreVisitStaus:(NSString *)status{
    
    /*用于记录门店拜访状态*/
    NSString *func_code= nil;
    if (self.moduleFC) {
        func_code = self.moduleFC;
    }
    if(self.relate_sub_menu_code){
        if (![func_code isEqualToString:self.relate_sub_menu_code]) {
            func_code = self.relate_sub_menu_code;
        }
    }
    
    NSString *currentEmpdId = [WSAppData getObjectbyKey:APPDATA_EMPID];
    NSString *subEmpId = self.currentSubEmpStore.Id;
    if ([self isMemberOfClass:[WSAcvtViewController class]]) {
        WSAcvtViewController *acvtVC =(WSAcvtViewController *)self;
        subEmpId = acvtVC.submitempid;
    }
    
    NSString *empId = subEmpId?:currentEmpdId;
    
    WSStoreBean *storeBean = self.model.currentNewStore ? self.model.currentNewStore : self.currentStore;
    if (self.currentVisitAction.fromModuleName&&[self.currentVisitAction.fromModuleName isEqualToString:kHelpSales_Name]) {
        LogInfo(@"助销更新VisitStoreStatusTable状态，不更新status值，只更新from_module");
        if([self isKindOfClass: NSClassFromString(@"WSEnterStoreAcvtViewController")]){
            [[WSVisitStoreStatusTable shareInstance] updateStatusWithStore:storeBean funcCode:func_code empId:empId withStatus:status fromModule:kHelpSales_Name];
        }
        if([self isKindOfClass: NSClassFromString(@"WSLeaveStoreAcvtViewController")]){
            [[WSVisitStoreStatusTable shareInstance] updateStatusWithStore:storeBean funcCode:func_code empId:empId withStatus:status fromModule:kHelpSales_Complete_Name];
        }
        
    }else{
        [[WSVisitStoreStatusTable shareInstance] updateStatusWithStore:storeBean funcCode:func_code empId:empId withStatus:status];
    }

}

- (void)checkTextView:(WSValidateTextView *)textView {
    NSInteger maxLength = textView.m_length.integerValue;
    NSInteger number = [textView.text length];
    
    if (number > maxLength) {
        [textView resignFirstResponder];
        
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:NSLocalizedString(@"text_exceed_max_length", nil) tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
        
        
        textView.text = [textView.text substringToIndex:maxLength];
    }
    
}

#pragma mark - UITextViewDelegate
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([textView isKindOfClass:[WSValidateTextView class]]) {
        WSValidateTextView *validateTextView = (WSValidateTextView *)textView;
        
        [validateTextView.placeholderLabel setHidden:YES];
        [validateTextView performSelector:@selector(selectAll:) withObject:nil afterDelay:0.0];
    }
}

- (void)textViewDidChange:(UITextView *)textView {
    if ([textView isKindOfClass:[WSValidateTextView class]]) {
        WSValidateTextView *validateTextView = (WSValidateTextView *)textView;
        if (validateTextView.m_length && validateTextView.m_length > 0) {
            
            NSString *inputMode = [[self.nextResponder textInputMode]primaryLanguage];
            // 中日文输入法时联想文字可以输入
            if([inputMode isEqualToString:@"zh-Hans"] || [inputMode isEqualToString:@"ja-JP"]){
                UITextRange *selectedRange = [validateTextView markedTextRange];
                UITextPosition *position = [validateTextView positionFromPosition:selectedRange.start offset:0];
                if (!position){
                    [self checkTextView:validateTextView];
                }
            } else {
                [self checkTextView:validateTextView];
            }
        }
    }
    
    
    NSString *text = textView.text;
    CGSize size = [text ws_sizeWithFont:textView.font constrainedToWidth:textView.frame.size.width];
    CGFloat borderHeight  = (textView.contentInset.top
                             + textView.contentInset.bottom
                             + textView.textContainerInset.top
                             + textView.textContainerInset.bottom);
    
    CGFloat height = size.height + borderHeight;
    
    editChangeHeight = height - textView.height;
    if (!FLOAT_IS_EQUAL(editChangeHeight, 0)) {
        editingOffsetY = textView.frame.origin.y;
        [textView setFrame:CGRectMake(textView.frame.origin.x, textView.frame.origin.y, textView.frame.size.width, height)];
        
        // 重置当前页面其他控件的 frame
        for(UIView *view in self.contentScrollView.subviews) {
            CGRect frame = view.frame;
            if (frame.origin.y > editingOffsetY) {
                frame.origin.y += editChangeHeight;
                view.frame = frame;
            }
        }
        CGPoint offset = self.contentScrollView.contentOffset;
        offset.y += editChangeHeight;
        self.contentScrollView.contentOffset = offset;
        CGSize contentSize = self.contentScrollView.contentSize;
        contentSize.height += editChangeHeight;
        self.contentScrollView.contentSize = contentSize;
    }
}

@end
