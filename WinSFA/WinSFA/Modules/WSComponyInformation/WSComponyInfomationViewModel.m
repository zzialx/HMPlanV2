//
//  WSComponyInfomationViewModel.m
//  WinSFA
//
//  Created by zzialx on 2024/1/23.
//  Copyright © 2024 WinChannel. All rights reserved.
//

#import "WSComponyInfomationViewModel.h"
#import "WSSNShowView.h"
#import "WSMsgBeanArray.h"
#import "WSBaseMsgTypeTable.h"
#import "WSFuncsBeanArray.h"
#import "WSMsgsBean.h"
#import "WSMsgsBean_msg.h"
#import "WSComponyInfomationManager.h"

static NSString *const title = @"消息提醒";
static NSString *const msg_fv = @"TAB_V1002";
//====================================================================================================================================

@interface WSComponyInfomationViewModel ()

@property (nonatomic, strong) UIViewController *cuurentVC;
@property (nonatomic, copy) NSString *openUrl;

@end
//====================================================================================================================================

@implementation WSComponyInfomationViewModel

- (void)showComponyInfomationAlertViewWithVC:(UIViewController *)vc {
    
    self.cuurentVC = vc;
    [self showComponyInfomationAlertView];
}

- (void)showComponyInfomationAlertView {
    
    LogInfo(@"显示公司公告消息---->");
    [[WSComponyInfomationManager sharedInstance] setIsShowComponyInfo:NO];
    
    NSArray *unReadMsgList = [self getAllMsgArrayData];
    if (unReadMsgList.count == 0) {
        LogError(@"没有未读的公告信息显示");
        return;
    }
    
    [[WSComponyInfomationManager sharedInstance] setIsShowComponyInfo:YES];

    [WSSNAlertView showEmptyInView:kApplicationWinddow part:^WSSNShowViewPart * _Nonnull {
        
        return [WSSNShowViewPart shared].setTitle(title).setSubtitle(@"").setinfoArray(unReadMsgList);
    }
                            config:^WSSNShowViewConfig * _Nonnull {
        
        UIColor *color = [UIColor colorWithRed:49 / 255.0f green:234 / 255.0f blue:0 / 255.0f alpha:1];
        return [WSSNShowViewConfig shared].setSubtitleFont([UIFont systemFontOfSize:15.0]).setSubtitleColor(UIColor.redColor).setButtonColor(color);
    }
                          callback:^(WSSNAlertView *view, UIButton *button,NSString * msgIds) {
        
        LogInfo(@"未读消息ids：%@",msgIds);
        [self p_pushMessageDetailsWithMsgIds:msgIds];
    }];
}





#pragma mark - # push消息详情
- (void)p_pushMessageDetailsWithMsgIds:(NSString*)msgIds{
    
    WinJSBridgeViewController *vc = [[WinJSBridgeViewController alloc] init];
    vc.externalOpenUrl = self.openUrl;
    vc.hidesBottomBarWhenPushed = YES;
    vc.externalInfoDic = @{Win_JSBridge_URL_Replacing_MSGID_Mark : msgIds};
    if(self.cuurentVC.navigationController){
        [self.cuurentVC.navigationController pushViewController:vc animated:YES];
    }
    
}

