//
//  WSPhotoViewPanel.h
//  WinSFA
//
//  Created by xiajl on 15/4/15.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSSingleTitlePanel.h"
@class WSPhotoBrowseView;
//=============================================================================================================================

#pragma mark - 照片视图面板
@interface WSPhotoViewPanel : WSSingleTitlePanel

@property (nonatomic, strong) WSPhotoBrowseView *photoView;     //照片浏览视图
@property (nonatomic, strong) NSMutableArray *delPhotoBrowses;  //删除照片浏览视图数组
@property (nonatomic, copy) NSString *randomMD5;                //随机md5值

- (NSString *)getAcvtQstId; //获取问题id方法

@end
//=============================================================================================================================
