
//
//  WSSingleTitlePanel.m
//  WinSFA
//
//  Created by winchannel on 15/3/19.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSSingleTitlePanel.h"
#import "I_W_BuildInfo.h"
#import "WidgetConstant.h"
#import "UILabel+Additional.h"

#define kBasePannelTitleColor ([UIColor colorForKey:@"BasePannelTitle"] ? [UIColor colorForKey:@"BasePannelTitle"] : PanelTextFieldColorReadonly)

@interface WSSingleTitlePanel ()

@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
@property (nonatomic, strong) UIImageView *foldImageView;
@property (nonatomic, strong)UIButton * checkBtn;

@end

@implementation WSSingleTitlePanel

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        return self;
    }
    return nil;
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    if ([xbuildInfo getQuestIconURL].length > 0) {
        
        CGFloat paddingX = CGRectGetMaxX(self.iconImageView.frame) + MAIN_TEXT_IMG_PADDING;
        CGRect frame = self.titleLabel.frame;
        [self setTitleLabelFrame:CGRectMake(paddingX, frame.origin.y, frame.size.width, frame.size.height)];
        
        if (self.iconImageView.height < frame.size.height) {
            
            CGRect iconFrame =  self.iconImageView.frame;
            iconFrame.origin.y = (frame.size.height - iconFrame.size.height) / 2;
            [self.iconImageView setFrame:iconFrame];
        }
    }
}

- (void)buildDisplayContent {
    
    [super buildDisplayContent];
    
    NSString *titlecontent = nil;
    if ( [[xbuildInfo getISRequire] isKindOfClass:[NSString class]] && [[xbuildInfo getISRequire] isEqualToString:@"1"]) {
        titlecontent = [NSString stringWithFormat:@"%@*", [xbuildInfo getQuestName]];
    }
    else {
        titlecontent = [xbuildInfo getQuestName];
    }
    
    self.titleLabel.numberOfLines = 0;
    self.titleLabel.lineBreakMode = NSLineBreakByCharWrapping;
    self.titleLabel.contentMode = UIViewContentModeCenter;
    
    [self setTitleLabelBgColor:[UIColor clearColor]];
    [self setTitleLabelColorStrByHex:[xbuildInfo getAnswerColor] ? [xbuildInfo getAnswerColor] : [xbuildInfo getTextColor] ];
    [self resetTitle:titlecontent];
    
    if (self.titleLabel.frame.size.height > self.frame.size.height) {
        
        CGFloat height = self.titleLabel.frame.origin.y + self.titleLabel.frame.size.height;
        if ([self class] == [WSSingleTitlePanel class]) {
            height += 5.0f;
        }
        CGFloat width = self.frame.size.width;
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, width, height);
    }
    
    [self setReadonlyStyle:[xbuildInfo getReadOnly]];
    
    if ([[xbuildInfo getIsHideQstName] isEqualToString:@"1"]) {
        
        self.titleLabel.hidden = YES;
        self.titleLabel.frame = CGRectMake(self.titleLabel.origin.x, self.titleLabel.origin.y, 0, 0);
    }
}

- (void)loadBuildInfo:(NSObject<I_W_BuildInfo> *)buildInfo {
    
    [super loadBuildInfo:buildInfo];
}

- (void)loadDataSource:(NSObject<I_W_DataSource> *)datasource {
    
    [super loadDataSource:datasource];
}

- (void)loadValidator:(NSObject<I_W_Validate> *)validateobjin {
    
    [super loadValidator:validateobjin];
}

- (void)setRequest:(NSString *)isRequest {
    
    [super setRequest:isRequest];
    
    BOOL orientition = NO;
    if ([xbuildInfo getOrientation] && [[xbuildInfo getOrientation] isEqualToString:@"1"]) {
        orientition = YES;
    }
    
    NSString *titlecontent = nil;
    if ( [[xbuildInfo getISRequire] isKindOfClass:[NSString class]] && [[xbuildInfo getISRequire] isEqualToString:@"1"]) {
        titlecontent = [NSString stringWithFormat:@"%@*",[xbuildInfo getQuestName]];
    }
    else {
        titlecontent = [xbuildInfo getQuestName];
    }
    
    [self resetTitle:titlecontent];
}

- (void)resetTitle:(NSString *)titlecontent {
    
    [self setTitleContent:titlecontent];
    
    BOOL orientition = NO;
    if ([xbuildInfo getOrientation] && [[xbuildInfo getOrientation] isEqualToString:@"1"]) {
        orientition = YES;
    }
    
    UIFont *titleLabelfont = self.titleLabel.font;
    CGFloat constrainedWidth = (self.width - MAIN_CELL_PADDING * 2);
    CGSize size = [titlecontent ws_sizeWithFont:titleLabelfont constrainedToWidth:constrainedWidth lineBreakMode:NSLineBreakByWordWrapping];
    CGFloat ratio = 1.0;
    if ([[xbuildInfo getDisplayMode] isEqualToString:QST_DISPLAYMODE_SMALL]) {
        ratio = DISPLAYMODE_SMALL_RATIO;
    }
    
    size = [self.titleLabel labelResize:size ratio:ratio];
    
    CGFloat paddingX = MAIN_CELL_PADDING;
    if ([xbuildInfo getQuestIconURL].length > 0 && !CGRectIsEmpty(self.iconImageView.frame)) {
        paddingX = CGRectGetMaxX(self.iconImageView.frame) + MAIN_TEXT_IMG_PADDING;
    }
    
    [self setTitleLabelFrame:CGRectMake(paddingX, 0, size.width, size.height)];
}

