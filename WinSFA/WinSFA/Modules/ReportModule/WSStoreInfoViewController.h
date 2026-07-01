//
//  StoreInfoViewController.h
//  WinChannelIPhone
//
//  Created by Chen Angus on 11-8-4.
//  Copyright 2011年 Winchannel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WSStoreBean.h"
#import "WSSubempstoreBean.h"

#define NOTIFY_STOREINFO    @ "storeInfo"
#define STOREINFO_NAME      @ "name"
#define STOREINFO_COD       @ "cod"
#define STOREINFO_ADDR      @ "addr"
#define STOREINFO_LINKMAN   @ "linkman"
#define STOREINFO_LINKTEL   @ "linktel"
#define STOREINFO_UPDATE    @ "updateStoreInfo"
#define STOREINFO_EMPTY     @ ""

@interface WSStoreInfoViewController : UITableViewController{
    NSMutableArray  *datas;
    NSMutableArray  *titles;
    WSStoreBean *_store;
}

@property (nonatomic, strong) NSMutableArray    *datas;
@property (nonatomic, strong) NSMutableArray           *titles;
// @property (nonatomic, retain)InPlanStore *inplan;
// @property (nonatomic, retain)OutPlanStore *outplan;
@property (nonatomic, strong) WSStoreBean *_store;
// Add by WangXiaotang
@property (nonatomic, strong) NSMutableString   *linkman;
@property (nonatomic, strong) NSMutableString   *linktel;
@property (nonatomic, strong) NSMutableString   *linkAddress;
@property (nonatomic, strong)WSSubempstoreBean *subempStore;

- (id)initWithStoreInfo:(id)store;

- (id)initWithStoreInfo:(id)store withSubempStore:(WSSubempstoreBean *)subempStore;
@end
