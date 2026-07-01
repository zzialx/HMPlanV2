//
//  WSRichItemModel.h
//  WinSFA
//
//  Created by huzepei on 16/8/17.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WSRichItemModel : NSObject <NSCoding>

@property (nonatomic,copy) NSString * name;

@property (nonatomic,copy) NSString * ID;

@property (nonatomic,copy) NSString * speid;

@property (nonatomic,copy) NSString * cod;

@property (nonatomic,copy) NSString * typ; 

@property (nonatomic,copy) NSString * memo;

@property (nonatomic,copy) NSString * img_url;

@property (nonatomic,copy) NSString * h5_url;

@property (nonatomic,copy) NSString * levelCode;

@property (nonatomic,copy) NSString * h5_add;

@property (nonatomic,copy) NSString * img_add;

@property (nonatomic,copy) NSString * fenleiId;

@property (nonatomic,copy) NSString * isread;

@property (nonatomic,copy) NSString * share_url;

@property (nonatomic,copy) NSString * type_ ;

@property (nonatomic,copy) NSString *seq;

@property (nonatomic,copy) NSString *clicktime;
@end
