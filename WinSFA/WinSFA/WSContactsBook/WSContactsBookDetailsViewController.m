//
//  WSContactsBookDetailsViewController.m
//  WinSFA
//
//  Created by yuanji on 2018/5/6.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import "WSContactsBookDetailsViewController.h"
#import "WSContactsBookGlobalDefinitions.h"
#import "WSContactsBookDetailsScrollView.h"
#import "WSContactsBookStoreDetailsScrollView.h"
#import "WSContactsBookTools.h"
#import "WSChartViewController.h"
#import "WSEMSDKManager.h"
#import "WSChartConst.h"
//===================================================================================================================================================================

#pragma mark - 通讯录详情视图管理器 延展(内部)
@interface WSContactsBookDetailsViewController ()

@property (nonatomic, strong) WSContactsBookDetailsScrollView *scrollView;          //滚动视图
@property (nonatomic, strong) WSContactsBookStoreDetailsScrollView *storeScrollView;//门店滚动视图

@end
//===================================================================================================================================================================

#pragma mark - 通讯录详情视图管理器 延展(工具)
@interface WSContactsBookDetailsViewController (Tools)

#pragma mark - 布局通讯录详情视图方法
- (void)layoutContactsBookDetails;

#pragma mark - 执行消息方法 phone:电话号码
- (void)executeMessage:(NSString *)phone;

#pragma mark - 执行电话方法 phone:电话号码
- (void)executePhone:(NSString *)phone;

@end
//===================================================================================================================================================================

#pragma mark - 通讯录详情视图管理器 延展(实现WSContactsBookDetailsScrollViewDelegate代理协议)
@interface WSContactsBookDetailsViewController (contactsBookDetailsScrollViewDelegate) <WSContactsBookDetailsScrollViewDelegate>

@end
//===================================================================================================================================================================

#pragma mark - 通讯录详情视图管理器 延展(实现WSContactsBookStoreDetailsScrollViewDelegate代理协议)
@interface WSContactsBookDetailsViewController (contactsBookStoreDetailsScrollViewDelegate) <WSContactsBookStoreDetailsScrollViewDelegate>

@end
//===================================================================================================================================================================

#pragma mark - 通讯录详情视图管理器
@implementation WSContactsBookDetailsViewController

#pragma mark - 获取scrollView方法
- (WSContactsBookDetailsScrollView *)scrollView
{
    if(_scrollView == nil)
    {
        _scrollView = [[WSContactsBookDetailsScrollView alloc] initWithFrame:CGRectZero];
        _scrollView.backgroundColor = [[WSContactsBookTools sharedManager] getContactsBookBgColor];
        _scrollView.interactiveDelegate = self;
    }
    return _scrollView;
}

#pragma mark - 获取storeScrollView方法
- (WSContactsBookStoreDetailsScrollView *)storeScrollView
{
    if(_storeScrollView == nil)
    {
        _storeScrollView = [[WSContactsBookStoreDetailsScrollView alloc] initWithFrame:CGRectZero];
        _storeScrollView.backgroundColor = [[WSContactsBookTools sharedManager] getContactsBookBgColor];
        _storeScrollView.interactiveDelegate = self;
    }
    return _storeScrollView;
}

#pragma mark - 重写viewDidLoad方法
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if(self.detailsType == WSContactsBookDetailsTypeStore)
    {
        [self.view addSubview:self.storeScrollView];
        WSContactsDetailInfo *data = [self.infoData.detailArray firstObject];
        self.storeScrollView.infoData = data;
    }
    else
    {
        [self.view addSubview:self.scrollView];
        self.scrollView.isHidePerInfo = (([self.optData.showStyle isEqualToString:@"hidePerInfo"] == YES) ? YES : NO);
        WSContactsDetailInfo *data = [self.infoData.detailArray firstObject];
        self.scrollView.infoData = data;
    }
}

#pragma mark - 重写viewWillLayoutSubviews方法
- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    [self layoutContactsBookDetails];
}

@end
//===================================================================================================================================================================

#pragma mark - 通讯录详情视图管理器 延展(工具)
@implementation WSContactsBookDetailsViewController (Tools)

#pragma mark - 布局通讯录详情视图方法
- (void)layoutContactsBookDetails
{
    if(self.detailsType == WSContactsBookDetailsTypeStore)
        self.storeScrollView.frame = self.view.bounds;
    else
        self.scrollView.frame = self.view.bounds;
}

#pragma mark - 执行消息方法 phone:电话号码
- (void)executeMessage:(NSString *)phone
{
    if (phone.length <= 0)
    {
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:NSLocalizedString(@"phone_no_set", nil) tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
        return;
    }
    
    if([[UIApplication sharedApplication] respondsToSelector:@selector(openURL:options:completionHandler:)])
    {
        NSString *num = [[NSString alloc] initWithFormat:@"sms://%@", phone];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:num] options:@{} completionHandler:nil];
    }
    else
    {
        NSString *num = [[NSString alloc] initWithFormat:@"sms://%@", phone];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:num]];
    }
}

