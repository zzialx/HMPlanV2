//
//  RevertArrayModel.h
//  demo
//
//  Created by admin on 15/10/27.
//  Copyright © 2015年 zhiqingPC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RevertArrayModel : NSObject 

@property(nonatomic,copy) NSString * userName;
@property(nonatomic,copy) NSString * revertMsg;
@property(nonatomic,copy) NSString * reply_time;


-(instancetype)initWithDict:(NSDictionary * )dict;

+(instancetype)cellWithDict:(NSDictionary * )dict;


@end
