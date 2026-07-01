//
//  I_W_DisplayInfo.h
//  WinSFA
//
//  Created by winchannel on 15/3/6.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#ifndef WinSFA_I_W_BuildInfo_h
#define WinSFA_I_W_BuildInfo_h

@protocol IAttachment;

@class WSStoreBean;

@protocol I_W_BuildInfo <NSObject>

-(NSString *)getQuestName;

-(NSString *)getAcvtQstId;

@optional

-(NSString *)getWidgetId;

-(CGRect)getLayOutInfo;

-(void)setLayOutInfo:(CGRect)rect;

-(NSString *)getISRequire;

- (NSString *)getAcvtQstType;

-(NSString *)getQstId;

-(NSString *)getReadOnly;

-(NSString *)getTextColor;

-(NSString *)getAnswerColor;

-(NSString *)getBgColor;

-(NSString *)getDataSource;

-(NSString *)getFilterCondition;

-(void)setFilterCondition:(NSString *)filter;

-(NSMutableArray *)getAnswerOpt;

-(NSString *)getDefaultValue;

-(void)setDefaultValue:(NSString *)defaultValue;

-(NSString *)getSnumx;

- (void)setSnumx:(NSString *)snumx;

-(NSString *)getMumx;

- (void)setMumx:(NSString *)mumx;

-(NSString *)getMlen;

-(NSString *)getDlen;

-(NSArray *)getOptArray;

-(NSString*)getOrientation;

-(NSString *)getAcvtNestId;

- (NSString *)getAcvtMemo;
- (NSString *)getAcvtMemo1;
- (NSString *)getAcvtMemo2;
- (NSString *)getAcvtMemo3;
- (NSString *)getAcvtMemo4;

-(NSString *)getIsHidden;

-(NSString *)getNeedUploadData;

- (NSString *)getQstAlign;

- (NSString *)getColKey;//获得列的标识

-(void)setIsHidden:(NSString *)hidden;

-(void)needUploadData:(NSString *)needUploadData;

-(void)setIsReadOnly:(NSString *)readonly;

-(void)setIsRequire:(NSString *)isquire;

-(NSString *)getQuestPos;

//获得下载对象信息
-(NSObject<IAttachment> *)getMediaInfo;

//设置下载对象信息
-(void)setI_Media_Info:(NSObject<IAttachment> *)mediaInfo;


- (NSString *)getQuestIconURL;

- (NSString *)getCharNum;

- (NSString *)getGroupName;

- (NSString *)getTabGroupName;



/**
 *  获取lua脚本内容
 *
 *  @return
 */
- (NSString *)getLuaScript;
//- (void)setLuaScript:(NSString *)script;

/**
 *  菜单编码
 *
 *  @return
 */
- (NSString *)getMenuCode;

/**
 *
 *
 *  @return
 */
- (NSInteger)isSupperLocalPhotoForXB;

/**
 *  获取最大相片数
 *  0 为不限制
 *  @return
 */
- (NSInteger) getMaxPhoto;

- (void)setLuaScript:(NSString *)luaScript;

- (NSString *)getQstDescription;

- (NSString *)getQstHint;

- (NSString *)getQstCode;

- (NSString *)getIsHideQstName;

- (NSString *)getIsHideQstOptName;

- (NSString *)getRegularExpression;

- (NSString *)getDisplayMode;

- (NSString *)getParentQuestionId;

- (NSString *)getHideBottomLine;

- (NSString *)getWidthPercent;

- (NSString *)getPhotoIsCoverNewId;

- (NSString *)getLocationType;

- (void)setLocationType:(NSString *)locationType;
- (NSString *)getLayout_gravity;

- (NSString *)getTitleReadColor;
- (NSString *)getValueReadColor;
- (NSString *)getValueColor;
- (NSString *)getTitleSize;
- (NSString *)getValueSize;
- (NSString *)getDependon;

- (void)setCheckType:(NSString*)checkType;

- (NSString *)getCheckType; //获取检查类型方法

- (void)setIsNoInset:(BOOL)isNoInset;

- (BOOL)isNoInset;

@end
#endif
