//
//  WCProductBeanItemofChoice.m
//  WinSFA
//
//  Created by xiaotang.wang on 7/18/13.
//  Copyright (c) 2013 WinChannel. All rights reserved.
//

#import "WSProductBeanItemofChoice.h"

@implementation WSProductBeanItemofChoice

@synthesize name = _name;
@synthesize iProductBean = _iProductBean;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization
    }
    return self;
}


- (id)initWithProductBean:(WSProdBean *)aProductBean
{
    self = [super init];
    if (self) {
        _name = [aProductBean.name copy];
        _iProductBean = aProductBean;
    }
    return self;
}




@end
