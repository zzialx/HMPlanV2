//
//  CalendarCell.m
//  TimeCalenda
//
//  Created by LIBB on 16/12/2.
//  Copyright © 2016年 huzepei. All rights reserved.
//

#import "CalendarCell.h"
#import "UIColor+Additions.h"
#import "WSDimensMacros.h"
#import "WSServerIPList.h"
#import "WSRequestHelper.h"

@implementation CalendarCell
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        
        CGFloat width = self.contentView.frame.size.width*0.4;
        CGFloat height = self.contentView.frame.size.height*0.4;
        UILabel *dayLabel = [[UILabel alloc] initWithFrame:CGRectMake( self.contentView.frame.size.width*0.5-width*0.5,  (self.contentView.frame.size.height-height)*0.5*0.5, width, height )];
        dayLabel.textAlignment = NSTextAlignmentCenter;
        dayLabel.textColor=[UIColor colorWithHexString:@"#242424"];
        dayLabel.font=[UIFont systemFontOfSize:UI_Font_Cell];
        [self.contentView addSubview:dayLabel];
        self.dayLabel = dayLabel;

        //分割线
        UIView * topline=[[UIView alloc]init];
        topline.frame=CGRectMake(0, self.contentView.bounds.size.height-2, self.contentView.bounds.size.width, 1);
        topline.backgroundColor=[UIColor colorWithRed:231.f/255.f green:231.f/255.f blue:231.f/255.f alpha:1];
        [self.contentView addSubview:topline];
        self.topLine = topline;
        
        UIView * bottomline=[[UIView alloc]init];
        bottomline.frame=CGRectMake(0, self.contentView.bounds.size.height-1, self.contentView.bounds.size.width, 1);
        bottomline.backgroundColor=[UIColor colorWithRed:241.f/255.f green:240.f/255.f blue:241.f/255.f alpha:1];
        [self.contentView addSubview:bottomline];
        self.bottomline = bottomline;
        
        isPlanImg=[[UIImageView alloc]initWithFrame:CGRectMake(width/2-4, CGRectGetMaxY(self.dayLabel.frame) + 2, 6, 6)];
//        cc_botomLImageView.center=CGPointMake(dayLabel.center.x, cc_botomLImageView.center.y);
        isPlanImg.image=[UIImage imageNamed:@"icon_signup_grey"];
        isPlanImg.hidden=YES;
        [self.contentView addSubview:isPlanImg];

        
        //10号 11号 12号 图片创建
        float cellwidth=self.contentView.bounds.size.width;
        float cellheight=self.contentView.bounds.size.height;
        float imageWidth=cellwidth/4.5;
        //图片距离底部距离
        CGFloat imageSpaceBottom = 5;
        //图片Y坐标
        CGFloat imageY = cellheight/2+(cellheight/2-imageWidth)/2;
#pragma mark -  ipad下的样式
        if (INTERFACE_IS_PAD)
        {
            //ipad修改label的frame
            dayLabel.frame = CGRectMake( self.contentView.frame.size.width*0.5-width*0.5,  (self.contentView.frame.size.height-width)*0.5-3, width, width);
            imageWidth = 15;
            imageY = self.contentView.frame.size.height-(imageSpaceBottom+imageWidth);
        }
        
        cc_botomLImageView=[[UIImageView alloc]initWithFrame:CGRectMake(cellwidth/2-imageWidth, imageY, imageWidth, imageWidth)];
        cc_botomLImageView.center=CGPointMake(dayLabel.center.x, cc_botomLImageView.center.y);
        cc_botomLImageView.image=[UIImage imageNamed:@"morning_icon__grey"];
        cc_botomLImageView.hidden=YES;

        [self.contentView addSubview:cc_botomLImageView];
        
        cc_botomRImageView=[[UIImageView alloc]initWithFrame:CGRectMake(cc_botomLImageView.frame.origin.x+cc_botomLImageView.bounds.size.width+5, cc_botomLImageView.frame.origin.y, imageWidth, imageWidth)];
        cc_botomRImageView.image=[UIImage imageNamed:@"birthday_iocn"];
        cc_botomRImageView.hidden=YES;
        [self.contentView addSubview:cc_botomRImageView];
        
        cc_topImageView=[[UIImageView alloc]initWithFrame:CGRectMake(cc_botomLImageView.frame.origin.x+cc_botomLImageView.bounds.size.width+5, dayLabel.frame.origin.y+(dayLabel.bounds.size.height-imageWidth)/2, imageWidth, imageWidth)];
        cc_topImageView.image=[UIImage imageNamed:@"button_waichu_icon"];
        cc_topImageView.hidden=YES;
        [self.contentView addSubview:cc_topImageView];

    }
    return self;
}

- (CAShapeLayer *)getDayLabelMask {
    CGFloat dayHeight = self.dayLabel.height;
    CGRect rect;
    UIBezierPath *maskPath;
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    if (INTERFACE_IS_PAD)
    {
        CGSize textSize = [self.dayLabel.text stringSizeWithFont:self.dayLabel.font width:self.dayLabel.width];
        CGFloat textWidth = textSize.width>textSize.height?textSize.width+10:textSize.height+10;
        CGFloat X = (dayHeight-textWidth)/2;
        rect = CGRectMake(X*0.5, X*0.5, textWidth, textWidth);
    }
    else
    {
        rect = self.dayLabel.bounds;
    }
    
    maskPath = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:dayHeight];
    maskLayer.frame = rect;
    maskLayer.path = maskPath.CGPath;
  
    return maskLayer;
}

