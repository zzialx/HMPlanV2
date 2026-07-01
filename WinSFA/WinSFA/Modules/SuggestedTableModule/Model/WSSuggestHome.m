//
//  WSSuggestHome.m
//  WinSFA
//
//  Created by huzepei on 16/9/10.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSSuggestHome.h"
#import "YYModel.h"

@implementation WSSuggestHome

@end



@implementation WSSuggestHomePro

- (void)encodeWithCoder:(NSCoder *)aCoder {
    
    [self yy_modelEncodeWithCoder:aCoder];
    
}
- (id)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super init];
    
    return [self yy_modelInitWithCoder:aDecoder];
}

@end


@implementation WSSuggestHomeModel

- (void)encodeWithCoder:(NSCoder *)aCoder {
    
    [self yy_modelEncodeWithCoder:aCoder];
    
}
- (id)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super init];
    
    return [self yy_modelInitWithCoder:aDecoder];
}

@end