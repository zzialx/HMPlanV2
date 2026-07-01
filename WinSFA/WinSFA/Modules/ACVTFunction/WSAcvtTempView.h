//
//  WSAcvtTempView.h
//  WinSFA
//
//  Created by winchannel on 15/4/22.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WSAcvtTempView : UIView{
    
    BOOL iSneedlayout;
    
    BOOL isrise;
    
    CGFloat  risehight;
    
    UIView *resizeview;
}
@property (nonatomic,assign) BOOL iSneedlayout;
@property (nonatomic,strong) UIView *resizeview;
@property (nonatomic,assign) CGFloat  risehight;
@property (nonatomic,assign) BOOL isrise;


@end
