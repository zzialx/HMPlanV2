//
//  WCNaviFile.h
//  WinCore
//
//  Created by sam wang on 13-2-28.
//  Copyright (c) 2013年 winchannel.net. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WCNaviFile : NSObject

@property (nonatomic, copy) NSString *encode;
@property (nonatomic, copy) NSString *ver;
@property (nonatomic, copy) NSString *isAnonymous;
@property (nonatomic, copy) NSString *salt;
@property (nonatomic, assign) BOOL loadFinished;

@property (nonatomic, copy) NSString *query;
@property (nonatomic, copy) NSString *upload;
@property (nonatomic, copy) NSString *message;
@property (nonatomic, copy) NSString *login;

@property (nonatomic, copy) NSString *sync;

- (id)initWithDictionary:(NSDictionary *)dic;

@end
