//
//  WSProdHttpService.h
//  WinSFA
//
//  Created by winchannel on 2017/11/23.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSBaseHttpService.h"

typedef void(^WSProdHttpServiceCompletionBlock)(NSArray * array, NSError *error);

@interface WSProdHttpService : WSBaseHttpService

- (void)getProdsDataWithCompletionBlock:(WSProdHttpServiceCompletionBlock)completionBlock;

//请求产品促销详情
- (void)getSalesDetailStringWithStoreId:(NSString*)storeID  prodId:(NSString *)prodId CompletionBlock:(WSProdHttpServiceCompletionBlock)completionBlock;
@end
