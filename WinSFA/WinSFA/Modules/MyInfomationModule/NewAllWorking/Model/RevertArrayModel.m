//
//  RevertArrayModel.m
//  demo
//
//  Created by admin on 15/10/27.
//  Copyright © 2015年 zhiqingPC. All rights reserved.
//

#import "RevertArrayModel.h"

@implementation RevertArrayModel

-(instancetype)initWithDict:(NSDictionary *)dict{
    
    self = [super init];
    if (self) {
        
        [self setValuesForKeysWithDictionary:dict];
    }

    return self;
}

+(instancetype)cellWithDict:(NSDictionary *)dict{
    
    return    [[self alloc]initWithDict:dict];
    
}


@end
