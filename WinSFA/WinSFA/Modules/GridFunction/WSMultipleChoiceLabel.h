//
//  WCMultipleChoiceLabel.h
//  WinChannelFrameWork
//
//  Created by xiaotang.wang on 4/8/13.
//
//

#import <UIKit/UIKit.h>
#import "WSValidateData.h"
#import "WSGettingValues.h"

@interface WSMultipleChoiceLabel : UILabel <WSValidateData, WSGettingValues>

@property (nonatomic, copy)NSString *iContent;
@property (nonatomic, retain)NSMutableDictionary *iInfos;

//前缀
@property (nonatomic, copy)NSString *iNotificationPrefix;

//行号
@property (nonatomic, assign)unsigned int iRow;

//列号
@property (nonatomic, assign)unsigned int iColumn;

//依赖类型
@property (nonatomic, assign)WSValidateDataDependType iDataType;

//存放多条消息
@property (nonatomic, strong)NSMutableDictionary *iDicNotificationName;

//逻辑类型
@property (nonatomic, assign)WSValidateDataLogicType iLogicType;

@property (nonatomic, assign) BOOL isValueChange;

//WSValidateData function
- (void)setNotificationPrefix:(NSString *)aNotificationPrefix
                       andRow:(unsigned int)aRow
                    andColumn:(unsigned int)aColumn
                  andDataType:(WSValidateDataDependType)aDataType;

- (void)startObservingEntity;

- (BOOL)entityIsEnable;

- (NSString *)getTextValue;

- (BOOL)isValueLegal;

@end
