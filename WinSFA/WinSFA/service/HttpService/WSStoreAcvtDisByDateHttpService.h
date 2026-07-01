//
//  WSStoreAcvtDisByDateHttpService.h
//  WinSFA
//
//  Created by winchannel on 16/1/4.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSBaseHttpService.h"

@interface WSStoreAcvtDisByDateHttpService : WSBaseHttpService

@property (nonatomic, strong) NSString    *jsEmpID;   //js跳转提供的empID

@property (nonatomic, strong) NSString *date;

- (void)getStoreAcvtDisDataWithCompletionBlock:(WSBaseHttpServiceBlock)completionBlock;

@end
