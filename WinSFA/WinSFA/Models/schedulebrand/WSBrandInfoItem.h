//
//  WSBrandInfoItem.h
//  WinSFA
//
//  Created by xiaotang.wang on 7/24/13.
//  Copyright (c) 2013 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WSBrandInfoItem : NSObject

@property (nonatomic, copy)NSString *iBrandId;
@property (nonatomic, copy)NSString *iBrandName;

- (id)initWithObject:(id)aObject;

@end