#pragma mark - # 获取消息列表
- (NSArray*)getAllMsgArrayData{

    WSFuncsBeanArray *funcsArray = [WSAppData getObjectbyKey:FUNCS];
    WSFuncsBean * currentFuncs = [funcsArray getFuncsBeanWithFV:msg_fv];
    if(currentFuncs){
        self.openUrl = currentFuncs.opt.jumpUrlLink;
    }
    NSArray * msgTypeList = [[WSBaseMsgTypeTable sharedTable] queryBaseMsgType];
    //过滤出来公司公告类型的消息
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"cod == %@",currentFuncs.opt.searchTag];
    if ([currentFuncs.opt.searchTag containsString:@","]) {
        NSString * params = [self getPredicateWithParams:currentFuncs.opt.searchTag];
        predicate = [NSPredicate predicateWithFormat:@"cod in %@ ",params];
    }
    NSMutableArray *resultArray = [[NSMutableArray alloc] initWithArray:[msgTypeList filteredArrayUsingPredicate:predicate]];
    WSMsgBeanArray *messageArray = [[WSMsgBeanArray alloc]initWithObject:resultArray];
   
    NSArray * msgArray;
    if (currentFuncs.styp && currentFuncs.styp.length > 0)
        msgArray = [[messageArray getMsgsBeansWithStyp:currentFuncs.styp] mutableCopy];
    else
        msgArray = messageArray.msgArray;
    if (messageArray.msgArray.count == 0){
        LogInfo(@"未下发消息类型");
        return nil;
    }
    //根据fillter过滤需要显示的消息类型
    __block WSMsgsBean * workMsgBean = nil;
    __block WSMsgsBean_msg * msgsB_msg = nil;
    NSArray *lastMsgsArray = nil;
    NSMutableArray *filterArray = [NSMutableArray array];
    if (currentFuncs.filter != nil && [currentFuncs.filter length] > 0){
        lastMsgsArray = [messageArray getMsgsBeansWithFilter:currentFuncs.filter];
        if (lastMsgsArray != nil)
        {
            WSFuncsBean* subfuncs = currentFuncs;
            if (currentFuncs.funcsArray.count > 0)
                subfuncs   = [currentFuncs.funcsArray objectAtIndex:0];
            
            [lastMsgsArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                workMsgBean = (WSMsgsBean*)obj;
                BOOL isFilter = NO;
                for (WSMsgsBean_msg *msg in workMsgBean.msg)
                {
                    if (msg.typcode != nil) {
                        if ([msg.typcode isEqualToString:subfuncs.filter]) {
                            msgsB_msg = msg;
                        } else if (!isFilter) {
                            isFilter = YES;
                            [filterArray addObject:obj];
                        }
                    }
                }
            }];
            if ([filterArray count] > 0) {
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF in %@", [filterArray copy]];
                lastMsgsArray = [[lastMsgsArray filteredArrayUsingPredicate:predicate] mutableCopy];
            } else {
                lastMsgsArray = [lastMsgsArray mutableCopy];
            }
            
        }
    }
    //计算所有的消息列表
    NSMutableArray * allMsgList = [NSMutableArray arrayWithCapacity:0];
    [allMsgList removeAllObjects];
    for (int i = 0; i < lastMsgsArray.count; i++){
        WSMsgsBean * msgBean = lastMsgsArray[i];
        for (WSMsgsBean_msg * tempMsg in msgBean.msg)
        {
            tempMsg.componentMsgs = [tempMsg generateComponentMsgsWith:tempMsg fileUrl:tempMsg.fileUrl];
            tempMsg.msgType = msgBean.name;
            [allMsgList addObject:tempMsg];
        }
    }
    //计算未读的消息数量
    NSMutableArray * isReadArray = [NSMutableArray arrayWithCapacity:allMsgList.count];
    NSMutableArray * unReadMsgArray = [NSMutableArray arrayWithCapacity:allMsgList.count];
    [unReadMsgArray removeAllObjects];
    for (WSMsgsBean_msg * tempMsg in allMsgList){
        tempMsg.componentMsgs = [tempMsg generateComponentMsgsWith:tempMsg fileUrl:tempMsg.fileUrl];
        NSString *key = [NSString stringWithFormat:@"%@#%@#%@", tempMsg.s, tempMsg.Id,[WSAppData getObjectbyKey:APPDATA_EMPID]];
        NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
        NSDictionary *dic = [user dictionaryForKey:kWSMessageDomainName];
        NSNumber *number = [dic objectForKey:key];
        if ([tempMsg.isread isEqualToString:@"1"] || (number && [number boolValue]))
            [isReadArray addObject:tempMsg];
        else
            [unReadMsgArray addObject:tempMsg];
    }
    NSArray *arr = [[unReadMsgArray reverseObjectEnumerator] allObjects];
    return arr;
}

- (NSString*)getPredicateWithParams:(NSString*)params{

    NSArray *tagsArray = [params componentsSeparatedByString:@","];
    NSMutableArray *quotedTags = [NSMutableArray array];
    for (NSString *tag in tagsArray) {
        [quotedTags addObject:[NSString stringWithFormat:@"'%@'", tag]];
    }
    NSString *resultTag = [quotedTags componentsJoinedByString:@","];
    return [NSString stringWithFormat:@"{ %@ }",resultTag];
}
@end
//====================================================================================================================================
