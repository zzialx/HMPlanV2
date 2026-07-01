//
//  WSProdSalesDetailView.m
//  WinSFA
//
//  Created by zhangmin on 2018/11/9.
//  Copyright © 2018年 WinChannel. All rights reserved.
//产品促销详情视图

#import "WSProdSalesDetailView.h"
@interface WSProdSalesDetailView ()

@property (nonatomic, copy) NSString  *content;  //展示的文字
@property (nonatomic, assign) CGRect selectRect; //选中按钮相对屏幕的rect

@end
@implementation WSProdSalesDetailView


- (instancetype)initWithContentString:(NSString* )content selectButtonRect:(CGRect)selectRect
{
    if(self == [super init]) {
        
        self.content = [content stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"];
        self.selectRect = selectRect;
        [self setupViews];
    }
    return  self;
}
- (void)showSalesDetailView {
    [[[[UIApplication sharedApplication] delegate] window]  addSubview:self];

}
- (void)closeSalesDetailView {
     [self removeFromSuperview];
}

- (void)setupViews {
    
    self.frame = [UIScreen mainScreen].bounds;
    UIView *shadow = [[UIView alloc]initWithFrame:self.frame];
    shadow.alpha = 0.1;
    shadow.backgroundColor = [UIColor blackColor];
    [self addSubview:shadow];
    
    CGFloat width = SCREEN_WIDTH *0.75;
    NSString *string = self.content;
    
    CGFloat y_offset = 15 ;
    CGFloat margin = 15;
    
    //容器试图
    UIView *backGroundView = [[UIView alloc]initWithFrame:CGRectMake(0,0,0,0)];
    backGroundView.layer.cornerRadius = 10;
    backGroundView.alpha = 0.8;
    backGroundView.backgroundColor = [UIColor blackColor];
    
    
    UILabel *contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,0,0)];
    [contentLabel setNumberOfLines:0];
    contentLabel.lineBreakMode = NSLineBreakByWordWrapping;
    contentLabel.textAlignment = NSTextAlignmentLeft;
    contentLabel.contentMode = UIViewContentModeCenter;
    contentLabel.text = string;
    contentLabel.textColor = [UIColor whiteColor];
    NSString *stringValue = string;
    UIFont *font = [UIFont fontWithName:@"Arial" size:15];
    contentLabel.font = font;
    
    CGSize size = CGSizeMake(width - (2 * margin),MAXFLOAT);
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    
    CGSize labelsize2 = [stringValue boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSParagraphStyleAttributeName : paragraphStyle, NSFontAttributeName : font} context:nil].size;
    
    contentLabel.frame = CGRectMake(margin,y_offset, size.width, labelsize2.height);
    [backGroundView addSubview:contentLabel];
    
    CGFloat  backGroundViewX = SCREEN_WIDTH - width - margin;
    CGFloat  backGroundViewH = contentLabel.height + y_offset *2;
    CGFloat  backGroundViewY = self.selectRect.origin.y +self.selectRect.size.height + 50;
    if ((backGroundViewY + backGroundViewH) > SCREEN_HEIGHT ) { //y靠近按钮，超出 则显示靠底
         backGroundViewY =  SCREEN_HEIGHT - backGroundViewH - margin;
    }
    backGroundView.frame = CGRectMake(backGroundViewX, backGroundViewY, width, backGroundViewH);
    
    [self addSubview:backGroundView];
    
    CGFloat buttonWH = 30;
    UIButton * closeButton = [[UIButton alloc]initWithFrame:CGRectMake(width - buttonWH - 5, 5, buttonWH, buttonWH)];
    [closeButton setImage:[UIImage imageNamed:@"guanbi"] forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(closeSalesDetailView) forControlEvents:UIControlEventTouchUpInside];
    [backGroundView addSubview: closeButton];
    
}

@end
