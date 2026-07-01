	//
//  BlockAlertView.m
//
//

#import "BlockAlertView.h"
#import "BlockBackground.h"
#import "BlockUI.h"


#define kMaxDescHeight      (SCREEN_HEIGHT * 0.48)
#define SUBPadSPACEY      10.f

@interface BlockAlertView () <CAAnimationDelegate>

@end

@implementation BlockAlertView

@synthesize view = _view;
@synthesize backgroundImage = _backgroundImage;
@synthesize vignetteBackground = _vignetteBackground;
@synthesize opdelegate;
@synthesize alignment = _alignment;
@synthesize subAlignment = _subAlignment;
@synthesize subMessage = _subMessage;
@synthesize subColor = _subColor;


static UIImage *background = nil;
static UIImage *backgroundlandscape = nil;
static UIFont *titleFont = nil;
static UIFont *messageFont = nil;
static UIFont *buttonFont = nil;


#pragma mark - init

+ (void)initialize
{
    if (self == [BlockAlertView class])
    {
        background = [UIImage imageNamed:kAlertViewBackground];
        background = [[background stretchableImageWithLeftCapWidth:0 topCapHeight:kAlertViewBackgroundCapHeight] retain];
        
        backgroundlandscape = [UIImage imageNamed:kAlertViewBackgroundLandscape];
        backgroundlandscape = [[backgroundlandscape stretchableImageWithLeftCapWidth:0 topCapHeight:kAlertViewBackgroundCapHeight] retain];
        
        titleFont = [kAlertViewTitleFont retain];
        messageFont = [kAlertViewMessageFont retain];
        buttonFont = [kAlertViewButtonFont retain];
    }
}

+ (BlockAlertView *)alertWithTitle:(NSString *)title message:(NSString *)message
{
    return [[[BlockAlertView alloc] initWithTitle:title message:message] autorelease];
}

+ (BlockAlertView *)alertWithTitle:(NSString *)title message:(NSString *)message subMessage:(NSString *)subMessage subColor:(UIColor *)subColor alignment:(BlockAlertViewAlignment)alignment subMessageAlignment:(BlockAlertViewAlignment)subMessageAlignment{
    return [[[BlockAlertView alloc] initWithTitle:title message:message subMessage:subMessage subColor:subColor alignment:alignment subMessageAlignment:subMessageAlignment] autorelease];
}

+ (BlockAlertView *)alertWithTitle:(NSString *)title message:(NSString *)message alignment:(BlockAlertViewAlignment)alignment;
{
    return [[[BlockAlertView alloc] initWithTitle:title message:message alignment:alignment] autorelease];
}

+ (void)showInfoAlertWithTitle:(NSString *)title message:(NSString *)message
{
    BlockAlertView *alert = [[BlockAlertView alloc] initWithTitle:title message:message];
    [alert setCancelButtonWithTitle:NSLocalizedString(@"Dismiss", nil) block:nil];
    [alert show];
    [alert release];
}

