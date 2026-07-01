//
//  WSHomePageCollectionViewCell.m
//  WinSFA
//
//  Created by mac on 16/11/8.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSHomePageCollectionViewCell.h"
#define CACHE_DIR [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0]

@interface WSHomePageCollectionViewCell ()

@property(nonatomic,strong)UIImageView * imageView;
@property(nonatomic,strong)UIImageView * yinyingView;


@end

@implementation WSHomePageCollectionViewCell
-(instancetype)initWithFrame:(CGRect)frame{

    if (self = [super initWithFrame:frame]) {
        _imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.contentView.width, self.contentView.height - 50)];
        [self.contentView addSubview:_imageView];
     
        
        _yinyingView = [[UIImageView alloc]initWithFrame:CGRectMake(0, self.contentView.height - 28, self.contentView.width, 28)];
        _yinyingView.image = [UIImage imageNamed:@"yinyingzheng"];
        [self.contentView addSubview:_yinyingView];
        
    }
    return self;
}

-(void)setModel:(WSRichItemModel *)model{
    _model = model;
    if (model.img_add.length > 0) {
        _imageView.image = [self getImageWith:model.img_add wihtType:@"3d-0.png"];
    }else{
        _imageView.image = [UIImage imageNamed:@"3d-0@2x"];
    }

}

-(UIImage *)getImageWith:(NSString *)filePath wihtType:(NSString *)type{
    
    NSString *imgStr = [NSString stringWithFormat:@"%@/richMedia/%@/%@",CACHE_DIR,filePath,type];
    UIImage *image = [[UIImage alloc] initWithContentsOfFile:imgStr];
    if (image == nil) {
        image = [UIImage imageNamed:@"3d-0@2x"];
    }
    return image;
}
@end
