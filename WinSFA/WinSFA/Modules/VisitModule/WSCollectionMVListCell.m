//
//  WSCollectionMVListCell.m
//  WinSFA
//
//  Created by Alicia on 17/1/14.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSCollectionMVListCell.h"
#import "UIImageView+EMWebCache.h"
#import "NSString+Valid.h"
#import "WSRequestHelper.h"
//MSTD-6650修改间距 为 12px 董宏
#define kIcon_Left_padding 10.0f
#define kIcon_Left_Img 6.0f
#define kIcon_Top_padding 10.0f
#define kIcon_Width 35.0f
#define kIcon_Height 35.0f
#define kMain_Title_Font_Size ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 16.0f : 18.0f)

@implementation WSCollectionMVListCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)setupViews {
    
    self.backgroundColor = [UIColor colorWithHexString:@"0xf1f1f1"];
    self.layer.cornerRadius = 5.0;
    self.layer.masksToBounds = YES;

    self.mainTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height)];
    self.mainTitleLabel.autoresizingMask =  UIViewAutoresizingFlexibleHeight;
    
    UIFont *font = [UIFont systemFontOfSize:16.0];
    if (SCREEN_WIDTH == 320) {
        font = [UIFont systemFontOfSize:15.0];
    }
    [self.mainTitleLabel setTextAlignment:NSTextAlignmentCenter];
    [self.mainTitleLabel setTextColor:MAIN_TEXT_COLOR];
    [self.mainTitleLabel setFont:font];
    [self.mainTitleLabel setNumberOfLines:2];
//    _mainTitleLabel.backgroundColor = [UIColor darkGrayColor];
    [self.contentView addSubview:self.mainTitleLabel];
    
    
    
    self.separatorLayer = [CALayer layer];
    CGFloat padding = 4;
    self.separatorLayer.frame = CGRectMake(0, padding, 1, CGRectGetHeight(self.mainTitleLabel.frame) - padding * 2);
    self.separatorLayer.backgroundColor =  DETAIL_SEPERATE_LINE_COLOR.CGColor;
//    [self.mainTitleLabel.layer addSublayer:self.separatorLayer];
    [self.separatorLayer setHidden:YES];
    
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    self.contentView.frame = frame;
}

- (void)setFuncsBean:(WSFuncsBean *)funcsBean {
    _funcsBean = funcsBean;
    
    self.mainTitleLabel.text = [NSString stringWithFormat:@"%@", funcsBean.name];


    [self setupImageViewWithFuncsBean:funcsBean];

}

