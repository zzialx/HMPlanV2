//
//  WSOrgBeanArray.m
//  WinSFA
//
//  Created by heju on 16/9/8.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSOrgBeanArray.h"

#import "WSOrgBean.h"

#define MASTER_LEVEL @"5"

@implementation WSOrgBeanArray

- (id)initWithObject:(id)object{
    
    if (object == nil) {
        return nil;
    }
    
    self = [super init];
    if (self) {
        NSArray *orgs =[object objectForKey:ORG_RELATION];
        

        _orgBeans = [[NSMutableArray alloc] init];
        
    
        NSMutableArray *superOrgs = [NSMutableArray array];
        NSMutableArray *levels = [NSMutableArray array];
        for (NSDictionary *dic  in orgs) {
            
            NSString *level = [NSString stringWithValue:dic[@"level"]];
            if ([level length] > 0) {
                [levels addObject:level];
            }
        
            /*此组织的最高级别是5*/
            if ([level isEqualToString:MASTER_LEVEL]) {
                [superOrgs addObject:dic];
            }
        }
        
        NSInteger maxLevel = [[levels valueForKeyPath:@"@max.self"] integerValue];
        NSInteger minLevle = [[levels valueForKeyPath:@"@min.self"] integerValue];
        _difLevelNum = (maxLevel - minLevle) + 1;
        
        for (NSDictionary *dic  in  superOrgs) {
            
            WSOrgBean *orgBean = [[WSOrgBean alloc] initWithObject:dic];
            orgBean.childen = [self generateOrgChildenWithParentOrg:orgBean orgs:orgs];
            [_orgBeans addObject:orgBean];
        }
    }
    return self;
}

- (NSMutableArray *)generateOrgChildenWithParentOrg:(WSOrgBean *)pOrgBean orgs:(NSArray *)orgDicts {
    
    NSMutableArray *childen = [NSMutableArray array];
    
    for (NSDictionary *dic in  orgDicts) {
        
        NSString *parentId = [NSString stringWithValue:dic[@"parentId"]];
        
        if ([parentId isEqualToString:pOrgBean.orgId]) {
            WSOrgBean *org = [[WSOrgBean alloc] initWithObject:dic];
            org.childen = [self generateOrgChildenWithParentOrg:org orgs:orgDicts];
            org.parentOrgBean = pOrgBean;
            [childen addObject:org];
        }
    }
    return childen;
}

@end