//
//  WSPolicyObject.h
//  WinSFA
//
//  Created by winchannel on 15/8/12.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WSPolicyObject : NSObject

@property (nonatomic,strong)   NSString *begin_time_str; //进店时间
@property (nonatomic,strong)   NSString *end_time_str;   //离店时间
@property (nonatomic,assign)   NSInteger duration;       //时间间隔
@property (nonatomic,strong)   NSString *message;        //alertMessage
@property (nonatomic,strong)    NSString *title;         //alertTitle

@end
