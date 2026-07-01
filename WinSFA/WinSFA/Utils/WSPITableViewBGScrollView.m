//
//  WSPITableViewBGScrollView.m
//  WinSFA
//
//  Created by xiajl on 14-7-23.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//

#import "WSPITableViewBGScrollView.h"
#import "UIView+WSPITableView.h"

@implementation WSPITableViewBGScrollView{
    NSMutableArray *lines;
}

@synthesize parent;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)reDraw {
    if (lines == nil) lines = [[NSMutableArray alloc] initWithCapacity:10];
    
    for (UIView *view in lines) {
        [view removeFromSuperview];
    }
    
    [lines removeAllObjects];
    
    
    UIView *hidView = [[UIView alloc] initWithFrame:CGRectMake(0.0f - parent.normalSeperatorLineWidth, 0, parent.normalSeperatorLineWidth, self.bounds.size.height)];
    hidView.backgroundColor = parent.normalSeperatorLineColor;
    hidView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight;
    [self addSubview:hidView];
    [lines addObject:hidView];
    
    UIView *line = nil;
    CGFloat x = 0.0f;
    NSUInteger columnCount = [parent.datasource arrayDataForTopHeaderInTableView:parent].count;
    for (int i = 0; i < columnCount; i++) {
        CGFloat width;
        if ([parent.datasource respondsToSelector:@selector(tableView:contentTableCellWidth:)]) {
            width = [parent.datasource tableView:parent contentTableCellWidth:i];
        }else {
            width = parent.cellWidth;
        }
        
        x += width + parent.normalSeperatorLineWidth;
        
        line = [self addVerticalLineWithWidth:parent.normalSeperatorLineWidth bgColor:parent.normalSeperatorLineColor atX:x];
        [lines addObject:line];
    }
}

- (void)dealloc {
    lines = nil;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
