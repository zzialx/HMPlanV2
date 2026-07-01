//
//  WSDocDownLoadVController.h
//  WinSFA
//
//  Created by mac on 16/12/2.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "WSMappingObject.h"

@interface WSDocDownLoadVController : BaseViewController
@property(nonatomic,strong) WSDownloadFileObject * downLoadFileObject;
@property (strong, nonatomic) UIDocumentInteractionController *documentInteractionController;
@property (nonatomic,copy) void (^back)(); // 完成后刷新 列表状态
-(void)startOrStop;
@end
