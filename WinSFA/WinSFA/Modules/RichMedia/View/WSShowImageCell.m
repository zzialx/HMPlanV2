//
//  WSShowImageCell.m
//  WinSFA
//
//  Created by mac on 16/9/25.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSShowImageCell.h"
#import "PureLayout.h"
#import "WSRequestHelper.h"

@interface WSShowImageCell()
@property(nonatomic,strong)UIImageView * icon;
@end

@implementation WSShowImageCell
-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        _icon = [[UIImageView alloc]init];
        _icon.contentMode = UIViewContentModeScaleAspectFit;
        _deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_deleteBtn addTarget:self action:@selector(deleteBtnActon:) forControlEvents:UIControlEventTouchUpInside];
        [_deleteBtn setImage:[UIImage imageNamed:@"delete"] forState:UIControlStateNormal];
        [self addSubview:_icon];
        [self addSubview:_deleteBtn];
        
        [_icon autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
        [_deleteBtn autoPinEdgeToSuperviewEdge:ALEdgeTop];
        [_deleteBtn autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:10];
        [_deleteBtn autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self withMultiplier:0.2];
        [_deleteBtn autoMatchDimension:ALDimensionHeight toDimension:ALDimensionWidth ofView:self withMultiplier:0.2];
    }

    return self;
}

-(void)setModel:(WSRichItemModel *)model{
    _model = model;
    
    NSFileManager *manager = [NSFileManager defaultManager];
    
    NSURL *url = [[manager URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] firstObject];
    NSString *imgStr2 = [NSString stringWithFormat:@"richMedia/%@/3d-0.png",model.img_add];
    
    NSURL *path = [url URLByAppendingPathComponent:imgStr2];
    
    UIImage *pathImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:path]];
    if (pathImage) {
        [[WSRequestHelper shareInstance] downloadImageWithUrl:[path absoluteString] imageView:_icon placeholderImage:[UIImage imageNamed:@"3d-0"]];
    }else{
        [_icon setImage:[UIImage imageNamed:@"3d-0"]];
    }
    
}

-(void)deleteBtnActon:(UIButton *)btn{
    if (self.deleteItem) {
        self.deleteItem(self.cellIndexPath);
    }
}
@end