#pragma mark - 执行电话方法 phone:电话号码
- (void)executePhone:(NSString *)phone
{
    if (phone.length <= 0)
    {
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:NSLocalizedString(@"phone_no_set", nil) tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
        return;
    }
    
    phone = [phone stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSURL *telUrl = [NSURL URLWithString:[NSString stringWithFormat:@"tel://%@", phone]];
    if ([[UIApplication sharedApplication] canOpenURL:telUrl]) {
        [[UIApplication sharedApplication] openURL:telUrl options:@{} completionHandler:nil];
    }
}

@end
//===================================================================================================================================================================

#pragma mark - 通讯录详情视图管理器 延展(实现WSContactsBookDetailsScrollViewDelegate代理协议)
@implementation WSContactsBookDetailsViewController (contactsBookDetailsScrollViewDelegate)

#pragma mark - 消息按键选择方法
- (void)messageButtonSelected:(NSString *)phone
{
    [self executeMessage:phone];
}

#pragma mark - 电话按键选择方法
- (void)phoneButtonSelected:(NSString *)phone
{
    [self executePhone:phone];
}

#pragma mark - 聊天按键选择方法
- (void)chatButtonSelected:(NSString *)chatCode name:(NSString *)name iconUrl:(NSString *)url
{
    if (chatCode.length <= 0)
    {
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:NSLocalizedString(@"load_data_failure", nil) tips:nil tapTarget:nil action:nil
                                 type:MBProgressHUDMessageTypeFailed];
        return;
    }

    //MN-1425 不能给自己发消息
    WSUserInfo *loginUserInfo = [[WSEMSDKManager sharedInstance] getUserInfo];
    if ([loginUserInfo.wschatID isEqualToString:chatCode])
    {
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:NSLocalizedString(@"send_message_self_error", nil) tips:nil tapTarget:nil action:nil
                                 type:MBProgressHUDMessageTypeFailed];
        return;
    }
    
    NSMutableDictionary *extDic = [[NSMutableDictionary alloc] initWithCapacity:4];
    NSString *nickname = [[WSEMSDKManager sharedInstance] getChatNickName];
    NSString *headImageUrl = [[WSEMSDKManager sharedInstance] getChatHeadImageLRL];
    [extDic setObject:((nickname.length > 0) ? nickname : @"") forKey:WS_MSG_fromChatrealName];
    [extDic setObject:((headImageUrl.length > 0) ? headImageUrl : @"") forKey:WS_MSG_fromChatHeadImgUrl];
    NSString *toChatUrl = @"";
    if (url.length > 0)
        toChatUrl = [WSHttpURLHelper getImageCompleteURL:url];
    [extDic setObject:toChatUrl forKey:WS_MSG_toChatHeadImgUrl];
    [extDic setObject:((name.length > 0) ? name : @"") forKey:WS_MSG_toChatrealName];
    // SFA-17284 安卓没有数据的地方传空字符串 SFA-17284 WS_MSG_toStoreId 不是门店 ID 的含义，是分类 ID
    [extDic setObject:WS_MSG_NO_STORE_VALUE forKey:WS_MSG_toStoreId];
    [extDic setObject:@"" forKey:WS_MSG_toStoreName];
    [extDic setObject:toChatUrl forKey:WS_MSG_toStoreUrl];
    
    NSString *jsonStr = [extDic JSONString];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:1];
    [dict setObject:jsonStr forKey:WS_MSG_protyKey];
    
    WSChartViewController *vc = [[WSChartViewController alloc]initWithConversationChatter:chatCode conversationType:EMConversationTypeChat extertDic:dict];
    vc.navigationItem.title = (name.length > 0) ? name : @"";
    vc.hidesBottomBarWhenPushed = YES;
    // SFA-17556 要传 store 信息
    WSStoreBean *store = [[WSStoreBean alloc] init];
    store.Id = WS_MSG_NO_STORE_VALUE;
    vc.store = store;
    [self.navigationController pushViewController:vc animated:YES];
}

@end
//===================================================================================================================================================================

#pragma mark - 通讯录详情视图管理器 延展(实现WSContactsBookStoreDetailsScrollViewDelegate代理协议)
@implementation WSContactsBookDetailsViewController (contactsBookStoreDetailsScrollViewDelegate)

#pragma mark - 消息按键选择方法
- (void)messageButtonSelected:(NSString *)phone
{
    [self executeMessage:phone];
}

#pragma mark - 电话按键选择方法
- (void)phoneButtonSelected:(NSString *)phone
{
    [self executePhone:phone];
}

@end
//===================================================================================================================================================================
