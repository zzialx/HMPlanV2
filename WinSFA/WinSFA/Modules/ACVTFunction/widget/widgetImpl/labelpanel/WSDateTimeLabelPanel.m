//
//  WSDateTimeLabelPanel.m
//  WinSFA
//
//  Created by zhangke on 15/3/26.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSDateTimeLabelPanel.h"
#import "WidgetConstant.h"
#import "UILabel+Additional.h"

@implementation WSDateTimeLabelPanel


-(instancetype)initWithFrame:(CGRect)frame
{
    self=[super initWithFrame:frame];
    if(self){
        // 解决高度不够遮挡文字的问题
        CGFloat wHeight = frame.size.height + 10;
        [self setFrame:CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, wHeight)];
    }
    
    return self;
}


-(void)loadBuildInfo:(NSObject<I_W_BuildInfo> *)buildInfo
{
    
    [super loadBuildInfo:buildInfo];

}

-(void)loadDataSource:(NSObject<I_W_DataSource> *)datasource
{
    [self loadDataSource:datasource];
    
}


-(void)buildDisplayContent
{
    [super buildDisplayContent];

    NSString *titlecontent = [WSCurrentTime getDateTime];
    
    CGSize size = [titlecontent ws_sizeWithFont:titleLabel.font constrainedToWidth:self.frame.size.width lineBreakMode:NSLineBreakByWordWrapping];
    
    size = [self.titleLabel labelResize:size];
    
    [self setTitleLabelFrame:CGRectMake(MAIN_CELL_PADDING, 0, self.frame.size.width, size.height)];
    
    [self setTitleContent:titlecontent];
    
    [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, size.height)];
}


//回显
-(void)loadDisplayValue:(NSObject<I_W_DisplayValue> *)displayValueobjin
{
    
}


@end
