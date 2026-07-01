//
//  AcvtBean_qst_opt.h
//  WinChannelFrameWork
//
//  Created by winchannel on 11-11-21.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "I_W_OptionDataItem.h"

//acvt选项的描述，有opt类型，qst父id。


@interface WSAcvtBean_qst_opt : NSObject<I_W_OptionDataItem>

@property (nonatomic, copy) NSString  *acvtQstId;
@property (nonatomic, copy) NSString  *optId;
@property (nonatomic, copy) NSString  *optName;
@property (nonatomic, copy) NSString  *qstId;
@property (nonatomic, copy) NSString  *qstType;
@property (nonatomic, copy) NSString  *optPic;
- (id)initWithObject:(id)object;

@end
