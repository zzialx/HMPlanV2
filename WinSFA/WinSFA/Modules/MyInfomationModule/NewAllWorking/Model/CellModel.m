//
//  CellModel.m
//  demo
//
//  Created by admin on 15/10/21.
//  Copyright (c) 2015年 zhiqingPC. All rights reserved.
//

#import "CellModel.h"

@implementation CellModel

-(instancetype)initWithDict:(NSDictionary *)dict{
    
    self = [super init];
    if (self) {
    //   demo 的数据KVC
      [self setValuesForKeysWithDictionary:dict];
        
    
        
    }
    

    
    return self;
}

+(instancetype)cellWithDict:(NSDictionary *)dict{

  return  [[self alloc]initWithDict:dict];

}

@end
