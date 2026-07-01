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

@implementation WSRatingPanel

-(id)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if (self) {
        
        
        return self;
    }
    return nil;
}


-(void)loadBuildInfo:(NSObject<I_W_BuildInfo> *)buildInfo{
    
    [super loadBuildInfo:buildInfo];
    
    CGFloat height=0;
    
    NSString *title = nil;

    if ( [[xbuildInfo  getISRequire] isKindOfClass:[NSString class]] && [[xbuildInfo  getISRequire] isEqualToString:@"1"]) {
        title = [NSString stringWithFormat:@"%@*",[xbuildInfo  getQuestName]];
    }else{
        title =     [xbuildInfo  getQuestName];
    }
    
    UIFont *font = [UIFont systemFontOfSize:UI_Font];
    CGSize size = [title sizeWithFont:font constrainedToSize:CGSizeMake(self.bounds.size.width - 2 * kLabelLeftSpace, 1000) lineBreakMode:NSLineBreakByWordWrapping];
    UILabel* lable = [[UILabel alloc]initWithFrame:CGRectMake(kLabelLeftSpace, 0.0, size.width, size.height)];
    lable.font = font;
    lable.backgroundColor = kCLEAR_COLOR_value;
    lable.text = title;
    lable.numberOfLines = 0;
   // [self setTextColorwithLabel:lable andColor:ab_qst.color];
    [self addSubview:lable];
    
    int xPosition = kQstLeftSpace;
    int starGap = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 15 : 8;
    int maxStarNum = [[xbuildInfo getMlen] integerValue] > 0 ? [[xbuildInfo getMlen] integerValue] : 5;
    UIImage *selectedImage = [UIImage imageForName:@"star_selected"];
    
    float ratingWidth = maxStarNum * (selectedImage.size.width + starGap);
    
    if (self.bounds.size.width - 2 * kLabelLeftSpace - size.width - 10 >= ratingWidth) {
        xPosition = self.bounds.size.width - kLabelLeftSpace - ratingWidth;
        
        height += (size.height - selectedImage.size.height)/2;
    
    }
    else
    {
        height += (lable.frame.size.height + 5);
    }
    
    
    ratingView = [[RatingView alloc] initWithFrame:CGRectMake(xPosition, height, ratingWidth, selectedImage.size.height) andTotalStarNum:maxStarNum];
    ratingView.itemGap = starGap;
    
    [ratingView setImagesDeselected:@"star_unselected.png" partlySelected:@"star_halfselected.png" fullSelected:@"star_selected.png" andDelegate:self];
    
    ratingView.tag = [[xbuildInfo getAcvtQstId] intValue];
    
    if ([[xbuildInfo getReadOnly] intValue]) {
        
        ratingView.userInteractionEnabled = NO;
    
    }
    
    [self addSubview:ratingView];
    
    [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, height+ratingView.frame.size.height+15.0)];
    

    
}

-(void)loadDataSource:(NSObject *)datasource{
    
    [super loadDataSource:datasource];
    
    
    NSString *datstr = [xdataSource getDataSourceFor:xbuildInfo];
    
   if (datstr) {
       
          [ratingView displayRating:[datstr floatValue]];
       
    }
    
}

-(NSObject *)getResultDirectly{
    
    if (ratingView.rating==0.0) {
        
        return nil;
    }
    
    return [NSString stringWithFormat:@"%f",ratingView.rating];
    
}
@end
