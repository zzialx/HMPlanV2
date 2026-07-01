//
//  WSGridWidget.m
//  WinSFA
//
//  Created by Alicia on 2018/6/8.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import "WSGridWidget.h"

@implementation WSGridWidget

- (instancetype)initWithParam:(WSFuncsBean_Param *)param
                     rowIndex:(NSUInteger)rowIndex
                  columnIndex:(NSUInteger)colIndex {
    self = [super init];
    if (self) {
        self.param = param;
        self.iRow = rowIndex;
        self.iColumn = colIndex;
        self.m_col = param.col;
        self.iColumnName = param.name;
        
        [self setupView];
    }
    return self;
}

- (void)setupView {
    
}


- (void)add:(WSGridWidget *)gridWidget {
    
}

- (WSGridWidget *)getGridWidgetByKey:(NSString *)key {
    return nil;
}

- (NSArray *)getGridWidgetAllKeys {
    return nil;
}

- (NSString *)getGridWidgetParentKeyByWidget:(WSGridWidget *)gridWidget {
    return nil;
}

- (UIView *)getView {
    return nil;
}

- (NSString *)getValue {
    LogError(@"子类没有实现对应方法");
    return nil;
}

- (NSString *)getValuePresentation {
    return [self getValue];
}

- (NSString *)getUploadValue {
    return [self getValue];
}

- (NSString *)getDBValue {
    return [self getValue];
}

- (void)setValue:(NSString *)value {
    LogError(@"子类没有实现对应方法");
}

- (void)setMaxValue:(NSString *)maxValue {
    LogError(@"子类没有实现对应方法");
}

- (void)setMinValue:(NSString *)minValue {
    LogError(@"子类没有实现对应方法");
}

- (void)setRequest:(BOOL)isRequest {
    LogError(@"子类没有实现对应方法");
}

- (void)setReadonly:(BOOL)isReadonly {
    LogError(@"子类没有实现对应方法");
}

- (void)setTextColorHexString:(NSString *)colorHexString {
    LogError(@"子类没有实现对应方法");
}

- (CGFloat)getSum {
    return 0;
}


#pragma mark - Generate Key
+ (NSString *)getGridMaxCountByRowId:(NSString *)rowId col:(NSString *)col dictionary:(NSMutableDictionary *)dictionary {
    if (!rowId) {
        return nil;
    }
    NSString *key;
    if (col) {
        key = [NSString stringWithFormat:@"%@%@%@", rowId, kKeyProdIdColSeparator, col];
    } else {
        key = rowId;
    }
    NSString *oldMaxCount = [dictionary objectForKey:key];
    if ([oldMaxCount length] == 0) {
        //YIHAIKERRY-4349  益海嘉里-【订单管理】 【IOS】KDS系统单据传回后，手机端显示的产品顺序与添加的顺序不一致
        oldMaxCount = @"-1";
    }
    NSString *newMaxCount = [NSString stringWithFormat:@"%ld", [oldMaxCount integerValue] + 1];
    [dictionary setObject:newMaxCount forKey:key];
    return newMaxCount;
}

+ (NSString *)getGridWidgetKeyByRowId:(NSString *)rowId col:(NSString *)col dictionary:(NSMutableDictionary *)dictionary {
    if (!dictionary) {
        if (col) {
            return [NSString stringWithFormat:@"%@%@%@", rowId, kKeyProdIdColSeparator, col];
        } else {
            return rowId;
        }
    } else {
        NSString *maxCount = [self getGridMaxCountByRowId:rowId col:col dictionary:dictionary];
        NSString *key;
        if (col) {
            key  = [NSString stringWithFormat:@"%@%@%@%@%@", rowId, kKeyRepeatProdIdSeparator, maxCount, kKeyProdIdColSeparator, col];
        } else {
            key  = [NSString stringWithFormat:@"%@%@%@", rowId, kKeyRepeatProdIdSeparator, maxCount];
        }
       
        return key;
    }
}

+ (NSString *)getGridWidgetKeyByRowId:(NSString *)rowId col:(NSString *)col {
    return [WSGridWidget getGridWidgetKeyByRowId:rowId col:col dictionary:nil];
}

@end
