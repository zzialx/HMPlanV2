//
//  WSGridImageView.m
//  WinSFA
//
//  Created by Alicia on 2018/6/8.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import "WSGridImageView.h"

// TODO 为了 DATAGRID_CELL_HEIGHT_DEFAULT
#import "DataGridComponent.h"
#import "WSRequestHelper.h"

@interface WSGridImageView()

@property (nonatomic, strong) UIImageView *imageView;

@end


@implementation WSGridImageView

- (void)setupView {
//    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DATAGRID_CELL_HEIGHT_DEFAULT, DATAGRID_CELL_HEIGHT_DEFAULT)];
//    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(8, 5, bgView.width - 16, bgView.height - 10)];
    
    CGSize bgSize = CGSizeMake(DATAGRID_CELL_HEIGHT_DEFAULT, DATAGRID_CELL_HEIGHT_DEFAULT);
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(8, 5, bgSize.width - 16, bgSize.height - 10)];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth| UIViewAutoresizingFlexibleHeight;
    
//    imageView.center = bgView.center;
//    [bgView addSubview:imageView];
    
    self.imageView = imageView;
}

- (UIView *)getView {
    return self.imageView;
}

- (void)setValue:(NSString *)value {
    if ([value length] > 0) {
        [[WSRequestHelper shareInstance] downloadImageWithUrl:[WSHttpURLHelper getImageCompleteURL:value] imageView:self.imageView];
    }
}

@end
