//
//  WSImageViewPanel.h
//  WinSFA
//
//  Created by huzepei on 17/1/4.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSSingleTitlePanel.h"

@interface WSImageViewPanel : WSSingleTitlePanel
@property (nonatomic,retain) UIImageView * headImageView;
@property (nonatomic,strong) UIAlertController * alartVC;
@property (nonatomic,strong) NSString * imageID;

@end
