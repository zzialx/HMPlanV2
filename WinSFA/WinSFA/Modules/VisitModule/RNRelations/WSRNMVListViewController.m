//
//  WSRNMVListViewController.m
//  WinSFA
//
//  Created by HZH on 16/11/1.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSRNMVListViewController.h"
//#import "RCTRootView.h"
//#import "YYModel.h"
//#import "WSFuncsBean.h"
//#import "WSBaseModel.h"
//#import "WSRNRelationData.h"
//#import "WSBaseFunsTable.h"
//#import "WSProdBeanArray.h"
//#import "UIView+Toast.h"


@implementation WSRNMVListViewController
//{
//    UIToolbar *_keyboardToolbar;
//}
//
//- (void)viewDidLoad {
//    [super viewDidLoad];
//    // Do any additional setup after loading the view.
//
//
//    if ([[UIDevice currentDevice] systemVersionLowerThan:@"7.0"])
//    {
//        BlockAlertView *alert = [BlockAlertView alertWithTitle:NSLocalizedString(@"系统版本太低", nil)  message:@"此功能只支持iOS 7.0以上的系统版本，请升级之后重试"];
//        [alert setCancelButtonWithTitle:NSLocalizedString(@"OK", nil) block:nil];
//        [alert show];
//    }else{
//
//        if ([self organizeDataString] == nil || [[self organizeDataString] isEqualToString:@""]) {
//            WSEmptyView *empty = [[WSEmptyView alloc] initWithFrame:self.view.bounds];
//            empty.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//
//            [self.view addSubview:empty];
//        }else{
//            [[WSRNRelationData sharedInstance] setDataJsonStr:[self organizeDataString]];
//
//            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(submitFormDataFinished:) name:@"submitFormDataFinished" object:nil];
//
//            [self addKeyboardNotificationObserver];
//
//            NSURL *jsCodeLocation;
//
//            // 打包环境
//            jsCodeLocation = [[NSBundle mainBundle] URLForResource:@"main" withExtension:@"jsbundle"];
//
//            // 模拟器环境
////            jsCodeLocation = [NSURL URLWithString:@"http://localhost:8081/index.ios.bundle?platform=ios&dev=true"];
//
//            // 真机测试需要替换本机的IP地址
////            jsCodeLocation = [NSURL URLWithString:@"http://192.168.6.110:8081/index.ios.bundle?platform=ios&dev=true"];
//
//
//            RCTRootView *rootView = [[RCTRootView alloc] initWithBundleURL:jsCodeLocation
//                                                                moduleName:@"winsfa_rn"
//                                                         initialProperties:nil
//                                                             launchOptions:nil];
//
//            rootView.frame = self.view.bounds;
//
////            UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"upload_label", nil)
////                                                                                   style:UIBarButtonItemStylePlain
////                                                                                  target:self
////                                                                                  action:@selector(saveData:)];
////            self.navigationItem.rightBarButtonItem = rightBarButtonItem;
//
//
//            [self.view addSubview:rootView];
//
//            _keyboardToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0,SCREEN_HEIGHT, SCREEN_WIDTH,44)];
//            UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 60, 7,50, 30)];
//            [button setTitle:@"complete"forState:UIControlStateNormal];
//            [button addTarget:self action:@selector(doneButton:) forControlEvents:UIControlEventTouchUpInside];
//            [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
//            [_keyboardToolbar addSubview:button];
//            _keyboardToolbar.hidden = YES;
//
//            [self.view addSubview:_keyboardToolbar];
//        }
//
//
//    }
//
//}
//
//- (void)saveData:(id)sender
//{
//    NSLog(@"saveData called!");
//    //添加 字典，可将要传递的参数通过key值设置传递
//    NSDictionary *dict =[[NSDictionary alloc] initWithObjectsAndKeys:@"hahaha",@"textOne", nil];
//    //创建通知
//    NSNotification *notification =[NSNotification notificationWithName:@"submitFormData" object:nil userInfo:dict];
//    //通过通知中心发送通知
//    [[NSNotificationCenter defaultCenter] postNotification:notification];
//
//}
//
//- (void)submitFormDataFinished:(NSNotification *)notification{
//    NSString *resultStr = notification.userInfo[@"result"];
//    NSLog(@"%@",resultStr);
//
//    if (resultStr != nil && ![resultStr isEqualToString:@""]) {
//        if ([resultStr isEqualToString:@"1"]) {
//            [kApplicationWinddow makeToast:@"upload_success"
//                        duration:1.0
//                        position:CSToastPositionCenter];
//            [UIView animateWithDuration:1.0 animations:^{
//                [self.navigationController popViewControllerAnimated:YES];
//            }];
//
//        }else{
//            [kApplicationWinddow makeToast:@"add_upload_queue"
//                        duration:1.0
//                        position:CSToastPositionCenter];
//
//            [UIView animateWithDuration:1.0 animations:^{
//                [self.navigationController popViewControllerAnimated:YES];
//            }];        }
//    }else{
//        [kApplicationWinddow makeToast:@"add_upload_queue"
//                    duration:1.0
//                    position:CSToastPositionCenter];
//
//        [UIView animateWithDuration:1.0 animations:^{
//            [self.navigationController popViewControllerAnimated:YES];
//        }];    }
//}
//
//// 组织要传
//- (NSString *)organizeDataString
//{
//    NSMutableDictionary *mDic = [[NSMutableDictionary alloc] init];
//
//    if (self.model) {
//        [mDic setObject:@1 forKey:@"result"];
//        NSString *serverUrlStr = @"";
//
//        serverUrlStr = [NSString stringWithFormat:@"%@", [WSPlistHelper valueForKey:kServerIP withPlistName:kConfilgFileName]];
//
//        [mDic setObject:serverUrlStr forKey:@"serverUrl"];
//        if (self.model.currentFuncs.opt.rn_url && self.model.currentFuncs.opt.rn_url.length > 0) {
//            [mDic setObject:self.model.currentFuncs.opt.rn_url forKey:@"urlParameter"];
//        }
//
//        if (self.model.currentFuncs.opt.rn_formcode && self.model.currentFuncs.opt.rn_formcode.length > 0) {
//            [mDic setObject:self.model.currentFuncs.opt.rn_formcode forKey:@"formcode"];
//        }
//
//        NSString *optStr = nil;
//
//        if (self.model.currentFuncs.opt) {
//             optStr = [self.model.currentFuncs.opt yy_modelToJSONString];
//        }
//
//        if (optStr && optStr.length > 0) {
//            [mDic setObject:optStr forKey:@"opt"];
//        }
//
//        if (!self.model.currentStore) {
//
//        }else{
//            if (!self.model.currentStore.Id) {
//                //            [mDic setObject:@"add" forKey:@"method"];
//            }else{
//                //            [mDic setObject:@"edit" forKey:@"method"];
//                [mDic setObject:self.model.currentStore.Id forKey:@"store_id"];
//            }
//        }
//
//
//        NSString *navString = [self getNavigateString];
//
//        [mDic setObject:navString forKey:@"navigate"];
//    }
//
//    NSString *dataStr = nil;
//
//    if (([mDic objectForKey:@"urlParameter"] == nil || [[mDic objectForKey:@"urlParameter"] isEqualToString:@""]) && ([mDic objectForKey:@"formcode"] == nil || [[mDic objectForKey:@"formcode"] isEqualToString:@""])) {
//        dataStr = @"";
//    }else
//        dataStr = [mDic yy_modelToJSONString];
//
//
//    return dataStr;
//}
//
//- (NSString *)getNavigateString
//{
//    WSBaseFunsObject *funcsBeanObject = [[[WSBaseFunsTable sharedTable] queryWithNames:@[@"fv",@"name"] ArgumentsValue:@[self.model.currentFuncs.fv, self.model.currentFuncs.name]] firstObject];
//    WSProdBeanArray *prodBeanArray = [WSAppData getObjectbyKey:PRODS];
//    NSString *seletedSerieId = [[self.currentStore.prodArray firstObject] pid];
//    __block NSMutableArray *selectedSerieProds = [NSMutableArray array];
//    if (prodBeanArray.prodArray) {
//        [prodBeanArray.prodArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//            WSProdBean *prodBean = (WSProdBean *)obj;
//            if (([seletedSerieId isEqualToString:prodBean.Id])) {
//                [selectedSerieProds addObject:prodBean];
//            }
//        }];
//    }
//
//    NSLog(@"funcsBeanObject.id = %@", funcsBeanObject.Id);
//    NSString *menuStr = [self getNavigateLevelInfoWithType:@"menu" andId:funcsBeanObject.Id];
//    NSString *storeStr = [self getNavigateLevelInfoWithType:@"store" andId:self.model.currentStore.Id];
//    NSString *dictitemStr = nil;
//    if ([selectedSerieProds count] > 0) {
//        WSProdBean *prodBean = (WSProdBean *)[selectedSerieProds objectAtIndex:0];
//        dictitemStr = [self getNavigateLevelInfoWithType:@"dictitem" andId:prodBean.brand];
//    }
//
//    if (dictitemStr && dictitemStr.length > 0) {
//
//    }else{
//        dictitemStr = [self getNavigateLevelInfoWithType:@"dictitem" andId:_dictItemStr];;
//    }
//
//    NSString *prodStr = [self getNavigateLevelInfoWithType:@"prod" andId:nil];
//
//    NSString *dataStr = [NSString stringWithFormat:@"[%@,%@,%@,%@]", menuStr, storeStr, dictitemStr, prodStr];
//    NSString *dataStr1 = [NSString stringWithString:[dataStr stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
//
//    return dataStr1;
//}
//
//- (NSString *)getNavigateLevelInfoWithType:(NSString *)type andId:(NSString *)lId
//{
//    NSMutableDictionary *mDic = [[NSMutableDictionary alloc] init];
//    NSMutableArray *mArray = [[NSMutableArray alloc] init];
//
//    [mDic setObject:type forKey:@"type"];
//    [mArray insertObject:[NSString stringWithFormat:@"{\"type\":\"%@\"", type] atIndex:0];
//    if (lId == nil || (lId != nil && [lId isEqualToString:@""])) {
////        mDic = [[NSMutableDictionary alloc] initWithObjectsAndKeys:type, @"type", nil];
//    }else{
//        [mDic setObject:lId forKey:@"id"];
//        [mArray insertObject:[NSString stringWithFormat:@"\"id\":\"%@\"}", lId] atIndex:1];
////        mDic = [[NSMutableDictionary alloc] initWithObjectsAndKeys:type, @"type", lId, @"id", nil];
//    }
//
//
//    NSString *dataStr = [mDic yy_modelToJSONString];
//
////    NSString *finalStr = @"";
////
////    if ([dataStr hasPrefix:@"{"]) {
////        finalStr = [dataStr stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@""];
////    }
////
////    if ([finalStr hasSuffix:@"}"]) {
////        finalStr = [finalStr stringByReplacingCharactersInRange:NSMakeRange(finalStr.length - 1, 1) withString:@""];
////    }
////
////    NSArray *tempArray = [finalStr componentsSeparatedByString:@","];
////
////    if ([tempArray count] > 1) {
////        NSString *tempStr = [tempArray objectAtIndex:0];
////        if ([tempStr rangeOfString:@"id"].location != NSNotFound) {
////            finalStr = [NSString stringWithFormat:@"%@,%@", [tempArray objectAtIndex:1], [tempArray objectAtIndex:0]];
////        }
////    }
////
////    finalStr = [NSString stringWithFormat:@"{%@}", finalStr];
//
//    return dataStr;
//}
//
//- (NSString*)dictionaryToJson:(id)sender
//
//{
//
//    NSError *parseError = nil;
//
//    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:sender options:NSJSONWritingPrettyPrinted error:&parseError];
//
//    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
//
//}
//
//- (void)addKeyboardNotificationObserver
//{
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShown:) name:UIKeyboardWillShowNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHidden:) name:UIKeyboardWillHideNotification object:nil];
//}
//
//- (void)removeKeyboardNotificationObserver
//{
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"keyboardWillShown" object:nil];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"keyboardWillHidden" object:nil];
//}
//
//#pragma mark - keyboard show and hiden
//-(void) keyboardWillShown:(NSNotification *) aNotification
//{
//    NSString *infoName = [aNotification name];
//    NSDictionary* info = [aNotification userInfo];
//    //kbSize即為鍵盤尺寸 (有width, height)
//    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;//得到鍵盤的高度
//    NSLog(@"hight_hitht:%f",kbSize.height);
//
//    if ([infoName isEqualToString:UIKeyboardWillShowNotification]) {
//            [_keyboardToolbar setFrame:CGRectMake(0, SCREEN_HEIGHT - kbSize.height - 44 - 64, SCREEN_WIDTH, 44)];
//            _keyboardToolbar.hidden = NO;
//    }
//}
//
//- (void)doneButton:(id)sender
//{
//    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
//
//}
//
//-(void)keyboardWillHidden:(NSNotification *) notif
//{
//    NSString *name = [notif name];
//    if ([name isEqualToString:UIKeyboardWillHideNotification]) {
//            _keyboardToolbar.hidden = YES;
//            [_keyboardToolbar setFrame:CGRectMake(0,SCREEN_HEIGHT, SCREEN_WIDTH,44)];
//    }
//}
//
//- (void)viewWillAppear:(BOOL)animated
//{
//    [super viewWillAppear:animated];
//
//    [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:NSLocalizedString(@"pull_to_refresh_refreshing_label", nil) tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeWaiting];
//}
//
//- (void)viewWillDisappear:(BOOL)animated
//{
//    [super viewWillDisappear:animated];
//
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"submitFormDataFinished" object:nil];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"submitFormData" object:nil];
//    [self removeKeyboardNotificationObserver];
//    [MBProgressHUD hideHUDForView:kApplicationWinddow animated:NO];
//}
//
////- (void)viewDidDisappear:(BOOL)animated
////{
////    [super viewDidDisappear:animated];
////
////    [[NSNotificationCenter defaultCenter] removeObserver:self];
////}
//
//- (void)didReceiveMemoryWarning {
//    [super didReceiveMemoryWarning];
//    // Dispose of any resources that can be recreated.
//}
//
///*
//#pragma mark - Navigation
//
//// In a storyboard-based application, you will often want to do a little preparation before navigation
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    // Get the new view controller using [segue destinationViewController].
//    // Pass the selected object to the new view controller.
//}
//*/

@end
