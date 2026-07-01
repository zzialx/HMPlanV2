//
//  WSAliyunUtil.h
//  WinSFA
//
//  Created by Alicia on 2017/4/19.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WSAliyunUtil : NSObject


+ (instancetype)sharedAliyunUtil;

-(void)uploadImageToAliCloud:(NSString*)cloudKey localPath:(NSString*)localPath block:(void(^)(BOOL isSuccess, NSString *refCloudKey, NSError *error)) block;


-(void)downLoadAliCloudImage:(NSString*)cloudKey category:(NSString*)category localFileName:(NSString*)localFileName progress:(void(^)(NSInteger receivedSize, NSInteger expectedSize))progressBlock completed:(void(^)(UIImage *image,NSError *error))completeBlock;


@end
