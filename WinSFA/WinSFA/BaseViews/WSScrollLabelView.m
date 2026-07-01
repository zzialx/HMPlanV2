//
//  WSScrollLabelView.m
//  WinSFA
//
//  Created by Alicia on 2017/11/22.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSScrollLabelView.h"


static const NSInteger kLabelCount  = 2;
static const CGFloat kLabelGap = 20;
static const CGFloat kScrollSpeed = 30;


@interface WSScrollLabelView()

@property (nonatomic, strong) NSArray *labelArray;
@property (nonatomic, strong, readonly) UILabel *mainLabel;
@property (nonatomic, strong) UIScrollView *scrollView;

@end

@implementation WSScrollLabelView

#pragma mark - Init
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationWillEnterForegroundNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidBecomeActiveNotification
                                                  object:nil];
    
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self refreshLabelArray];
}

- (void)setupViews {
     self.backgroundColor = [UIColor clearColor];
    
    NSMutableArray *labelArray = [[NSMutableArray alloc] initWithCapacity:kLabelCount];
    
    for (NSInteger i = 0; i < kLabelCount; i++) {
        UILabel *label = [[UILabel alloc] init];
        [self.scrollView addSubview:label];
        [labelArray addObject:label];
    }
    
    self.labelArray = [labelArray copy];
    
 
    self.scrollSpeed = kScrollSpeed;
    self.textAlignment = NSTextAlignmentCenter;
    
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.scrollEnabled = NO;
    
    self.userInteractionEnabled = NO;
    self.clipsToBounds = YES;
    
    [self refreshLabelArray];
    [self addObserverToScrollIfNeeded];
}

#pragma mark - Pubilc Method
- (void)scrollIfNeeded {
    if (!self.text.length)
        return;
    
    CGFloat labelWidth = CGRectGetWidth(self.mainLabel.bounds);
    if (labelWidth <= CGRectGetWidth(self.bounds))
        return;
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(scrollIfNeeded) object:nil];
    
    [self.scrollView.layer removeAllAnimations];
    
    self.scrollView.contentOffset = CGPointZero;
    
    NSTimeInterval duration = labelWidth / self.scrollSpeed;
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction animations:^{
        self.scrollView.contentOffset = CGPointMake(labelWidth + kLabelGap, 0);
    } completion:^(BOOL finished) {
        // Loop
        if (finished) {
             [self performSelector:@selector(scrollIfNeeded) withObject:nil];
        }
    }];
}


#pragma mark - KVO
- (void)addObserverToScrollIfNeeded {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(scrollIfNeeded)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(scrollIfNeeded)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
}

#pragma mark - Private Method

- (void)refreshLabelArray {
    CGFloat offset = 0;
    CGRect viewFrame = self.frame;
    for (UILabel *label in self.labelArray) {
        [label sizeToFit];
        CGRect frame = label.frame;
        frame.origin = CGPointMake(offset, 0);
        frame.size.height = CGRectGetHeight(self.bounds);
        label.frame = frame;
        
        viewFrame.size.width = frame.size.width;
        
        // center label vertically
        label.center = CGPointMake(label.center.x, self.center.y - self.frame.origin.y);
        
        offset += CGRectGetWidth(label.bounds) + kLabelGap;
    }
    if (viewFrame.size.width > 0 && viewFrame.size.width < self.frame.size.width) {
        if (self.textAlignment == NSTextAlignmentCenter) {
            viewFrame.origin.x = (self.frame.size.width - viewFrame.size.width) / 2;
        }
        [self setFrame:viewFrame];
    }
    self.scrollView.contentOffset = CGPointZero;
    [self.scrollView.layer removeAllAnimations];
    
    // When label text longer then its bounds then scroll
    if (CGRectGetWidth(self.mainLabel.bounds) > CGRectGetWidth(self.bounds)) {
        CGSize size;
        size.width = CGRectGetWidth(self.mainLabel.bounds) + CGRectGetWidth(self.bounds) + kLabelGap;
        size.height = CGRectGetHeight(self.bounds);
        self.scrollView.contentSize = size;
        
        [self setLabelArrayIsHidden:NO];
    } else {
        [self setOtherLabelIsHidden];
        
        self.scrollView.contentSize = self.bounds.size;
        self.mainLabel.frame = self.bounds;
        self.mainLabel.hidden = NO;
        self.mainLabel.textAlignment = self.textAlignment;
        
        [self.scrollView.layer removeAllAnimations];
    }
}

- (void)setLabelArrayIsHidden:(BOOL)isHidden {
    for (UILabel *label in self.labelArray) {
        [label setHidden:isHidden];
    }
}

- (void)setOtherLabelIsHidden {
    for (UILabel *label in self.labelArray) {
        if (label != self.mainLabel) {
            [label setHidden:YES];
        }
    }
}


#pragma mark - Properties

- (void)setText:(NSString *)text {
    if ([text isEqualToString:self.text])
        return;
    
    _text = text;
    
    for (UILabel *label in self.labelArray) {
        [label setText:text];
    }
    
    [self refreshLabelArray];
}

- (void)setTextColor:(UIColor *)textColor {
    for (UILabel *label in self.labelArray) {
        [label setTextColor:textColor];
    }
}


- (void)didMoveToWindow {
    [super didMoveToWindow];
    
    if (self.window) {
        // Add delay to make sure animation begins after view did appear
        [self performSelector:@selector(scrollIfNeeded) withObject:nil afterDelay:1];
    }
}


- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        _scrollView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
        _scrollView.backgroundColor = [UIColor clearColor];
        
        [self addSubview:_scrollView];
    }
    return _scrollView;
}

- (UILabel *)mainLabel {
    if (self.labelArray) {
        return self.labelArray[0];
    } else {
        return nil;
    }
}

@end
