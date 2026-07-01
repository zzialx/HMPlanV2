//
//  WSChartViewController.m
//  WinSFA
//
//  Created by huzepei on 16/12/20.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSChartViewController.h"
#import "WSChartConst.h"
#import "WSServerIPList.h"
#import "NSDictionary+Additional.h"

@interface WSChartViewController () <EaseMessageViewControllerDelegate,EaseMessageViewControllerDataSource>

@end

@implementation WSChartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[EaseBaseMessageCell appearance] setSendBubbleBackgroundImage:[[UIImage imageNamed:@"qp_02.png"] stretchableImageWithLeftCapWidth:12 topCapHeight:12]];//设置发送气泡
    [[EaseBaseMessageCell appearance] setRecvBubbleBackgroundImage:[[UIImage imageNamed:@"qp_01.png"] stretchableImageWithLeftCapWidth:25 topCapHeight:12]];//设置接收气泡
    //[[EaseBaseMessageCell appearance] setSendBubbleBackgroundImage:[UIImage imageNamed:@"qp_02.png"]];
    //[[EaseBaseMessageCell appearance] setRecvBubbleBackgroundImage:[UIImage imageNamed:@"qp_01.png"]];
    
    [[EaseBaseMessageCell appearance] setAvatarSize:40.f];//设置头像大小
    [[EaseBaseMessageCell appearance] setAvatarCornerRadius:20.f];//设置头像圆角
    //[[EaseBaseMessageCell appearance] setMessageNameHeight:5];
    //[EaseBaseMessageCell appearance].bubbleMargin=UIEdgeInsetsMake(0, 0, 0, 0);
    
    self.tableView.backgroundColor=[UIColor colorWithRed:238.f/255.f green:239.f/255.f blue:241.f/255.f alpha:1];
    // Do any additional setup after loading the view.
    self.delegate=self;
    self.dataSource=self;
    [self.chatBarMoreView removeItematIndex:1];
    [self.chatBarMoreView removeItematIndex:3];
    [self.chatBarMoreView removeItematIndex:2];
    
    if (self.imageUrlArray) {
        for (NSString * image in self.imageUrlArray) {
            NSString * urlString = [WSHttpURLHelper getImageCompleteURL:image];
            NSString * imgUrlString = [NSString stringWithFormat:@"%@%@",PHOTO_WALL_IMAGE_URL_PREFIX,urlString];
             
            
            // SFA-22183 zhaodanyang
            NSDictionary *jsonDictionary = self.conversation.ext;
            NSString *jsonString = jsonDictionary[WS_MSG_protyKey];
            
            NSMutableDictionary *dictionary =[NSMutableDictionary dictionaryWithDictionary:[NSDictionary dictionaryWithJsonString:jsonString]];
            
            NSString *sourceFrom = dictionary[WS_MSG_SOURCENEEDNOTIFICATION] ? : nil;

            if (sourceFrom.length > 0) {
                
                [self didSendText:imgUrlString withExt:self.conversation.ext];
                
                [self changeSourceFromState];
            }

            else{
                [self sendTextMessage:imgUrlString];
            }
            
            
        }
    }

}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear: animated];
    UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(MAIN_BUTTON_WH, 0, MAIN_BUTTON_WH, 44)];
    
    [backBtn setBackgroundColor:[UIColor clearColor]];
    
    [backBtn setImage:[UIImage scaledImageForName:@"icon_back" ofType:@"png"] forState:UIControlStateNormal];
    
    //    [backBtn setImage:[UIImage imageForName:@"icon_back_press.png"] forState:UIControlStateHighlighted];
    
    [backBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *homeButtonItem = [[UIBarButtonItem alloc]initWithCustomView:backBtn];
    self.navigationItem.leftBarButtonItem=homeButtonItem;
    [self.navigationController setNavigationBarHidden:NO];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark
#pragma mark 按钮函数
- (void)backAction
{
   
    [self.navigationController setNavigationBarHidden:self.isParentShowNavgation];
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark
#pragma mark EaseMessageViewControllerDataSource

//具体样例：
- (id<IMessageModel>)messageViewController:(EaseMessageViewController *)viewController
                           modelForMessage:(EMMessage *)message
{
    //用户可以根据自己的用户体系，根据message设置用户昵称和头像
    id<IMessageModel> model = [[EaseMessageModel alloc] initWithMessage:message];
    NSString * store_josnStr=[self.conversation.ext objectForKey:WS_MSG_protyKey];
    NSDictionary * store_Dic=[store_josnStr objectFromJSONString];
    NSString * store_ID=[store_Dic objectForKey:WS_MSG_toStoreId];
    
    NSString * josnStr=[message.ext objectForKey:WS_MSG_protyKey];
    NSDictionary * Dic=[josnStr objectFromJSONString];
    NSString * msgstoreID=[Dic objectForKey:WS_MSG_toStoreId];
    
    // 这里的 storeID 实际上是 conversationID 必须传 storeID
    if([store_ID isEqualToString:msgstoreID]){
        
    }else {
        
        return nil;
    }

    [self changeSourceFromState];
    
    model.isMessageRead=NO;
    
    if(message.direction==EMMessageDirectionSend){
        //本方发送的消息
        model.avatarImage = [UIImage imageNamed:@"mrtx"];//默认头像
        model.avatarURLPath =[Dic objectForKey:WS_MSG_fromChatHeadImgUrl];//头像网络地址
        model.nickname = [Dic objectForKey:WS_MSG_fromChatrealName]; ;//用户昵称
        if(model.nickname==nil || model.nickname.length<=0){
           model.nickname=[[NSUserDefaults standardUserDefaults] objectForKey:WS_CHARTMODULE_USERNICKNAME];
        }
    }else{
        //本方接收的消息
        model.avatarImage = [UIImage imageNamed:@"mrtx"];//默认头像
        model.avatarURLPath =[Dic objectForKey:WS_MSG_fromChatHeadImgUrl];//头像网络地址
        model.nickname = [Dic objectForKey:WS_MSG_fromChatrealName]; ;//用户昵称
    }
    
    return model;
}


#pragma mark 改变 sourcFrom 状态
- (void) changeSourceFromState{
    
    NSDictionary *jsonDictionary = self.conversation.ext;
    NSString *jsonString = jsonDictionary[WS_MSG_protyKey];
    
    NSMutableDictionary *dictionary =[NSMutableDictionary dictionaryWithDictionary:[NSDictionary dictionaryWithJsonString:jsonString]];
    
    NSString *sourceFrom = dictionary[WS_MSG_sourceFrom];
    
    sourceFrom = [NSString stringWithFormat:WS_MSG_SOURCENOTNEEDNOTIFICATION];
    
    [dictionary setObject:sourceFrom forKey:WS_MSG_sourceFrom];
    
    NSString *jsonStr=[dictionary JSONString];
    
    NSMutableDictionary *dictionaryExt = [[NSMutableDictionary alloc]initWithCapacity:1];
    [dictionaryExt setObject:jsonStr forKey:WS_MSG_protyKey];
    
    self.conversation.ext = dictionaryExt;
}

#pragma mark


-(void)dealloc{
    NSLog(@"WSChartViewController");
}
@end
