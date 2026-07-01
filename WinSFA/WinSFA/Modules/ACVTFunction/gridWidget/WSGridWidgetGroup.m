//
//  WSGridWidgetGroup.m
//  WinSFA
//
//  Created by Alicia on 2018/6/29.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import "WSGridWidgetGroup.h"

@interface WSGridWidgetGroup ()

@property (nonatomic, strong) NSMutableDictionary *groupDictionary;

@end


@implementation WSGridWidgetGroup

- (instancetype)initWithParam:(WSFuncsBean_Param *)param
                     rowIndex:(NSUInteger)rowIndex
                  columnIndex:(NSUInteger)colIndex {
    self = [super initWithParam:param rowIndex:rowIndex columnIndex:colIndex];
    if (self) {
        self.widgetKey = self.param.tpy;
    }
    return self;
}
- (void)add:(WSGridWidget *)gridWidget {
    NSString *key = gridWidget.widgetKey;
    if (!key) {
        LogError(@"未设置Key");
        return;
    }
    [self.groupDictionary setObject:gridWidget forKey:key];
}

- (void)removeGridWidgetByKey:(NSString *)key {
    [self.groupDictionary removeObjectForKey:key];
}

- (WSGridWidget *)getGridWidgetByKey:(NSString *)key {
    if (!key) {
        return self;
    }
    WSGridWidget *gridWidget = [self.groupDictionary objectForKey:key];
    if (!gridWidget && [key containsString:@"_"]) {
        LogError(@"找不到表格控件: %@", key);
    }
    return gridWidget;
}

- (NSString *)getGridWidgetParentKeyByWidget:(WSGridWidget *)gridWidget {
     if ([gridWidget isMemberOfClass:[WSGridWidgetGroup class]]) {
         return nil;
     } else {
         return [WSGridWidget getGridWidgetKeyByRowId:gridWidget.rowId col:gridWidget.param.parent];
     }
}

- (NSArray *)getGridWidgetAllKeys {
    return [self.groupDictionary allKeys];
}

- (CGFloat)getSum {
    CGFloat sum = 0;
    NSArray *allKeys = [self getGridWidgetAllKeys];
    for (NSString *key in allKeys) {
        WSGridWidget *widget = [self getGridWidgetByKey:key];
        if (![widget isKindOfClass:[WSGridWidgetGroup class]]) {
            sum +=[widget getSum];
        }
    }
    return sum;
}

#pragma mark - Setters
- (NSMutableDictionary *)groupDictionary {
    if (!_groupDictionary) {
        _groupDictionary = [NSMutableDictionary dictionary];
    }
    return _groupDictionary;
}

@end

