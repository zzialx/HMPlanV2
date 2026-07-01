//
//  WSSNShowViewPart.m
//  WSSNShowView
//
//  Created by zzialx on 2023/2/14.
//  Copyright © 2023年 zzialx. All rights reserved.
//

#import "WSSNShowViewPart.h"

@implementation WSSNShowViewPart

+ (instancetype)shared
{
    return [[self alloc]init] ;
}

- (WSSNShowViewPart *(^)(NSString *))setTitle
{
    return ^WSSNShowViewPart* (NSString *title) {
        self.title = title;
        return self;
    };
}
- (WSSNShowViewPart *(^)(NSString *))setSubtitle
{
    return ^WSSNShowViewPart* (NSString *subtitle){
        self.subtitle = subtitle ;
        return self ;
    };
}
- (WSSNShowViewPart *(^)(NSString *))setImageName
{
    return ^WSSNShowViewPart *(NSString *imageName){
        self.imageName = imageName ;
        return self ;
    };
}
- (WSSNShowViewPart *(^)(NSArray<NSString *> *))setButtonArray
{
    return ^WSSNShowViewPart *(NSArray *buttonArray){
        self.buttonArray = [buttonArray copy];
        return self ;
    };
}
- (WSSNShowViewPart *(^)(NSArray<NSString *> *))setinfoArray
{
    return ^WSSNShowViewPart *(NSArray *infoArray){
        self.infoArray = [infoArray copy];
        return self ;
    };
}

+ (instancetype)itemWithTitle:(NSString *)title
{
    return [self itemWithTitle:title subtitle:nil];
}
+ (instancetype)itemWithTitle:(NSString *)title subtitle:(NSString *)subtitle
{
    return [self itemWithTitle:title subtitle:subtitle imageName:nil];
}
+ (instancetype)itemWithTitle:(NSString *)title subtitle:(NSString *)subtitle imageName:(NSString *)imageName
{
    return [self itemWithTitle:title subtitle:subtitle imageName:imageName buttonArray:nil infoArray:nil];
}
//+ (instancetype)itemWithTitle:(NSString *)title subtitle:(NSString *)subtitle imageName:(NSString *)imageName buttonArray:(NSArray *)buttonArray
//{
//    WSSNShowViewPart *item = [[WSSNShowViewPart alloc]init];
//    item.title = title ;
//    item.subtitle = subtitle ;
//    item.imageName = imageName ;
//    item.buttonArray = [buttonArray copy];
//    return item ;
//}

+ (instancetype)itemWithTitle:(NSString *)title subtitle:(NSString *)subtitle imageName:(NSString *)imageName buttonArray:(NSArray *)buttonArray infoArray:(NSArray*)infoArray{
    WSSNShowViewPart *item = [[WSSNShowViewPart alloc]init];
    item.title = title ;
    item.subtitle = subtitle ;
    item.imageName = imageName ;
    item.buttonArray = [buttonArray copy];
    item.infoArray = [infoArray copy];
    return item ;
}





+ (instancetype)itemWithTitle:(NSString *)title subtitle:(NSString *)subtitle imageName:(NSString *)imageName buttonArray:(NSArray *)buttonArray {
    WSSNShowViewPart *item = [[WSSNShowViewPart alloc]init];
    item.title = title ;
    item.subtitle = subtitle ;
    item.imageName = imageName ;
    item.buttonArray = [buttonArray copy];
    return item ;
}

@end
