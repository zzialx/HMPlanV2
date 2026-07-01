//
//  WSPaiPaiUploadCallBack.h
//  WinSFA
//
//  Created by zhangmin on 2019/12/9.
//  Copyright © 2019 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <LenzBusinessSDK/LenzBusinessSDK.h>

NS_ASSUME_NONNULL_BEGIN
typedef void (^WSPaiPaiUploadSuccessBlock)(BOOL success,NSArray *params);

@interface WSPaiPaiUploadCallBack : NSObject<LenzUploadCallback>

@property (nonatomic, strong) LenzEngine *lenzEng;
@property (nonatomic, strong) NSArray *busDataIds;
@property (nonatomic, strong) LenzTaskInfo *lenzInfo;
@property (nonatomic, copy) WSPaiPaiUploadSuccessBlock successBlock;

@end

NS_ASSUME_NONNULL_END
