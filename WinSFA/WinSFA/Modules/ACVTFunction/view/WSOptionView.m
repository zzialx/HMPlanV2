//
//  WSOptionView.m
//  WinSFA
//
//  Created by yang on 15-3-25.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSOptionView.h"
#import "WSRequestHelper.h"

#define kNumberOfLines      -1

static const CGFloat iconImageViewGap = 2;
static const CGFloat imageWH = 16.5;

@implementation WSOptionView {
    
    UILabel *_label;
    BOOL _isMultiseriate;
    BOOL _isHasReason;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame andDataItem:nil withMultiseriate:NO];
}

- (instancetype)initWithFrame:(CGRect)frame andDataItem:(NSObject<I_W_OptionDataItem> *)dataItem withMultiseriate:(BOOL)isMultiseriate
{
    return [self initWithFrame:frame andDataItem:dataItem withMultiseriate:isMultiseriate isHideOptionnName:NO];
}

- (instancetype)initWithFrame:(CGRect)frame andDataItem:(NSObject<I_W_OptionDataItem> *)dataItem withMultiseriate:(BOOL)isMultiseriate isHideOptionnName:(BOOL)isHideOptionnName
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
 
        _isMultiseriate = isMultiseriate;
        
        UIImage *buttonImage = [UIImage imageNamed:@"icn_nocheck"];

        // MSTD-3605 iPad2等老设备@1x图片尺寸不对或已经删除导致_button的size不正确，所以此处设固定宽高，并且注释掉后面重试frame的语句
        _button = [[UIButton alloc] initWithFrame:CGRectMake(0, (frame.size.height - buttonImage.size.height)/2, buttonImage.size.width, buttonImage.size.height)];

        _button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        // 多行文字按钮在第一行位置
        if (frame.size.height > MAIN_CELL_HEIGHT) {
//            CGFloat lineSpacing = 6.0;
//            _button.imageEdgeInsets = UIEdgeInsetsMake(0, 0, (frame.size.height - imageWH) / 2 - lineSpacing, 0);
        }
        _button.backgroundColor = [UIColor clearColor];
        _button.titleLabel.textColor = MAIN_TEXT_COLOR;
        [_button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        if (!([dataItem respondsToSelector:@selector(getDataItemPic)] && [[dataItem getDataItemPic] length] > 0)) {
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cellClicked:)];
            [self addGestureRecognizer:tap];
        }
        
        [self addSubview:_button];
        //SFA-24513
        CGFloat paddingX = imageWH + MAIN_PADDING;
        CGFloat labelWidth = frame.size.width - paddingX;
        CGFloat buttonWidth = buttonImage.size.width + MAIN_TEXT_IMG_PADDING;
    
        
        _label = [[UILabel alloc] initWithFrame:CGRectMake(paddingX, 0, labelWidth, frame.size.height)];
//        if (_isMultiseriate) {
//            _label.frame = CGRectMake(0, 0, labelWidth - 10, frame.size.height);
//        }
        _label.lineBreakMode = NSLineBreakByWordWrapping;
        _label.numberOfLines = kNumberOfLines;
        
        _label.font = ([dataItem respondsToSelector:@selector(getDataItemPic)] && [[dataItem getDataItemPic] length] > 0) ?  FONT_SIZE_PINGFANG_MEDIUM(11) :  FONT_SIZE_PINGFANG_MEDIUM(UI_Font);
        _label.textColor = DETAIL_TEXT_COLOR;
        _label.backgroundColor = [UIColor clearColor];
        [self addSubview:_label];
        if (isHideOptionnName) {
            [_label removeFromSuperview];
            if (isMultiseriate) {
                _button.frame = CGRectMake(frame.size.width - buttonWidth, (frame.size.height - buttonWidth)/2, buttonWidth, buttonWidth);
            }
        }
        
        
        if (dataItem) {
            self.dataItem = dataItem;
        }
   
        return self;
    }
    
    return nil;
}

- (instancetype)initWithFrame:(CGRect)frame andDataItem:(NSObject<I_W_OptionDataItem> *)dataItem hasReason:(BOOL)hasReason readonly:(BOOL)isReadonly
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        
        _isHasReason = hasReason;
        
        CGFloat textFieldWidth = 0;
        
        if (hasReason) {
            textFieldWidth = frame.size.width * 0.4;
        }
        
        UIImage *buttonImage = [UIImage imageNamed:@"icn_check"];
        CGFloat labelX = buttonImage.size.width + MAIN_PADDING;
        
        if (isReadonly) {
            textFieldWidth = 0;
            labelX = 30;
        }
        
        _button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, frame.size.width - textFieldWidth - MAIN_PADDING, frame.size.height)];
        _button.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        _button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        _button.backgroundColor = [UIColor clearColor];
        [_button setTitleColor:MAIN_TEXT_COLOR forState:UIControlStateNormal];
        [_button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:_button];
        
        if (isReadonly) {
            _button.hidden = YES;
        }
        
        CGFloat labelWidth = _button.width - labelX;
        
        _label = [[UILabel alloc] initWithFrame:CGRectMake(labelX, 0, labelWidth, frame.size.height)];
        _label.lineBreakMode = NSLineBreakByWordWrapping;
        _label.numberOfLines = kNumberOfLines;
        _label.font = FONT_SIZE_PINGFANG_MEDIUM(UI_Font);
        _label.backgroundColor = [UIColor clearColor];
        _label.textColor = DETAIL_TEXT_COLOR;
        [self addSubview:_label];
        
        if (!isReadonly) {
            _reasonTextField = [[UITextField alloc] initWithFrame:CGRectMake(_button.right + MAIN_PADDING, (self.height - 35)/2, textFieldWidth, 35)];
            _reasonTextField.layer.cornerRadius = 5.0;
            _reasonTextField.layer.borderColor = MAIN_TINT_COLOT.CGColor;
            _reasonTextField.layer.borderWidth = 1.5;
            _reasonTextField.textAlignment = NSTextAlignmentLeft;
            _reasonTextField.font = [UIFont systemFontOfSize:15];
            _reasonTextField.textColor = MAIN_TEXT_COLOR;
            _reasonTextField.placeholder = NSLocalizedString(@"请填写原因（必填）", nil);
            _reasonTextField.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
            _reasonTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 35)];
            _reasonTextField.leftView = view;
            _reasonTextField.leftViewMode = UITextFieldViewModeAlways;
            
            [self addSubview:_reasonTextField];
        }
        
        if (dataItem) {
            self.dataItem = dataItem;
        }
        
        return self;
        
    }
    
    return self;
}

