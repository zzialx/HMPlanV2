//
//  WSGridStringValueChangeChecker.m
//  WinSFA
//
//  Created by wangzhiwei on 2018/6/28.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import "WSGridStringValueChangeChecker.h"
#import "WSAcvtDataGridViewPanel.h"
@implementation WSGridStringValueChangeChecker

- (BOOL)checkValueIsChange:(NSObject<I_W_ValueChangeObject> *)object {
//  TODO-----
//    SFA-21519
//    立白SFA【经销商】IOS-新增订单/门店拜访订单/车销售订单，在添加产品页面勾选产品不填数量/子数量，完成添加返回新增订单页面填写数量/子数量，再修改数量/子数量，未上传数据，点返回键没有弹出提示语
    //添加了产品以后才判断是否改变上面的值
   BOOL isEdited = [object isEdited];
    if (isEdited) {
        if (![object isKindOfClass:[WSAcvtDataGridViewPanel class]]) {
            BOOL isChange = [super checkValueIsChange:object];
            return isChange;
        }
    }
    return isEdited;
}

@end
