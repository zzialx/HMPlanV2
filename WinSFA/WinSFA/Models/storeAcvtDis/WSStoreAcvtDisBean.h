//
//  StoreAcvtDisBean.h
//  WinChannelFrameWork
//
//  Created by winchannel on 12-4-9.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define ACVTDIS_STOREID             0     //store id
#define ACVTDIS_ACVTID              1     //acvt id
#define ACVTDIS_QSTID               2     //acvtQstId
#define ACVTDIS_VALUE               3     //value

@protocol I_W_OptionDataItem;

@interface WSStoreAcvtDisBean : NSObject<I_W_OptionDataItem>

@property (nonatomic, copy) NSString            *m_empId;
@property (nonatomic, strong) NSMutableArray    *m_p;
@property (nonatomic, strong) NSString          *gen_id;
@property (nonatomic, strong) NSString          *acvt_newStoreId;

- (id)initWithObject:(id)object;

@end
