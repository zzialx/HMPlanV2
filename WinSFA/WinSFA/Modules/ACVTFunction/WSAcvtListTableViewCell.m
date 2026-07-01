//
//  WSAcvtListTableViewCell.m
//  WinSFA
//
//  Created by Alicia on 2017/5/26.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSAcvtListTableViewCell.h"

@implementation WSAcvtListTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
//        YIHAIKERRY-1823 董宏
        UIImage *mustImage = [UIImage imageForName:@"star_must"];
        self.isRequireImageView = [[UIImageView alloc] initWithImage:mustImage];
        self.isRequireImageView.backgroundColor = [UIColor clearColor];
        self.isRequireImageView.hidden = YES;
        [self.contentView addSubview: self.isRequireImageView];

        self.iconImageView = [[UIImageView alloc] init];
        [self.contentView addSubview:self.iconImageView];
        
        [self.imageView setContentMode:UIViewContentModeCenter];
        [self.iconImageView setContentMode:UIViewContentModeLeft];
    }
    return self;
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    [self.imageView setFrame:CGRectMake(self.contentView.width - MAIN_CELL_BUTTON_WH, 0, MAIN_CELL_BUTTON_WH, MAIN_CELL_BUTTON_WH)];
    
    CGFloat padding = MAIN_CELL_BUTTON_WH + MAIN_TEXT_IMG_PADDING;
    if (self.iconImageView.image) {
        CGFloat iconWidth = MAIN_BUTTON_WH;
        [self.iconImageView setFrame:CGRectMake(MAIN_CELL_PADDING, 0, iconWidth, MAIN_CELL_BUTTON_WH)];
        padding = iconWidth  + MAIN_CELL_BUTTON_WH;
    } else {
        padding = MAIN_CELL_PADDING;
    }
    
    [self.textLabel setFrame:CGRectMake(padding, self.textLabel.origin.y, self.imageView.left - padding - MAIN_CELL_PADDING, self.textLabel.height)];
}

- (void)setAction:(WSVisitStoreActionObject *)action andAcvtBean:(WSAcvtBean *)acvtBean
{
    
    CGSize titleSize = [acvtBean.acvtName ws_sizeWithFont:self.textLabel.font constrainedToWidth:(self.contentView.width - self.iconImageView.right - MAIN_CELL_PADDING)];
    
    if ([action.is_required isEqualToString:@"R"]) {
        self.isRequireImageView.hidden = NO;
        UIImage *mustImage = [UIImage scaledImageForName:@"star_must" ofType:@"png"];
        self.isRequireImageView.frame = CGRectMake(self.textLabel.frame.origin.x + titleSize.width + MAIN_PADDING * 2, (MAIN_CELL_HEIGHT - mustImage.size.height) / 2, mustImage.size.width, mustImage.size.height);
    } else {
        self.isRequireImageView.hidden = YES;
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
