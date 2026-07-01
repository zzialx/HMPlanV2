//
//  StoreBean_prod.m
//  WinChannelFrameWork
//
//  Created by winchannel on 11-11-21.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "WSStoreBean_prod.h"
#import "WSAppData.h"


@implementation WSStoreBean_prod
@synthesize sid = _sid;
@synthesize pid = _pid;
@synthesize item = _item;
@synthesize itemV = _itemV;
@synthesize dt = _dt;
@synthesize dn = _dn;

-(NSInteger)getPidIndex
{
    NSArray* ps = [WSAppData getObjectbyKey:PRODSPEC];
    for(int i = 0 ; i < [ps count]; i++)
    {
        if([@"pid" isEqualToString:[ps objectAtIndex:i]])
            return i;
    }
    return 100;
}

-(NSInteger)getSidIndex
{
    NSArray* ps = [WSAppData getObjectbyKey:PRODSPEC];
    for(int i = 0 ; i < [ps count]; i++)
    {
        if([@"sid" isEqualToString:[ps objectAtIndex:i]])
            return i;
    }
    return 100;
}



-(id)initWithSid:(NSString *)aSid Pid:(NSString *)aPid Prods:(NSArray*)aProds Dis:(NSArray*)aDis
{
    if(aSid == nil || aPid == nil)
        return nil;
    
    self = [super init];
    if(self != nil)
    {
        _sid = aSid; 
        _pid = aPid;
        _item = [[NSMutableArray alloc]init];
        _itemV = [[NSMutableArray alloc]init];
        
        [_item addObjectsFromArray:aProds];
        [_itemV addObjectsFromArray:aDis];
        return self;
    }
    return nil;
}
-(NSString *)description{
    return [NSString stringWithFormat:@"WSStoreBean_prod{sid:%@,pid:%@,prods:%@,dis:%@}",self.sid,self.pid,self.item,self.itemV];
}

@end
