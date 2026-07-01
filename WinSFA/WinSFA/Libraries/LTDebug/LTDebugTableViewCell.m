//
//  LTDebugTableViewCell.m
//  WinSFA
//
//  Created by Alicia on 2017/3/18.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "LTDebugTableViewCell.h"
#import "LTDDLogModel.h"

#define kViewPadding        10
#define kColorWidth         2
#define kColorPadding       2

#define kLogFontSize        15

@interface LTDebugTableViewCell ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIView *colorView;
@property (nonatomic, strong) NSDictionary *colorDic;

@end

@implementation LTDebugTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect titleFrame = CGRectMake(kViewPadding, 0, self.bounds.size.width - 2 * kViewPadding, self.bounds.size.height);
    self.titleLabel.frame = titleFrame;
    
    CGRect colorFrame = CGRectMake(0, kColorPadding, kColorWidth, self.bounds.size.height - 2 * kColorPadding);
    self.colorView.frame = colorFrame;
}

- (void)setupViews {
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.numberOfLines = 0;
    [titleLabel setFont:[UIFont systemFontOfSize:kLogFontSize]];
    [self.contentView addSubview:titleLabel];
    self.titleLabel = titleLabel;
    
    UIView *colorView = [[UIView alloc] init];
    [self.contentView addSubview:colorView];
    self.colorView = colorView;
}

- (void)setLogModel:(LTDDLogModel *)logModel {
    [self.titleLabel setText:logModel.message];
    
    UIColor *color = (UIColor *)[self.colorDic objectForKey:[NSNumber numberWithUnsignedInteger:logModel.logFlag]];
    [self.colorView setBackgroundColor:color];
}

- (NSDictionary *)colorDic {
    if (!_colorDic) {
        _colorDic = @{[NSNumber numberWithUnsignedInteger:DDLogFlagError]: [UIColor redColor],
                      [NSNumber numberWithUnsignedInteger:DDLogFlagWarning]: [UIColor yellowColor]};
    }
    return _colorDic;
}


+ (CGFloat)getCellHeightByLogModel:(LTDDLogModel *)logModel {
    CGSize messageSize = [LTDebugTableViewCell sizeString:logModel.message WithFont:[UIFont systemFontOfSize:kLogFontSize] constrainedToWidth:UIScreen.mainScreen.bounds.size.width - 2 * kViewPadding];
    return messageSize.height + kViewPadding;
}

+ (CGSize)sizeString:(NSString *)str WithFont:(UIFont *)font constrainedToWidth:(CGFloat)width {
    UIFont *textFont = font ? font : [UIFont systemFontOfSize:[UIFont systemFontSize]];
    
    CGSize textSize;
    
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 70000
    if ([str respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)]) {
        NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
        paragraph.lineBreakMode = NSLineBreakByWordWrapping;
        NSDictionary *attributes = @{NSFontAttributeName: textFont,
                                     NSParagraphStyleAttributeName: paragraph};
        textSize = [str boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX)
                                     options:(NSStringDrawingUsesLineFragmentOrigin |
                                              NSStringDrawingTruncatesLastVisibleLine)
                                  attributes:attributes
                                     context:nil].size;
    } else {
        textSize = [str sizeWithFont:textFont
                   constrainedToSize:CGSizeMake(width, CGFLOAT_MAX)
                       lineBreakMode:NSLineBreakByWordWrapping];
    }
#else
    NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
    paragraph.lineBreakMode = NSLineBreakByWordWrapping;
    NSDictionary *attributes = @{NSFontAttributeName: textFont,
                                 NSParagraphStyleAttributeName: paragraph};
    textSize = [str boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX)
                                 options:(NSStringDrawingUsesLineFragmentOrigin |
                                          NSStringDrawingTruncatesLastVisibleLine)
                              attributes:attributes
                                 context:nil].size;
#endif
    
    return CGSizeMake(ceil(textSize.width), ceil(textSize.height));
}

@end
