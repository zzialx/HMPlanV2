//
//  MsgAcvtListViewController.m
//  WinChannelFrameWork
//
//  Created by winchannel on 12-3-27.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "WSMyMsgAcvtListViewController.h"
#import "WSMyMsgViewController.h"
#import "WSBaseStoreOtherDataDBService.h"
#import "WSMsgBeanArray.h"
#import "WSMsgsBean.h"
#import "WSMsgsBean_msg.h"
#import "WSBaseMsgTypeTable.h"


@implementation WSMyMsgAcvtListViewController

- (void)loadView {
    [self filterHomePageFuncBean];
    
    [super loadView];
    
    if([self.selectViewController isKindOfClass:[WSMyMsgViewController class]]){
        WSMyMsgViewController *msgVC = (WSMyMsgViewController *)self.selectViewController;
        msgVC.subFuncsBeanNeedShow = self.subFuncsBeanNeedShow;
    }
}

- (void)filterHomePageFuncBean {
    if (!self.currentFuncs || !self.currentFuncs.funcsArray) {
        return;
    }

    NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:0];
    for (WSFuncsBean *fb in self.currentFuncs.funcsArray) {
        NSString *className = [WSPlistHelper valueForKey:fb.fv withPlistName:kControllerMappingFileName];
        if (className) {
            [tempArray addObject:fb];
        }
    }
    self.currentFuncs.funcsArray = tempArray;
}

- (void)handleTabBarItemBadgeValue {

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(markBadgeForMessage) name:MAIN_VC_NEED_UPDATE_BADGE_NOTIFY object:nil];

    [self markBadgeForMessage];
}

- (NSInteger)markBadgeForMessage
{
    NSInteger unReadMessageCount = 0;
    NSInteger unUploadCount = 0;
    NSMutableArray *arrayForMessage = nil;
    
    WSFuncsBean* fb = self.currentFuncs;
    if ( [fb.fv isEqualToString:@"TB_V10"]
        || [fb.fv isEqualToString:@"TB_V12"]){
        
        WSMsgBeanArray * messageArray = [[WSMsgBeanArray alloc]initWithObject:[[WSBaseMsgTypeTable sharedTable] queryBaseMsgType]];
        for (int j=0; j<[messageArray.msgArray count]; j++) {
            WSMsgsBean *msgsB=[messageArray.msgArray objectAtIndex:j];
            if ([msgsB.name isEqualToString:@"总裁致词"]) {
                [messageArray.msgArray  removeObjectAtIndex:j];
            }
        }
        //  汉高合并逻辑 董宏
        NSMutableString *str = [NSMutableString stringWithCapacity:0];
        for(NSInteger j = 0 ; fb.funcsArray.count > j ; j++ )
        {
            WSFuncsBean* fbNew = fb.funcsArray[j] ;
            if (fbNew.filter.length>0) {
                NSString *strDecollator = @"";
                if(str.length>0)
                {
                    strDecollator = @",";
                }
                
                [str appendString:[NSString stringWithFormat:@"%@%@",strDecollator,fbNew.filter]];
            }
            
        }
        
        NSArray *msgsArray = nil;
        if (str != nil && [str length] > 0) {
            msgsArray = [messageArray getMsgsBeansWithFilter:str];
        }
        if (msgsArray != nil) {
            arrayForMessage = [NSMutableArray arrayWithArray:msgsArray];
        }else{
            arrayForMessage = [NSMutableArray arrayWithArray:messageArray.msgArray];
        }
        
        int m = 0;
        
        for (WSMsgsBean *aMsg in arrayForMessage) {
            for (WSMsgsBean_msg *tempMsg in aMsg.msg)
            {
                NSString *key = [NSString stringWithFormat:@"%@#%@#%@", tempMsg.s, tempMsg.Id,[WSAppData getObjectbyKey:APPDATA_EMPID]];
                
                NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
                NSDictionary *dic = [user dictionaryForKey:kWSMessageDomainName];
                NSNumber *number = [dic objectForKey:key];
                if ([tempMsg.isread isEqualToString:@"1"] || (number && [number boolValue])){
                    
                }else{
                    ++m;
                }
            }
        }
        
        unReadMessageCount = m;
        UIViewController *vc = (self.ownParentViewController) ? self.ownParentViewController : self;
        
        if (unReadMessageCount <= 0) {
            vc.tabBarItem.badgeValue = nil;
        } else {
            NSString *badgeValue = (unReadMessageCount > 99) ? @"..." : [NSString stringWithFormat:@"%ld", unReadMessageCount];
            vc.tabBarItem.badgeValue = badgeValue;
        }
    }
    
    return unReadMessageCount + unUploadCount;
}
-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
