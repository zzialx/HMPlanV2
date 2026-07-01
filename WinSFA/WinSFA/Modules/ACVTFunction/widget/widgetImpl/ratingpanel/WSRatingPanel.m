//
//  WSRatingPanel.m
//  WinSFA
//
//  Created by winchannel on 15/3/12.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSRatingPanel.h"
#import "I_W_BuildInfo.h"
#import "WidgetConstant.h"
#import "RatingView.h"
#import "I_W_DataSource.h"
#import "WSStringValueChangeChecker.h"

#import "I_W_DisplayValue.h"

#define kValueNonSet        -1



@interface WSRatingPanel ()
{
    BOOL isSupportHalfStatr;
}

@property (nonatomic, strong) UIView *lineView;     //线视图
@property (nonatomic, strong) UILabel *ratingLabel; //评级标签

@end

@implementation WSRatingPanel

-(id)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if (self) {
        
        self.xvalueChangeChecker = [[WSStringValueChangeChecker alloc] init];
        currentrating = kValueNonSet;
        return self;
    }
    return nil;
}

- (void)buildDisplayContent {
    
    [super buildDisplayContent];
    
    isSupportHalfStatr = YES;
    
    if ([[xbuildInfo getAcvtMemo3] isEqualToString:@"1"]) {
        isSupportHalfStatr = NO;
    }
    
    
//    UIFont *font = [UIFont systemFontOfSize:UI_Font];
//    CGSize size = [titleLabel.text sizeWithFont:font constrainedToSize:CGSizeMake(self.bounds.size.width - 2 * kLabelLeftSpace, 1000) lineBreakMode:NSLineBreakByWordWrapping];
    
    NSInteger starGap = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 15 : (MAIN_PADDING / 2);
    NSInteger maxStarNum = [[xbuildInfo getMlen] integerValue] > 0 ? [[xbuildInfo getMlen] integerValue] : 5;
    
    UIImage *selectedImage = [UIImage imageNamed:@"star_selected"];
    
    BOOL orientition = NO;
    if ([xbuildInfo getOrientation] && [[xbuildInfo getOrientation] isEqualToString:@"1"]) {
        orientition = YES;
    }
    
    CGFloat imageWidth = selectedImage.size.width;
    CGFloat imageHeight = selectedImage.size.height;
    CGFloat height = MAIN_CELL_HEIGHT;
    if ([[xbuildInfo getDisplayMode] isEqualToString:QST_DISPLAYMODE_SMALL]) {
        imageHeight = imageHeight * DISPLAYMODE_SMALL_RATIO;
        imageWidth = imageWidth * DISPLAYMODE_SMALL_RATIO;
        height = height * DISPLAYMODE_SMALL_RATIO;
    }
    
    float ratingWidth = maxStarNum * (imageWidth + starGap);
   
    CGFloat xPosition;
    CGFloat yPosition;
    if (orientition && (self.frame.size.width - 2 * MAIN_CELL_PADDING - titleLabel.origin.x - titleLabel.width >= ratingWidth)) {
        xPosition = self.bounds.size.width - ratingWidth - MAIN_CELL_PADDING;
    } else {
        xPosition = self.titleLabel.origin.x;
        height = height * 2;
    }
     yPosition = height - imageHeight / 2 - imageHeight;
    
    ratingView = [[RatingView alloc] initWithFrame:CGRectMake(xPosition, yPosition, ratingWidth, imageHeight) andTotalStarNum:maxStarNum];
    ratingView.isSupportHalfStatr = isSupportHalfStatr;
    
    ratingView.itemGap = starGap;
    ratingView.contentMode = UIViewContentModeCenter;
    
    [ratingView setImagesDeselected:@"star_unselected" partlySelected:@"star_halfselected" fullSelected:@"star_selected" andDelegate:self];
    
    ratingView.tag = [[xbuildInfo getAcvtQstId] intValue];
    
    if ([[xbuildInfo getReadOnly] intValue]) {
        ratingView.userInteractionEnabled = NO;
    }
    
    [self addSubview:ratingView];
    
    //MMSH-7382
    if ([[xbuildInfo getAcvtMemo4] isEqualToString:@"1"]) {
        
        float x = CGRectGetMaxX(ratingView.frame) + GROUP_CELL_PADDING;
        float y = CGRectGetMinY(ratingView.frame);
        float w = 1.0f;
        float h = CGRectGetHeight(ratingView.frame);
        UIColor *color = [UIColor colorForKey:@"RatingPanelLineColor"];
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(x, y , w, h)];
        lineView.backgroundColor = (color ? color : [UIColor blackColor]);
        [self addSubview:lineView];
        self.lineView = lineView;
        
        x = CGRectGetMaxX(lineView.frame) + GROUP_CELL_PADDING;
        y = CGRectGetMinY(lineView.frame);
        w = CGRectGetWidth(self.frame) - xPosition - x;
        h = CGRectGetHeight(lineView.frame);
        color = [UIColor colorForKey:@"RatingPanelScoreColor"];
        UILabel *ratingLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y , w, h)];
        ratingLabel.backgroundColor = [UIColor clearColor];
        ratingLabel.textAlignment = NSTextAlignmentLeft;
        ratingLabel.font = [UIFont systemFontOfSize:UI_Enhance_Font];
        ratingLabel.textColor = (color ? color : [UIColor blackColor]);
        ratingLabel.text = [NSString stringWithFormat:@"%.1f", ((currentrating >= 0) ? currentrating : 0.0f)];
        [self addSubview:ratingLabel];
        self.ratingLabel = ratingLabel;
    }

    [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, height)];
    
    NSString *displayValue = (NSString *)[xdisplayValue getDisplayValueFor:xbuildInfo];
    if ([displayValue length] > 0) {
        [ratingView displayRating:[displayValue floatValue]];
        
    }
}


-(void)loadDataSource:(NSObject<I_W_DataSource> *)datasource{
    
    [super loadDataSource:datasource];
    
    
    NSString *datstr = (NSString *)[xdataSource getDataSourceFor:xbuildInfo];
    
   if (datstr) {
       
          [ratingView displayRating:[datstr floatValue]];
       
    }
    
}

-(NSObject *)getResultDirectly{
    
    if (currentrating == kValueNonSet) {
        
        return nil;
        
    }
    
    NSString *value = nil;
    if (isSupportHalfStatr) {
        value = [NSString stringWithFormat:@"%f",currentrating];
    }else {
        value = [NSString stringWithFormat:@"%d", ((int)currentrating)];
    }
    
    return value;
    
}

- (void)setCurrentValueWithPresentation:(NSString *)valuePresentation {
    CGFloat value = 0;
    if (valuePresentation.length > 0) {
        value = [valuePresentation floatValue];
    }
    [ratingView displayRating:value];
}

#pragma mark -
#pragma mark RatingViewDelegate method

-(void)ratingView:(RatingView *)ratingView ratingChanged:(float)newRating{
    
    //2017-11-03-MSTD-6781
    currentrating = newRating;
    if(currentrating <= 0)
        currentrating = kValueNonSet;
    
    //MMSH-7382
    if (self.ratingLabel) {
        self.ratingLabel.text = [NSString stringWithFormat:@"%.1f", ((currentrating >= 0) ? currentrating : 0.0f)];
    }
    
    [self checkValueChange];
    
    if ([[xbuildInfo getLuaScript] length] > 0) {
        if ([delegate respondsToSelector:@selector(executeLuaScript:widget:)]) {
            [delegate executeLuaScript:xbuildInfo widget:self];
        }
    }
}
@end
