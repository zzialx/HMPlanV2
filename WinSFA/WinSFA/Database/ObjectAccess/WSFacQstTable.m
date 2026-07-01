//
//  WSFacQstTable.m
//  WinSFA
//
//  Created by zhangke on 14/9/16.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//

#import "WSFacQstTable.h"

@implementation WSFacQstTable

static WSFacQstTable *facqstTable=nil;
+ (WSFacQstTable *)sharedTable
{
    if (facqstTable==nil) {
        
        facqstTable= [[WSFacQstTable alloc]init];
    }
    return  facqstTable;
}
-(NSArray*)queryFacQst:(NSString *)ANS_ID
{
    NSString *facImg_idx=ANS_ID;
    NSArray *whereN=[NSArray arrayWithObjects:@"ans_id", nil];
    NSArray *whereV=[NSArray arrayWithObjects:[NSString stringNotNilWithValue:facImg_idx], nil];
    return [[WSFacQstTable sharedTable] queryWithNames:whereN ArgumentsValue:whereV];
}


-(NSArray*)queryFacQst:(NSString *)ANS_ID andQstId:(NSString *)qustId{
    
    NSString *facImg_idx=ANS_ID;
    
    NSArray *whereN=[NSArray arrayWithObjects:@"ans_id",@"qst_id", nil];
    
    NSArray *whereV=[NSArray arrayWithObjects:[NSString stringNotNilWithValue:facImg_idx],qustId, nil];
    
    return [[WSFacQstTable sharedTable] queryWithNames:whereN ArgumentsValue:whereV];
    
}


@end
