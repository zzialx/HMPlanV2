//
//  AcvtListViewController.h
//  WinChannelFrameWork
//
//  Created by winchannel on 12-3-2.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WSFuncsBean.h"
#import "WSStoreBean.h"
#import "WSSubempstoreBean.h"
#import "BaseViewController.h"

#import "WSHosBean.h"

@interface WSAcvtListViewController : BaseViewController<UITableViewDelegate,UITableViewDataSource> {}
@property (nonatomic, strong) UITableView         *tableView;

@property (nonatomic, strong) WSFuncsBean         *m_currentFuncs;
@property (nonatomic, strong) WSStoreBean         *m_currentStore;
@property (nonatomic, strong) WSHosBean           *hosBean;

@property (nonatomic, strong) NSMutableArray    *m_currentAcvtArray;
@property (nonatomic, weak) UIViewController  *m_ParentViewController;
@property (nonatomic, strong) NSString* filterResult;//过滤问卷
;


@property (nonatomic, strong) WSSubempstoreBean   *m_SubempstoreBean;

//-------------------------added by melody---------------------
@property (nonatomic, strong) NSMutableDictionary      *m_storeInfoDic;//存储请求返回的调查问卷数据
@property (nonatomic, strong) NSString      *Subempid;//随访人id


- (id)initWithFuncs:(WSFuncsBean *)funcs Store:(WSStoreBean *)aStore;

- (id)initWithFuncs:(WSFuncsBean *)funcs Store:(WSStoreBean *)aStore hosBean:(WSHosBean*)hosBean;

- (id)initWithFuncs:(WSFuncsBean *)funcs;
-(void)initAcvtList:(NSArray *)acvtIds;

+ (NSArray *)filterAcvtListWithCurrentFuncs:(WSFuncsBean *)currentFuncs withCurrentStore:(WSStoreBean *)currentStore;

@end
