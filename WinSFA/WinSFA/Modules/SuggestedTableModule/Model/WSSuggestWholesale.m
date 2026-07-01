//
//  WSSuggestWholesale.m
//  WinSFA
//
//  Created by huzepei on 16/9/8.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSSuggestWholesale.h"
#import "YYModel.h"
@implementation WSSuggestWholesale



@end

@implementation WSSuggestWhoModel

- (void)encodeWithCoder:(NSCoder *)aCoder {
    
    [self yy_modelEncodeWithCoder:aCoder];
    
}
- (id)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super init];
    
    return [self yy_modelInitWithCoder:aDecoder];
}

@end


@implementation WSSuggestPro

- (void)encodeWithCoder:(NSCoder *)aCoder {
    
    [self yy_modelEncodeWithCoder:aCoder];
    
}
- (id)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super init];
    
    return [self yy_modelInitWithCoder:aDecoder];
}

@end


