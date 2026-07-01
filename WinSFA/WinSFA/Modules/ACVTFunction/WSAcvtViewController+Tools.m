//
//  WSAcvtViewController+Tools.m
//  WinSFA
//
//  Created by zzialx on 2025/7/9.
//  Copyright © 2025 WinChannel. All rights reserved.
//

#import "WSAcvtViewController+Tools.h"
#import "WSInventoryModel.h"
#import "WinInventoryPopupView.h"
#import "WinInventoryPopupView.h"
#import "WSRequestTools.h"
#import "YYModel.h"
#import "WinJYOrderDetialPopupView.h"
#import "FCFileManager.h" 
#import "WSAcvtModel.h"

@implementation WSAcvtViewController (Tools)

#pragma mark - # 显示库存建议订单alertView
- (void)showInventoryAlertViewWithResultDic:(NSDictionary*)resultDic withNotifyId:(NSString *)aNotifyId complete:(GoBackBlock)complete{
    
    if (!resultDic){
        if (complete) {
            complete();
        }
        return;
    }
    LogInfo(@"建议订单转发数据---->%@",resultDic);
    WSInventoryResultModel * resultModel = [WSInventoryResultModel yy_modelWithJSON:resultDic];
    NSString * title = [NSString stringWithFormat:@"%@-%@",self.currentStore.code,self.currentStore.name];
    NSString * subtotalValue = [NSString stringWithFormat:@"%@",resultModel.sum];
    @weakify_self
    WinInventoryPopupConfig *config = [[WinInventoryPopupConfig alloc] init];
    config.setTitle(title)
            .setSubtitle(@"建议订单已生成")
            .setPopupType(WinInventoryPopupTypeTwo)
            .setTableData(resultModel.data)
            .setSubtotalText(subtotalValue)
            .setCancelButtonTitle(@"返回")
            .setConfirmButtonTitle(@"转发")
            .setCancelAction(^{
                LogInfo(@"用户点击了取消");
                @strongify_self;
                //移除暂存信息（用户在弹出来建议订单弹框的时候，退到后台会有数据暂存下来）,暂时不采用先存再删除的方案，直接采用不存储的方案
                if (complete) {
                    complete();
                }
            })
            .setConfirmAction(^{
                LogInfo(@"用户点击了转发");
                @strongify_self;
                [self startDownLoadTaskWithFileUrl:resultModel];
            });
    [WinInventoryPopupView showWithConfig:config];
}
#pragma mark - # 下载建议订单文件
- (void)startDownLoadTaskWithFileUrl:(WSInventoryResultModel*)resultModel{
    
    
    if (resultModel.url.length==0||resultModel.url == nil) {
        [SVProgressHUD showHudMsg:@"没有下发下载链接"];
        return;
    }
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
    [SVProgressHUD showWithStatus:@"正在下载中"];
    NSURL *downloadURL = [NSURL URLWithString:resultModel.url];
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString * biz_date = [WSAppData getObjectbyKey:APPDATA_BIZDATE];
    NSString *destinationPath = [documentsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@/%@",@"share",biz_date,resultModel.mobileFileName]];
    //先删除旧的文件
    if ([FCFileManager existsItemAtPath:destinationPath]) {
        if ([FCFileManager removeItemAtPath:destinationPath]) {
            LogInfo(@"删除旧的文件");
        }
    }
    @weakify_self
    [WSRequestTools downloadFileFromURL:downloadURL toDestinationPath:destinationPath progress:^(NSProgress *downloadProgress) {
        // 更新UI进度
        dispatch_async(dispatch_get_main_queue(), ^{
            float progress = (float)downloadProgress.completedUnitCount / downloadProgress.totalUnitCount;
            NSLog(@"下载进度: %.2f%%", progress * 100);
               
        });
    } completion:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        if (error) {
            LogError(@"下载失败: %@", error.localizedDescription);
            [SVProgressHUD showHudMsg:error.localizedDescription];
        } else {
            [SVProgressHUD dismiss];
            LogInfo(@"下载成功，文件路径: %@", filePath);
            @strongify_self;
            [self shareFileToWeChatAtPath:filePath];
            
        }
    }];
}
- (void)shareFileToWeChatAtPath:(NSURL *)filePath {
    
    if(filePath==nil){
       [SVProgressHUD showHudMsg:@"文件下载路径不存在"];
       return;
    }
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc]
                                         initWithActivityItems:@[filePath]
                                   applicationActivities:nil];
    
    // 排除不需要的分享选项（可选）
    activityVC.excludedActivityTypes = @[
        UIActivityTypePostToFacebook,
        UIActivityTypePostToTwitter,
        UIActivityTypePostToWeibo,
        UIActivityTypeMessage,
        UIActivityTypeMail,
        UIActivityTypePrint,
        UIActivityTypeCopyToPasteboard,
        UIActivityTypeAssignToContact,
        UIActivityTypeSaveToCameraRoll,
        UIActivityTypeAddToReadingList,
        UIActivityTypePostToFlickr,
        UIActivityTypePostToVimeo,
        UIActivityTypePostToTencentWeibo
    ];
    
    activityVC.completionWithItemsHandler = ^(UIActivityType __nullable activityType,
                                          BOOL completed,
                                          NSArray *__nullable returnedItems,
                                          NSError *__nullable activityError) {
        if (completed) {
            LogInfo(@"分享成功，活动类型: %@", activityType);
            if ([activityType isEqualToString:UIActivityTypeMessage]) {
                NSLog(@"用户选择了通过短信分享");
            } else if ([activityType containsString:@"com.tencent.xin"]) {
                LogInfo(@"用户选择了通过微信分享");
            }
        } else {
            LogInfo(@"分享取消或失败");
            [SVProgressHUD showHudMsg:@"分享失败或者取消"];
        }
        
        if (activityError) {
            LogError(@"分享错误: %@", activityError.localizedDescription);
            [SVProgressHUD showHudMsg:@"分享失败"];
        }
    };
    
    [self presentViewController:activityVC animated:YES completion:nil];
}

@end