+ (void)showErrorAlert:(NSError *)error
{
    BlockAlertView *alert = [[BlockAlertView alloc] initWithTitle:NSLocalizedString(@"Operation Failed", nil) message:[NSString stringWithFormat:NSLocalizedString(@"The operation did not complete successfully: %@", nil), error]];
    [alert setCancelButtonWithTitle:@"Dismiss" block:nil];
    [alert show];
    [alert release];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - NSObject

- (void)addComponents:(CGRect)frame {
    // 标题不为空 但是消息为空时，二者调换
    if (!_message || [_message isEqualToString:@""]) {
        if (_title && ![_title isEqualToString:@""]&& !_subMessage) {
            _message = [_title copy];
            _title = [[NSString alloc] initWithString:NSLocalizedString(@"js_alert_title", nil)];
        }
    }
    
    CGFloat labelWidth = frame.size.width - 2 * MAIN_PADDING;
    CGSize size;
    if (IOS_LESS_THAN_7) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        size = [_title sizeWithFont:titleFont constrainedToSize:CGSizeMake(labelWidth, 1000) lineBreakMode:NSLineBreakByWordWrapping];
#pragma clang diagnostic pop
    }
    else {
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        size = [_title boundingRectWithSize:CGSizeMake(labelWidth, 1000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSParagraphStyleAttributeName : paragraphStyle, NSFontAttributeName : titleFont} context:nil].size;
        size = CGSizeMake(ceilf(size.width), ceilf(size.height));
        [paragraphStyle release];
    }
    if (size.height < MAIN_CELL_HEIGHT) {
        size.height = MAIN_CELL_HEIGHT;
    }
    
    UILabel *labelView = [[UILabel alloc] initWithFrame:CGRectMake(MAIN_PADDING, MAIN_PADDING, labelWidth, size.height)];
    labelView.font = titleFont;
    labelView.numberOfLines = 0;
    labelView.lineBreakMode = NSLineBreakByWordWrapping;
    labelView.textColor = MAIN_TEXT_COLOR;
    //        labelView.backgroundColor = kAlertViewTitleBackgroudColor;
    labelView.textAlignment = NSTextAlignmentCenter;
    labelView.shadowColor = kAlertViewTitleShadowColor;
    labelView.shadowOffset = kAlertViewTitleShadowOffset;
//    labelView.backgroundColor = [UIColor clearColor];
    labelView.text = _title;
    [_view addSubview:labelView];
    [labelView release];
    
    
    _height += size.height;
    
    CGFloat paddingY = CGRectGetMaxY(labelView.frame);
    CGFloat subPaddingY;
    if (_message)
    {
        CGSize size;
        if (IOS_LESS_THAN_7) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            size = [_message sizeWithFont:messageFont constrainedToSize:CGSizeMake(frame.size.width-kAlertViewLabelLeftMargin*2, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
#pragma clang diagnostic pop
        }
        else {
            NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
            paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
            size = [_message boundingRectWithSize:CGSizeMake(frame.size.width-kAlertViewLabelLeftMargin*2, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSParagraphStyleAttributeName : paragraphStyle, NSFontAttributeName : messageFont} context:nil].size;
            size = CGSizeMake(ceilf(size.width), ceilf(size.height));
            [paragraphStyle release];
        }
        
        CGRect descLabelFrame;
        CGFloat descLabelHeight;
        UIScrollView *scrollView = nil;
        if (size.height <= kMaxDescHeight) {
            descLabelFrame = CGRectMake(kAlertViewLabelLeftMargin, paddingY, frame.size.width-kAlertViewLabelLeftMargin*2, size.height);
            descLabelHeight = size.height;
        } else {
            scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, paddingY, frame.size.width, kMaxDescHeight)];
            [scrollView setContentSize:CGSizeMake(frame.size.width, size.height)];
            [_view addSubview:scrollView];
            
            descLabelFrame = CGRectMake(kAlertViewLabelLeftMargin, 0, frame.size.width-kAlertViewLabelLeftMargin*2, size.height);
            descLabelHeight = kMaxDescHeight;
        }
        
        UILabel *labelView = [[UILabel alloc] initWithFrame:descLabelFrame];
        labelView.font = messageFont;
        labelView.numberOfLines = 0;
        labelView.lineBreakMode = NSLineBreakByWordWrapping;
        labelView.textColor = DETAIL_TEXT_COLOR;
        labelView.backgroundColor = [UIColor clearColor];
        NSTextAlignment textAlignment;
        if (_alignment == BlockAlertViewAlignmentLeft) {
            textAlignment = NSTextAlignmentLeft;
        } else {
            textAlignment = NSTextAlignmentCenter;
        }
        labelView.textAlignment = textAlignment;
        labelView.shadowColor = kAlertViewMessageShadowColor;
        labelView.shadowOffset = kAlertViewMessageShadowOffset;
        labelView.text = _message;
        if (!scrollView) {
            [_view addSubview:labelView];
        } else {
            [scrollView addSubview:labelView];
            [scrollView release];
        }
        
        [labelView release];
        
        _height += descLabelHeight;
        subPaddingY = CGRectGetMaxY(labelView.frame);

    }
    
    //SFA-23678 【iOS】扫码查询中，物流码不属于该终端时，应提示：该物流码不属于该终端，且置红(添加子message在主message下边显示)
    if (_subMessage)
    {
        CGSize size;
        if (!_message || [_message isEqualToString:@""]) {
            subPaddingY = CGRectGetMaxY(labelView.frame) + SUBPadSPACEY;
        }else{
            subPaddingY = subPaddingY + SUBPadSPACEY;
        }
        
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        size = [_subMessage boundingRectWithSize:CGSizeMake(frame.size.width-kAlertViewLabelLeftMargin*2, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSParagraphStyleAttributeName : paragraphStyle, NSFontAttributeName : messageFont} context:nil].size;
        size = CGSizeMake(ceilf(size.width), ceilf(size.height));
        [paragraphStyle release];
        
        CGRect descLabelFrame;
        CGFloat descLabelHeight;
        UIScrollView *scrollView = nil;
        if (size.height <= kMaxDescHeight) {
            descLabelFrame = CGRectMake(kAlertViewLabelLeftMargin, subPaddingY, frame.size.width-kAlertViewLabelLeftMargin*2, size.height);
            descLabelHeight = size.height;
        } else {
            scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, subPaddingY, frame.size.width, kMaxDescHeight)];
            [scrollView setContentSize:CGSizeMake(frame.size.width, size.height)];
            [_view addSubview:scrollView];
            
            descLabelFrame = CGRectMake(kAlertViewLabelLeftMargin, 0, frame.size.width-kAlertViewLabelLeftMargin*2, size.height);
            descLabelHeight = kMaxDescHeight;
        }
        
        UILabel *labelView = [[UILabel alloc] initWithFrame:descLabelFrame];
        labelView.font = messageFont;
        labelView.numberOfLines = 0;
        labelView.lineBreakMode = NSLineBreakByWordWrapping;
        
        if (_subColor) {
            labelView.textColor = _subColor;
        }else{
            labelView.textColor = DETAIL_TEXT_COLOR;
        }
        labelView.backgroundColor = [UIColor clearColor];
        NSTextAlignment textAlignment;
        if (_subAlignment == BlockAlertViewAlignmentLeft) {
            textAlignment = NSTextAlignmentLeft;
        } else {
            textAlignment = NSTextAlignmentCenter;
        }
        labelView.textAlignment = textAlignment;
        labelView.shadowColor = kAlertViewMessageShadowColor;
        labelView.shadowOffset = kAlertViewMessageShadowOffset;
        labelView.text = _subMessage;
        if (!scrollView) {
            [_view addSubview:labelView];
        } else {
            [scrollView addSubview:labelView];
            [scrollView release];
        }
        
        [labelView release];
        
        _height += descLabelHeight;
    }

}

