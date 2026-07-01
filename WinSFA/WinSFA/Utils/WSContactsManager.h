//
//  WSContactsManager.h
//  WinSFA
//
//  Created by yang on 13-10-16.
//  Copyright (c) 2013年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WSContactsManager : NSObject

+ (WSContactsManager *)sharedInstance;

- (void)addServiceCallToAddressBook;

@end
