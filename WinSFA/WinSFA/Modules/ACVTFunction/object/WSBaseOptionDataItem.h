//
//  WSBaseOptionDataItem.h
//  WinSFA
//
//  Created by Stephanie on 16/8/30.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "I_W_OptionDataItem.h"

@interface WSBaseOptionDataItem : NSObject<I_W_OptionDataItem>

@property (nonatomic, copy) NSString *itemID;
@property (nonatomic, copy) NSString *itemName;

@end