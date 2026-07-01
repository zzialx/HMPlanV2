//
//  WSNewAddAcvtViewController.h
//  WinSFA
//
//  Created by heju on 14-4-10.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//

#import "WSAcvtViewController.h"
#import "WinSFA.h"
#import "WSCurrentTime.h"
#import "WSAcvtBean_qst_opt.h"
#import "WSDictBean.h"


@interface WSNewAddAcvtViewController : WSAcvtViewController

@property (nonatomic, strong) NSMutableDictionary *replayDic;
@property (nonatomic, strong) NSArray *acvtNewStoreQstInfos;


-(id)initWithAcvt:(WSAcvtBean*)anAcvt Funcs:(WSFuncsBean*)funcs Store:(WSStoreBean*)store md5:(NSString *)acvtMd5 withReplayDic:(NSMutableDictionary*)dic;

/**
 pram: storeId   // 新增对店的调查问卷作为门店时的id
 */
-(id)initWithAcvt:(WSAcvtBean*)anAcvt Funcs:(WSFuncsBean*)funcs Store:(WSStoreBean*)store acvtNewStore:(WSStoreBean *)acvtNewStore newStoreAcvtInfos:(NSArray *)acvtInfos md5:(NSString *)acvtMd5;


@end
