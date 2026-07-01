//
//  WSLocationArray.m
//  WinSFA
//
//  Created by ZhengJiepeng on 13-8-16.
//  Copyright (c) 2013年 WinChannel. All rights reserved.
//

#import "WSLocationArray.h"
#import "WSDictBean.h"

@implementation WSLocationArray

- (void)initLocationWithArray:(NSArray *)array {
    _locationArray = [[NSMutableArray alloc] init];
    
    if ([array isKindOfClass:[NSArray class]]){
        
        if (array != nil) {
            
            for (int i = 0; i < [array count]; i++) {
                
                id temp = [array objectAtIndex:i];
                WSLocation *location = nil;
                if (temp && [temp isKindOfClass:[WSDictBean class]]) {
                    WSDictBean *dictBean = (WSDictBean *)temp ;
                    location = [[WSLocation alloc] init];
                    location.city = [NSString stringNotNilWithValue:dictBean.name];
                    location.cityCode = [NSString stringNotNilWithValue:dictBean.Id];
                    [self.locationArray insertObject:location atIndex:i];
                    
                }else if (temp && [temp isKindOfClass:[WSLocation class]]){
                    
                    location = [[WSLocation alloc] initWithObject:temp];
                    [self.locationArray insertObject:location atIndex:i];
                }
                

            }
        }
    }
}

//- (id)initWithObject:(id)object {
//    self = [super init];
//    if(self != nil) {
//        if ([object isKindOfClass:[NSDictionary class]]){
//            NSArray *Array = [object objectForKey:CITYNAMES];
//            [self initLocationWithArray:Array];
//        }
//        return self;
//    }
//    return nil;
//}

- (id)initWithObject:(id)object andNode:(NSString *)aNode
{
    self = [super init];
    if(self != nil) {
        if ([object isKindOfClass:[NSDictionary class]]){
            NSString *node = (aNode != nil) ? aNode : CITYNAMES;
            NSArray *Array = [object objectForKey:node];
            [self initLocationWithArray:Array];
        }
        return self;
    }
    return nil;
}


@end
