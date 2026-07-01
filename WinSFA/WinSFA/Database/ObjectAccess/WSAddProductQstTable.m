//
//  WSAddProductQstTable.m
//  WinSFA
//
//  Created by zhangke on 14/9/14.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//

#import "WSAddProductQstTable.h"

@implementation WSAddProductQstTable

static WSAddProductQstTable *addProductTable = nil;

+ (WSAddProductQstTable*)sharedTable
{
    if (addProductTable == nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            addProductTable = [[WSAddProductQstTable alloc] init];
        });
    }
    return addProductTable;
}


- (NSArray*)queryQstByAnsId:(NSString*)aAnsId andQstId:(NSString*)aQstId
{
    NSMutableArray* nameArray=[NSMutableArray array];
    NSMutableArray* valueArray=[NSMutableArray array];

    if(aAnsId){
        [nameArray addObject:@"ans_id"];
        [valueArray addObject:aAnsId];
    }
    if(aQstId){
        [nameArray addObject:@"qst_id"];
        [valueArray addObject:aQstId];
    }
    return [self queryWithNames:nameArray ArgumentsValue:valueArray];
}


@end
