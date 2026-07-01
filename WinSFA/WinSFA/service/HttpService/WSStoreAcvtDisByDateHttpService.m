//
//  WSStoreAcvtDisByDateHttpService.m
//  WinSFA
//
//  Created by winchannel on 16/1/4.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSStoreAcvtDisByDateHttpService.h"
#import "WSRequestHelper.h"

#define UPDATE_NOTIFY       @"upDate_notify"
@interface WSStoreAcvtDisByDateHttpService ()

@property (nonatomic, copy) WSBaseHttpServiceBlock completionBlock;

@end

@implementation WSStoreAcvtDisByDateHttpService

- (NSString *)getEmpID{

    if ([self.jsEmpID length]> 0) {
        return self.jsEmpID;
    }
    return [super getEmpID];
}

- (NSString *)getObjID{
    
    if ([self.paramDic objectForKey:@"objId"]) {
        
        return [self.paramDic objectForKey:@"objId"];
    }
    return nil;
}

- (NSString *)getTime{
    
    if ([self.date length]>0) {
        return self.date;
    }
    else if([self.paramDic objectForKey:@"bizDate"]){
        
        return [self.paramDic objectForKey:@"bizDate"];
    }
    return nil;
}

- (NSDictionary *)getParametersDic{
    NSMutableDictionary *dic =[NSMutableDictionary dictionary];
    
    if ([self getTime]) {
        [dic setObject:[self getTime] forKey:@"bizDate"];
    }
    [dic setObject:[self getObjID] forKey:@"objId"];
    [dic setObject:[self getEmpID] forKey:@"empId"];
    
    return dic;
}
- (void)getStoreAcvtDisDataWithCompletionBlock:(WSBaseHttpServiceBlock)completionBlock{
    
    self.completionBlock = completionBlock;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(finishRequest:)
                                                 name:UPDATE_NOTIFY
                                               object:nil];
    WSRequestHelper *uploadMgr = [WSRequestHelper shareInstance];
    [uploadMgr postRequestData:[self getParametersDic] notifyName:UPDATE_NOTIFY];

}


-(void)finishRequest:(id)sender{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UPDATE_NOTIFY
                                                  object:nil];
    

    
     NSString *info = [[sender userInfo] objectForKey:DATAS];
    //NSLog(@"outplan is %@",info);
     NSError *error = [[sender userInfo] objectForKey:ERROR];
    
     if (error.code != 0) {
        self.completionBlock(nil,error);
        NSString *tmpString = NSLocalizedString(@"network_failure",nil);
         NSLog(@"WSStoreAcvtDisByDateHttpServiceBlock ===>> finishRequest:%@",tmpString);
        return;
        
     }
    NSDictionary *dataDic = [info objectFromJSONString];
    self.completionBlock(dataDic,nil);
    

}
@end