- (void)setupDisplay
{
    [[_view subviews] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [obj removeFromSuperview];
    }];
    
    UIWindow *parentView = [BlockBackground sharedInstance];
    CGRect frame = parentView.bounds;
    
    float width;
    if (background) {
        width = background.size.width;
    }
    else
    {
        width = SCREEN_WIDTH * POP_VIEW_WIDTH_RATIO;
    }
    frame.origin.x = floorf((frame.size.width - width) * 0.5);
    frame.size.width = width;
    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        if (background) {
            frame.size.width += 150;
            frame.origin.x -= 75;
        }
    }
    
    _view.frame = frame;
    
    _height = kAlertViewTitleLabelTopGap;
    
    if (NeedsLandscapePhoneTweaks) {
        _height -= 15; // landscape phones need to trimmed a bit
    }

    [self addComponents:frame];

    if (_shown)
        [self show];
}

- (id)initWithTitle:(NSString *)title message:(NSString *)message {
    return [self initWithTitle:title message:message alignment:BlockAlertViewAlignmentCenter];
}

- (id)initWithTitle:(NSString *)title message:(NSString *)message subMessage:(NSString *)subMessage subColor:(UIColor *)subColor alignment:(BlockAlertViewAlignment)alignment subMessageAlignment:(BlockAlertViewAlignment)subMessageAlignment{
    _subMessage = subMessage;
    _subColor = subColor;
    _subAlignment = subMessageAlignment;
    return  [self initWithTitle:title message:message alignment:alignment];
    
    
}

