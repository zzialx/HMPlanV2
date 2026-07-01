//
//  I_W_ContactDisplay.h
//  WinSFA
//
//  Created by winchannel on 15/3/23.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#ifndef WinSFA_I_W_ContactDisplay_h
#define WinSFA_I_W_ContactDisplay_h

#import <Foundation/Foundation.h>

@protocol I_W_ContactDisplay <NSObject>


-(NSString *)getContactName;

-(NSString *)getContactMobile;

-(NSMutableArray *)getContactMobileList;

-(NSData *)getContactImageData;

@end


#endif
