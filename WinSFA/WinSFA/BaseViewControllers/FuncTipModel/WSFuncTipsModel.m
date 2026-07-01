//
//  WSFuncTipsModel.m
//  WinSFA
//
//  Created by zzialx on 2023/11/18.
//  Copyright © 2023 WinChannel. All rights reserved.
//

#import "WSFuncTipsModel.h"

@implementation WSFuncTipsModel

@end

@implementation WSFuncTipsList

+ (NSDictionary *)modelContainerPropertyGenericClass {
    
    return @{@"funcTip" : [WSFuncTipsModel class]};
}

@end
