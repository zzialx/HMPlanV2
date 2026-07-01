//
//  WSGridWidgetFactory.m
//  WinSFA
//
//  Created by Alicia on 2018/6/11.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import "WSGridWidgetFactory.h"

#define GRID_WIDGET_CONFIG_FILE     @"gridWidget"

@interface WSGridWidgetFactory ()

@property (nonatomic, strong) NSDictionary *gridConfigDic;

@end

@implementation WSGridWidgetFactory

static WSGridWidgetFactory *gridFactory;

+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        gridFactory = [[WSGridWidgetFactory alloc] init];
        
    });
    return gridFactory;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.gridConfigDic = [NSDictionary dictionaryWithDictionary:[WSPlistHelper allPropertiesWithPlistName:GRID_WIDGET_CONFIG_FILE]];
    }
    return self;
}


- (WSGridWidget *)createGridWidgetByParam:(WSFuncsBean_Param *)param rowIndex:(NSUInteger)rowIndex columnIndex:(NSUInteger)colIndex {
    NSDictionary *configDic = [self.gridConfigDic valueForKey:[param tpy]];
    NSString *widget_class_name = [configDic valueForKey:@"widget_class"];
    if (![widget_class_name isKindOfClass:[NSString class]] || [widget_class_name length] == 0) {
        widget_class_name = @"WSGridUnImplementLabel";
    }
    WSGridWidget *widget = (WSGridWidget *)[[NSClassFromString(widget_class_name) alloc] initWithParam:param rowIndex:rowIndex columnIndex:colIndex];
    if (widget) {
        widget.isSupportDepend = [configDic valueForKey:@"is_support_depend"];
        widget.groupName = [configDic valueForKey:@"group_name"];
    }
    return widget;
}

@end
