//
//  WSAcvtQstWidgetRelationTools.h
//  WinSFA
//
//  Created by HZH on 2018/5/15.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WSAcvtQstWidgetRelationTools : NSObject

//+ (instancetype)sharedManager;

// 实时获取调查问卷问题的数据源或者显示值，暂时只有下拉框用到，之后可在用到的问题类型panel里面添加
- (void)getRealtimeDataWithParamDic:(NSDictionary *)paramDic andRealtimeRequestFinishCallback:(void (^)(id resultDic))callback;

@end
