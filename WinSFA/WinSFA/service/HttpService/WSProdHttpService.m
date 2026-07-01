//
//  WSProdHttpService.m
//  WinSFA
//
//  Created by winchannel on 2017/11/23.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSProdHttpService.h"
#import "WSRequestHelper.h"
#import "WSBaseProductDBService.h"
#import "WSBaseDictsDBService.h"
#import "WSDictBean+child.h"

#define kNotifyName_ProdsOnTime @"prodontime"
#define kNotifyName_queryOrderProductInfo @"queryOrderProductInfo"

@interface WSProdHttpService ()

@property (nonatomic, copy) WSProdHttpServiceCompletionBlock completionBlock;

@end

@implementation WSProdHttpService

//- (NSDictionary *)getParametersDic
//{
//
//    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
//
//    [dic setObject:self.objID forKey:JSON_OBJID];
//    [dic setObject:[self getEmpID] forKey:JSON_EMPID];
//
//    return dic;
//
//}
- (void)getProdsDataWithCompletionBlock:(WSProdHttpServiceCompletionBlock)completionBlock{
    self.completionBlock = completionBlock;

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(finishRequest:)
                                                 name:kNotifyName_ProdsOnTime
                                               object:nil];
    [[WSRequestHelper shareInstance] postRequestOnRoadsManager:@{@"objId" :self.objID} notifyName:kNotifyName_ProdsOnTime];

}
- (void)finishRequest:(id)sender{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotifyName_ProdsOnTime object:nil];
    
    [MBProgressHUD hideAllHUDsForView:kApplicationWinddow animated:NO];
    
    NSString *info = [[sender userInfo] objectForKey:DATAS];
    NSError *error = [[sender userInfo] objectForKey:ERROR];
    NSDictionary *uploadState = [info objectFromJSONString];
    NSMutableArray *array = [NSMutableArray array];
    if (error.code != 0)
    {
        self.completionBlock(nil,error);
        return;
    }else{
        NSArray *dicts = [uploadState objectForKey:self.objID];
        for (NSObject *object in dicts) {
            WSDictBean *dictBean = [[WSDictBean alloc]initWithObject:object];
            NSMutableArray *array2 = [NSMutableArray array];
            
            // MN-1016 加入无产品的情况下也显示品牌的逻辑
            if (dictBean.child_data.count > 0) {
                for (NSObject *objet2 in dictBean.child_data) {
                    WSDictBean *dictBean2 = [[WSDictBean alloc]initWithObject:objet2];
                    NSMutableArray *array3 = [NSMutableArray array];

                    if (dictBean.child_data.count > 0) {
                        for (NSObject *objet3 in dictBean2.product) {
                            WSProdBean *prodBean = [[WSProdBean alloc]initWithObject:objet3];
                            [array3 addObject:prodBean];
                        }

                    }
                    if (array3.count > 0) {
                        dictBean2.childArray = array3;
                    }
                    [array2 addObject:dictBean2];
                }

            }
            
            if (array2.count > 0) {
                dictBean.childArray = array2;
            }
            
            [array addObject:dictBean];

        }
    }
    self.completionBlock(array, nil);
    
    
}

//请求产品促销详情
- (void)getSalesDetailStringWithStoreId:(NSString*)storeID  prodId:(NSString *)prodId CompletionBlock:(WSProdHttpServiceCompletionBlock)completionBlock {
    self.completionBlock = completionBlock;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(SalesDetailfinishRequest:)
                                                 name:kNotifyName_queryOrderProductInfo
                                               object:nil];
    [[WSRequestHelper shareInstance] postRequestOnRoadsManager:@{@"objId" :self.objID,@"storeId":(storeID ? : @""),@"prodId":(prodId ? : @"")} notifyName:kNotifyName_queryOrderProductInfo];
}
- (void)SalesDetailfinishRequest:(id)sender{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotifyName_queryOrderProductInfo object:nil];
    
    NSString *info = [[sender userInfo] objectForKey:DATAS];
    NSError *error = [[sender userInfo] objectForKey:ERROR];
    NSDictionary *uploadState = [info objectFromJSONString];
    if (error.code != 0)
    {
        self.completionBlock(nil,error);
        return;
    }else{
        NSArray *dicts = [uploadState objectForKey:self.objID];
        self.completionBlock(dicts, nil);
    }
    
    
}

@end
