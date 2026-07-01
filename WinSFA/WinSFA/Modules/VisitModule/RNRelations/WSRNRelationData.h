//
//  WSRNRelationData.h
//  WinSFA
//
//  Created by HZH on 16/11/3.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WSRNRelationData : NSObject

@property (nonatomic, copy) NSString *dataJsonStr;

+ (WSRNRelationData*)sharedInstance;


@end
