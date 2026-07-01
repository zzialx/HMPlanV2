//
//  WSEmptySearchView.m
//  WinSFA
//
//  Created by winchannel on 2017/5/1.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSEmptySearchView.h"
#import "UIColor+Additions.h"
@implementation WSEmptySearchView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        
        UILabel *tiTleLabel = [[UILabel alloc] init];
        tiTleLabel.text = NSLocalizedString(@"empty_prompt", nil);
        tiTleLabel.font = [UIFont systemFontOfSize:16.0];
        tiTleLabel.textColor = [UIColor colorWithHexString:@"0x999999"];
        tiTleLabel.textAlignment = NSTextAlignmentCenter;
        tiTleLabel.frame = CGRectMake(0, 45, self.width,36);
        tiTleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self addSubview:tiTleLabel];
        
    }
    return self;
}


@end
