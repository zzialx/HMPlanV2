//
//  PromBean.m
//  WinChannelFrameWork
//
//  Created by winchannel on 11-11-21.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "WSPromBean.h"
#import "WSPromBean_opt.h"

@implementation WSPromBean
@synthesize efrdat = _efrdat;
@synthesize eftdat = _eftdat;
@synthesize empId = _empId;
@synthesize Id = _Id;
@synthesize name = _name;
@synthesize opt = _opt;

- (id)initWithObject:(id)object{
    
    if (nil == object) {
        return nil;
    }
    
    self = [super init];
    
    if (self) {
        if ([object isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dic = (NSDictionary *)object;
            _efrdat = [dic objectForKey:PROMS_EFRDAT];
            _eftdat = [dic objectForKey:PROMS_EFTDAT];
            _empId = [NSString stringWithValue:[dic objectForKey:PROMS_EMPID]];
            _Id = [NSString stringWithValue:[dic objectForKey:PROMS_ID]];
            _name = [dic objectForKey:PROMS_NAME];
            
            NSArray *subopt = [dic objectForKey:PROMS_OPT];
            
            if ([subopt isKindOfClass:[NSArray class]]) {
                _opt = [[NSMutableArray alloc] 
                       initWithCapacity:[subopt count]];
                
                for (int i = 0; i < [subopt count]; i++) {
                    WSPromBean_opt *popt = [[WSPromBean_opt alloc]
                                     initWithObject:[subopt objectAtIndex:i]];
                    [self.opt insertObject:popt atIndex:i];
                }
            }
        }
        return self;
    }
    
    return nil;
}

@end
