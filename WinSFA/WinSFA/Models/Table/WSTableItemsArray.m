//
//  WSTableItemArray.m
//  WinSFA
//
//  Created by ZhengJiepeng on 13-7-24.
//  Copyright (c) 2013年 WinChannel. All rights reserved.
//

#import "WSTableItemsArray.h"
#import "WSTableItem.h"

@implementation WSTableItemsArray

@synthesize tableItemsArray = _tableItemsArray;

- (id)initWithObject:(id)object {
    self = [super init];
    if(self != nil) {
        if ([object isKindOfClass:[NSDictionary class]]) {
            NSArray *Array = [object objectForKey:TB];
            [self initTableItemsWithArray:Array];
        }
    }
    return self;
}

- (void)initTableItemsWithArray:(NSArray *)array {
    _tableItemsArray = [[NSMutableArray alloc] init];
    
    if ([array isKindOfClass:[NSArray class]]) {
        for (int i = 0; i < [array count]; i++) {
            id itemDic = [array objectAtIndex:i];
            WSTableItem *dict = [[WSTableItem alloc] initWithObject:itemDic];
            [self.tableItemsArray insertObject:dict atIndex:i];
        }
    }
}

-(void)initTableItemsWithFuncsBeanArray:(NSArray*)array{
    _tableItemsArray = [[NSMutableArray alloc] init];
    
    if ([array isKindOfClass:[NSArray class]]) {
        for (int i = 0; i < [array count]; i++) {
            id itemDic = [array objectAtIndex:i];
            WSTableItem *dict = [[WSTableItem alloc] initWithFuncsBean:itemDic];
            [self.tableItemsArray insertObject:dict atIndex:i];
        }
    }

}

- (NSArray *)getTableItemWithMc:(NSString *)aMc {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (WSTableItem *item in self.tableItemsArray) {
        if([item.mc isEqualToString:aMc]) {
            [array addObject:item];
        }
        
    }
    return array;
}

@end
