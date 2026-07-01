//
//  WSSubMsgTableViewCell.m
//  WinSFA
//
//  Created by xiajl on 14-10-27.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//

#import "WSSubMsgTableViewCell.h"


#define CellBottomPadding 14.


@interface WSSubMsgTableViewCell ()
@property (nonatomic, strong) UILabel *readStatus_label;
@end

@implementation WSSubMsgTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    
    self.msg_imageView = [[UIImageView alloc] init];
    [self.contentView addSubview:self.msg_imageView];
    
    self.msgTitle_label = [[UILabel alloc] init];
    self.msgTitle_label.textColor = [UIColor blackColor];
    self.msgTitle_label.font = [UIFont systemFontOfSize:18.6];
    [self.contentView addSubview:self.msgTitle_label];
    
    self.msgContent_label = [[UILabel alloc] init];
    self.msgContent_label.textColor = [UIColor colorWithHexString:@"#666666"];
    self.msgContent_label.font = [UIFont systemFontOfSize:14.2];
    self.msgContent_label.numberOfLines = 2;
    [self.contentView addSubview:self.msgContent_label];
    


    self.navButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.navButton.titleLabel.font = [UIFont systemFontOfSize:13.1];
    CALayer  *layerButton = self.navButton.layer ;
    layerButton.borderWidth = 1;
    layerButton.borderColor = [UIColor colorWithHexString:@"#0093d4"].CGColor;
    layerButton.cornerRadius = 8;
    self.navButton.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    [self.navButton setTitleColor:[UIColor colorWithHexString:@"#0093d4"] forState:UIControlStateNormal];
    [self.navButton setTitleColor:[UIColor colorWithHexString:@"#888888"] forState:UIControlStateSelected];
    [self.contentView addSubview: self.navButton];
    
    self.msgDate_label = [[UILabel alloc] init];
    self.msgDate_label.textColor = [UIColor colorWithHexString:@"#777777"];
    self.msgDate_label.font = [UIFont systemFontOfSize:13.1];
    self.msgDate_label.textAlignment = NSTextAlignmentCenter;
    self.msgDate_label.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:self.msgDate_label];
    
    self.readStatus_label= [[UILabel alloc] init];
    self.readStatus_label.textColor = [UIColor colorWithHexString:@"#f19149"];
    self.readStatus_label.font = [UIFont systemFontOfSize:12.];
    self.readStatus_label.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:self.readStatus_label];
    
    [self addProgressView];
}

- (void)removeProgressView {
    if (self.progressView) {
        [self.progressView removeFromSuperview];
    }
}
 


- (void)addProgressView {
    self.progressView = [[UIProgressView alloc] init];
    self.progressView.progressViewStyle = UIProgressViewStyleDefault;
    self.progressView.progressTintColor = MAIN_TINT_COLOT;
    self.progressView.backgroundColor = [UIColor yellowColor];
    [self.contentView addSubview:self.progressView];

}

- (void)layoutSubviews
{
    [super layoutSubviews];
    // 图片控件长宽 87
    if (self.imageURLString && [self.imageURLString length] > 0) {
        
        CGRect rect_imageview = CGRectMake(self.bounds.size.width - 14. - 87.,15.,87.,87.);
        [self.msg_imageView setFrame:rect_imageview];
        
        CGRect rect_progressView = CGRectMake(rect_imageview.origin.x, rect_imageview.origin.y + rect_imageview.size.height + 5.0f, rect_imageview.size.width, 3.0);
        [self.progressView setFrame:rect_progressView];

        CGRect rect_msgTitle_label = CGRectMake(15.,15.,self.bounds.size.width - 15. - 14. * 2 - 87. ,30);
        [self.msgTitle_label setFrame:rect_msgTitle_label];
        
        CGRect rect_msgContent_label = CGRectMake(15.,self.msgTitle_label.origin.y + self.msgTitle_label.size.height ,self.bounds.size.width - 15. - 14. * 2 - 87. ,34.);
        [self.msgContent_label setFrame:rect_msgContent_label];
        
    }else{
        
        [self.msg_imageView setFrame:CGRectZero];
        
        [self.progressView setFrame:CGRectZero];
        
        CGRect rect_msgTitle_label = CGRectMake(15.,15.,self.bounds.size.width - 15. - 14. ,30);
        [self.msgTitle_label setFrame:rect_msgTitle_label];
        
        CGRect rect_msgContent_label = CGRectMake(15.,self.msgTitle_label.origin.y + self.msgTitle_label.size.height,self.bounds.size.width - 15. - 14. ,34.);
        [self.msgContent_label setFrame:rect_msgContent_label];
    
    }
//      
//    CGSize textSize = CGSizeZero;
//    if (IOS7_OR_LATER) {
//        
//        textSize = [self.navButton.currentTitle sizeWithAttributes: [[self.navButton.titleLabel.font fontDescriptor] fontAttributes]];
//    }else{
//        
//        textSize = [self.navButton.currentTitle sizeWithFont:[UIFont systemFontOfSize:13.1]];
//    }
  
    CGRect rect_navButton = CGRectMake(15.,self.bounds.size.height - 16. - CellBottomPadding, 48. + 26. , 16.);
    [self.navButton setFrame:rect_navButton];
    
    CGSize textSize2 = [self.msgDate_label.text ws_sizeWithFont:self.msgDate_label.font constrainedToWidth:CGFLOAT_MAX lineBreakMode:NSLineBreakByWordWrapping];
    
    CGRect rect_msgDate_label = CGRectMake(self.navButton.origin.x + self.navButton.size.width + 6.0 * 2 ,self.bounds.size.height - 16. - CellBottomPadding, textSize2.width + 10. ,16.);
    [self.msgDate_label setFrame:rect_msgDate_label];
    
    
    CGRect rect_readStatus_label = CGRectMake(self.msgDate_label.origin.x + self.msgDate_label.size.width + 6.0 * 2,self.bounds.size.height - 16. - CellBottomPadding,40.,16.);
    [self.readStatus_label setFrame:rect_readStatus_label];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)setReadStatus:(ECELLTAGStatus)readStatus
{
    _readStatus = readStatus;
    
    switch (_readStatus) {
        case ECELLTAGStatusRead:
        {
            self.readStatus_label.text =NSLocalizedString(@"readed", nil);
            self.readStatus_label.textColor = [UIColor colorWithHexString:@"#888888"];
            CALayer  *layerButton = self.navButton.layer ;
            layerButton.borderColor = [UIColor colorWithHexString:@"#888888"].CGColor;
            [self.navButton setSelected:YES];
        }
            break;
        default:
        {
        
            self.readStatus_label.text = NSLocalizedString(@"unread", nil);
            self.readStatus_label.textColor = [UIColor colorWithHexString:@"#f19149"];
            CALayer  *layerButton = self.navButton.layer ;
            layerButton.borderColor = [UIColor colorWithHexString:@"#0093d4"].CGColor;
            [self.navButton setSelected:NO];
        }
            break;
    }
}

@end
