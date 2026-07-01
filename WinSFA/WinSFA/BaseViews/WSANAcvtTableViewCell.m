//
//  WSANAcvtTableViewCell.m
//  WinSFA
//
//  Created by zhangmin on 2018/12/13.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import "WSANAcvtTableViewCell.h"
#import "WSEmbeddedNewAcvtViewController.h"
#import "WSInterAction.h"
#import "WSDataSourceManager.h"
#import "WSAcvtModel.h"


@interface WSANAcvtTableViewCell()
@property (nonatomic, strong) WSEmbeddedNewAcvtViewController *acvtViewController;



@end

@implementation WSANAcvtTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
 
        CGRect rect = self.frame;

        UIView *shadow = [[UIView alloc]initWithFrame:rect];
        shadow.layer.cornerRadius = 10;
        shadow.backgroundColor = [UIColor whiteColor];
        shadow.layer.borderWidth = 1.0;
        shadow.layer.borderColor = [[UIColor colorWithHexString:@"0xd4d4d4"] CGColor];
        
        self.containerView = shadow;
        
        [self.contentView addSubview:shadow];
        
        [self.contentView addSubview:self.deleteButton ];
        
    }
    
    return self;
}

-(UIButton *)deleteButton {
    if (!_deleteButton) {
        UIButton *deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _deleteButton = deleteBtn;
       
        [_deleteButton setImage:[UIImage imageNamed:@"close_icon"] forState:UIControlStateNormal];
        _deleteButton.frame = CGRectMake(SCREEN_WIDTH - 50, 6, 50, 32);
        [_deleteButton addTarget:self action:@selector(deleteAcvtView) forControlEvents:UIControlEventTouchUpInside];
    }
    return _deleteButton;
}

#pragma mark - 删除按键响应方法
- (void)deleteAcvtView {
    LogInfo(@"删除问卷");
    
    BlockAlertView * alterView = [BlockAlertView alertWithTitle:NSLocalizedString(@"js_alert_title", nil) message:NSLocalizedString(@"确定要删除吗？", nil)];
    [alterView setCancelButtonWithTitle:NSLocalizedString(@"cancel_label", nil) block:nil];
    [alterView addButtonWithTitle:NSLocalizedString(@"confirm_label", nil) block:^{
        if ([self.delegate respondsToSelector:@selector(anAcvtTableViewCellDidDeleteButton:index:)]) {
            [self.delegate anAcvtTableViewCellDidDeleteButton:self index:self.tag];
        }
    }];
    [alterView show];
    
   
}



@end
