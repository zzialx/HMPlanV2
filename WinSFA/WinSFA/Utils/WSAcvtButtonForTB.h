//
//  WSAcvtButtonForTB.h
//  WinSFA
//
//  Created by xiaotang.wang on 9/2/13.
//  Copyright (c) 2013 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WSValidateData.h"

@interface WSAcvtButtonForTB : UIButton <WSValidateData, WSGettingValues>

@property (nonatomic, strong)NSString *iIdentifyId; //回显时使用
@property (assign) BOOL hasBeenFilled;

- (id)initWithFrame:(CGRect)frame;

- (void)setNotificationPrefix:(NSString *)aNotificationPrefix
                       andRow:(unsigned int)aRow
                    andColumn:(unsigned int)aColumn
                  andDataType:(WSValidateDataDependType)aDataType;

- (void)startObservingEntity;

- (BOOL)entityIsEnable;

//- (NSString *)getTextValue;

@end
