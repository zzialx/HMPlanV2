//
//  WSStepNotePanel.m
//  WinSFA
//
//  Created by winchannel on 15/11/10.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSStepNotePanel.h"
#import "I_W_BuildInfo.h"

@implementation WSStepNotePanel

-(id)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    
    if (self) {
        
        
        return self;
    }
    return nil;
}

-(void)buildDisplayContent{

    [super buildDisplayContent];
    
    
//    NSString *titlecontent = nil;
//    
//    BOOL orientition = NO;
//    if ([xbuildInfo getOrientation] && [[xbuildInfo getOrientation] isEqualToString:@"1"]) {
//        orientition = YES;
//    }
//    
//    if ( [[xbuildInfo  getISRequire] isKindOfClass:[NSString class]] && [[xbuildInfo  getISRequire] isEqualToString:@"1"]) {
//        titlecontent = [NSString stringWithFormat:@"%@*",[xbuildInfo getQuestName]];
//    }else{
//        titlecontent = [xbuildInfo getQuestName];
//    }
//    
//    UIFont *titleLabelfont = [UIFont systemFontOfSize:UI_Font_DEFAULT_SIZE];
//    
//    CGFloat constrainedWidth = orientition ?  (self.width )/2 : (self.width );
//    
//    self.titleLabel.numberOfLines = 0;
//    
//    self.titleLabel.lineBreakMode = NSLineBreakByCharWrapping;
//    
//    CGSize size = [titlecontent sizeWithFont:titleLabelfont constrainedToSize:CGSizeMake(constrainedWidth, LABLE_DEFAULT_HIGHT) lineBreakMode:NSLineBreakByWordWrapping];
//    
//    [self setTitleLabelFrame:CGRectMake(0, 5, size.width, size.height)];
//    
//    [self setTitleLabelBgColor:[UIColor clearColor]];
//    
//    [self setTitleLabelColorStrByHex:[xbuildInfo getTextColor]];
//    
//    [self setTitleContent:titlecontent];
//    
//    [self setTitleLabelFont:titleLabelfont];
//    
//    if (self.titleLabel.frame.size.height>self.frame.size.height) {
//        
//        CGFloat height = self.titleLabel.frame.size.height;
//        
//        self.frame=WSRect(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, height);
//    }
}

-(void)loadBuildInfo:(NSObject<I_W_BuildInfo> *)buildInfo{
    
    [super loadBuildInfo:buildInfo];
    
    
}

- (void)loadDataSource:(NSObject<I_W_DataSource> *)datasource{
    
    [super loadDataSource:datasource];
}

-(void)loadValidator:(NSObject<I_W_Validate> *)validateobjin{
    
    [super loadValidator:validateobjin];
    
}
@end
