//
//  WSOffLineUploadTable.h
//  WinChannelFrameWork
//
//  Created by Chen Angus on 12-2-3.
//  Copyright 2012年 dumbrock. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WSSqliteUtil.h"
#import "WSStoreBean.h"
#import "WSFuncsBean.h"
#import "WSAppData.h"


typedef NS_OPTIONS (NSUInteger, UploadFlagType){
    Failed = 0,   //未上传数据
    Success = 1,  //上传成功数据
    Error = 2,    // 错误数据
    UploadedError = 3,    // 已经上传诊断日志的错误数据
    All = 4,    //全部
};


@interface WSOffLineUploadTable : WSSqliteUtil

+ (WSOffLineUploadTable *)sharedTable;

//清除前天数据
- (void)cleanOldData;

//更新离线上传数据状态
- (void)updateUploadFlagWithNotifyId:(NSString *)aNotifyId;
- (void)updateUploadFlagZeroWithNotifyId:(NSString *)aNotifyId;

//设置该记录为错误数 单条数据状态不能用imageIndex作为更新条件，因为它代表一组数据。但是为跟踪问题记录暂时保留这个参数，增加一个notifyId
- (void)updateUploadFlagErrorWithImageIndex:(NSString*)imageIndex notifyId:(NSString *)notifyId;

//将错误数据的flag设置为3
- (void)updateErrorToUploadedError;

//根据类型查询对象
- (NSArray*)queryWithUploadFlagType:(UploadFlagType)type;

//根据类型查询个数
- (NSInteger)queryCountWithUploadFlagType:(UploadFlagType)type;

//查询未上传数据的PhotoName
- (NSArray *)queryUploadFailedPhotoNames;

//根据img_idx查询
-(NSArray *)queryWithImg_idx:(NSString *)img_idx;

-(BOOL) insertUploadData:(NSString*)aPostDate
                     URL:(NSString*)aUrl
                     MD5:(NSString*)aMd5
                 IsPhoto:(BOOL)aIsPhoto
              NotifyName:(NSString*)aNotifyName;

-(BOOL) insertUploadMedia:(NSString *)aPostDate
                     Type:(NSString *)type
                      URL:(NSString *)aUrl
                      MD5:(NSString *)aMd5
                  IsPhoto:(BOOL)aIsPhoto
               NotifyName:(NSString *)aNotifyName
            photoFileName:(NSString *)photoFileName;

@end

