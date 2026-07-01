//
//  WSCommunicateViewController.m
//  WinSFA
//
//  Created by LIBB on 16/12/15.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSCommunicateViewController.h"
#import "WSSelectListNewTableviewCell.h"
#import "WSCharMessageCell.h"
#import "WSMsgData.h"
#import "WSEMSDKManager.h"
#import "WSChartViewController.h"
#import "WSChartConst.h"
#import "WSSearchBar.h"
#import "WSEmptySearchView.h"
#import "WSBaseAcvtdisDBService.h"
#import "WSEmptyViewCell.h"

#import "WSFuncsBeanArray.h"
#import "WSMultiTextViewController.h"


//=======================================================================================================================================================
@interface WSCommunicateViewController ()

@property (nonatomic, strong) WSEmptySearchView *emptySerchView;
@property (nonatomic, assign) BOOL viewIswillAppear;

@end
//=======================================================================================================================================================

@implementation WSCommunicateViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetUnreadNumber) name:WS_CHATNOTIFY_RESETUNREADNUMBER object:nil];
}

- (void)loadView
{
    [super loadView];
    self.isChatViewDidAppear=NO;
    self.dataArray=[[NSMutableArray alloc]init];
    self.filterArray=[[NSMutableArray alloc]init];
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1)
        self.edgesForExtendedLayout = UIRectEdgeNone;
#endif
    [self creatTableView];
}

- (void)addNOSeacrchResultView
{
    UIView *tableViewHeaderView = self.tableView.tableHeaderView;
    self.emptySerchView = [[WSEmptySearchView alloc] initWithFrame:CGRectMake(self.view.origin.x, self.view.bounds.origin.y + tableViewHeaderView.height, self.view.width, self.view.height - tableViewHeaderView.height)];
    self.emptySerchView.backgroundColor = [UIColor whiteColor];
    self.emptySerchView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.emptySerchView];
}

- (void)viewDidLayoutSubviews
{
   
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.viewIswillAppear = YES;
    [self initAllDataFromDb];
}

