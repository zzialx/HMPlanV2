//
//  WSGroupValidate.m
//  WinSFA
//
//  Created by winchannel on 16/1/15.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSGroupValidate.h"
#import "I_W_BuildInfo.h"
#import "WSAcvtModel.h"
#import "WSDataSourceManager.h"
#import "WSAcvtView.h"
#import "WSMessageObject.h"
#import "WSMessageCenter.h"

@implementation WSGroupValidate

- (NSObject *)executeGroupValidate:(NSObject<I_W_BuildInfo> *)buildinfo withAcvtView:(WSAcvtView *)acvtView{
    
    BOOL hasValue = NO;
    
    WSAcvtModel *acvtModel=(WSAcvtModel *)[WSDataSourceManager sharedInstance].currentActiveModel;
    
    NSDictionary *qstValueDict =(NSDictionary *)[acvtView getAllPrepareSubmitData];
    
    if ([buildinfo getGroupName].length>0) {
        //        MN-2605 donghong 分组不需要 is_req = 2 才判断 与安卓逻辑同  MN-2665 根据分组进行过滤
        //is_req = 2时代表有一组qst，只要有一个填了就可以，groupName用来代表分组。
        NSString *buildInfokey =[NSString stringWithFormat:@"%@%@",[buildinfo getWidgetId],[buildinfo getAcvtQstId]];
        
        id buildObj = [qstValueDict objectForKey:buildInfokey];
        
        NSString *buildObjStr = (NSString *)buildObj;
        
        if (buildObj == nil && buildObjStr.length == 0) {
            for (NSObject<I_W_BuildInfo> *otherBuildInfo in acvtModel.currentAcvtBean.qsts) {
                
                if ([[otherBuildInfo getGroupName] isEqualToString:[buildinfo getGroupName]]
                    &&![[otherBuildInfo getAcvtQstId] isEqualToString:[buildinfo getAcvtQstId]]) {
                    
                    NSString *key =[NSString stringWithFormat:@"%@%@",[otherBuildInfo getWidgetId],[otherBuildInfo getAcvtQstId]];
                    
                    id obj = [qstValueDict objectForKey:key];
                    
                    if (obj && [obj isKindOfClass:[NSString class]] ) {
                        
                        NSString *value = (NSString *)obj;
                        
                        if (value!= nil && [value length]>0) {
                            
                            hasValue = YES;
                            
                            break;
                        }
                    }
                }
            }
            
            if (!hasValue) {
                return [buildinfo getQuestName];
            }

        }
    }
    return nil;

}


@end
