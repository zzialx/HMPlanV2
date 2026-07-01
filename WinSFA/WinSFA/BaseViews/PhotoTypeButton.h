//
//  PhotoTypeButton.h
//  WinChannelFrameWork
//
//  Created by ZhengJiepeng on 13-5-9.
//
//

#import <Foundation/Foundation.h>
#import "WSValidateData.h"
#import "WSGettingValues.h"

#define PhotoTypeButton_Notification @"PhotoTypeButton_Notification"

@class PhotoTypeButton;

@protocol PhotoTypeButtonDelegate <NSObject>

@optional
- (void)photoTypeButtonClick:(PhotoTypeButton *)aPhotoTypeButton;

@end

@interface PhotoTypeButton : UIView <WSValidateData, WSGettingValues>

@property (nonatomic, strong) NSMutableArray *photoIDArray;
@property (nonatomic, strong, readonly) NSArray *deleteIDArray;
@property (nonatomic, strong) NSString *imageMD5;
@property (nonatomic, weak) id<PhotoTypeButtonDelegate> customDelegate;

@property (nonatomic,strong) NSString *qst_id;

@property (nonatomic, assign) NSInteger maxPhotoCount;

+ (NSString *)getPhotoMD5:(UIImage *)aImage;



/**
 发送消息前缀 一般为 fc_col 或者 mc_col
 **/
@property (nonatomic, copy)NSString *iNotificationPrefix;

//行号
@property (nonatomic, assign)unsigned int iRow;

//列号
@property (nonatomic, assign)unsigned int iColumn;

//是否是被依赖体
@property (nonatomic, assign)WSValidateDataDependType iDataType;

//存放多条消息
@property (nonatomic, strong)NSMutableDictionary *iDicNotificationName;

//逻辑类型
@property (nonatomic, assign)WSValidateDataLogicType iLogicType;

@property (nonatomic, assign) BOOL isValueChange;

@property (nonatomic, assign) BOOL isSupperLocalPhoto;


//- (id)initWithFuncs:(WSFuncsBean *)func;

- (void)setNotificationPrefix:(NSString *)aNotificationPrefix
                       andRow:(unsigned int)aRow
                    andColumn:(unsigned int)aColumn
                  andDataType:(WSValidateDataDependType)aDataType;

- (void)startObservingEntity;


- (BOOL)entityIsEnable;

//WSGettingValues
- (BOOL)isValueLegal;

- (void)resetTitle:(id)sender;

- (NSString *)getTextValue;


@end
