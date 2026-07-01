//
//  WSPhotoTypeItem.h
//  WinSFA
//
//  Created by yang on 13-12-10.
//  Copyright (c) 2013年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WSPhotoTypeItem : NSObject

@property (nonatomic, copy) NSString *typeID;

@property (nonatomic, copy) NSString *typeName;

@property (nonatomic, strong) NSMutableArray *photoIDArray;



@end
