//
//  WSSMSSendView.m
//  WinSFA
//
//  Created by mac on 16/12/14.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSSMSSendView.h"
#import "WSSmsController.h"

#define top_Height 64.0f
#define view_Height 44.0f
#define left_Space  10.0f
#define DATAGRID_TITLE_FONTSIZE  (INTERFACE_IS_PHONE ? 15.0 : 17.0)
#define TilteTextFont [UIFont fontWithName:@"Helvetica-Light" size:DATAGRID_TITLE_FONTSIZE]
@interface WSSMSSendView () <UITextViewDelegate>

@property(nonatomic,strong) UITextView  *detailTextView;
@property (nonatomic , strong) UITextView * phonesTextView;

@end

@implementation WSSMSSendView

-(instancetype)initWithFrame:(CGRect)frame phones:(NSString *)phones{
    if (self = [super initWithFrame:frame]) {
        [self setUpSubViewsWithPhones:phones];
    }
    
    return self;
}

-(void)setUpSubViewsWithPhones:(NSString *)phones{
    CGFloat topHight = top_Height;
    CGFloat buttonSpace = 20;
    if ((SCREEN_HEIGHT - 568)<= 0) {
        topHight = 20;
        buttonSpace = 10;
    }
    float width = self.width - 4 * left_Space;
    UIView * bgView = [[UIView alloc]initWithFrame:self.bounds];
    [bgView setBackgroundColor:[UIColor blackColor]];
    bgView.alpha = 0.4;
    [self addSubview:bgView];
    
    UIView * detaiView = [[UIView alloc]initWithFrame:CGRectMake(left_Space, topHight, self.width - 2 * left_Space , 320)];
    detaiView.backgroundColor = [UIColor whiteColor];
    [self addSubview:detaiView];
    
    UILabel * titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.width, view_Height)];
    titleLabel.textColor = MAIN_TINT_COLOT;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = NSLocalizedString(@"sms_default_title", nil);
    [detaiView addSubview:titleLabel];

    
    UILabel * line = [[UILabel alloc]initWithFrame:CGRectMake(2, view_Height , self.width -4 - 2* left_Space, 1)];
    line.backgroundColor = [UIColor grayColor];
    [detaiView addSubview:line];
    detaiView.layer.cornerRadius = 5;
    detaiView.clipsToBounds = YES;

    
    UILabel * recevier = [[UILabel alloc]initWithFrame:CGRectMake(left_Space, view_Height + 1, width, view_Height)];
    recevier.text = NSLocalizedString(@"收件人", nil);

    [detaiView addSubview:recevier];
    
//    NSMutableAttributedString * string = [[NSMutableAttributedString alloc]initWithString:phones attributes:@{NSBackgroundColorAttributeName:[UIColor colorWithRed:180/255.0 green:224/255.0 blue:137/255.0 alpha:1]}];
//    CGSize size ;
//#if  __IPHONE_OS_VERSION_MIN_REQUIRED >= 70000
//    size =  [phones boundingRectWithSize:CGSizeMake(width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:DATAGRID_TITLE_FONTSIZE]} context:nil].size;
//#else
//    size=[phones sizeWithFont:[UIFont systemFontOfSize:DATAGRID_TITLE_FONTSIZE] constrainedToSize:CGSizeMake(width, MAXFLOAT)];
//#endif
    _phonesTextView = [[UITextView alloc]initWithFrame:CGRectMake(left_Space, 2* view_Height  +1, width, view_Height/2 + 4)];
    _phonesTextView.textContainerInset = UIEdgeInsetsMake(2, 0, 2, 0);
    _phonesTextView.text = phones;
    _phonesTextView.layer.cornerRadius = 5;
    _phonesTextView.layer.borderColor = [UIColor grayColor].CGColor;
    
    _phonesTextView.layer.borderWidth = 1;
    _phonesTextView.dataDetectorTypes = UIDataDetectorTypeNone;
    _phonesTextView.delegate = self;
    _phonesTextView.font = [UIFont systemFontOfSize:DATAGRID_TITLE_FONTSIZE];
    [detaiView addSubview:_phonesTextView];
    
    UILabel * smsContent = [[UILabel alloc]initWithFrame:CGRectMake(left_Space, _phonesTextView.bottom + 1, width, view_Height)];
    smsContent.text = NSLocalizedString(@"sms_content_title", nil);

    [detaiView addSubview:smsContent];
    
    _detailTextView = [[UITextView alloc] initWithFrame:CGRectMake(left_Space, smsContent.bottom  + 1, width, 2 * view_Height)];
    _detailTextView.layer.cornerRadius = 5;
    _detailTextView.layer.borderColor = [UIColor grayColor].CGColor;
    _detailTextView.layer.borderWidth = 1;
    _detailTextView.delegate = self;
    _detailTextView.font = [UIFont systemFontOfSize:DATAGRID_TITLE_FONTSIZE];
    [detaiView addSubview:_detailTextView];
    
    UIButton * cancel = [[UIButton alloc]initWithFrame:CGRectMake(0, _detailTextView.bottom + buttonSpace , (self.width - 2 * left_Space)/2 - 2, view_Height)];
    cancel.tag = 1000;
    [cancel addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [cancel setTitle:NSLocalizedString(@"cancel_label", nil) forState:UIControlStateNormal];
    [cancel setBackgroundColor:MAIN_TINT_COLOR];
    [detaiView addSubview:cancel];
    
    UIButton * fixOn = [[UIButton alloc]initWithFrame:CGRectMake(cancel.right + 4, _detailTextView.bottom + buttonSpace, (self.width - 2 * left_Space)/2 - 2, view_Height)];
    fixOn.tag = 1001;

    [fixOn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];

    [fixOn setTitle:NSLocalizedString(@"confirm", nil) forState:UIControlStateNormal];
    [fixOn setBackgroundColor:MAIN_TINT_COLOR];

    [detaiView addSubview:fixOn];
    detaiView.height = cancel.bottom;
}

-(void)selectAllPhone{
    
  [_phonesTextView selectAll:self];

}

-(void)buttonClick:(UIButton *)sender{
    [self resignFirstResponder];
    [self removeFromSuperview];

    if (sender.tag == 1000) {
    }else{
        NSMutableArray * phones = [[_phonesTextView.text componentsSeparatedByString:@","] mutableCopy];
        for (int i = 0; i < phones.count; i++) {
            if ([phones[i] length] == 0) {
                [phones removeObjectAtIndex:i];
                i--;
            }
        }
        NSString * detail = _detailTextView.text;
        if (self.sendSMS) {
            self.sendSMS(detail,phones);
        }
    }

}
@end