- (id)initWithTitle:(NSString *)title message:(NSString *)message alignment:(BlockAlertViewAlignment)alignment
{
    self = [super init];
    
    if (self)
    {
        if (title) {
            _title = [title copy];
        } else {
            _title = [[NSString alloc] initWithString:NSLocalizedString(@"js_alert_title", nil)];
        }
        _message = [message copy];
        
        _view = [[UIView alloc] init];
        
        _view.layer.cornerRadius = kAlertViewBackgroundCornerRadius;
        _view.clipsToBounds = YES;
        _view.layer.masksToBounds = YES;
        
        _view.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        
        _blocks = [[NSMutableArray alloc] init];
        
        _alignment = alignment;
        
        if ([[[UIDevice currentDevice] systemVersion] compare:@"8.0" options:NSNumericSearch] == NSOrderedDescending){
            // don't register for notification, rotation is handled by iOS on 8+
        }
        else {        
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(setupDisplay) 
                                                         name:UIApplicationDidChangeStatusBarOrientationNotification 
                                                       object:nil];
        }
        
        if ([self class] == [BlockAlertView class])
            [self setupDisplay];
        
        _vignetteBackground = NO;
    }
    
    return self;
}

- (void)dealloc 
{
    [_title release];
    [_message release];
    [_backgroundImage release];
    [_view release];
    [_blocks release];
    [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Public

- (void)addButtonWithTitle:(NSString *)title color:(NSString*)color block:(void (^)())block 
{
    [_blocks addObject:[NSArray arrayWithObjects:
                        block ? [[block copy] autorelease] : [NSNull null],
                        title,
                        color,
                        nil]];
}

- (void)addButtonWithTitle:(NSString *)title block:(void (^)())block 
{
    [self addButtonWithTitle:title color:@"gray" block:block];
}

- (void)setCancelButtonWithTitle:(NSString *)title block:(void (^)())block 
{
    [self addButtonWithTitle:title color:@"black" block:block];
}

- (void)setDestructiveButtonWithTitle:(NSString *)title block:(void (^)())block
{
    [self addButtonWithTitle:title color:@"red" block:block];
}

- (void)addButtonWithTitle:(NSString *)title imageIdentifier:(NSString*)identifier block:(void (^)())block {
    [self addButtonWithTitle:title color:identifier block:block];
}

- (void)show
{
    LogInfo(@"Alert msg:%@, title:%@", _title, _message);
    
    // MSTD-5448 弹出提示框时收起键盘，防止键盘遮挡无法操作页面的情况
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];

    _shown = YES;
    
    BOOL isSecondButton = NO;
    NSUInteger index = 0;
    
    
    _height += kAlertViewButtonTopGap;
    for (NSUInteger i = 0; i < _blocks.count; i++)
    {
        NSArray *block = [_blocks objectAtIndex:i];
        NSString *title = [block objectAtIndex:1];
        NSString *color = [block objectAtIndex:2];

        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"alert-%@-button.png", color]];
        image = [image stretchableImageWithLeftCapWidth:(int)(image.size.width+1)>>1 topCapHeight:0];
        
        UIImage *highlightedImage = [UIImage imageNamed:[NSString stringWithFormat:@"alert-%@-button-highlighted.png", color]];
        
        highlightedImage = [highlightedImage stretchableImageWithLeftCapWidth:(int)(highlightedImage.size.width+1)>>1 topCapHeight:0];
        
        CGFloat maxHalfWidth = ceilf((_view.bounds.size.width - kAlertViewButtonBLeftMargin*2 - kAlertViewButtonGap)*0.5);
        CGFloat width = _view.bounds.size.width - kAlertViewButtonBLeftMargin*2;
        CGFloat xOffset = kAlertViewButtonBLeftMargin;
//        if (isSecondButton)
//        {
//            width = maxHalfWidth;
//            xOffset = width + kAlertViewButtonBLeftMargin + kAlertViewButtonGap;
//            isSecondButton = NO;
//        }
//        else if (i + 1 < _blocks.count)
//        {
//            // In this case there's another button.
//            // Let's check if they fit on the same line.
//            CGSize size = [title sizeWithFont:buttonFont 
//                                  minFontSize:10 
//                               actualFontSize:nil
//                                     forWidth:_view.bounds.size.width-kAlertViewButtonBLeftMargin*2
//                                lineBreakMode:NSLineBreakByClipping];
//            
//            if (size.width < maxHalfWidth - kAlertViewButtonBLeftMargin)
//            {
//                // It might fit. Check the next Button
//                NSArray *block2 = [_blocks objectAtIndex:i+1];
//                NSString *title2 = [block2 objectAtIndex:1];
//                size = [title2 sizeWithFont:buttonFont 
//                                minFontSize:10 
//                             actualFontSize:nil
//                                   forWidth:_view.bounds.size.width-kAlertViewButtonBLeftMargin*2
//                              lineBreakMode:NSLineBreakByClipping];
//                
//                if (size.width < maxHalfWidth - kAlertViewButtonBLeftMargin)
//                {
//                    // They'll fit!
//                    isSecondButton = YES;  // For the next iteration
//                    width = maxHalfWidth;
//                }
//            }
//        }
//        else if (_blocks.count  == 1)
//        {
//            // In this case this is the ony button. We'll size according to the text
//            CGSize size = [title sizeWithFont:buttonFont
//                                  minFontSize:10
//                               actualFontSize:nil
//                                     forWidth:_view.bounds.size.width-kAlertViewButtonBLeftMargin*2
//                                lineBreakMode:NSLineBreakByClipping];
//            
//            size.width = MAX(size.width, 80);
//            if (size.width + 2 * kAlertViewButtonBLeftMargin < width)
//            {
//                width = size.width + 2 * kAlertViewButtonBLeftMargin;
//                xOffset = floorf((_view.bounds.size.width - width) * 0.5);
//            }
//        }
        
        if (_blocks.count == 2) {
            width = maxHalfWidth;
            if (i == 1) {
                isSecondButton = NO;
                xOffset = width + kAlertViewButtonBLeftMargin + kAlertViewButtonGap;
            }
            else
            {
                isSecondButton = YES;
            }
        }
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(xOffset, _height, width, kAlertButtonHeight);
        button.titleLabel.font = buttonFont;
        if (IOS_LESS_THAN_6) {
#pragma clan diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            button.titleLabel.minimumFontSize = 10;
#pragma clan diagnostic pop
        }
        else {
            button.titleLabel.adjustsFontSizeToFitWidth = YES;
            button.titleLabel.adjustsLetterSpacingToFitWidth = YES;
            button.titleLabel.minimumScaleFactor = 0.1;
        }
        button.titleLabel.textAlignment = NSTextAlignmentCenter;
        button.titleLabel.shadowOffset = kAlertViewButtonShadowOffset;
        
        button.tag = i+1;
        
        if (image) {
            button.backgroundColor = [UIColor clearColor];
            [button setBackgroundImage:image forState:UIControlStateNormal];
        }
        else
        {
            button.backgroundColor = kAlertViewButtonBackgroundColor;
        }
        
        if (highlightedImage)
        {
            [button setBackgroundImage:highlightedImage forState:UIControlStateHighlighted];
        }
        else
        {
            [button setBackgroundImage:[UIImage imageFromColor:kAlertViewButtonBackgroundColorHL with:button.bounds] forState:UIControlStateHighlighted];
        }
        [button setTitleColor:[color isEqualToString:@"red"] ? [UIColor redColor] : kAlertViewButtonTextColor forState:UIControlStateNormal];
        [button setTitleShadowColor:kAlertViewButtonShadowColor forState:UIControlStateNormal];
        [button setTitle:title forState:UIControlStateNormal];
        button.accessibilityLabel = title;
        
        [button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        
        CALayer *TopBorder = [CALayer layer];
        TopBorder.frame = CGRectMake(0, 0, button.frame.size.width, 1);
        TopBorder.backgroundColor =  DETAIL_SEPERATE_LINE_COLOR.CGColor;
        [button.layer addSublayer:TopBorder];

        if (i != _blocks.count - 1) {
            CALayer *RightBorder = [CALayer layer];
            RightBorder.frame = CGRectMake(button.frame.size.width, 0, 1, button.frame.size.height);
            RightBorder.backgroundColor = DETAIL_SEPERATE_LINE_COLOR.CGColor;
            [button.layer addSublayer:RightBorder];
        }
        
        [_view addSubview:button];
        
        if (!isSecondButton)
        {
            _height += kAlertButtonHeight;
            if (i != _blocks.count - 1) {
                _height += kAlertViewButtonGap;
            }
        }
        
        index++;
    }

    //_height += 10;  // Margin for the shadow // not sure where this came from, but it's making things look strange (I don't see a shadow, either)
    
    if (_height < background.size.height)
    {
        CGFloat offset = background.size.height - _height;
        _height = background.size.height;
        CGRect frame;
        for (NSUInteger i = 0; i < _blocks.count; i++)
        {
            UIButton *btn = (UIButton *)[_view viewWithTag:i+1];
            frame = btn.frame;
            frame.origin.y += offset;
            btn.frame = frame;
        }
    }
    
    
    CGRect frame = _view.frame;
//    frame.origin.y = - _height;
    frame.origin.y = [BlockBackground sharedInstance].frame.size.height;
    frame.size.height = _height;
    _view.frame = frame;
    
    UIView *modalBackground;
    
    if (background && backgroundlandscape) {
        modalBackground = [[UIImageView alloc] initWithFrame:_view.bounds];
        
        if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]))
            ((UIImageView *)modalBackground).image = backgroundlandscape;
        else
            ((UIImageView *)modalBackground).image = background;
    }
    else
    {
        modalBackground = [[UIView alloc] initWithFrame:_view.bounds];
        modalBackground.layer.cornerRadius = kAlertViewBackgroundCornerRadius;
        modalBackground.backgroundColor = kAlertViewBackgroundColor;
    }

    modalBackground.contentMode = UIViewContentModeScaleToFill;
    modalBackground.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [_view insertSubview:modalBackground atIndex:0];
    [modalBackground release];
    
    if (_backgroundImage)
    {
        [BlockBackground sharedInstance].backgroundImage = _backgroundImage;
        [_backgroundImage release];
        _backgroundImage = nil;
    }
    
    [BlockBackground sharedInstance].vignetteBackground = _vignetteBackground;
    [[BlockBackground sharedInstance] addToMainWindow:_view];

    __block CGPoint center = _view.center;
    center.y = floorf([BlockBackground sharedInstance].bounds.size.height * 0.5) + kAlertViewBounce;
    
    _cancelBounce = NO;
    
