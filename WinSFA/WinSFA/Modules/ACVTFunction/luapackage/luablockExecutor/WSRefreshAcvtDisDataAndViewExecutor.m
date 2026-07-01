//
//  WSRefreshAcvtDisDataAndViewExecutor.m
//  WinSFA
//
//  Created by winchannel on 16/1/16.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSRefreshAcvtDisDataAndViewExecutor.h"
#import "WSBaseHttpService.h"
#import "WSStoreAcvtDisArray.h"
#import "WSStoreAcvtDisBean.h"
#import "WSWidget.h"
#import "WSTAAcvtDataGridViewPanel.h"
#import "WSStoreBeans.h"
#import "WSBaseStoreTable.h"

@implementation WSRefreshAcvtDisDataAndViewExecutor

-(LuaScriptWithParamsExpandBlock)getLuaScriptWithParamsExpandBlock{
    
    __weak __typeof(self) wself = self;
    
    LuaScriptWithParamsExpandBlock paramExpanedBlock = ^NSString *(id firstObj,...){
        
        __strong __typeof(wself) sself = wself ;
        
        //service objId
        NSString *objId =[NSString stringWithFormat:@"%@",firstObj];
        
      
        
        va_list argsList;
        va_start(argsList, firstObj);
        id secondObj = va_arg(argsList, id);
        
        //参数(当配置参数时，字符串转字典，赋值给service)
        NSString *paramStr = [NSString stringWithFormat:@"%@",secondObj];
        //参数可配
        NSDictionary *paramDic = [NSMutableDictionary dictionary];
        [paramDic setValue:paramStr forKey:@"bizDate"];
        [paramDic setValue:objId forKey:@"objId"];
        if (paramStr && ![paramStr isEqualToString:@""]) {
         
            
            //args 需要执行实时刷新的qstCod
            id args = va_arg(argsList, id);
            va_end(argsList);
            
            LogInfo(@"WSGetValueByServerExecutor,ObjId:%@,paramStr:%@,args:%@",objId,paramStr,args);
            self.service =[[WSStoreAcvtDisByDateHttpService alloc]initWithParamDictionary:paramDic];
            
            [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:NSLocalizedString(@"加载中…", nil)  tips:nil tapTarget:self action:nil];
            
            [self.service getStoreAcvtDisDataWithCompletionBlock:^(NSDictionary *dic, NSError *error) {
                
                [MBProgressHUD hideAllHUDsForView:kApplicationWinddow animated:YES];
                
                NSMutableArray *acvtWidgetArray = [sself.delegate getQstWidgetArray];
                
                if (error) {
                    
                    NSString *msg= NSLocalizedString(@"refresh_failure", nil);
                    [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:msg tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
                    
                    return ;
                }
                else{
                    
                    NSArray *objArray =[dic objectForKey:objId];
                    NSDictionary *objDic =[objArray firstObject];
                    
                 
                    WSStoreBeans * storeBeans =[[WSStoreBeans alloc]initWithObjectForSer:objDic andParseKey:@"stores:storeAcvtDisByDate"];
                    WSStoreAcvtDisArray *acvtDisArray = [[WSStoreAcvtDisArray alloc]initWithObject:objDic andKey:@"acvtdis:storeAcvtDisByDate"];
                 
                   
                    if (storeBeans.storesArray.count >0) {
                        
                        WSWidget *currentExecuteObj =[acvtWidgetArray objectAtIndex:1];
                                
                        [currentExecuteObj updateContent:storeBeans.storesArray];
                                
                    }

                     //解析storeAcvtDisByDate节点
                    
                    //获取acvtView 的问题控件
                   
                    if (args && [args isKindOfClass:[NSArray class]]&& [args count]>0) {
                        
                        for (NSString *qstCod in args) {
                            
                            for (WSWidget *widget in acvtWidgetArray){
                                
                                if ([qstCod isEqualToString:[widget.xbuildInfo getQstCode]]){
                                    NSMutableArray *qstValueArray =[[NSMutableArray alloc]init];
                                    for (WSStoreAcvtDisBean *bean in acvtDisArray.storeAcvtDisArray) {
                                        if (bean.m_p.count >2) {
                                            NSString *acvtQstId   = [bean.m_p objectAtIndex:1];
                                            NSString *acvtQstValue =[bean.m_p objectAtIndex:2];
                                            if ([acvtQstId isEqualToString:[widget.xbuildInfo getAcvtQstId]]) {
                                                //根据回显结果重新赋值
                                                [qstValueArray addObject:acvtQstValue];
                                            }
                                        }
                                    }
                                    //storeAcvtDisByDate节点做单独处理
                                    if (qstValueArray.count && [objId isEqualToString:@"storeAcvtDisByDate"]) {
                                        
                                        [sself.delegate setUploadButtonHidden:YES];
                                    }
                                    if ([widget isKindOfClass:[WSTAAcvtDataGridViewPanel class]]) {
                                        [widget reloadCurrentWidgetWithValue:dic andRequestNodeName:objId];
                                    }else{
                                        [widget reloadCurrentWidgetWithValue:[qstValueArray componentsJoinedByString:@","]];
                                    }
                                }
                            }
                        }
                        
                    }
                    
                    self.service = nil;
                }
            }];
        } else {
            va_end(argsList);
        }
        
        return @"";
    };
    return [paramExpanedBlock copy];
}

@end
