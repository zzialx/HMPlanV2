//
//  WSRadioButton.h
//  WinSFA
//
//  Created by heju on 14-4-17.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//  单选按钮

#import <UIKit/UIKit.h>
#import "WSValidateData.h"
#import "WSGettingValues.h"

@interface WSRadioButton : UIButton <WSValidateData,WSGettingValues>

@property (nonatomic, assign) BOOL isClicked;

// 控件的表格属性
@property (nonatomic, copy) NSString  *m_col;


- (id)initWithFrame:(CGRect)frame;

- (void)setNotificationPrefix:(NSString *)aNotificationPrefix
                       andRow:(unsigned int)aRow
                    andColumn:(unsigned int)aColumn
                  andDataType:(WSValidateDataDependType)aDataType;

- (void)startObservingEntity;

- (BOOL)entityIsEnable;

-(void)setCurSelected:(BOOL)selected;

@end