//    [UIView animateWithDuration:0.4
//                          delay:0.0
//                        options:UIViewAnimationOptionCurveEaseOut
//                     animations:^{
//                         [BlockBackground sharedInstance].alpha = 1.0f;
//                         _view.center = center;
//                     } 
//                     completion:^(BOOL finished) {
//                         if (_cancelBounce) return;
//                         
//                         [UIView animateWithDuration:0.1
//                                               delay:0.0
//                                             options:0
//                                          animations:^{
//                                              center.y -= kAlertViewBounce;
//                                              _view.center = center;
//                                          } 
//                                          completion:^(BOOL finished) {
//                                              [[NSNotificationCenter defaultCenter] postNotificationName:@"AlertViewFinishedAnimations" object:self];
//                                          }];
//                     }];
    
    //以下是自己定制的动画，上面注掉的代码是开源库原来的默认动画
    _view.center = center;
    [BlockBackground sharedInstance].alpha = 1.0f;
    [[BlockBackground sharedInstance].layer addAnimation:fadeInAnimation(kFadeAnimationDuration) forKey:@"fadeAnimation"];
    CAAnimation *popup = popupAnimation([BlockBackground sharedInstance].frame.size.height + _height/2 + 10, center.y);
    popup.delegate = self;
    [_view.layer addAnimation:popup forKey:@"popupAnimation"];
    [self performSelector:@selector(showAnimationFinished) withObject:nil afterDelay:kPopupAnimationDuration];
    
    
    [self retain];
}

