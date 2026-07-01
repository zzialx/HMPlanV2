//
//  WSRichMediaItemCell.m
//  WinSFA
//
//  Created by huzepei on 16/8/2.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSRichMediaItemCell.h"
#import "WSRequestHelper.h"

#define CACHE_DIR [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0]

@interface WSRichMediaItemCell()

@property (weak, nonatomic) IBOutlet UILabel *productTitle;

@property (weak, nonatomic) IBOutlet UIImageView *richMediaImageView;
@property (strong, nonatomic) IBOutlet UIImageView *jiaobiao;

@property (nonatomic,strong) UIImage *placeholderImage;


@end

@implementation WSRichMediaItemCell

- (void)awakeFromNib {
    [super awakeFromNib];
    _richMediaImageView.contentMode = UIViewContentModeScaleAspectFit;
    _jiaobiao.contentMode = UIViewContentModeScaleAspectFit;
}

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}
- (IBAction)clickPlusBtn:(id)sender {
    
    if (_clickPlusBtn) {
        _clickPlusBtn(_cellIndexPath);
    }
}
#pragma mark - setter 
-(void)setItemModel:(WSRichItemModel *)itemModel
{
    _itemModel = itemModel;
    
    _productTitle.text = _itemModel.name;
//  img_add是图片名称,要求拿到文件路
    
    NSFileManager *manager = [NSFileManager defaultManager];
    NSURL *url = [[manager URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] firstObject];
    NSString *imgStr2 = [NSString stringWithFormat:@"richMedia/%@/sort-0.png",_itemModel.img_add];
    
    NSURL *path = [url URLByAppendingPathComponent:imgStr2];
    //判断当前的path是否指向一个Image
    UIImage *pathImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:path]];
    
    if (pathImage) {
        [[WSRequestHelper shareInstance] downloadImageWithUrl:[path absoluteString] imageView:_richMediaImageView placeholderImage:self.placeholderImage];
    }else{
        [_richMediaImageView setImage:self.placeholderImage];
    }
//    [_richMediaImageView sd_setImageWithURL:path placeholderImage:self.placeholderImage];
    
    if ([itemModel.isread isEqualToString:@"1"] || itemModel.h5_add.length ==0 ) {
        
        self.jiaobiao.hidden = YES;
    }else{
        self.jiaobiao.hidden = NO;
        
    }
}


-(void)setIsNotEdit:(BOOL)isNotEdit
{
    _isNotEdit = isNotEdit;
    if (_isNotEdit == YES) {
        self.plusBtn.hidden = YES;
    }
}
-(UIImage *)placeholderImage
{
    if (!_placeholderImage) {
        _placeholderImage = [UIImage imageForName:@"sort-0@2x.png"];
    }
    return _placeholderImage;
}
@end
