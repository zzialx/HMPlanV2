//
//  WSHelpSalesViewConfig.m
//  WinSFA
//
//  Created by zzialx on 2025/5/7.
//  Copyright © 2025 WinChannel. All rights reserved.
//

#import "WSHelpSalesViewConfig.h"

@implementation WSHelpSalesViewConfig

- (WSHelpSalesViewConfig *(^)(NSString *))setDefaultConfig{
    return ^WSHelpSalesViewConfig *(NSString * defaultConfig){
        self.isCanSelectVisitModule = YES;
        self.isCanSelectHelpSalesModule = YES;
        self.defaultConfig = defaultConfig;
        return self;
    };
}

- (WSHelpSalesViewConfig *(^)(UIColor *))setBgColor
{
    return ^WSHelpSalesViewConfig *(UIColor *bgColor){
        self.bgColor = bgColor ;
        return self ;
    };
}
- (WSHelpSalesViewConfig *(^)(BOOL ))setIsCanSelectVisitModule{
    return ^WSHelpSalesViewConfig *(BOOL isCanSelectVisitModule){
        self.isCanSelectVisitModule = isCanSelectVisitModule ;
        return self ;
    };
}
- (WSHelpSalesViewConfig *(^)(BOOL ))setIsCanSelectHelpSalesModule{
    return ^WSHelpSalesViewConfig *(BOOL isCanSelectHelpSalesModule){
        self.isCanSelectHelpSalesModule = isCanSelectHelpSalesModule ;
        return self ;
    };
}

@end
