//
//  WSGetValueByServerExecutor.m
//  WinSFA
//
//  Created by winchannel on 16/1/5.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSGetValueByServerExecutor.h"
#import "WSBaseHttpService.h"
#import "WSStoreAcvtDisArray.h"
#import "WSStoreAcvtDisBean.h"

#import "WSWidget.h"

@implementation WSGetValueByServerExecutor
-(LuaScriptWithParamsExpandBlock)getLuaScriptWithParamsExpandBlock{
    
    __weak __typeof(self) wself = self;
   
    LuaScriptWithParamsExpandBlock paramExpanedBlock = ^NSString *(id firstObj,...){
        
        __strong __typeof(wself) sself = wself ;

        //获得当前的执行者panel
        WSWidget *executWidget = (WSWidget *)sself.currentTargetObject;

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
         if (paramStr) {

            id args = va_arg(argsList, id);
            va_end(argsList);
             
            LogInfo(@"WSGetValueByServerExecutor,ObjId:%@,paramStr:%@,args:%@",objId,paramStr,args);
            self.service =[[WSStoreAcvtDisByDateHttpService alloc]initWithParamDictionary:paramDic];
             
                [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:NSLocalizedString(@"加载中…", nil)  tips:nil tapTarget:self action:nil];
                [self.service getStoreAcvtDisDataWithCompletionBlock:^(NSDictionary *dic, NSError *error) {
                    
                    [MBProgressHUD hideAllHUDsForView:kApplicationWinddow animated:YES];
                    if (error) {
                        
                        NSString *msg= NSLocalizedString(@"更新失败", nil);
                        BlockAlertView *alert = [BlockAlertView alertWithTitle:nil message:msg];
                        [alert addButtonWithTitle:NSLocalizedString(@"确定", nil) block:^{
                            
                        }];
                        [alert show];
                        
                        return ;
                    }
                    else{
                        [sself.delegate setUploadButtonHidden:NO];
                        //解析storeAcvtDisByDate节点
                        WSStoreAcvtDisArray *acvtDisArray = [[WSStoreAcvtDisArray alloc]initWithObject:dic andKey:objId];
                        //获取acvtView 的问题控件
                        NSMutableArray *acvtWidgetArray = [sself.delegate getQstWidgetArray];
                        
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
                                        [widget reloadCurrentWidgetWithValue:[qstValueArray componentsJoinedByString:@","]];
                                    }
                                }
                            }
                           
                        }
                        self.service = nil;
                    }
                }];
            }
        return @"";
    };
    return [paramExpanedBlock copy];
}
@end
