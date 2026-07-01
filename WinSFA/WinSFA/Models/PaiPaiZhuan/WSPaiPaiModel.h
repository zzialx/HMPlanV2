//
//  WSPaiPaiModel.h
//  WinSFA
//
//  Created by zhangmin on 2019/12/10.
//  Copyright © 2019 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <LenzBusinessSDK/LenzBusinessSDK.h>

NS_ASSUME_NONNULL_BEGIN


@interface WSPaiPaiModel : NSObject

//上传
- (void)onlineUploadWithImageIndex:(NSString *)imageIndex withIds:(NSArray*)ids;

#pragma mark--离线上传逻辑

-(void)offlineUploadOneDataWithObj:(id)aFailedData ;
@end

NS_ASSUME_NONNULL_END
