//
//  WinQueueUploadImageTool.h
//  WinSFA
//
//  Created by yuanji on 2023/1/30.
//  Copyright © 2023 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>
//===================================================================================================================================================================================================

NS_ASSUME_NONNULL_BEGIN

typedef void (^UploadImageSuccessBlock)(NSString *successInfo, BOOL isAll); //定义成功闭包
typedef void (^UploadImageFailureBlock)(BOOL isAll);                        //定义失败闭包

#pragma mark - 队列上传图片工具
@interface WinQueueUploadImageTool : NSObject

@property (nonatomic, copy) NSString *storeId;                              //门店id
@property (nonatomic, copy) NSString *uploadURL;                            //上传url
@property (nonatomic, copy) NSString *uuidH5;                               //h5交互的uuid
@property (nonatomic, strong) NSMutableDictionary *otherInfoDic;            //其它信息字典
@property (nonatomic, copy) UploadImageSuccessBlock uploadImageSuccessBlock;//成功闭包
@property (nonatomic, copy) UploadImageFailureBlock uploadImageFailureBlock;//失败闭包

+ (instancetype)sharedInstance;                                             //共享实例
- (void)uploadWithImage:(UIImage *)image imageID:(NSString *)imageID;       //上传方法
- (void)clearCacheData;                                                     //清理缓存数据方法
- (BOOL)currentIsUpload;                                                    //获取当前是否上传方法

@end


NS_ASSUME_NONNULL_END
//===================================================================================================================================================================================================
