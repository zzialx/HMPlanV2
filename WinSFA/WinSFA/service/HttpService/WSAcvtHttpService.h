//
//  WSAcvtHttpService.h
//  WinSFA
//
//  Created by yang on 15/12/22.
//  Copyright © 2015年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WSBaseHttpService.h"

typedef void(^WSAcvtHttpServiceCompletionBlock)(NSDictionary * dic, NSError *error);

@interface WSAcvtHttpService : WSBaseHttpService

@property (nonatomic, strong) NSString    *jsEmpID;   //js跳转提供的empID
@property (nonatomic, strong) WSAcvtBean  *acvtBean;


- (void)getAcvtDataWithCompletionBlock:(WSAcvtHttpServiceCompletionBlock)completionBlock;

@end
