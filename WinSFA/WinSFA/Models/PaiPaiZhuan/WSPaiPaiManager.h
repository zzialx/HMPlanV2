//
//  WSPaiPaiManager.h
//  WinSFA
//
//  Created by zhangmin on 2019/12/6.
//  Copyright © 2019 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>
#import "WSPaiPaiModel.h"

#define PPCamera_Normal     @"2"
#define PPCamera_connect    @"3"
#define PPCamera_StoreFP    @"4"
#define PPZ_Upload_Logo     @"ppzImage@#"
#define PPZ_maxPhotoMark    @"maxPhoto"

static const NSString * _Nonnull tiltKey = @"tiltKey";
static const NSString * _Nonnull pzMaxKey = @"pzMaxKey";
//=============================================================================================================================================================================================

NS_ASSUME_NONNULL_BEGIN

@protocol WSPaiPaiManagerDelegate <NSObject>

- (void)didFinishImage:(UIImage *)image withImgID:(NSString *)imgID;
- (void)didFinishPhotoModelArray:(NSArray *)list;

@end
//=============================================================================================================================================================================================

@interface WSPaiPaiManager : NSObject

@property (nonatomic,weak) id <WSPaiPaiManagerDelegate>delegate;
@property (nonatomic,assign) BOOL isTasking;
@property (nonatomic,strong) NSMutableDictionary * engineDic;

+ (WSPaiPaiManager*)sharedInstance;
- (void)registerPaiPai;
- (LenzTaskInfo *)getLenzTaskInfo;
- (UIImage *)getImageWithModel:(LTImageItem *)model ;
- (void)deleteImageWithImgID:(NSString *)imgID;
- (void)deleteTraxAllImageList;
- (BOOL)createEngineWithBusinessDataIds:(NSArray *)ids;
- (BOOL)createEngineWithBusinessDataIds:(NSArray *)ids engineKey:(NSString*)engineKey;
- (void)modifyLenzTaskInfoWithTaskId:(NSString *)taskId;
- (void)ppzUploadFailDataWithObj:(id)aFailedData;
- (void)uploadFailedDatas;
- (void)uploadPPzImagesWithImageIndex:(NSString *)imageIndex;
- (void)jumpToPPZCameraWithPZType:(NSString *)pztype withVc:(UIViewController *)VC extendParam:(NSDictionary *)extendParam;
- (void)jumpToPPZCameraWithPZType:(NSString *)pztype withVc:(UIViewController *)VC engineKey:(NSString *)engineKey extendParam:(NSDictionary *)extendParam;

@end

NS_ASSUME_NONNULL_END
//=============================================================================================================================================================================================
