//
//  WSANActivityTableViewCell.m
//  WinSFA
//
//  Created by zzialx on 2025/5/9.
//  Copyright © 2025 WinChannel. All rights reserved.
//

#import "WSANActivityTableViewCell.h"
#import "WSEmbeddedNewAcvtViewController.h"

@interface WSANActivityTableViewCell ()

@property (nonatomic, strong) WSEmbeddedNewAcvtViewController *acvtViewController;

@end

@implementation WSANActivityTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
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
    }
    
    return self;
}

@end
