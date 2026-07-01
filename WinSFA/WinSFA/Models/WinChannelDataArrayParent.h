//
//  WinChannelDataArrayParent.h
//  WinChannelFrameWork
//
//  Created by winchannel on 11-11-22.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WinChannelDataArrayParent : NSObject

@property (nonatomic, strong) NSMutableDictionary *pParent;

- (void)initWithObject:(id) object Key:(NSString *)targetId;

@end
