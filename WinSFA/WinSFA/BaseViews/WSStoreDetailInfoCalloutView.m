//
//  WSStoreDetailInfoCalloutView.m
//  WinSFA
//
//  Created by mac on 2017/10/24.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSStoreDetailInfoCalloutView.h"
#define K_TitleLabel_Max_Width  250
#define K_LEFT_SPACE  10
#define K_TitleLabel_Height  20


@interface WSStoreDetailInfoCalloutView ()

@property (nonatomic,strong) UILabel *storeNameLabel;
@property (nonatomic,strong)UILabel *latLabel;
@property (nonatomic,strong)UILabel *lonLabel;
@property (nonatomic,strong)UILabel *storeAddressLabel;
@property (nonatomic,strong) UIImageView *backgroundView;

@end

@implementation WSStoreDetailInfoCalloutView
-(instancetype)initWithFrame:(CGRect)frame{

    if (self = [super initWithFrame:frame]) {
        [self setUpSubViews];
    }
    return self;
}

-(void)setUpSubViews{
    _backgroundView = [[UIImageView alloc]init];
    [_backgroundView setImage:[UIImage imageNamed:@"site_bj"]];
    [self addSubview:self.backgroundView];

    _storeNameLabel = [[UILabel alloc] init];
    _storeNameLabel.textColor = RGBCOLOR(51, 51, 51);
    _storeNameLabel.numberOfLines = 0;
    _storeNameLabel.font = [UIFont systemFontOfSize:13];
    _storeNameLabel.lineBreakMode = NSLineBreakByCharWrapping;
    [self addSubview:self.storeNameLabel];
    
    _latLabel = [[UILabel alloc] init];
    _latLabel.textColor = RGBCOLOR(153, 153, 153);
    _latLabel.font = [UIFont systemFontOfSize:10];
    _latLabel.textAlignment = NSTextAlignmentLeft;
    _latLabel.numberOfLines = 0;
    _latLabel.lineBreakMode = NSLineBreakByCharWrapping;
    [self addSubview:self.latLabel];

    _lonLabel = [[UILabel alloc] init];
    _lonLabel.textColor = RGBCOLOR(153, 153, 153);
    _lonLabel.font = [UIFont systemFontOfSize:10];
    _lonLabel.textAlignment = NSTextAlignmentLeft;
    _lonLabel.numberOfLines = 0;
    _lonLabel.lineBreakMode = NSLineBreakByCharWrapping;
    [self addSubview:self.lonLabel];
    
    _storeAddressLabel = [[UILabel alloc] init];
    _storeAddressLabel.textColor = RGBCOLOR(153, 153, 153);
    _storeAddressLabel.font = [UIFont systemFontOfSize:10];
    _storeAddressLabel.textAlignment = NSTextAlignmentLeft;
    _storeAddressLabel.numberOfLines = 0;
    _storeAddressLabel.lineBreakMode = NSLineBreakByCharWrapping;
    [self addSubview:self.storeAddressLabel];
}


-(void)setAnnotation:(WSStoreAnnotation *)annotation{
    self.calloutAnnotaion = annotation;
    _storeNameLabel.text = annotation.storeName;
    CGFloat height = 0;
    CGFloat width = K_TitleLabel_Max_Width;
    CGSize storeNameSize = [annotation.storeName ws_sizeWithFont:[UIFont systemFontOfSize:13] constrainedToWidth:(width - 2 *K_LEFT_SPACE ) lineBreakMode:NSLineBreakByCharWrapping];
    _storeNameLabel.frame = CGRectMake(K_LEFT_SPACE, K_LEFT_SPACE, width, storeNameSize.height);
    height += storeNameSize.height;
    _latLabel.text = [NSString stringWithFormat:@"纬度:%f",annotation.store.latitude];
    _latLabel.frame = CGRectMake(K_LEFT_SPACE, _storeNameLabel.bottom, width, K_TitleLabel_Height);
    height += K_TitleLabel_Height + K_LEFT_SPACE;

    _lonLabel.text = [NSString stringWithFormat:@"经度:%f",annotation.store.longitude];
    _lonLabel.frame = CGRectMake(K_LEFT_SPACE, _latLabel.bottom, width, K_TitleLabel_Height);
    height += K_TitleLabel_Height;

    CGSize storeAddrSize = CGSizeZero;
    NSString * addr = [NSString stringWithFormat:@"门店地址:%@",annotation.store.addr];
    if (annotation.store.addr.length > 0) {
        storeAddrSize = [addr ws_sizeWithFont:[UIFont systemFontOfSize:13] constrainedToWidth:(width - 2 *K_LEFT_SPACE ) lineBreakMode:NSLineBreakByCharWrapping];
    }
    _storeAddressLabel.text = addr;
    _storeAddressLabel.frame = CGRectMake(K_LEFT_SPACE, _lonLabel.bottom, width, storeAddrSize.height);
    height += storeAddrSize.height + K_LEFT_SPACE;

    self.frame = CGRectMake(0, 0, width, height);
    self.layer.anchorPoint = CGPointMake(0.5, 1.0);
    self.backgroundView.frame = CGRectMake(0, 0, width, height);
    
}

@end
