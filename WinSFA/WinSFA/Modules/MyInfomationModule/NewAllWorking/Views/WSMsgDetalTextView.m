//
//  WSMsgDetalTextView.m
//  WinSFA
//
//  Created by admin on 15/12/3.
//  Copyright © 2015年 WinChannel. All rights reserved.
//

#import "WSMsgDetalTextView.h"
#define FONT_NAME @"MicrosoftYaHei"

#define FONT_SIZE ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 13 : 15)
@implementation WSMsgDetalTextView
-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.numberOfLines = 0;
        self.font = [UIFont fontWithName:FONT_NAME size:FONT_SIZE];
        self.textColor = [UIColor colorWithHexString:@"#646464"];
        self.textAlignment = NSTextAlignmentLeft;
        self.userInteractionEnabled = YES;
        UILongPressGestureRecognizer * gesture = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressAction:)];
        [self addGestureRecognizer:gesture];
    }
    
    return self;
}

-(void)setDetailStr:(NSString *)detailStr{

    _detailStr = detailStr;
    self.numberOfLines = 0;
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing =INTERFACE_IS_PHONE ? 10 : 15;// 字体的行间距
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    NSDictionary *attributes = @{
                                 NSFontAttributeName:[UIFont systemFontOfSize:FONT_SIZE],
                                 NSParagraphStyleAttributeName:paragraphStyle
                                 };
    
    self.attributedText = [[NSAttributedString alloc] initWithString:[NSString stringNotNilWithValue:detailStr] attributes:attributes];
}

-(void)longPressAction:(UILongPressGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        if (self.text) {
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            pasteboard.string = self.text;
            [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:nil tips:NSLocalizedString(@"copyed", nil) tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed autoHideTime:1.5f];
        }
    }
}
@end
