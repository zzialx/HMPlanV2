//
//  WSVideoView.h
//  WinSFA
//
//  Created by mac on 17/2/21.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WSVideoView : UIView
@property (nonatomic , copy) NSString * videoUrl;
@property (nonatomic , copy) NSString *type;
@property (nonatomic , assign)  BOOL isDownloadComplete; //是否下载完成
- (void)cancelDowmLoadVideo;
- (void)checkfileSizeForPath;

@end
