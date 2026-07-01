//
//  WSMainCellView.m
//  WinSFA
//
//  Created by heju on 12/16/13.
//  Copyright (c) 2013 WinChannel. All rights reserved.
//


#define k_IconYOffSet ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ?   10:40)
#define kIconRaito  0.5


#define k_LabelWidth ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ?  67: 114)
#define k_LabelHeight ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ?  21: 21 )
#define k_LabelXOffSet ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ?  ((320/3)-67)/2 :((768/3)-114)/2)


#define isIPhone4 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 960), [[UIScreen mainScreen] currentMode].size) : NO)
#define isIpad  (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

#define k_IconBaseTag 1000
#define k_CellViewBaseTag 100
#define k_DrawSepatateLineWidth  ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ?   1 :2 )

#define KMainCellViewTitleColor ([UIColor colorForKey:@"MainCellViewTitleColor"] ? [UIColor colorForKey:@"MainCellViewTitleColor"] :[UIColor blackColor])

#import "WSMainCellView.h"

@interface WSMainCellView () {
    CGFloat difDeviceIconYOffSet;
    CGFloat difDeviceLabelYOffSet;
}

- (void)initSubViews;
@end

@implementation WSMainCellView

- (id)initWithFrame:(CGRect)frame tag:(NSInteger)viewTag superColumns:(NSInteger)cCount
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.multipleTouchEnabled = NO;

        if (isIPhone4) {
            difDeviceIconYOffSet = -10.0f;
            difDeviceLabelYOffSet = -15.0f;
        }
        self.superColunms = cCount;
        _isHasBeenDarwed = NO;
        self.backgroundColor = [UIColor clearColor];
        self.tag = viewTag;
        self.viewTag = viewTag;
        [self setExclusiveTouch:YES];
        [self initSubViews];
    }
    return self;
}

- (void)initSubViews {
    /*
    _button = [UIButton buttonWithType:UIButtonTypeCustom];
    _button.frame = CGRectMake(k_ButtonXOffSet, k_ButtonYOffSet + deviceButtonYOffSet, k_ButtonWidth, k_ButtonHeight);
    _button.tag = k_ButtonBaseTag + self.viewTag;
    [_button addTarget:self action:@selector(changeBackgroundHighlighted) forControlEvents:UIControlEventTouchDown];
    [_button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [_button addTarget:self action:@selector(changeBackgroundNormal) forControlEvents:UIControlEventTouchDragOutside];
    [self addSubview:_button];
     */
 
 
    
    _iconBgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.width, self.height)];
    _iconBgView.layer.cornerRadius = 2.0f;
    [self addSubview:_iconBgView];
    
    
    CGFloat imageWH = self.height * kIconRaito;
    CGFloat paddingX = (self.width - imageWH) / 2;
    CGFloat paddingY = (self.height - imageWH - k_LabelHeight) * 0.5;
    _iconImageView = [[UIImageView alloc]initWithFrame:CGRectMake(paddingX, paddingY, imageWH, imageWH)];
    _iconImageView.tag = k_IconBaseTag + self.viewTag;
    [self addSubview:_iconImageView];
    
    _label = [[UILabel alloc]initWithFrame:CGRectMake(0, paddingY + imageWH, self.width, k_LabelHeight)];
    _label.backgroundColor = [UIColor clearColor];
    _label.font = [UIFont systemFontOfSize:UI_Font - 1];
    _label.textAlignment = NSTextAlignmentCenter;
    _label.numberOfLines = 0;
    _label.textColor = KMainCellViewTitleColor;
    [self addSubview:_label];
}



- (void)changeBackgroundHighlighted  {
//    self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"cell_selected.png"]];
    _iconBgView.backgroundColor = [UIColor colorWithRed:225.0f/255 green:225.0f/255 blue:225.0f/255 alpha:0.5f];
    self.label.textColor = [UIColor grayColor];
}

- (void)changeBackgroundNormal {
   _iconBgView.backgroundColor = [UIColor clearColor];
    self.label.textColor = KMainCellViewTitleColor;
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
//    UITapGestureRecognizer
    if (touch.view == self) {
        [self changeBackgroundHighlighted];
    }
    CGPoint endPoint = [touch  locationInView:self];
    CGRect contentRect = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    // 判断endPoint是否在当前cellView内
    BOOL  containsEndPoint = CGRectContainsPoint(contentRect, endPoint);
    if (containsEndPoint) {
    // do nothing
        if (touch.view == self) {
            if ( [_delegate respondsToSelector:@selector(cellView:touchBegin:)]) {
                [_delegate cellView:self touchBegin:self.viewTag];
            }
        }
    } else {
        [self changeBackgroundNormal];
    }

}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint endPoint = [touch  locationInView:self];
    CGRect contentRect = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    // 判断endPoint是否在当前cellView内
    BOOL  containsEndPoint = CGRectContainsPoint(contentRect, endPoint);
    if (containsEndPoint) {
        if (touch.view == self) {
            if ( [_delegate respondsToSelector:@selector(cellView:touchEnd:)]) {
                [_delegate cellView:self touchEnd:self.viewTag];
                [self changeBackgroundNormal];
            }
        }
    } else {
        [self changeBackgroundNormal];
    }
}



// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
/*
- (void)drawRect:(CGRect)rect
{
    // Drawing code.
    //获得处理的上下文
    CGContextRef context = UIGraphicsGetCurrentContext();
    //设置线条样式
    CGContextSetLineCap(context, kCGLineCapSquare);
    //设置线条粗细宽度
    CGContextSetLineWidth(context,k_DrawSepatateLineWidth);
    //设置颜色
    CGContextSetRGBStrokeColor(context, 162.0f/255,192.0f/255,245.0f/255, 1.0);
    // begain path
    CGContextBeginPath(context);
    //起始点设置为(0,rect.size.height):注意这是上下文对应区域中的相对坐标，
    CGContextMoveToPoint(context,0,rect.size.height);
    //设置下一个坐标点
    CGContextAddLineToPoint(context,rect.size.width,rect.size.height);
    //当此视图位于父视图的每一行的最后一个位置时候,不在此视图上画右侧分割线
    if ((self.tag - k_CellViewBaseTag)%self.superColunms != 2) {
        CGContextAddLineToPoint(context,rect.size.width, 0);
    }
    //连接上面定义的坐标点
    CGContextStrokePath(context);
 
}
 */


@end
