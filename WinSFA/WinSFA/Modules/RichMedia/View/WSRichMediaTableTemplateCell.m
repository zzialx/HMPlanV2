//
//  WSRichMediaTableTemplateCell.m
//  WinSFA
//
//  Created by zhiqing on 16/8/29.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSRichMediaTableTemplateCell.h"
#import "PureLayout.h"
#import "WSRequestHelper.h"

#define CACHE_DIR [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0]

@interface WSRichMediaTableTemplateCell ()
{
    UIImageView  *imageView;
    UIImageView * jiaobiao;

}

@end

@implementation WSRichMediaTableTemplateCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setUpSubViews];
    }
    return self;
}

-(void)setUpSubViews{
    imageView = [[UIImageView alloc]init];
    imageView.contentMode = UIViewContentModeScaleToFill;
    [self.contentView addSubview:imageView];
    [imageView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    
    jiaobiao = [[UIImageView alloc]init];
    jiaobiao.contentMode = UIViewContentModeScaleAspectFit;
    jiaobiao.image = [UIImage imageNamed:@"zx@2X.png"];
    [self.contentView addSubview:jiaobiao];
    
    [jiaobiao autoPinEdgeToSuperviewEdge:ALEdgeLeft];
    [jiaobiao autoPinEdgeToSuperviewEdge:ALEdgeTop];
    [jiaobiao autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self.contentView withMultiplier:0.3];
    [jiaobiao autoMatchDimension:ALDimensionHeight toDimension:ALDimensionWidth ofView:self.contentView withMultiplier:0.3];

}



-(void)setModel:(WSRichItemModel *)model{
    _model = model;
    NSString *imgStr2 = [NSString stringWithFormat:@"richMedia/%@/sort-0.png",model.img_add];
    
    NSFileManager *manager = [NSFileManager defaultManager];
    
    NSURL *url = [[manager URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] firstObject];
    
    NSURL *path = [url URLByAppendingPathComponent:imgStr2];
    
    [[WSRequestHelper shareInstance] downloadImageWithUrl:[path absoluteString] imageView:imageView placeholderImage:[UIImage imageNamed:@"sort-0"]];
    
    if ([model.isread isEqualToString:@"1"] || model.h5_add.length ==0 ) {
        
        jiaobiao.hidden = YES;
    }else{
        jiaobiao.hidden = NO;
        
    }
    
}
@end
