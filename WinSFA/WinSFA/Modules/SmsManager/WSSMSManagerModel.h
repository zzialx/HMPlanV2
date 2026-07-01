//
//  WSSMSManagerModel.h
//  WinSFA
//
//  Created by mac on 16/12/16.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "WSMappingObject.h"

@interface WSSMSManagerModel : NSObject
@property(nonatomic,strong) WSBaseSmsDataObject * lastObject;
@property (nonatomic , strong) NSArray * array;
@end
