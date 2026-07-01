//
//  PropertyManager.h
//  WinChannelIPhone
//
//  Created by Chen Angus on 11-7-20.
//  Copyright 2011年 dumbrock. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PropertyManager : NSObject {
    @private
    BOOL isDefaultPath;
}

@property (nonatomic, strong) NSMutableDictionary *property;

/*
 * *如果获取的是非defaultPath的key每次使用的时候都需要重新调用
 *+ (BOOL)setFilePath:(NSString*)aFileName;
 */
+ (id)getPropertybyKey:(NSString *)key;
+ (void)setDefaultPath;
+ (BOOL)setFilePath:(NSString *)aFileName;

@end