- (void)setTitle:(NSString *)title {

    if (self.titleLabel.text.length > 0 && title.length > self.titleLabel.text.length && [xbuildInfo getOrientation] && [[xbuildInfo getOrientation] isEqualToString:@"0"]) {
        
        self.titleLabel.text = title;
        [self resetTittleFrame:self.titleLabel];
    }
    
    self.titleLabel.text = title;
}

- (NSString *)getTitle {
    
    return self.titleLabel.text;
}

- (void) resetTittleFrame :(UILabel *)label{
    
    CGFloat height = label.height;
    CGSize titleSize = [label.text ws_sizeWithFont:label.font constrainedToHeight:height];
    [self.titleLabel setFrame:CGRectMake(label.frame.origin.x, self.titleLabel.frame.origin.y, titleSize.width, height)];
}

- (void)setReadonlyStyle:(NSString *)isReadonly {
    
    UIColor *bgColor = nil;
    NSString *bgColorString = [xbuildInfo getBgColor];
    if (bgColorString.length > 0) {
        bgColor = [UIColor colorWithHexString:bgColorString];
    }
    
    if ([isReadonly intValue] == 1) {
        
        [self setTitleLabelColor:[xbuildInfo getTitleReadColor] ? [UIColor colorWithHexString:[xbuildInfo getTitleReadColor]] : kBasePannelTitleColor];
        if (bgColor) {
            self.backgroundColor = [bgColor colorWithAlphaComponent:ALPHA_DISABLED];
        }
        else {
            self.backgroundColor = MAIN_CELL_DISABLE_COLOR;
        }
    }
    else {
        
        [self setTitleLabelColorStrByHex:[xbuildInfo getTextColor]];
        [self setTitleContent:self.titleLabel.text];

        if (bgColor) {
            self.backgroundColor = bgColor;
        }
    }
}

- (void)setReadonly:(NSString *)isReadonly {
    
    [super setReadonly:isReadonly];
    [self setReadonlyStyle:isReadonly];
}

- (void)setTitleFoldEnable:(BOOL)isEnable {
    
    UIImage *foldImage = [UIImage imageNamed:@"brand_checked"];
    CGRect titleFrame = self.titleLabel.frame;
    if (!self.foldImageView) {
        
        UIImageView *foldImageView = [[UIImageView alloc] initWithImage:foldImage];
        [self addSubview:foldImageView];
        
        CGRect foldFrame = CGRectMake(titleFrame.origin.x, (titleFrame.size.height - foldImage.size.height) / 2, foldImage.size.width, foldImage.size.height);
        [foldImageView setFrame:foldFrame];
        
        self.foldImageView = foldImageView;
    }
    
    if (isEnable) {
        
        if (!self.tapGesture) {
            self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(titleFoldTapped:)];
        }
        [self addGestureRecognizer:self.tapGesture];
        
        [self.foldImageView setHidden:NO];
        titleFrame.origin.x += foldImage.size.width + MAIN_TEXT_IMG_PADDING;
    }
    else {
        
        if (self.tapGesture) {
            [self removeGestureRecognizer:self.tapGesture];
        }
        [self.foldImageView setHidden:YES];
        titleFrame.origin.x -= foldImage.size.width + MAIN_TEXT_IMG_PADDING;
    }
    
    self.titleLabel.frame = titleFrame;
}

- (void)setIsTitleFold:(BOOL)isTitleFold {
    
    _isTitleFold = isTitleFold;
    [self titleFold];
}

- (void)titleFoldTapped:(UITapGestureRecognizer *)recognizer {
    
    CGPoint point = [recognizer locationInView:self];
    CGRect titleFrame = CGRectMake(0, 0, self.width, self.titleLabel.height);
    BOOL isInTitleRect = CGRectContainsPoint(titleFrame, point);
    if (!isInTitleRect) {
        return;
    }
    
    self.isTitleFold = !self.isTitleFold;
    [self titleFold];
}

- (CGFloat)getFoldedContentHeight {
    
    return 0.0;
}

- (void)titleFold {
    
    [UIView animateWithDuration:MAIN_ANIM_DURATION animations:^{
    
        CGRect frame = self.frame;
        if ([self isTitleFold]) {
            self.foldImageView.transform = CGAffineTransformIdentity;
            frame.size.height = self.titleLabel.height;
        }
        else {
            frame.size.height = [self getFoldedContentHeight];
            self.foldImageView.transform = CGAffineTransformMakeRotation(M_PI);
        }
        self.frame = frame;
        
        [[self superview] layoutSubviews];
    }];
}

@end
