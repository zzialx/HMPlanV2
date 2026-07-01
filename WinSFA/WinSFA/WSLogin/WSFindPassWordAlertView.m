//
//  WSFindPassWordAlertView.m
//  WinSFA
//
//  Created by zhangmin on 2018/9/17.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import "WSFindPassWordAlertView.h"



@interface WSFindPassWordAlertView()<UITextViewDelegate>

//title
 @property (strong , nonatomic)  UITextView *textview;
@property (nonatomic,copy) NSString *phoneNum;


@end

@implementation WSFindPassWordAlertView

- (instancetype)init
{
    if(self == [super init])
    {
        self.frame = [UIScreen mainScreen].bounds;
        UIView *shadow = [[UIView alloc]initWithFrame:self.frame];
        shadow.alpha = 0.3;
        shadow.backgroundColor = [UIColor blackColor];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(closeAlertView)];
        [shadow addGestureRecognizer:tap];
        [self addSubview:shadow];
        
        
        //视图
        UIView * imgBackground = [[UIView alloc] init];
        imgBackground.layer.cornerRadius = 10;
        imgBackground.backgroundColor = [UIColor whiteColor];
        [self addSubview:imgBackground];

        //内容
        self.textview = [[UITextView alloc] init];
        
        NSString *findPasswordMjet = [WSPlistHelper valueForKey:kGET_PASSWORD_URL withPlistName:kConfilgFileName];
        NSArray *array = [findPasswordMjet componentsSeparatedByString:@"/"];
        NSString *phone = @"";
        if (array.count == 2) {
            phone = [array lastObject];
            self.phoneNum = phone;
        }
        
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]initWithString:[findPasswordMjet stringByReplacingOccurrencesOfString:@"/" withString:@""]];
        
        [attributedString addAttribute:NSLinkAttributeName
                                 value:@"dadianhua://"
                                 range:[[attributedString string] rangeOfString:phone]];//点击事件
        [attributedString addAttribute:NSUnderlineStyleAttributeName
                                 value:[NSNumber numberWithInteger:NSUnderlineStyleSingle]
                                 range:[[attributedString string] rangeOfString:phone]]; // 下划线类型
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.alignment = NSTextAlignmentCenter;
        [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [attributedString length])];
        [paragraphStyle setLineSpacing:8];
        _textview.attributedText = attributedString;
        
        UIColor *numColor = MAIN_TINT_COLOT ? :[UIColor blueColor] ;//获得主颜色
        _textview.linkTextAttributes = @{NSForegroundColorAttributeName: numColor,
                                         NSUnderlineColorAttributeName: numColor
                                         };
        _textview.delegate = self;
        _textview.editable = NO;        //必须禁止输入，否则点击将弹出输入键盘
        _textview.scrollEnabled = NO;
        _textview.font = UI_SEGMENTCONTROL_FONT;
        [imgBackground addSubview:_textview];
        
        CGFloat alertH = 130;
        CGFloat alertW = 180;
        //文本高度
        CGRect fram = [_textview.attributedText boundingRectWithSize:CGSizeMake(alertW-20, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
        
        alertH = (fram.size.height + 50) < alertH ? alertH : (fram.size.height + 50);
        
        imgBackground.frame = CGRectMake((self.frame.size.width-alertW)/2,(self.frame.size.height-alertH)/2,alertW,alertH);
        _textview.frame = CGRectMake(10 ,10,alertW - 20,alertH - 20);
        
    }
    return self;
}

//添加视图
- (void)showFindPasswordAlertView
{
    [[[[UIApplication sharedApplication] delegate] window]  addSubview:self];
}

//移除视图
- (void)closeAlertView {
    [self removeFromSuperview];
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange {
    
    if ([[URL scheme] isEqualToString:@"dadianhua"]) {
        NSURL *telUrl = [NSURL URLWithString:[NSString stringWithFormat:@"tel://%@", self.phoneNum]];
        if ([[UIApplication sharedApplication] canOpenURL:telUrl]) {
            [[UIApplication sharedApplication] openURL:telUrl options:@{} completionHandler:nil];
        }
        
        [self closeAlertView];
        
        return NO;
    }
    return YES;
}

@end
