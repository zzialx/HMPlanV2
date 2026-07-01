//
//  DictBean.m
//  WinChannelFrameWork
//
//  Created by winchannel on 11-11-21.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "WSDictBean.h"

#define kRequired                   @"require"

@implementation WSDictBean

@synthesize dtyp=_dtyp;
@synthesize btyp= _btyp;
@synthesize Id = _Id;
@synthesize name = _name;
@synthesize cod = _cod;
@synthesize p = _p;
@synthesize typ =_typ;
@synthesize SEQ = _SEQ;
@synthesize levelCode = _levelCode;
@synthesize dicts_sequence = _dicts_sequence;

- (id)initWithObject:(id)object
{
    if (nil == object)
    {
        return nil;
    }
    self = [super init];
    
    if (self)
    {
        if ([object isKindOfClass:[NSDictionary class]])
        {
            NSDictionary *dic = (NSDictionary *)object;
            _dtyp = [NSString stringWithValue:[dic objectForKey:DICTS_DTYP]];
            _btyp = [NSString stringWithValue:[dic objectForKey:DICTS_BTYP]];
            
            id idcod = [dic objectForKey:DICTS_ID];
            if ([idcod isKindOfClass:[NSNumber class]]) {
                NSNumber *idnum = (NSNumber *)idcod;
                _Id = [idnum stringValue];
            } else {
                _Id = [NSString stringWithValue:[dic objectForKey:DICTS_ID]];
            }
            
            _name = [NSString stringWithValue:[dic objectForKey:DICTS_NAME]];
            _cod = [NSString stringWithValue:[dic objectForKey:DICTS_COD]];
            
            id idp = [dic objectForKey:DICTS_P];
            if ([idp isKindOfClass:[NSNumber class]]) {
                NSNumber *np = (NSNumber*)idp;
                _p = [np stringValue];
            }else{
                _p = [NSString stringWithValue:[dic objectForKey:DICTS_P]];
            }
            
            _typ = [NSString stringWithValue:[dic objectForKey:DICTS_TYP]];
            
            id seq = [dic objectForKey:DICTS_SEQ];
            if ([seq isKindOfClass:[NSNumber class]]) {
                NSNumber *np = (NSNumber*)seq;
                _SEQ = [np stringValue];
            }else{
                _SEQ = [NSString stringWithValue:[dic objectForKey:DICTS_SEQ]];
            }
            
            _fl = [NSString stringWithValue:dic[DICTS_FL]];
            _col1 = [NSString stringWithValue:dic[@"col1"]];
            _col2 = [NSString stringWithValue:dic[@"col2"]];
            _child_data = dic[@"child_data"];
            _product = dic[@"product"];
            _iconUrl = [NSString stringWithValue:[dic objectForKey:DICTS_ICON_URL]];
            _levelCode = [NSString stringWithValue:[dic objectForKey:DICTS_LEVEL_CODE]];
            
            id seqence = [dic objectForKey:DICTS_DICTS_SEQENCE];
            if ([seqence isKindOfClass:[NSNumber class]])
                _dicts_sequence = [((NSNumber *)seqence) stringValue];
            else
                _dicts_sequence = [NSString stringWithValue:[dic objectForKey:DICTS_DICTS_SEQENCE]];
        }
    }
    
    return self;
}

#pragma mark - I_W_OptionDataItem

- (NSString *)getDataItemID
{
    return self.Id;
}

- (NSString *)getDataItemName
{
    return self.name;
}
- (NSString *)getDataItemMemo
{
    return self.memo;
}
- (BOOL)isDataItemRequired {
     if ([self.btyp isEqualToString:kRequired]) {
         return YES;
     } else {
         return NO;
     }
}
@end
