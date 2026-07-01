//
//  WSBaseMsgTypeTable.m
//  WinSFA
//
//  Created by weida on 15/12/26.
//  Copyright © 2015年 WinChannel. All rights reserved.
//

#import "WSBaseMsgTypeTable.h"

@implementation WSBaseMsgTypeTable

static WSBaseMsgTypeTable *baseStoreTable = nil;

+ (WSBaseMsgTypeTable *)sharedTable{
    if (baseStoreTable == nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            baseStoreTable = [[WSBaseMsgTypeTable alloc] init];
        });
    }
    return baseStoreTable;
}

-(NSArray *)queryBaseMsgType{
    //SFA-25706
    NSArray *msgsArray =[self queryWithNames:nil ArgumentsValue:nil];
    NSSortDescriptor *firstDescriptor = [[NSSortDescriptor alloc] initWithKey:@"sort" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:firstDescriptor, nil];
    return  [msgsArray sortedArrayUsingDescriptors:sortDescriptors];
}

- (WSBaseMsgTypeObject *)queryBaseMsgTypeById:(NSString *)typeId {
    
    if (!typeId) {
        return nil;
    }
    
    return [[self queryWithNames:@[@"_id"] ArgumentsValue:@[[NSNumber numberWithInteger:[typeId integerValue]]]] firstObject];
}

- (void)cleanOldData{
    
    [self deleteAll];
}

@end
