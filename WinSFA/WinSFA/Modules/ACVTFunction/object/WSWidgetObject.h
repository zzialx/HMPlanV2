//
//  WSWidgetObject.h
//  WinSFA
//
//  Created by winchannel on 15/3/6.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WSWidgetObject : NSObject

@property (nonatomic,retain) NSString  *widgetId;   //控件id

@property (nonatomic,retain) NSString  *widget_class;   //控件类名称

@property (nonatomic,retain) NSString  *validate_class;  //验证类

@property (nonatomic,retain) NSString  *group_validate_class; //组合验证类

@property (nonatomic,retain) NSString  *descriptionInfo;  //描述

@property (nonatomic,retain) NSString  *datasource_class;  //数据源类   －－－即将作废

@property (nonatomic,retain) NSString  *displayValue_class;    //显示的值类

@property (nonatomic,retain) NSMutableDictionary  *datasource_class_m;  //多数据源扩展


@end
