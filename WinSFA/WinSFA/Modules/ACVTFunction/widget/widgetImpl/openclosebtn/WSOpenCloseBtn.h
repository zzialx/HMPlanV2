//
//  WSOpenCloseBtn.h
//  WinSFA
//
//  Created by winchannel on 15/3/23.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSWidget.h"


@interface WSOpenCloseBtn : WSWidget{
    
    UIImageView  *openclosebtn;
    
    BOOL isopen;
    
    
    UIImage  *normalimg;
    
    UIImage   *heightlightimg;
    
    BOOL touchable;
}


@property (nonatomic,retain) UIImage  *normalimg;

@property (nonatomic,retain) UIImage   *heightlightimg;

- (id)initWithFrame:(CGRect)frame normalimg:(UIImage *)nimg hightlightimg:(UIImage *)himg;

-(void)setIsOpen:(BOOL)isopen;

-(void)setTouchable:(BOOL)istouchable;

@end
