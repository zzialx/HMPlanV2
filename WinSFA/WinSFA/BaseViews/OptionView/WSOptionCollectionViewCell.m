//
//  WSOptionCollectionViewCell.m
//  WinSFA
//
//  Created by wangzhiwei on 2018/1/23.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import "WSOptionCollectionViewCell.h"
#import "WSOptionView.h"



@implementation WSOptionCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    
    
    WSOptionView *optionView = [[WSOptionView alloc] initWithFrame:frame];
    
    [self.contentView addSubview:optionView];
    
    return self;
    
}

@end
