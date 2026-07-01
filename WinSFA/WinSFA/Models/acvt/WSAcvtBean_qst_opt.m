//
//  AcvtBean_qst_opt.m
//  WinChannelFrameWork
//
//  Created by winchannel on 11-11-21.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "WSAcvtBean_qst_opt.h"

@implementation WSAcvtBean_qst_opt

@synthesize acvtQstId = _acvtQstId;
@synthesize optId = _optId;
@synthesize optName = _optName;
@synthesize qstId = _qstId;
@synthesize qstType = _qstType;


- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (id)initWithObject:(id)object{
    
    if (nil == object) {
        return nil;
    }
    self = [super init];
    
    if (self) {
        if ([object isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dic = (NSDictionary *)object;

            _acvtQstId = [NSString stringWithValue: [dic objectForKey:ACVT_ACVTQSTID]];
            _optId = [NSString stringWithValue: [dic objectForKey:ACVT_OPTID]];
            _optName = [NSString stringWithValue:[dic objectForKey:ACVT_OPTNAME]];
            _optPic = [NSString stringWithValue:dic[ACVT_OPTPIC]];
            _qstId = [NSString stringWithValue: [dic objectForKey:ACVT_QSTID]];
            _qstType = [NSString stringWithValue:[dic objectForKey:ACVT_QSTTYPE]];
        };
    }
    
    return self;
}

#pragma  mark - I_W_OptionDataItem

- (NSString *)getDataItemID
{
    return self.optId;
}

- (NSString *)getDataItemName
{
    return self.optName;
}


- (NSString *)getDataItemPic {
    return self.optPic;
}


@end
