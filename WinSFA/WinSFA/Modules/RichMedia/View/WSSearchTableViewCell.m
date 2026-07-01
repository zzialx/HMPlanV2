//
//  WSSearchTableViewCell.m
//  WinSFA
//
//  Created by zhiqing on 16/9/10.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSSearchTableViewCell.h"
#import "PureLayout.h"
#import "WSRequestHelper.h"

#define CACHE_DIR [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0]

@implementation WSSearchTableViewCell
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withStyle:(WSSearchTableViewCellStyle) cellStyle{
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
     
        self.icon = [[UIImageView alloc]init];
        self.name = [[UILabel alloc]init];
        self.jiaobiao = [[UIImageView alloc]init];
        self.jiaobiao.contentMode = UIViewContentModeScaleAspectFit;
        self.jiaobiao.image = [UIImage imageNamed:@"zx@2x.png"];
        self.addButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.addButton setImage:[UIImage imageNamed:@"richMedia_add.png"] forState:UIControlStateNormal];
        [self.addButton addTarget:self action:@selector(addRichItemToDemoList) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.icon];
        [self.contentView addSubview:self.name];
        [self.contentView addSubview:self.jiaobiao];
        if (cellStyle == WSSearchTableViewCellStyleNone) {
            [self.icon autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(0, 0, 0, 0) excludingEdge:ALEdgeRight];
            [self.icon autoSetDimension:ALDimensionWidth toSize:60];
            
            [self.name autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(0, 0, 0, 0) excludingEdge:ALEdgeLeft];
            [self.name autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:self.icon withOffset:10];
            

        }else if (cellStyle == WSSearchTableViewCellStyleAdd){
            [self.contentView addSubview:self.addButton];

            [self.addButton autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(20, 15, 10, 0) excludingEdge:ALEdgeRight];
              [self.addButton autoSetDimension:ALDimensionWidth toSize:30];
            
            [self.icon autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(0, 55, 0, 0) excludingEdge:ALEdgeRight];
            [self.icon autoSetDimension:ALDimensionWidth toSize:60];
            
            [self.name autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(0, 0, 0, 0) excludingEdge:ALEdgeLeft];
            [self.name autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:self.icon withOffset:10];

        
        }
        
        [self.jiaobiao autoPinEdgeToSuperviewEdge:ALEdgeLeft];
        [self.jiaobiao autoPinEdgeToSuperviewEdge:ALEdgeTop];
        [self.jiaobiao autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self.icon withMultiplier:0.4];
        [self.jiaobiao autoMatchDimension:ALDimensionHeight toDimension:ALDimensionWidth ofView:self.icon withMultiplier:0.4];
    }
    return self;
}

-(void)setModel:(WSRichItemModel *)model{
    _model = model;
    NSFileManager *manager = [NSFileManager defaultManager];
    
    NSURL *url = [[manager URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] firstObject];
    NSString *imgStr2 = [NSString stringWithFormat:@"richMedia/%@/sort-0.png",model.img_add];
    
    NSURL *path = [url URLByAppendingPathComponent:imgStr2];
    
    [[WSRequestHelper shareInstance] downloadImageWithUrl:[path absoluteString] imageView:self.icon placeholderImage:[UIImage imageNamed:@"sort-0"]];
    
    self.name.text = model.name;
    if ([model.isread isEqualToString:@"1"] || model.h5_add.length ==0 ) {
        
        self.jiaobiao.hidden = YES;
    }else{
        self.jiaobiao.hidden = NO;
        
    }
}

-(void)addRichItemToDemoList{
    if (self.addDemolist) {
        
        self.addDemolist (self.model);
    }

}
@end
