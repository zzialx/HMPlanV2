//
//  WSStoreOtherBean.m
//  WinSFA
//
//  Created by winchannel on 2017/10/8.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSStoreOtherBean.h"

@implementation WSStoreOtherBean
#pragma mark - I_W_OptionDataItem

- (id)copyWithZone:(NSZone *)zone {
    
    WSStoreOtherBean *copy = [[[self class] allocWithZone:zone]init ];
    copy.emp_id = [self.emp_id copy];
    copy.store_id = [self.store_id copy];
    copy.biz_date = [self.biz_date copy];
    copy.type = [self.type copy];
    copy.item1 = [self.item1 copy];
    copy.item2 = [self.item2 copy];
    copy.item3 = [self.item3 copy];
    copy.item4 = [self.item4 copy];
    copy.item5 = [self.item5 copy];
    copy.item6 = [self.item6 copy];
    copy.item7 = [self.item7 copy];
    copy.item8 = [self.item8 copy];
    copy.item9 = [self.item9 copy];
    copy.item10 = [self.item10 copy];
    copy.item11 = [self.item11 copy];
    copy.item12 = [self.item12 copy];
    copy.item13 = [self.item13 copy];
    copy.item14 = [self.item14 copy];
    copy.item15 = [self.item15 copy];
    copy.item16 = [self.item16 copy];
    copy.item17 = [self.item17 copy];
    copy.item18 = [self.item18 copy];
    copy.item19 = [self.item19 copy];
    copy.item20 = [self.item20 copy];
    return copy;
}

- (NSString *)getDataItemID
{
    return self.item1;
}

- (NSString *)getDataItemName
{
    return self.item17;
}

@end
