//
//  WSEnterStoreAcvtModel.m
//  WinSFA
//
//  Created by yang on 16/12/9.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSEnterStoreAcvtModel.h"

@implementation WSEnterStoreAcvtModel

#pragma mark - 重写loadDataFromDataBase方法
- (void)loadDataFromDataBase {
    
    //开启了app进入后台缓存功能 会调用读取缓存 其他情况不加载缓存
    WinEnterBackgroundDataModel *model = [self queryEnterBackgroundMark];
    if (model) {
        [super loadDataFromDataBase];
    }
}

#pragma mark - 获取md5参数
- (NSDictionary *)md5Param {
    
    //进店配置成调查问卷显示时 MD5还是根据原来规则生成 不需要拼接acvtId 所以重写此方法
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    if ([self.currentVisitAction.module_fc length] > 0) {
        [dic setValue:self.currentVisitAction.module_fc forKey:MEMO_MD5_PARAM_KEY];
    }
    
    return dic;
}

@end
