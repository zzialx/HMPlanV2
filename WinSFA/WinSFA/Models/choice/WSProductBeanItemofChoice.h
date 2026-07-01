//
//  WCProductBeanItemofChoice.h
//  WinSFA
//
//  Created by xiaotang.wang on 7/18/13.
//  Copyright (c) 2013 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WSBaseItemOfChoice.h"
#import "WSProdBean.h"

@interface WSProductBeanItemofChoice : NSObject<WSBaseItemOfChoice>

@property (nonatomic, strong)WSProdBean *iProductBean;

- (id)init;
- (id)initWithProductBean:(WSProdBean *)aProductBean;

@end
