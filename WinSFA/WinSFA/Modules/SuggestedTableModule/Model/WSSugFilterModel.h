//
//  WSSugFilterModel.h
//  WinSFA
//
//  Created by huzepei on 16/9/21.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>
@class WSCateModel;
@class WSBrandModel;
@class WSSuggestPro;

@interface WSSugFilterModel : NSObject

@property (nonatomic,strong) WSCateModel *cate;
@property (nonatomic,strong) WSBrandModel *brand;

@end



@interface WSSugAvProModel : NSObject

@property (nonatomic,strong) WSBrandModel *brand;
@property (nonatomic,strong) NSArray *avCate;

@end