- (void)setMonthModel:(MonthModel *)monthModel{
    _monthModel = monthModel;
    self.dayLabel.text = [NSString stringWithFormat:@"%02ld",monthModel.dayValue];
    UIColor *color = [UIColor colorWithRed:32.f/255.f green:166.f/255.f blue:249.f/255.f alpha:1];
    if(self.newPlan)
    {
        CGFloat width =  self.contentView.frame.size.width*0.5;
        self.dayLabel.frame =  CGRectMake( self.contentView.frame.size.width*0.5-width*0.5,  (self.contentView.frame.size.height-width)*0.5*0.5, width, width );
        isPlanImg.frame = CGRectMake(self.contentView.frame.size.width/2-3, CGRectGetMaxY(self.dayLabel.frame) + 2, 6, 6);
        self.topLine.hidden = YES;
        self.bottomline.hidden = YES;
        color = [UIColor colorWithHexString:@"#28A707"];
        if(!monthModel.isCurMonth){
            self.dayLabel.hidden = YES;
        }
        else{
            self.dayLabel.hidden = NO;
        }
    }

    
    if (monthModel.isSelectedDay) {
        self.dayLabel.backgroundColor = color;
        self.dayLabel.textColor = [UIColor whiteColor];
        self.dayLabel.layer.mask = [self getDayLabelMask];
    }else {
        if(monthModel.isCurMonth){
           self.dayLabel.textColor=[UIColor colorWithHexString:@"#242424"];
        }else{
            self.dayLabel.textColor=[UIColor colorWithHexString:@"#a7a7a7"];
        }
        self.dayLabel.backgroundColor = [UIColor clearColor];
        self.dayLabel.layer.mask = nil;
    }
    
    
    //设置图片
    if(monthModel.num10ImageUrl){
        cc_topImageView.hidden=NO;
        [[WSRequestHelper shareInstance] downloadImageWithUrl:monthModel.num10ImageUrl imageView:cc_topImageView completed:^(UIImage *image, NSError *error, NSURL *imageURL) {
            if (image) {
                cc_topImageView.image = image;
                [cc_topImageView setNeedsLayout];
            }
        }];
    }else{
        cc_topImageView.hidden=YES;
    }
    
    if(monthModel.num12ImageUrl){
        cc_botomLImageView.hidden=NO;
        [[WSRequestHelper shareInstance] downloadImageWithUrl:monthModel.num12ImageUrl imageView:cc_botomLImageView completed:^(UIImage *image, NSError *error, NSURL *imageURL) {
            if (image) {
                cc_botomLImageView.image = image;
                [cc_botomLImageView setNeedsLayout];
            }
        }];
    }else{
        cc_botomLImageView.hidden=YES;
    }
    if(monthModel.num13ImageUrl){
         cc_botomRImageView.hidden=NO;
        [[WSRequestHelper shareInstance] downloadImageWithUrl:monthModel.num13ImageUrl imageView:cc_botomRImageView completed:^(UIImage *image, NSError *error, NSURL *imageURL) {
            if (image) {
                cc_botomRImageView.image = image;
                [cc_botomRImageView setNeedsLayout];
            }
        }];
       
    }else{
        cc_botomRImageView.hidden=YES;
    }
    
}
- (void)setIsPlan:(BOOL)isPlan
{
    _isPlan = isPlan;
    if (_isPlan) {
        isPlanImg.hidden = NO;
    }else{
        isPlanImg.hidden = YES;
    }
}
-(void)setVisible:(BOOL)visible{
    
    _visible=visible;
    UIView *backView = self.contentView;
    NSMutableArray *array = [NSMutableArray array];
    for (CALayer *layer in backView.layer.sublayers) {
        if ([layer.name isEqualToString:@"eventIndentiferLayer"]) {
            [array addObject:layer];
        }
    }
    for (CALayer *layer in array) {
        [layer removeFromSuperlayer];
    }
    if (_visible) {
        //选中
//        self.dayLabel.frame =  CGRectMake( self.contentView.frame.size.width*0.5-width*0.5,  (self.contentView.frame.size.height-width)*0.5*0.5, width, width );
        CGRect rect = CGRectMake(0, 0, backView.bounds.size.width, backView.bounds.size.height - 2);
        CGFloat width = 10;
        UIColor *color = [UIColor colorWithRed:32.f/255.f green:166.f/255.f blue:249.f/255.f alpha:1];
        
        if(self.newPlan){
            width =  self.contentView.frame.size.width*0.5;
            rect = CGRectMake( self.contentView.frame.size.width*0.5-width*0.5,  (self.contentView.frame.size.height-width)*0.5*0.5, width, width);
            color = [UIColor colorWithHexString:@"#28A707"];
        }
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:width/2];
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.frame = rect;
        maskLayer.path = maskPath.CGPath;
        maskLayer.name = @"eventIndentiferLayer";
        maskLayer.fillColor = [[UIColor clearColor] CGColor];
        maskLayer.borderColor = color.CGColor;
        maskLayer.borderWidth = 1.5;
        if(self.newPlan){
            maskLayer.cornerRadius = width/2;
        }
        [backView.layer insertSublayer:maskLayer atIndex:0];
    }
}


@end