- (void)setupImageViewWithFuncsBean:(WSFuncsBean *)fb
{
    
    if (fb.icon.length > 0) {
//        NSMutableString *unselectedIconUrlSeg = [NSMutableString stringWithFormat:@"%@", fb.icon];
//        [unselectedIconUrlSeg replaceOccurrencesOfString:@"\\" withString:@"/" options:NSCaseInsensitiveSearch range:NSMakeRange(0, unselectedIconUrlSeg.length)];
//        NSString *unselectedImageUrlStr = [NSString stringWithFormat:@"%@%@", [WSPlistHelper valueForKey:kServerIP withPlistName:kConfilgFileName], unselectedIconUrlSeg];
        NSString * unselectedImageUrlStr = [WSHttpURLHelper getImageCompleteURL:fb.icon];
        if (_imageView) {
            [_imageView removeFromSuperview];
        }else
            _imageView = [[UIImageView alloc] init];
        
        [[WSRequestHelper shareInstance] downloadImageWithUrl:unselectedImageUrlStr imageView:_imageView placeholderImage:[UIImage imageNamed:@"picture_loading"]];
        
        [_imageView setFrame:CGRectMake(kIcon_Left_padding, kIcon_Top_padding, self.height - 2 * kIcon_Top_padding, self.height - 2 * kIcon_Top_padding)];
        
        [self.contentView addSubview:_imageView];
        
        CGFloat mainTitleLabelWidthBefore = self.width - _imageView.frame.size.width - kIcon_Left_padding * 2;
        
        
        if (SCREEN_WIDTH == 320 &&
            self.width <= (SCREEN_WIDTH/3) &&
            [[UIDevice getPreferredLanguage] hasPrefix:@"zh"] &&
            [fb.name isChinese] &&
            [fb.name length] > 3) {
            mainTitleLabelWidthBefore -= 10;
        }
        
        [self.mainTitleLabel setFrame:CGRectMake(_imageView.frame.origin.x + _imageView.frame.size.width + kIcon_Left_padding, 0, mainTitleLabelWidthBefore, self.height)];
        
        
        CGSize nameSize = [fb.name ws_sizeWithFont:[UIFont systemFontOfSize:kMain_Title_Font_Size] constrainedToHeight:self.mainTitleLabel.frame.size.height lineBreakMode:NSLineBreakByWordWrapping];
        
        CGRect titleRect = self.mainTitleLabel.frame;
        titleRect.size.width = nameSize.width < mainTitleLabelWidthBefore ? nameSize.width : mainTitleLabelWidthBefore;

        self.mainTitleLabel.frame = titleRect;
        
//        MENGNIU-598 董宏。MSTD-6650 再次修改 去掉了单一判断 统一剧中
        CGFloat btnWidth = titleRect.size.width + kIcon_Left_padding + _imageView.frame.size.width;

        _imageView.frame = CGRectMake((self.width-btnWidth)/2, kIcon_Top_padding, self.height - 2 * kIcon_Top_padding, self.height - 2 * kIcon_Top_padding);
        
        self.mainTitleLabel.frame = CGRectMake(_imageView.frame.origin.x + _imageView.frame.size.width + kIcon_Left_Img, 0, titleRect.size.width, self.height);
        
        if (_badgeView) {
            [_badgeView reset];
            [_badgeView removeFromSuperview];
            _badgeView = nil;
        }
        
        if (_badgeCount > 0) {

            _badgeView = [[XMBadgeView alloc] initWithAttachView:_imageView alignment:XMBadgeViewAlignmentTopRight];
            
            [_badgeView setBadgeTextFont:[UIFont systemFontOfSize:12.0f]];
            [_badgeView setPanable:NO];
            
            NSString *badgeCntStr = [NSString stringWithFormat:@"%ld", (long)_badgeCount];
            
            if (_badgeCount > 99) {
                badgeCntStr = @"";
                [_badgeView setBadgeMinWidth:7.0];
            }else{
                [_badgeView setBadgeMinWidth:10.0];
            }
            [_badgeView setBadgeText:badgeCntStr];
        }

    }else{
        
        if (_imageView) {
            [_imageView removeFromSuperview];
        }
        
        CGSize nameSize = [fb.name ws_sizeWithFont:[UIFont systemFontOfSize:kMain_Title_Font_Size] constrainedToHeight:self.mainTitleLabel.frame.size.height lineBreakMode:NSLineBreakByWordWrapping];
        
        CGRect titleRect = self.mainTitleLabel.frame;
        titleRect.size.width = nameSize.width;
        titleRect.origin.x = (self.frame.size.width - nameSize.width)/2;
        self.mainTitleLabel.frame = titleRect;

        if (_badgeView) {
            [_badgeView reset];
            [_badgeView removeFromSuperview];
            _badgeView = nil;
        }

        if (_badgeCount > 0) {
            
            _badgeView = [[XMBadgeView alloc]  initWithAttachView:self.mainTitleLabel alignment:XMBadgeViewAlignmentCenterRight];
            
            // 设置是否可拖动移除红点
            [_badgeView setPanable:NO];
            NSString *badgeCntStr = [NSString stringWithFormat:@"%ld", (long)_badgeCount];
            
            if (_badgeCount > 99) {
                badgeCntStr = @"";
                [_badgeView setBadgeMinWidth:7.0];
                [_badgeView setBadgePositionAdjustment:CGPointMake(10, 0)];
                [_badgeView setBadgeTextFont:[UIFont systemFontOfSize:6.0]];
            }else{
                [_badgeView setBadgeMinWidth:14.0];
                [_badgeView setBadgePositionAdjustment:CGPointMake(10, 0)];
                [_badgeView setBadgeTextFont:[UIFont systemFontOfSize:8.0]];
            }
            [_badgeView setBadgeText:badgeCntStr];

            
            titleRect.origin.x = (self.frame.size.width - nameSize.width - 18)/2;
            self.mainTitleLabel.frame = titleRect;
        }
        
    }
}

- (void)setTitle:(NSString *)title {
    self.mainTitleLabel.text = title;
}


@end
