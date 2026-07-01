//
//  WSPaiPaiUploadCallBack.m
//  WinSFA
//
//  Created by zhangmin on 2019/12/9.
//  Copyright © 2019 WinChannel. All rights reserved.
//

#import "WSPaiPaiUploadCallBack.h"

@implementation WSPaiPaiUploadCallBack

- (void)dealloc {
    NSLog(@"call dealloc");
}
- (void)setEngine:(LenzEngine *)engine {
    _lenzEng = engine;
}

//LenzEngine初始化时传入的参数
- (void)setBusinessDataIds:(NSArray *)businessDataIds {
    _busDataIds = businessDataIds;
}

//LenzEngine初始化时传入的taskInfo
- (void)setTaskInfo:(LenzTaskInfo *)taskInfo {
    _lenzInfo = taskInfo;
}


//上传进度回调
- (void)progress:(NSUInteger)current total:(NSUInteger)total progress:(float)progress {
    LogInfo(@"当前文件：%zd,总文件：%zd,但前文件的上传进度%f",current,total,progress);
}
//上传成功或者失败
- (void)completion:(BOOL)success message:(NSString *)message code:(NSInteger)code data:(NSDictionary *)data{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD hideAllHUDsForView:kApplicationWinddow animated:NO];
    });
    if (success) {
        LogInfo(@"提交图片到ppz成功,busDataIds = %@",self.busDataIds);
        self.successBlock(success, self.busDataIds);
        
    }else {
        LogError(@"提交图片失败---code=%ld,message = %@,busDataIds = %@",(long)code,message,self.busDataIds);
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:message tips:nil tapTarget:nil action:nil
                                     type:MBProgressHUDMessageTypeFailed];
        });

    }
}



@end
