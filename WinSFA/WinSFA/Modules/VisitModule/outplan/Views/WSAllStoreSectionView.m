//
//  WSAllStoreSectionView.m
//  WinSFA
//
//  Created by donghong on 2018/4/26.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import "WSAllStoreSectionView.h"

@implementation WSAllStoreSectionView
{
    UILabel * _labAddress;
}
-(id)initWithFrame:(CGRect)frame andAddress:(NSString*)address{
    
    self = [super initWithFrame:frame];
    if (self) {
        
        [self setupViews];
        self.address = address;
        
        return self;
    }
    
    return self;
}
- (void)setupViews
{
    CGFloat x = 24;
    CGFloat y = 0;
    CGFloat w = self.frame.size.width - x;
    CGFloat h = 30;
    
    UILabel *labAddress = [[UILabel alloc] initWithFrame:CGRectMake(x, y, w, h)];
    
    labAddress.textColor = [UIColor colorWithHexString:@"323131"];
    
    labAddress.font = [UIFont systemFontOfSize:13.0];
    
    _labAddress = labAddress;
    
    [self addSubview:labAddress];
    
    y = CGRectGetMaxY(_labAddress.frame);
    h = 34;
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, y, self.frame.size.width, h)];
    
    view.backgroundColor = [UIColor colorWithHexString:@"fffbc9"];

    [self addSubview:view];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y, w, h)];
    
    titleLabel.font = [UIFont systemFontOfSize:12.0];
    
    NSMutableAttributedString *AttributedStr = [[NSMutableAttributedString alloc]initWithString:@"如果选择其他地点，请点击地图选择地点"];
    
    [AttributedStr addAttribute:NSUnderlineStyleAttributeName
     
                          value:@(NSUnderlineStyleSingle)
     
                          range:NSMakeRange(12, AttributedStr.length-12)];
    
    titleLabel.attributedText = AttributedStr;
    
    titleLabel.textColor = [UIColor colorWithHexString:@"e1dba9"];
    
    
    titleLabel.userInteractionEnabled = YES;
    
    [self addSubview:titleLabel];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(btnDown)];
    [titleLabel addGestureRecognizer:tap];
    
    
}
- (void)btnDown
{
    if (self.resultIndex) {
        self.resultIndex(1);
    }
}
- (void)setAddress:(NSString *)address
{
    _labAddress.text = address;

    if (address.length < 1) {
        _labAddress.text = @"无法获取您当前定位，请开启定位功能，或刷新重试";

    }
}


-(id)initWithFrame:(CGRect)frame andLoadNum:(NSInteger)loadNum
{
    
    self = [super initWithFrame:frame];
    if (self) {
        self.loadNum = loadNum;
        [self setupNewView];
        
        return self;
    }
    
    return self;
}

-(void) setupNewView  {
    CGFloat w = self.frame.size.width *0.5;
    
    UIButton *leftBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, w, 44)];
    _leftButton = leftBtn;
    leftBtn.backgroundColor = [UIColor colorWithHexString:@"f4f4f4"];
    leftBtn.titleLabel.font = [UIFont systemFontOfSize:13.0];
    [leftBtn setTitleColor:[UIColor colorWithHexString:@"333333"] forState:UIControlStateNormal];
    
    NSString *str = NSLocalizedString(@"download_near_store_info", nil);
    if ([str containsString:@"X"]) {
        str = [str stringByReplacingOccurrencesOfString:@"X" withString:[NSString stringWithFormat:@"%ld",_loadNum]];
    }
    [leftBtn setTitle:str forState:UIControlStateNormal] ;
    //  YIHAIKERRY-3388 zhaodanyang
    leftBtn.titleLabel.lineBreakMode =  NSLineBreakByTruncatingTail;
    [self addSubview:leftBtn];
    
    
    UIButton *rightBtn = [[UIButton alloc] initWithFrame:CGRectMake(w, 0, w, 44)];
    _rightButton = rightBtn;
    rightBtn.titleLabel.font = [UIFont systemFontOfSize:13.0];
    rightBtn.backgroundColor = [UIColor colorWithHexString:@"f4f4f4"];
    [rightBtn setTitleColor:[UIColor colorWithHexString:@"333333"] forState:UIControlStateNormal];
    [rightBtn setTitle:NSLocalizedString(@"update_city_store_list", nil) forState:UIControlStateNormal];
    [self addSubview:rightBtn];
    
    
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(w, 10, 1, 24)];
    line.backgroundColor = [UIColor colorWithHexString:@"cdcdcd"];
    [self addSubview:line];
    //YIHAIKERRY-3385 zhaodanyang
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 44, self.width, 42)];
    titleLabel.font = [UIFont systemFontOfSize:13.0];
    
    titleLabel.textColor = [UIColor colorWithHexString:@"f94414"];
    titleLabel.backgroundColor = [UIColor colorWithHexString:@"ffefd0"];
    titleLabel.userInteractionEnabled = YES;
    [self addSubview:titleLabel];
    
    titleLabel.text = NSLocalizedString(@"no_network_or_gps", nil);
    titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel = titleLabel;
    
}



@end
