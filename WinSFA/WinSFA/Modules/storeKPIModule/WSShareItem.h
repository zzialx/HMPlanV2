//
//  WSShareItem.h
//  WinSFA
//
//  Created by winchannel on 2017/7/3.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WSShareItem : NSObject

@property (nonatomic,copy) NSString * title;
@property (nonatomic,copy) NSString * icon;

-(instancetype)initWithTitle:(NSString *)title Icon:(NSString *)icon;
@end
