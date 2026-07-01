//
//  WSGridPhotoButton.h
//  WinSFA
//
//  Created by Alicia on 2018/6/8.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import "WSGridWidget.h"
@class PhotoTypeButton;

@interface WSGridPhotoButton : WSGridWidget

@property (nonatomic, assign) NSInteger maxPhotoCount;
@property (nonatomic, strong) PhotoTypeButton *photoButton;

@end