- (void)setDataItem:(NSObject<I_W_OptionDataItem> *)dataItem
{
    if (_dataItem != dataItem) {
        _dataItem = dataItem;
        
        NSString *itemName = [dataItem getDataItemName];
        [self setLabelStyleWithText:itemName];

        CGSize size = [[dataItem getDataItemName] ws_sizeWithFont:_label.font constrainedToWidth:_label.frame.size.width lineBreakMode:NSLineBreakByWordWrapping];
        
        if (size.height < _button.height) {
            size.height = _button.height;
        }

        if (size.height > self.frame.size.height) {
            CGRect rect = _label.frame;
            
            CGSize labelSize = [_label labelResize:size];
            rect.size.height = labelSize.height;
            _label.frame = rect;
            
            CGRect buttonRect = _button.frame;
            buttonRect.origin.y = (labelSize.height - _button.height)/2.0;
//            buttonRect.size.height = labelSize.height;
            _button.frame = buttonRect;

            rect = self.frame;
            rect.size.height = labelSize.height;
            self.frame = rect;
        }
        
        if ([dataItem respondsToSelector:@selector(getDataItemPic)] && [[dataItem getDataItemPic] length] > 0) {
            
            CGFloat imageViewHeight = OPTVIEW_ICONIMAGEVIEW_WH;
            if (!_iconImageView) {
                self.iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, imageViewHeight, imageViewHeight)];
                UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(browseImage:)];
                [self addGestureRecognizer:tap];
                [self addSubview:_iconImageView];
            }
            
            typeof(self) wself = self;
            [[WSRequestHelper shareInstance] downloadImageWithUrl:[WSHttpURLHelper getImageCompleteURL:[dataItem getDataItemPic]] imageView:_iconImageView placeholderImage:[UIImage scaledImageForName:@"picture_loading" ofType:@"png"] completed:^(UIImage *image, NSError *error, NSURL *imageURL) {
                if (error || !image) {
                    image = [UIImage scaledImageForName:@"picture_loading_failed" ofType:@"png"];
                }
                
                wself.iconImageView.image = image;
            }];
            CGRect labelRect = _label.frame;
            labelRect.origin.y = _iconImageView.bottom + 5;
            labelRect.size.height = size.height;
            _label.frame = labelRect;
            
            CGRect buttonRect = _button.frame;
            buttonRect.origin.y = labelRect.origin.y;
            _button.frame = buttonRect;
            CGRect rect = self.frame;
            rect.size.height = _label.size.height + iconImageViewGap + OPTVIEW_ICONIMAGEVIEW_WH + 10;
            self.frame = rect;
            
        }
    }
}

- (void)setLabelStyleWithText:(NSString *)text {
    //YIHAIKERRY-2986 2018-06-01
    NSMutableAttributedString * attrStr = [[NSMutableAttributedString alloc] initWithString:((text.length > 0) ? text : @"")];
    //NSMutableAttributedString * attrStr = [[NSMutableAttributedString alloc] initWithString:text];
    
    NSMutableParagraphStyle * style = [[NSMutableParagraphStyle alloc] init];
    style.alignment = NSTextAlignmentJustified;
//    style.lineSpacing = MAIN_FONT_LINE_HEIGHT;

    NSDictionary * dicAttr = @{NSParagraphStyleAttributeName:style,
                               NSUnderlineStyleAttributeName:[NSNumber numberWithInteger:NSUnderlineStyleNone]};
    [attrStr setAttributes:dicAttr range:NSMakeRange(0, attrStr.length)];
    [_label setAttributedText:attrStr];
}

- (void)optionViewEnable:(BOOL)enable {
    if (enable) {
        self.userInteractionEnabled = YES;
        _button.userInteractionEnabled = YES;
        _label.enabled = YES;
        _reasonTextField.hidden = _button.selected;
    }else {
        self.userInteractionEnabled = NO;
        _button.userInteractionEnabled = NO;
        _label.enabled = NO;
        _reasonTextField.hidden = YES;
    }
    
}

-(void)controlClick {
    if ([self.delegate respondsToSelector:@selector(optionView:didClickItem:)]) {
        [self.delegate optionView:self didClickItem:self.dataItem];
    }
    
    if (_isHasReason) {
        _reasonTextField.hidden = _button.selected;
    }
}


- (void)buttonClicked:(id)sender {
    [self controlClick];
}

- (void)cellClicked:(UITapGestureRecognizer*)tap
{
    [self controlClick];
}

- (void)browseImage:(UITapGestureRecognizer*)tap{

    if ([self.delegate respondsToSelector:@selector(optionView:didClickItem:)]) {
        [self.delegate optionView:self didClickItemImage:_iconImageView.image];
    }

    
}
@end
