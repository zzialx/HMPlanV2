//
//  WSAcvtModel.h
//  WinSFA
//
//  Created by yang on 15/3/31.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSBaseModel.h"
#import "WSHosBean.h"
#import "I_W_BuildInfo.h"

@class WSAcvtBean;
@class WinEnterBackgroundDataModel;

#define HORIZONTAL_GROUP_START @"horizontal_group_start"
#define HORIZONTAL_GROUP_INNER @"horizontal_group"
#define HORIZONTAL_GROUP_END @"horizontal_group_end"

@interface WSAcvtModel : WSBaseModel

@property (nonatomic, strong) WSAcvtBean *currentAcvtBean;
@property (nonatomic, strong) NSMutableDictionary *qstDBValueDictionary;
@property (nonatomic, assign) BOOL isNewAddAcvt;
@property (nonatomic, copy) NSString *subEmpId;
@property (nonatomic, strong) NSMutableDictionary *anJsonDataDictionary;
@property (nonatomic, assign) BOOL hasLoadDataBaseData;
@property (nonatomic, assign) BOOL hasLocalData;
@property (nonatomic,strong) WSHosBean *hosBean;
@property (nonatomic,strong) NSString *luaExecuteParams;
@property (nonatomic,strong) NSString *updateGenId;
@property (nonatomic,assign) BOOL isSubAcvt;
@property (nonatomic, copy) NSString *feedbackPhotoId;                      //用于设置截屏反馈图片
@property (nonatomic, strong) NSDictionary *customEnterStoreTimeDic;        //补录时间dic
@property (nonatomic, copy) NSString *confirm;                              //确认字段
@property (nonatomic, assign) BOOL isReqFromLua;                            //问卷调查是否必填（和安卓一致）

- (NSString *)getAcvtDisValueByAcvtQstId:(NSString*)acvtQstId;
- (NSString *)getAcvtDisValueWhenCreatetForPeopleByQstId:(NSString *)acvtQstId;
- (NSString *)generateAcvtStoreNameWithQstValueDic:(NSDictionary *)qstValueDic;
- (NSString *)getAcvtDisValueByStore:(WSStoreBean *)store acvtQstId:(NSString *)acvtQstId;
- (NSArray *)getAcvtDisArrayValueByAcvtQstId:(NSString*)acvtQstId;
- (void)setUpQstDBValueDicWithAcvtQstObjectArray:(NSArray *)array;
- (BOOL)isNeedNewImageIndex;                                                                //是否需要重新生成照片的imageIndex
- (BOOL)firstLoadIsExtended:(id<I_W_BuildInfo>)buildInfo;
- (BOOL)isFromNewAddList;
- (BOOL)isSupperChangedLocalPhoto;
- (BOOL)isSynchronizeRequest;
- (BOOL)needSoleTime;
- (BOOL)deleteAcvtDatasWithGenId:(NSString *)genId;

- (BOOL)enterBackgroundSaveAcvtDatasToDB:(NSDictionary *)dataDic useNewMd5:(NSString *)newMd5
                                   vcMd5:(NSString *)vcMd5 vcUpdateGenId:(NSString *)vcUpdateGenId; //进入后台保存调查问卷数据方法
- (BOOL)saveAcvtDatasToDB:(NSDictionary *)dataDic useNewMd5:(NSString *)newMd5;                     //保存调查问卷数据方法
- (BOOL)getEnterBackgroundSaveAcvtDataMark;                                                         //获取进入后台存储调查问卷数据标识(开关)方法
- (WinEnterBackgroundDataModel *)queryEnterBackgroundMark;                                          //查询进入后台标识方法
+ (void)clearEnterBackgroundMarkWithMD5:(NSString *)md5;                                            //通过md5清除进入后台标识
+ (void)claerDateEnterBackgroundMark;                                                               //清除日期后台标识
+ (void)claerAllEnterBackgroundMark;                                                                //清除全部后台标识

@end

#pragma mark - 进入后台数据模型
@interface WinEnterBackgroundDataModel : NSObject

@property (nonatomic, copy) NSString *vcMd5;
@property (nonatomic, copy) NSString *vcUpdateGenId;
@property (nonatomic, copy) NSString *modelMd5;
@property (nonatomic, copy) NSString *modelUpdateGenId;

@end
