//
//  WSInfoService.h
//  WinSFA
//
//  Created by heju on 15/10/15.
//  Copyright © 2015年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol WSInfoServiceDelegate;


@interface WSInfoService : NSObject

@property (nonatomic, assign) NSInteger tag;

@property (nonatomic, assign) id <WSInfoServiceDelegate>delegate;

- (id)initWith:(NSString *)objId notify:(NSString *)name;

- (void)startRequest;

@end

@protocol WSInfoServiceDelegate <NSObject>

- (void)infoService:(WSInfoService *)service feedback:(NSInteger)count;

@end