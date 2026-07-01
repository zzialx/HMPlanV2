//
//  WSProdGrideWithExpandableBrandsRightTableViewCell.m
//  WinSFA
//
//  Created by HZH on 2017/7/18.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSProdGrideWithExpandableBrandsRightTableViewCell.h"

#define CELL_LEFT_SPACE (INTERFACE_IS_PHONE ? 15.0f : 20.0f)
#define INDICATOR_ICON_WIDTH 20.0f

#define hImageLeftSpace 15.0
#define hImageRightSpace 15.0
#define hImageTopSpace 15.0
#define hImageBottomSpace 15.0

#define hImageWidth 50.0


@implementation WSProdGrideWithExpandableBrandsRightTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        
        if (!IOS7_OR_LATER) {
            self.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        [self setupSubviews];
        //        self.separatorLineColor = RGBCOLOR(218, 218, 218);//[UIColor colorWithHexString:@"#c7c7c7"];
        
    }
    
    return self;
}

- (void)setupSubviews
{
//    self.itemImageView = [[UIImageView alloc] initWithFrame:CGRectMake(hImageLeftSpace, hImageTopSpace, self.height - hImageTopSpace - hImageBottomSpace, self.height - hImageTopSpace - hImageBottomSpace)];
    self.itemImageView = [[UIImageView alloc] init];

    [self.contentView addSubview: self.itemImageView];

//    CGFloat titleLabelWidth = self.contentView.frame.size.width - self.itemImageView.frame.size.width - hImageLeftSpace - hImageRightSpace - INDICATOR_ICON_WIDTH - CELL_LEFT_SPACE*2;

//    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(hImageLeftSpace + self.itemImageView.frame.size.width + hImageRightSpace, hImageTopSpace, titleLabelWidth, self.itemImageView.frame.size.height)];
    self.titleLabel = [[UILabel alloc] init];

    self.titleLabel.font = FONT_SIZE_PINGFANG_MEDIUM(13.0);
    self.titleLabel.textColor = [UIColor colorWithHexString:@"0x353535"];
    self.titleLabel.numberOfLines = 0;
//    self.titleLabel.backgroundColor = [UIColor lightGrayColor];
    
    [self.contentView addSubview:self.titleLabel];
    
    self.indicatorImageView = [[UIImageView alloc] initWithImage:[UIImage scaledImageForName:@"carat-open" ofType:@"png"]];
//    self.indicatorImageView.frame = CGRectMake(self.contentView.width - CELL_LEFT_SPACE - INDICATOR_ICON_WIDTH, (self.height - INDICATOR_ICON_WIDTH)/2, INDICATOR_ICON_WIDTH, INDICATOR_ICON_WIDTH);
    self.indicatorImageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
    self.indicatorImageView.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview: self.indicatorImageView];
}

- (void)setIndicatorImageOpenedOrClosed:(BOOL)indicatorImageOpenedOrClosed
{
    _indicatorImageOpenedOrClosed = indicatorImageOpenedOrClosed;
    
    if (_indicatorImageOpenedOrClosed) {
        self.indicatorImageView.transform = CGAffineTransformMakeRotation(0);
        _dataGridComponentView.hidden = YES;
    } else {
        self.indicatorImageView.transform = CGAffineTransformMakeRotation(M_PI);
        _dataGridComponentView.hidden = NO;
    }
    
}

- (void)setItemCellHeight:(CGFloat)itemCellHeight
{
    _itemCellHeight = itemCellHeight;
    
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    
//    if ([_dataGridComponentView.superview isEqual:self.contentView]) {
//        
//    }else{
//        [_dataGridComponentView removeFromSuperview];
//        
//        [self.contentView addSubview:_dataGridComponentView];
//    }
    [_dataGridComponentView removeFromSuperview];

    if (_indicatorImageOpenedOrClosed) {

    }else{
        
        [self.contentView addSubview:_dataGridComponentView];
    }
    
    [self resetSubviewsFrame];
    
    
}

- (void)setDataGridComponentView:(WSDataGridComponentView *)dataGridComponentView
{
    _dataGridComponentView = dataGridComponentView;
    
}

- (void)resetSubviewsFrame
{
    [self.itemImageView setFrame:CGRectMake(hImageLeftSpace, hImageTopSpace, hImageWidth, hImageWidth)];
    
    CGFloat titleLabelWidth = self.contentView.frame.size.width - hImageWidth - hImageLeftSpace - hImageRightSpace - INDICATOR_ICON_WIDTH - CELL_LEFT_SPACE*2;

    [self.titleLabel setFrame:CGRectMake(hImageLeftSpace + hImageWidth + hImageRightSpace, hImageTopSpace, titleLabelWidth, hImageWidth)];
    
    [self.indicatorImageView setFrame:CGRectMake(self.contentView.width - CELL_LEFT_SPACE - INDICATOR_ICON_WIDTH, (hImageWidth + hImageLeftSpace + hImageRightSpace - INDICATOR_ICON_WIDTH)/2, INDICATOR_ICON_WIDTH, INDICATOR_ICON_WIDTH)];
    
    if (_indicatorImageOpenedOrClosed) {
        [self.dataGridComponentView setFrame:CGRectMake(0, hImageWidth + hImageTopSpace + hImageBottomSpace, self.contentView.frame.size.width, 0)];
    }else
        [self.dataGridComponentView setFrame:CGRectMake(0, hImageWidth + hImageTopSpace + hImageBottomSpace, self.contentView.frame.size.width, self.dataGridComponentView.frame.size.height)];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
