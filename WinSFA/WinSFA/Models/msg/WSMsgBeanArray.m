//
//  MsgBeanArray.m
//  WinChannelFrameWork
//
//  Created by winchannel on 11-11-25.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "WSMsgBeanArray.h"
#import "WSMsgsBean.h"

@implementation WSMsgBeanArray

@synthesize msgArray = _msgArray;

-(void)initMsgWithArray:(NSArray*)array
{
    [self initMsgWithArray:array storeId:@""];
}
-(void)initMsgWithArray:(NSArray*)array storeId:(NSString*)storeId
{
    _msgArray = [[NSMutableArray alloc] init];
    
    if ([array isKindOfClass:[NSArray class]]){
        
        if (array != nil){
            
            for (int i = 0; i < [array count]; i++) {
                WSMsgsBean *msg = [[WSMsgsBean alloc] initWithObject:[array objectAtIndex:i] storeId:storeId];
                [self.msgArray insertObject:msg atIndex:i];
            }
        }
    }
}



- (id)initWithObject:(id)object
{
    return [self initWithObject:object storeId:@""];
}

- (id)initWithObject:(id)object storeId:(NSString*)storeId
{
    self = [super init];
    if(self != nil)
    {
        if ([object isKindOfClass:[NSDictionary class]]){
            NSArray *Array = [object objectForKey:MSGS];
            [self initMsgWithArray:Array storeId:storeId];
        }else if ([object isKindOfClass:[NSArray class]]){
            NSArray * array = (NSArray *)object;
            [self initMsgWithArray:array storeId:storeId];
        }
        return self;
    }
    return nil;
}

- (NSArray *)getMsgsBeansWithFilter:(NSString *)filter
{
    if ([filter length] == 0) return nil;
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    [self.msgArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        WSMsgsBean *bean = (WSMsgsBean*)obj;
        NSRange findRange = [filter rangeOfString:bean.cod];
        if (findRange.location != NSNotFound) {
            [array addObject:bean];
        }
    }];
    
    return (([array count] > 0) ? array : nil);
}

- (NSArray *)getMsgsBeansWithStyp:(NSString *)styp
{
    if ([styp length] == 0) return nil;
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (WSMsgsBean * msgArray  in self.msgArray)
    {
        if ([styp rangeOfString:msgArray.cod].location != NSNotFound) {
            [array addObject:msgArray];
        }
    }
    
    return (([array count] > 0) ? array : nil);
}
@end
