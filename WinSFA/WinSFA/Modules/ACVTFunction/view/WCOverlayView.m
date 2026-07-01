//
//  WCOverlayView.m
//  QuadCore
//
//  Created by sam wang on 13-2-28.
//  Copyright (c) 2013年 winchannel.net. All rights reserved.
//

#import "WCOverlayView.h"

@interface WCOverlayView (private)
// 重置图片
- (void)resetImgWithName:(NSString *)name;

@end

@implementation WCOverlayView

@synthesize status = _overlayStatus;
@synthesize imgView = _imgView;
@synthesize label = _label;
@synthesize loadingText = _loadingText;
@synthesize emptyText = _emptyText;
@synthesize errorText = _errorText;
@synthesize forbitText = _forbitText;
@synthesize indicatorView = _indicatorView;
@synthesize supportSkin = _supportSkin;
@synthesize animate = _animate;


- (void)dealloc {
    self.imgView = nil;
    self.label = nil;
    self.loadingText = nil;
    self.emptyText = nil;
    self.errorText = nil;
    self.forbitText = nil;
    self.indicatorView = nil;
    
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

// 适配
- (void)suitForStatus:(RROverlayStatus)status {
    self.status = status;
    
    if (status == EOverlayStatusLoading) {
        [self.indicatorView startAnimating];
    }
    else {
        if ([self.indicatorView isAnimating]) {
            [self.indicatorView stopAnimating];
        }
    }
    
    switch (status) {
        case EOverlayStatusLoading:
            [self resetImgWithName:nil];
            [self.indicatorView startAnimating];
            self.label.text = _loadingText;
            break;
            
        case EOverlayStatusEmpty:
            self.label.text = _emptyText;
            //自己手动设置empty image
          //  [self resetImgWithName:@"overlay_empty"];
            break;
            
        case EOverlayStatusError:
            self.label.text = _errorText;
            [self resetImgWithName:@"overlay_error"];
            break;
            
        case EOverlayStatusForbit:
            self.label.text = _forbitText;
            [self resetImgWithName:@"overlay_forbit"];
            break;
            
        case EOverlayStatusRemove:
            self.label.text = nil;
            [self resetImgWithName:nil];
            break;
            
        default:
            break;
    }
}

// 换肤
- (void)changeSkinAction {
    [self.label setTextColor:[UIColor grayColor]];
    [self.label setFont:[UIFont systemFontOfSize:12]];
    //    SkinType sType = [RCResManager sharedInstance].skinType;
    //    if (sType == SkinType_Light) {
    //        self.indicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    //    }else if (sType == SkinType_Night) {
    //        self.indicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    //    }else {
    //        self.indicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    //    }
}

- (UIImageView *)imgView {
    if (_imgView == nil) {
        CGRect newFrame = CGRectMake(0, 0, self.width, kOverlayImageHeight);
        _imgView = [[UIImageView alloc] initWithFrame:newFrame];
        [self addSubview:_imgView];
    }
    
    return _imgView;
}

- (UILabel *)label {
    if (_label == nil) {
        CGRect newFrame = CGRectMake(25, kOverlayImageHeight, self.width - 50, kOverlayTextHeight);
        _label = [[UILabel alloc] initWithFrame:newFrame];
        _label.numberOfLines = 0;
        [self addSubview:_label];
        _label.textAlignment = UITextAlignmentCenter;
        [_label setBackgroundColor:[UIColor clearColor]];
        [self.label setTextColor:[UIColor grayColor]];
        [self.label setFont:[UIFont systemFontOfSize:12]];
    }
    
    return _label;
}

- (UIActivityIndicatorView *)indicatorView {
    if (_indicatorView == nil) {
        //CGFloat indicatorWidth = 30;
        CGRect newFrame = CGRectMake((self.width - kIndicatorWidth) / 2,
                                     kOverlayImageHeight - kIndicatorWidth,
                                     kIndicatorWidth,
                                     kIndicatorWidth);
        _indicatorView = [[UIActivityIndicatorView alloc] initWithFrame:newFrame];
        _indicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        //        SkinType sType = [RCResManager sharedInstance].skinType;
        //        if (sType == SkinType_Light) {
        //            _indicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        //        }else if (sType == SkinType_Night) {
        //            _indicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
        //        }else {
        //            _indicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
        //        }
        
        [self addSubview:_indicatorView];
    }
    
    return _indicatorView;
}

// 重置图片
- (void)resetImgWithName:(NSString *)name {
    //    if (_supportSkin) {
    //        [self.imgView setImage:[[RCResManager sharedInstance]imageForName:name]];
    //    }
    //    else {
    //        [self.imgView setImage:[UIImage imageNamed:name]];
    //    }
    
    [self.imgView setImage:[UIImage imageForName:name]];
}

@end