- (void)dismissWithClickedButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated 
{
    _shown = NO;
    
    
    // add by jimmy lee
    if ([opdelegate respondsToSelector:@selector(clickBtnAtIndex:inBlockView:)]) {
        
        [opdelegate clickBtnAtIndex:buttonIndex inBlockView:self];
        
    }
    // add by jimmy lee
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    if (buttonIndex >= 0 && buttonIndex < [_blocks count])
    {
        id obj = [[_blocks objectAtIndex: buttonIndex] objectAtIndex:0];
        if (![obj isEqual:[NSNull null]])
        {
            ((void (^)())obj)();
        }
    }
    
    if (animated)
    {
//        [UIView animateWithDuration:0.1
//                              delay:0.0
//                            options:0
//                         animations:^{
//                             CGPoint center = _view.center;
//                             center.y += 20;
//                             _view.center = center;
//                         } 
//                         completion:^(BOOL finished) {
//                             [UIView animateWithDuration:0.4
//                                                   delay:0.0 
//                                                 options:UIViewAnimationOptionCurveEaseIn
//                                              animations:^{
//                                                  CGRect frame = _view.frame;
//                                                  frame.origin.y = -frame.size.height;
//                                                  _view.frame = frame;
//                                                  [[BlockBackground sharedInstance] reduceAlphaIfEmpty];
//                                              } 
//                                              completion:^(BOOL finished) {
//                                                  [[BlockBackground sharedInstance] removeView:_view];
//                                                  [_view release]; _view = nil;
//                                                  [self autorelease];
//                                              }];
//                         }];
        
        //以下是自己定制的动画，上面注掉的代码是开源库原来的默认动画
        [UIView animateWithDuration:kFadeAnimationDuration
                              delay:kPopupAnimationDuration - kFadeAnimationDuration
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             [[BlockBackground sharedInstance] reduceAlphaIfEmpty];
        }
                         completion:^(BOOL finished) {
                             [self hideAnimationFinished];
        }];
       
        float originY = _view.layer.position.y;
        CGPoint center = _view.center;
        center.y = [BlockBackground sharedInstance].frame.size.height + _view.height + 10;
        _view.center = center;
        [_view.layer addAnimation:popupAnimation(originY, center.y) forKey:@"popupAnimation"];
    }
    else
    {
        [[BlockBackground sharedInstance] removeView:_view];
        [_view release]; _view = nil;
        [self autorelease];
    }
}

