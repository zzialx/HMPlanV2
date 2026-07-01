//
//  WSMultiTextViewController.m
//  WinSFA
//
//  Created by wanghaipeng on 2018/5/24.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import "WSMultiTextViewController.h"
#import "WSAcvtListViewController.h"
#import "WSAcvtScrollView.h"
#import "WSAcvtView.h"
#import "WSTreeListPanel.h"
#import "WSEMSDKManager.h"
#import "WSChartConst.h"

@interface WSMultiTextViewController ()<UIScrollViewDelegate>

@property (nonatomic, strong) WSAcvtScrollView *scrollView;
@property (nonatomic, strong) WSAcvtView  *acvtview;
@property (nonatomic, strong) WSTreeListPanel *tmpTrpanel;
@property (nonatomic, assign) NSUInteger smsNumCount;
@property (nonatomic, strong) NSMutableArray *selectDataArray;
@property (nonatomic, copy)   NSString *contxtStr;


@end

@implementation WSMultiTextViewController

-(id)initWithFuncs:(WSFuncsBean*)funcs
{
    if(funcs == nil)
        return nil;
    self = [super init];
    if(self)
    {
        self.currentFuncs = funcs;
        self.smsNumCount = 0;
        self.selectDataArray = [[NSMutableArray alloc] init];
        self.contxtStr = [[NSString alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)loadView
{
    [super loadView];
    
    if (![self isFuncsBeanValid]) {
        return;
    }
    
    self.view.backgroundColor = [UIColor grayColor];
    
    [self addTabBarRightView];
    
    WSFuncsBean *funbean = self.currentFuncs;
    NSArray* l_acvtFilters = [WSAcvtListViewController filterAcvtListWithCurrentFuncs:funbean withCurrentStore:self.currentStore];
    
    
    WSAcvtBean *newAddAcvtBean = nil;
    
    if( l_acvtFilters.count >= 1 ) {
        
        newAddAcvtBean = [l_acvtFilters firstObject];
        
        self.title = [newAddAcvtBean acvtName];
        
        CGFloat titleHeight = 50.0;
        _scrollView = [[WSAcvtScrollView alloc] initWithFrame:CGRectMake(0, titleHeight, SCREEN_WIDTH, SCREEN_HEIGHT) andAcvtBean:newAddAcvtBean];
        _scrollView.delegate = self;
        _scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        
        self.acvtview = _scrollView.acvtView;
        [self.acvtview buildDisplayContent];
        [self.view addSubview:_scrollView.acvtView];
        
    }
}

- (void)addTabBarRightView
{
    UIBarButtonItem *buttonItem = [self barButtonItemTitle:NSLocalizedString(@"send_mass_chat", nil) target:self action:@selector(rightButtonItemClick)];
    self.navigationItem.rightBarButtonItem = buttonItem;
}

- (void)rightButtonItemClick{
    
    //先判断网络是否可用
    if (![self checkNetWorkStateAndAlert]) {
        NSString *title = NSLocalizedString(@"network_failure", nil);
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:title tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
        return;
    }
    
    for (WSWidget *widget  in  self.acvtview.widgetArray) {
        
        if ([[widget.xbuildInfo getWidgetId] isEqualToString:@"T"]) {
            self.contxtStr = (NSString *)[widget getResultDirectly];
            if (!self.contxtStr || [self.contxtStr isEqualToString:@""]) {
                [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:NSLocalizedString(@"content_can_not_impety", nil) tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
                return;
            }
            
        }else if([widget isKindOfClass:[WSTreeListPanel class]]){
            
            NSString *tmpStr = (NSString *)[widget getResultDirectly];
            if (!tmpStr || [tmpStr isEqualToString:@""]) {
                [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:NSLocalizedString(@"please_select_user", nil) tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
                return;
            }
            NSArray *tmpArr = [tmpStr componentsSeparatedByString:@","];
            if (tmpArr.count > 30) {
                [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:NSLocalizedString(@"beyond_limit", nil) tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
                return;
            }
            
            self.tmpTrpanel = (WSTreeListPanel *)widget;
            NSArray *dataArray =  self.tmpTrpanel.dataArray;
            for (NSString *selectItemID in tmpArr) {
                for (NSObject<I_W_Cell> *subempStoreBean in dataArray) {
                    if ([selectItemID isEqualToString:[subempStoreBean getId]]) {
                        [self.selectDataArray addObject:subempStoreBean];
                    }
                }
            }
            LogError(@"%@",self.selectDataArray);
        }
    }
    [self startPackagSmsData];
    
}

- (void)startPackagSmsData{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

        for (int i = 0; i < self.selectDataArray.count; i ++ ) {

            WSSubempstoreBean *subObject = [self.selectDataArray objectAtIndex:i];
            if (subObject.detailArray.count > 0) {

                WSDetailInfo *info = [subObject.detailArray objectAtIndex:0];

                NSString *hxCode = info.hxCode != nil ? info.hxCode:@"";
                NSString *name = info.name != nil ? info.name:@"";

                NSString * nickname = [[WSEMSDKManager sharedInstance] getChatNickName];
                if(nickname == nil || nickname.length <= 0) nickname = @"";
                NSString * headImageUrl = [[WSEMSDKManager sharedInstance]getChatHeadImageLRL];
                if(headImageUrl == nil || headImageUrl.length <= 0) headImageUrl = @"";
                NSString * toChartHeadURL = @"";
                if(info.headPhoto && info.headPhoto.length > 0) toChartHeadURL = [WSHttpURLHelper getImageCompleteURL:info.headPhoto];

                NSDictionary *pramDic = @{ WS_MSG_fromChatHeadImgUrl:headImageUrl,WS_MSG_fromChatrealName:nickname,WS_MSG_toStoreId:WS_MSG_NO_STORE_VALUE,WS_MSG_toChatrealName:name,WS_MSG_toChatHeadImgUrl:toChartHeadURL,WS_MSG_toStoreName:@""};
                NSString *parmJson = [pramDic JSONString];
                NSDictionary *extDic = @{WS_MSG_protyKey:parmJson};

                if ([hxCode isEqualToString:[[EMClient sharedClient] currentUsername]]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:NSLocalizedString(@"can_not_send_self", nil) tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
                    });
                }else{
                    [self sendMsgTest:hxCode context:self.contxtStr withExt:extDic andInfor:subObject];
                }

            }else{
                [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:NSLocalizedString(@"send_message_fail", nil) tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
                LogError(@"没有详情数据！");
            }
        }

    });
}

- (void)sendMsgTest:(NSString *)hxCode context:(NSString *)conText withExt:(NSDictionary *)extDic andInfor:(WSSubempstoreBean *)infoBean{
    
    EMTextMessageBody *body = [[EMTextMessageBody alloc] initWithText:conText];
    NSString *from = [[EMClient sharedClient] currentUsername];
    
    //生成Message, 其中hxCode是自己设置的消息的接收方
    EMMessage *message = [[EMMessage alloc] initWithConversationID:hxCode from:from to:hxCode body:body ext:extDic];//e102111
    message.chatType = EMChatTypeChat;
    self.smsNumCount ++;
    [self back];
    [[EMClient sharedClient].chatManager sendMessage:message progress:^(int progress) {
    } completion:^(EMMessage *message, EMError *error) {
        if (!error)
        {
            EMMessage *aMessage =  message;
            LogError(@"---%d---",aMessage.status);
        }else{
            LogError(@"发送的消息错误原因---%@",error);
        }
    }];
    
}

// 返回
- (void)back{
    if (self.smsNumCount == self.selectDataArray.count) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:NSLocalizedString(@"send_message", nil) tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
            [self.navigationController popViewControllerAnimated:YES];
        });
    }
}

- (BOOL)isFuncsBeanValid {
    WSFuncsBean *funbean = self.currentFuncs;
    if (funbean == nil && funbean.filter == nil) {
        return NO;
    } else {
        return YES;
    }
}

#pragma mark path delegate
- (BOOL)checkNetWorkStateAndAlert {
    Reachability *r =[Reachability reachabilityWithHostname:@"www.baidu.com"];
    if ([r currentReachabilityStatus] == NotReachable) {
        return NO;
    }
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
