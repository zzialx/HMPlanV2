//
//  WSGetMsgHttpService.h
//  WinSFA
//
//  Created by winchannel on 16/4/20.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSBaseHttpService.h"

typedef void(^WSGetMsgHttpServiceCompletionBlock)(NSDictionary * dic, NSError *error);

@interface WSGetMsgHttpService : WSBaseHttpService

- (void)getMsgDataWithCompletionBlock:(WSGetMsgHttpServiceCompletionBlock)completionBlock;
@end