- (void)showAnimationFinished
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"AlertViewFinishedAnimations" object:self];
}

- (void)hideAnimationFinished
{
    [[BlockBackground sharedInstance] removeView:_view];
    [_view release]; _view = nil;
    [self autorelease];;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Action

- (void)buttonClicked:(id)sender 
{
    /* Run the button's block */
    NSInteger buttonIndex = [(UIButton *)sender tag] - 1;
    [self dismissWithClickedButtonIndex:buttonIndex animated:YES];
}

#pragma mark - Animation delegate
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
}

//以下是我们自己定制的动画，不使用开源库原来的动画效果
#pragma mark - Animation

CAAnimation *fadeInAnimation(float duration)
{
    CABasicAnimation *basicAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    basicAnimation.fromValue = @(0.0);
    basicAnimation.toValue = @(1.0);
    basicAnimation.duration = duration;
    return basicAnimation;
}

CAAnimation *fadeOutAnimation(float duration)
{
    CABasicAnimation *basicAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    basicAnimation.fromValue = @(1.0);
    basicAnimation.toValue = @(0.0);
    basicAnimation.duration = duration;
    return basicAnimation;
}

CAAnimation *popupAnimation(float startValue, float endValue) {
    
    NSArray *frameValues = [BlockAlertView generateValuesWithFrom:startValue to:endValue duration:kPopupAnimationDuration];
    
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"position.y"];
    animation.values = frameValues;
    animation.fillMode = kCAFillModeForwards;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    animation.removedOnCompletion = YES;
    animation.duration = kPopupAnimationDuration;
    return animation;
}

+ (NSArray *)generateValuesWithFrom:(double)startValue to:(double)endValue duration:(CGFloat)duration
{
    NSUInteger steps = (NSUInteger)ceil(kFPS * duration) + 2;
	
	NSMutableArray *valueArray = [NSMutableArray arrayWithCapacity:steps];
    
    const double increment = 1.0 / (double)(steps - 1);
    
    double progress = 0.0,
    v = 0.0,
    value = 0.0;
    
    NSUInteger i;
    for (i = 0; i < steps; i++)
    {
        v = NSBKeyframeAnimationFunctionEaseInOutElastic(duration * progress * 1000, 0, 1, duration * 1000);
        value = startValue + v * (endValue - startValue);
        
        [valueArray addObject:[NSNumber numberWithDouble:value]];
        
        progress += increment;
    }
    
    return [NSArray arrayWithArray:valueArray];
}

double NSBKeyframeAnimationFunctionEaseInOutElastic(double t, double b, double c, double d)
{
    double s=1.70158, p=0, a=c;
    if (t==0) return b;  if ((t/=d/2)==2) return b+c;  if (!p) p=d*(.3*1.5);
    if (a < abs(c)) { a=c; s=p/4; }
    else s = p/(2*M_PI) * asin(c/a);
    if (t < 1) return -.5*(a*pow(2,10*(t-=1)) * sin( (t*d-s)*(2*M_PI)/p )) + b;
    return a*pow(2,-10*(t-=1)) * sin( (t*d-s)*(2*M_PI)/p )*.5 + c + b;
}

@end
