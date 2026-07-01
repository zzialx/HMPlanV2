//
//  WSChatMessageUploadController.m
//  WinSFA
//
//  Created by mac on 2017/9/28.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSChatMessageUploadController.h"
#import "WSEMSDKManager.h"

@interface WSChatMessageUploadController ()

@property (nonatomic, strong) UIView *backupView;
@property (nonatomic, strong) UIImageView *leftImageView;
@property (nonatomic, strong) UILabel *rightLabel;

@end

@implementation WSChatMessageUploadController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = NSLocalizedString(@"Backup", nil);
    self.view.backgroundColor = MAIN_CELL_DISABLE_COLOR;
    
    UIBarButtonItem * uploadItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_upload"] style:UIBarButtonItemStylePlain
                                                                   target:self action:@selector(upload)];
    self.navigationItem.rightBarButtonItem = uploadItem;
    
    UIView *backupView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, 44)];
    backupView.backgroundColor = [UIColor whiteColor];
    self.backupView = backupView;
    
    UIImageView * leftImageView = [[UIImageView alloc]initWithFrame:CGRectMake(MAIN_CELL_PADDING, MAIN_PADDING, 20, 20)];
    leftImageView.image = [UIImage imageNamed:@"gtjlbf_icone"];
    [backupView addSubview:leftImageView];
    self.leftImageView = leftImageView;
    
    UILabel *rightLabel = [[UILabel alloc]initWithFrame:CGRectMake(leftImageView.right  +MAIN_PADDING, MAIN_PADDING,
                                                                self.view.width - leftImageView.right - MAIN_PADDING, 20)];
    rightLabel.text = NSLocalizedString(@"This function provides communication data backup of 7 days or less", nil);
    rightLabel.font = [UIFont systemFontOfSize:UI_Font];
    rightLabel.textColor = [UIColor colorWithHexString:@"#b2b2b2"];
    rightLabel.textAlignment = NSTextAlignmentLeft;
    rightLabel.numberOfLines = 0;
    [backupView addSubview:rightLabel];
    self.rightLabel = rightLabel;
    
    [self.view addSubview:backupView];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    UIImage *image = [UIImage imageNamed:@"gtjlbf_icone"];
    NSString *text = NSLocalizedString(@"This function provides communication data backup of 7 days or less", nil);
    CGFloat maxTextWidth = CGRectGetWidth(self.view.frame) - MAIN_PADDING * 2 - image.size.width - MAIN_PADDING;
    CGSize drawTextSize = [text ws_sizeWithFont:self.rightLabel.font constrainedToWidth:maxTextWidth];
    CGFloat height = (drawTextSize.height > image.size.height) ? drawTextSize.height : image.size.height;
    height += MAIN_PADDING;
    
    CGFloat x = 0.0f;
    CGFloat y = 0.0f;
    CGFloat w = CGRectGetWidth(self.view.frame);
    CGFloat h = height;
    self.backupView.frame = CGRectMake(x, y, w, h);
    
    x = MAIN_PADDING;
    y = (height - image.size.height) / 2;
    w = image.size.width;
    h = image.size.height;
    self.leftImageView.frame = CGRectMake(x, y, w, h);
    
    x = CGRectGetMaxX(self.leftImageView.frame) + MAIN_PADDING;
    y = (height - drawTextSize.height) / 2;
    w = drawTextSize.width;
    h = drawTextSize.height;
    self.rightLabel.frame = CGRectMake(x, y, w, h);
}

// 上传数据
-(void)upload
{
    [[WSEMSDKManager sharedInstance] uploadBackupFor7Day];
}

@end
