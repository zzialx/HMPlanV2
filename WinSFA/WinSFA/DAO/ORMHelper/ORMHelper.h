//
//  ORMHelper.h
//  lechat
//
//  Created by lizhenjie on 12-6-26.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMResultSet.h"

@interface ORMHelper : NSObject{
    
    NSMutableDictionary *typeind;
    

}

@property (nonatomic,retain) NSMutableDictionary *typeind;
//获得单例
+(ORMHelper *)DefaultOrmHelper;
//转化结果集合到对象
-(id)transformResult:(FMResultSet *)resultset ToObject:(NSString *)classname;

-(NSMutableDictionary *)transformNsObjectToMap:(NSObject *)obj;

@end
