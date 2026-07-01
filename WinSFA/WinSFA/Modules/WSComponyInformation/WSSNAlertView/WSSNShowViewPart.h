//
//  WSSNShowViewPart.h
//  WSSNShowView
//
//  Created by zzialx on 2023/2/14.
//  Copyright © 2023年 zzialx. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WSMsgsBean_msg.h"
@interface WSSNShowViewPart : NSObject

@property (nonatomic,strong)NSString *title ;                 //标题
@property (nonatomic,strong)NSString *subtitle ;              //副标题
@property (nonatomic,strong)NSString *imageName ;             //图片名称
@property (nonatomic,strong)NSArray<NSString *> *buttonArray ;//下面需要的按钮

///产品信息
@property (nonatomic,strong)NSArray<NSObject *> *infoArray ;

+ (instancetype)shared ;
- (WSSNShowViewPart *(^)(NSString *))setTitle ;
- (WSSNShowViewPart *(^)(NSString *))setSubtitle ;
- (WSSNShowViewPart *(^)(NSString *))setImageName ;
- (WSSNShowViewPart *(^)(NSArray<NSString *> *))setButtonArray ;
- (WSSNShowViewPart *(^)(NSArray<NSString *> *))setinfoArray ;


+ (instancetype)itemWithTitle:(NSString *)title ;
+ (instancetype)itemWithTitle:(NSString *)title subtitle:(NSString *)subtitle ;
+ (instancetype)itemWithTitle:(NSString *)title subtitle:(NSString *)subtitle imageName:(NSString *)imageName ;
+ (instancetype)itemWithTitle:(NSString *)title subtitle:(NSString *)subtitle imageName:(NSString *)imageName buttonArray:(NSArray *)buttonArray ;
+ (instancetype)itemWithTitle:(NSString *)title subtitle:(NSString *)subtitle imageName:(NSString *)imageName buttonArray:(NSArray *)buttonArray infoArray:(NSArray*)infoArray;


@end