-(void)viewDidAppear:(BOOL)animated
{
    if(self.isChatViewDidAppear==YES)
    {
        self.isChatViewDidAppear=NO;
       [[NSNotificationCenter defaultCenter] postNotificationName:WS_CHATNOTIFY_RESETUNREADNUMBER object:nil];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    self.viewIswillAppear = NO;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - 重写HYPageViewButtonClickEvent方法
-(void)HYPageViewButtonClickEvent
{
    WSFuncsBeanArray *funcsArray = [WSAppData getObjectbyKey:FUNCS];
    WSFuncsBean *fb = [funcsArray getHideFuncsBeanWithFC:[self currentFuncs].opt.isAdd];//FAC_112
    
    UIViewController *vc = [[WSMultiTextViewController alloc] initWithFuncs:fb];
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)initAllDataFromDb
{
    [self.filterArray removeAllObjects];
    [self.dataArray removeAllObjects];

    NSString * userName=[[WSEMSDKManager sharedInstance] getLoginName];
    NSArray *conversations = [[EMClient sharedClient].chatManager getAllConversations];

    __weak typeof(self)weakSelf = self;
    for (EMConversation * obj in conversations)
    {
        EMMessage * myMsg=obj.latestMessage;
        if([myMsg.from isEqualToString:userName] || [myMsg.to isEqualToString:userName])
        {
            [obj loadMessagesStartFromId:nil count:1000 searchDirection:EMMessageSearchDirectionUp completion:^(NSArray *aMessages, EMError *aError) {

                NSMutableDictionary * storeIdAndEMMessageDic  = [NSMutableDictionary dictionary];// 门店id与消息的字典
                NSMutableDictionary * storeUnreadCountdict = [NSMutableDictionary dictionary];// 每个门店回话的未读数
                for (EMMessage * subMsg in aMessages)// 获取未读数
                {
                    // 把回话的id与门店id 拼接，区分一点多岗的情况
                    NSString * conversationId = subMsg.conversationId;
                    NSString * storeAndconversationId = [NSString stringWithFormat:@"%@_%@",[weakSelf getstoreIDwithMsg:subMsg],conversationId];
                    [storeIdAndEMMessageDic setValue:subMsg forKey:storeAndconversationId];
                    
                    if (!subMsg.isRead)
                    {
                        NSNumber * unReadCount = [storeUnreadCountdict objectForKey:storeAndconversationId];
                        NSInteger count = unReadCount.integerValue;
                        if (unReadCount.integerValue)
                            count ++ ;
                        else
                            count = 1;
                        [storeUnreadCountdict setValue:@(count) forKey:storeAndconversationId];
                    }
                }

                NSArray * storeIds = [storeIdAndEMMessageDic allKeys];
                for (NSString * storeId in storeIds)
                {
                    NSNumber * unReadCount = [storeUnreadCountdict objectForKey:storeId];
                    WSMsgData * msg = [weakSelf getLastMsgWith:[storeIdAndEMMessageDic objectForKey:storeId] andLastMessage:unReadCount.integerValue ];
                    
                    BOOL isReplace = NO;
                    NSInteger index;
                    for (int i = 0; i < weakSelf.filterArray.count; i++)
                    {
                        WSMsgData * tmpMsg = weakSelf.filterArray[i];
                      NSString * conversationId = tmpMsg.msConversationID;

                      NSString * storeAndconversationId =  [NSString stringWithFormat:@"%@_%@",tmpMsg.storeID,conversationId];
                        if ([storeId isEqualToString:storeAndconversationId])
                        {
                            isReplace = YES;
                            index = i;
                            break;
                        }
                    }
                    if (isReplace)
                        [weakSelf.filterArray replaceObjectAtIndex:index withObject:msg];
                    else
                        [weakSelf.filterArray addObject:msg];
                }
                
                if (weakSelf.viewIswillAppear)
                {
                    [weakSelf.tableView reloadData];
                    [weakSelf.tableView layoutIfNeeded];
                    [weakSelf.dataArray addObjectsFromArray:self.filterArray] ;
                }
            }];
        }
    }
    
    if ([conversations count] == 0) {
        // MN-275 空的时候不刷新，会导致切换标签后 WSEmptyViewCell 变小
        [self.tableView reloadData];
    }
    
}

-(void)searchDateForInputContent:(NSString *)storName
{
    [self.filterArray removeAllObjects];
    if (storName.length == 0)
    {
        [self.filterArray addObjectsFromArray:self.dataArray];
        return;
    }
    for (WSMsgData * data in self.dataArray)
    {
//        SFA-17363
//        SFA葵花药业--IOS端沟通→消息中搜索数据只能搜索店名
        if ([data.storeID containsString:storName] || [data.storeName containsString:storName] || [data.toChatName containsString:storName])
            [self.filterArray addObject:data];
    }
}

-(void)creatTableView
{
    UITableView* tv;
    tv= [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
    tv.backgroundColor = [UIColor whiteColor];
    tv.tableFooterView = [[UIView alloc] init];
    tv.backgroundView = nil;
    tv.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [tv setDelegate:self];
    [tv setDataSource:self];
    tv.tableHeaderView = [self getTableHeaderView];
    self.tableView = tv;
    [self.view addSubview:self.tableView];
    
    if (INTERFACE_IS_PAD)
        tv.backgroundColor = RGBCOLOR(246, 246, 246);

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 90000
    if ([self.tableView respondsToSelector:@selector(setCellLayoutMarginsFollowReadableWidth:)])
        self.tableView.cellLayoutMarginsFollowReadableWidth = NO;
#endif
}

- (UIView *)getTableHeaderView
{
    WSSearchBar *searchBar = [[WSSearchBar alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, 44.0) isResetTextField:NO isResetBackgroundColor:YES isTop:NO isNotAutoresizingFlexible:YES];
    self.ownSearchBar = searchBar;
    self.ownSearchBar.searchBar.delegate = self;
    self.ownSearchBar.backViewColor = [UIColor whiteColor];
    
    if(INTERFACE_IS_PAD)
    {
        CGRect rect=self.ownSearchBar.frame;
        rect.size.width/=2;
        //self.ownSearchBar.frame=rect;
        self.ownSearchBar.centerX=self.view.bounds.size.width/2;
        
        UIView* view;
        if(IOS7_OR_LATER)
        {
            self.ownSearchBar.searchBar.barTintColor=[UIColor clearColor];
            view = [self.ownSearchBar.searchBar.subviews objectAtIndex:0];
        }
        else
            view = self.ownSearchBar.searchBar;
        
        
        for (UIView *subview in view.subviews)
        {
            if ([subview isKindOfClass:NSClassFromString(@"UISearchBarBackground")])
                if (@available(iOS 13.0, *)) {
                                           subview.hidden = YES;
                                       } else {
                                           [subview removeFromSuperview];
                                       }
        }
    }
    self.ownSearchBar.searchBar.placeholder = NSLocalizedString(@"chat_search_hint", nil);
    return self.ownSearchBar;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return ((self.filterArray.count > 0) ? self.filterArray.count : 1);
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.filterArray.count > 0)
    {
        WSMsgData *msgData = self.filterArray[indexPath.row];
        
        static NSString *SimpleTableIdentifier = @"SimpleTableIdentifier";
        WSCharMessageCell * cell = [tableView dequeueReusableCellWithIdentifier:SimpleTableIdentifier];
//        SFA-17408
//        SFA葵花药业--IOS端沟通→消息列表中对人沟通和对店沟通展示头像问题
        BOOL isStore = [msgData.storeID isEqualToString:WS_MSG_NO_STORE_VALUE] > 0 ? NO : YES;
        if (cell == nil) {
            cell = [[WSCharMessageCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:SimpleTableIdentifier];
        }
        cell.isCornerRadius = !isStore;
        cell.msgData = msgData;
        return cell;
    }
    
    static NSString *EmptyViewCellIdentifier = @"concernsCelEmptyViewCellIdentifierlIdentifier";
    WSEmptyViewCell *emptyViewCell = [tableView dequeueReusableCellWithIdentifier:EmptyViewCellIdentifier];
    if(emptyViewCell == nil)
    {
        emptyViewCell = [[WSEmptyViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:EmptyViewCellIdentifier];
        [emptyViewCell setBackgroundColor:[UIColor whiteColor]];
        [emptyViewCell setAccessoryType:UITableViewCellAccessoryNone];
        [emptyViewCell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    
    [emptyViewCell setupEmptyViewCellFromFuncsBean:self.currentFuncs];
    return emptyViewCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.filterArray.count > 0)
    {
        WSMsgData *rowStore = [self.filterArray objectAtIndex:indexPath.row];
        return [WSCharMessageCell  heightForRowWithStore:rowStore cellWidth:self.tableView.width];
    }

    return CGRectGetHeight(tableView.bounds) - CGRectGetHeight(self.ownSearchBar.frame);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.filterArray.count <= 0)
        return;
    
    WSMsgData *msg=[self.filterArray objectAtIndex:indexPath.row];

    NSString *storeimage=@"";
    if(msg.storeImg && msg.storeImg.length>0)
        storeimage=msg.storeImg;
    
    NSString *storeName=@"";
    if(msg.storeName && msg.storeName.length>0)
        storeName=msg.storeName;
    
    NSString *local_ImageID=@"";
    if(msg.local_ImageID && msg.local_ImageID.length>0)
        local_ImageID=msg.local_ImageID;
    
    NSString *nickname=[[WSEMSDKManager sharedInstance]getChatNickName];
    if(nickname==nil || nickname.length<=0)
        nickname=@"";
    
    NSString *headImageUrl=[[WSEMSDKManager sharedInstance]getChatHeadImageLRL];
    if(headImageUrl==nil || headImageUrl.length<=0)
        headImageUrl=@"";
    
    NSString *storeID=@"";
    if(msg.storeID && msg.storeID.length>0)
        storeID=msg.storeID;
    
    NSString *tochatImage=@"";
    if(msg.toChatImg && msg.toChatImg.length>0)
        tochatImage=msg.toChatImg;
    
    NSString *tochatName=@"";
    if(msg.toChatName && msg.toChatName.length>0)
        tochatName=msg.toChatName;
    
    NSMutableDictionary * dict=[[NSMutableDictionary alloc]init];
    NSMutableDictionary * extDic=[[NSMutableDictionary alloc] init];
    [extDic setObject:storeimage forKey:WS_MSG_toStoreUrl];
    [extDic setObject:storeID forKey:WS_MSG_toStoreId];
    [extDic setObject:storeName forKey:WS_MSG_toStoreName];
    [extDic setObject:nickname forKey:WS_MSG_fromChatrealName];
    [extDic setObject:headImageUrl forKey:WS_MSG_fromChatHeadImgUrl];
    [extDic setObject:tochatImage forKey:WS_MSG_toChatHeadImgUrl];
    [extDic setObject:tochatName forKey:WS_MSG_toChatrealName];
    NSString * jsonStr=[extDic JSONString];
    [dict setObject:jsonStr forKey:WS_MSG_protyKey];

    WSChartViewController * wfvc=[[WSChartViewController alloc]initWithConversationChatter:msg.msConversationID conversationType:EMConversationTypeChat extertDic:dict];
    wfvc.isParentShowNavgation = self.navigationController.navigationBarHidden;
    WSStoreBean * store = [[WSStoreBean alloc] init];
    store.Id = storeID;
    store.name = storeName;
    wfvc.store = store;
    NSString *title = [storeName length] > 0 ? storeName : tochatName;
    wfvc.navigationItem.title = title;
    
    WSAppDelegate *delegate = (WSAppDelegate *)[UIApplication sharedApplication].delegate;
    UIViewController *rootViewController = delegate.window.rootViewController;

    if (rootViewController.presentedViewController)
        rootViewController = rootViewController.presentedViewController;
    
    if([rootViewController isKindOfClass:[UITabBarController class]])
    {
       wfvc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:wfvc animated:YES];
       
    }
    else
        [self.navigationController pushViewController:wfvc animated:YES];

    self.isChatViewDidAppear=YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:WS_CHATNOTIFY_RESETUNREADNUMBER object:nil];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    CGFloat headHeight = 0;
    if (!([[UIDevice currentDevice] systemVersionByFloat] < 7.0))
        headHeight = 1.0f;
    
    return headHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    CGFloat viewHeight  = 0;
    if (!([[UIDevice currentDevice] systemVersionByFloat] < 7.0)) {
        viewHeight = 1.0f;
    }
    UIView *headView = [[UIView alloc]init];
    [headView setFrame:CGRectMake(0,0, tableView.frame.size.width, viewHeight)];
    return headView;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    
}

- (void)didSelectStore:(WSStoreBean *)store  notification:(NSNotification *)notificaiton
{
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES animated:YES];
    
    for(UIView *cc in [searchBar subviews])
    {
        for (UIView *views in [cc subviews])
        {
            if([views isKindOfClass:[UIButton class]])
            {
                UIButton *btn = (UIButton *)views;
                NSString *CancelString = NSLocalizedString(@"cancel_label",nil);
                [btn setTitle:CancelString  forState:UIControlStateNormal];
                [btn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
                [btn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
                break;
            }
        }
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    searchBar.text=@"";
    [self.emptySerchView removeFromSuperview];
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
    [self initAllDataFromDb];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self searchDateForInputContent:searchBar.text];
    [self.tableView reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    [self searchDateForInputContent:searchBar.text];
    [self.emptySerchView removeFromSuperview];
    if (self.filterArray.count < 1 && searchBar.text.length >0) {
        [self addNOSeacrchResultView];
    }
    [self.tableView reloadData];
}

- (WSVisitStoreActionObject*) findActionIDAndCreateNextAction:(WSFuncsBean *)funcsBean
                                        andCurrentVisitAction:(WSVisitStoreActionObject *)currentAction
                                                   andStoreId:(NSString *)store_id
                                             subMenuFuncsCode:(NSString *)subMenuFuncsCode
{
    WSVisitStoreActionObject *action = [[WSVisitStoreActionObject alloc] init];
    action.parent_action_id = currentAction.ID;
    action.store_id = store_id;
    action.func_code = funcsBean.fc;
    action.biz_date = [WSAppData getObjectbyKey:APPDATA_BIZDATE];
    action.emp_id = [WSAppData getObjectbyKey:APPDATA_EMPID];
    action.title = funcsBean.name;
    
    NSString *moduleFC;
    if ([currentAction.module_fc length] > 0)
        moduleFC = currentAction.module_fc;
    else if([subMenuFuncsCode length] > 0)
        moduleFC = subMenuFuncsCode;
    else
        moduleFC = funcsBean.fc;
    
    action.module_fc = moduleFC;
    if (self.currentStore.mappingStoreListFV && [self.currentStore.mappingStoreListFV isEqualToString:@"TAB_V8003"])
        action.module_fc = self.currentStore.mappingStoreListFC;
    action.ID = (int)[[WSVisitStoreActionTable sharedTable] queryActionId:action];
    
    return action;
}

- (NSString *)latestMessageTimeForConversation:(EMConversation*)conversation
{
    NSString *latestMessageTime = @"";
    EMMessage *lastMessage = [conversation latestMessage];;
    if (lastMessage)
    {
        double timeInterval = lastMessage.timestamp ;
        if(timeInterval > 140000000000)
            timeInterval = timeInterval / 1000;
        
        NSDateFormatter* formatter = [NSDateFormatter standardDateFormatter];
        NSDate* lastDate= [NSDate dateWithTimeIntervalSince1970:timeInterval];
        [formatter setDateFormat:@"YYYY-MM-dd"];
        NSString *lastdateSMS = [formatter stringFromDate:lastDate];
        NSDate * cor_date=[NSDate date];
        NSString *dateNowSMS = [formatter stringFromDate:cor_date];
        if([dateNowSMS isEqualToString:lastdateSMS])
            [formatter setDateFormat:@"HH:mm"];
        else
            [formatter setDateFormat:@"YYYY-MM-dd"];

        latestMessageTime = [formatter stringFromDate:lastDate];
    }
    return latestMessageTime;
}

- (NSString *)latestMessageTimeForMsg:(EMMessage*)lastMsg
{
    NSString *latestMessageTime = @"";
    EMMessage *lastMessage = lastMsg;
    if (lastMessage)
    {
        double timeInterval = lastMessage.timestamp ;
        if(timeInterval > 140000000000)
            timeInterval = timeInterval / 1000;

        NSDateFormatter* formatter = [NSDateFormatter standardDateFormatter];
        NSDate* lastDate= [NSDate dateWithTimeIntervalSince1970:timeInterval];
        [formatter setDateFormat:@"YYYY-MM-dd"];
        NSString *lastdateSMS = [formatter stringFromDate:lastDate];
        NSDate * cor_date=[NSDate date];
        NSString *dateNowSMS = [formatter stringFromDate:cor_date];
        if([dateNowSMS isEqualToString:lastdateSMS])
            [formatter setDateFormat:@"HH:mm"];
        else
            [formatter setDateFormat:@"YYYY-MM-dd"];

        latestMessageTime = [formatter stringFromDate:lastDate];
        
    }
    return latestMessageTime;
}

-(void)resetUnreadNumber
{
    if(self.isChatViewDidAppear==YES)
        return;
    [self initAllDataFromDb];
}

-(NSString *)getstoreIDwithMsg:(EMMessage*)msg
{
    NSString *storeID=nil;
    NSString *lastjosnStr=[msg.ext objectForKey:WS_MSG_protyKey];
    NSDictionary *lastDic=[lastjosnStr objectFromJSONString];
    if(lastDic)
        storeID =[lastDic objectForKey:WS_MSG_toStoreId];

    return storeID;
}

-(BOOL)isInArray:(NSString*)storID
{
    for(WSMsgData * msg in self.filterArray)
    {
        if([msg.storeID isEqualToString:storID])
            return YES;
    }
    return NO;
}

-(WSMsgData *)getLastMsgWith:(EMMessage *)objmsg andLastMessage:(NSInteger)unReadCount
{
    WSMsgData * lastMsg= [[WSMsgData alloc] init];
    NSString * josnStr=[objmsg.ext objectForKey:WS_MSG_protyKey];
    NSDictionary * Dic=[josnStr objectFromJSONString];
    NSString * storeId = [Dic objectForKey:WS_MSG_toStoreId];
    NSString * storeImg = [Dic objectForKey:WS_MSG_toStoreUrl];
    
    BOOL isStore = [storeId isEqualToString:WS_MSG_NO_STORE_VALUE] ? NO : YES;
    if (isStore) {
        if (storeImg.length == 0) {
            storeImg = [[[WSBaseAcvtdisDBService alloc]init] queryStoreImageUrlWithStoreId:storeId imgType:WSStoreImgTypeSmall];
            storeImg = [WSHttpURLHelper getImageCompleteURL:storeImg];
        }
    } else {
        if (objmsg.direction == EMMessageDirectionSend) {
            storeImg = [Dic objectForKey:WS_MSG_toChatHeadImgUrl];
            lastMsg.toChatName = [Dic objectForKey:WS_MSG_toChatrealName];
        } else {
            storeImg = [Dic objectForKey:WS_MSG_fromChatHeadImgUrl];
            lastMsg.toChatName = [Dic objectForKey:WS_MSG_fromChatrealName];
        }
        lastMsg.toChatImg = storeImg;
    }
    lastMsg.msConversationID = objmsg.conversationId;
    lastMsg.storeName = [Dic objectForKey:WS_MSG_toStoreName];
    lastMsg.local_ImageID = @"";
    lastMsg.storeImg = storeImg;
    lastMsg.storeID = storeId;
    lastMsg.msgUnreadNum = unReadCount;
    
    
    lastMsg.msgType = objmsg.body.type;
    if(objmsg.body.type == EMMessageBodyTypeText)//文本
        lastMsg.msgContent = ((EMTextMessageBody*)(objmsg.body)).text;
    else if(objmsg.body.type == EMMessageBodyTypeImage)//图片
        lastMsg.msgContent = @"[图片]";
    else if(objmsg.body.type == EMMessageBodyTypeVoice)//语音
        lastMsg.msgContent = @"[语音]";
    
    lastMsg.msgTime = [self latestMessageTimeForMsg:objmsg];
    return lastMsg;
}

-(void)resetStoreUnreadNumber
{
}

@end
//=======================================================================================================================================================

