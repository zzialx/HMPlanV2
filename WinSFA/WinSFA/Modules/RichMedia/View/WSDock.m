//
//  WSDock.m
//  WinSFA
//
//  Created by huzepei on 16/7/22.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSDock.h"
#import "WSMediaOptionBtn.h"
#import "PureLayout.h"

#define WSColor(r, g, b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1.0]

@interface WSDock()

@property (nonatomic,strong) NSMutableArray *btns;

@property (weak, nonatomic) WSMediaOptionBtn *selectedButton;

@property (nonatomic,strong) UIImageView *outImageView;

@property(nonatomic,assign) WSDockType layoutType;
@property (nonatomic , copy) NSString *isShowRichMediaHome;

@end

@implementation WSDock


-(instancetype)initWithFrame:(CGRect)frame with:(WSDockType)layoutType
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        self.layoutType = layoutType;
    }
    return self;
}

-(void)setUpOptions
{
    NSDictionary * imageMappingDict = @{NSLocalizedString(@"product_category", nil):@"cpfl_h",
                                        NSLocalizedString(@"channel_plan", nil):@"qdfn_h",
                                        NSLocalizedString(@"inspire_menu", nil):@"lgcp_h",
                                        NSLocalizedString(@"professional_service", nil):@"zyfw_h",
                                        NSLocalizedString(@"Promotion", nil):@"cxhd_h",
                                        NSLocalizedString(@"about_our", nil):@"gywm_h",
                                        };

    if (self.layoutType == WSDockTypeVertical) {
         [self setupButtonWithIcon:@"fmt_h" title:NSLocalizedString(@"back_to_main_page", nil)];
        _isShowRichMediaHome = [[NSUserDefaults standardUserDefaults] objectForKey:IS_SHOW_RICHMEDIA_HOME];
        if ([_isShowRichMediaHome isEqualToString:@"1"]) {
            [self setupButtonWithIcon:@"sy_h" title:@"首页"];
        }
//         [self setupButtonWithIcon:@"cpfl_h" title:@"产品品类"];
//         [self setupButtonWithIcon:@"qdfn_h" title:@"渠道方案"];
//         [self setupButtonWithIcon:@"lgcp_h" title:@"灵感菜谱"];
//         [self setupButtonWithIcon:@"zyfw_h" title:@"专业服务"];
//         [self setupButtonWithIcon:@"cxhd_h" title:@"促销活动"];
//         [self setupButtonWithIcon:@"gywm_h" title:@"about_our"];
        for (WSDictBean * bean in self.dictArray) {
            [self setupButtonWithIcon:imageMappingDict[bean.name] title:(bean.dtyp ? (bean.dtyp): (bean.name))];
        }
         [self setupButtonWithIcon:@"wdsc_h" title:@"我的收藏"];

    }

    if (self.layoutType == WSDockTypeHorizontal) {
//        [self setupButtonWithIcon:@"cpfl_h" title:@"产品品类"];
//        [self setupButtonWithIcon:@"qdfn_h" title:@"渠道方案"];
//        [self setupButtonWithIcon:@"lgcp_h" title:@"灵感菜谱"];
//        [self setupButtonWithIcon:@"zyfw_h" title:@"专业服务"];
//        [self setupButtonWithIcon:@"cxhd_h" title:@"促销活动"];
//        [self setupButtonWithIcon:@"gywm_h" title:@"about_our"];
        for (WSDictBean * bean in self.dictArray) {
            [self setupButtonWithIcon:imageMappingDict[bean.name] title:(bean.dtyp ? (bean.dtyp): (bean.name))];
        }
        [self setupButtonWithIcon:@"wdmb_h" title:@"我的模板"];


    }
   
    if (self.layoutType == WSDockTypeVertical) {
        [self buttonClick:_btns[1]];
        
    }else{
        [self buttonClick:_btns[0]];
        
        self.layer.cornerRadius = 10.0;
        
    }
}
- (void)setupButtonWithIcon:(NSString *)icon title:(NSString *)title
{
    WSMediaOptionBtn *button = [WSMediaOptionBtn buttonWithType:UIButtonTypeCustom];
    if ([title isEqualToString:NSLocalizedString(@"back_to_main_page", nil)]) {
        button.layOuttype = @"back";
    }
    button.tag = self.subviews.count;
    UIImage *image = [UIImage imageNamed:icon];
    [button setImage:image forState:UIControlStateNormal];
    if (self.layoutType == WSDockTypeHorizontal) {
//       [button setBackgroundColor:WSColor(253, 224, 207)];
        self.backgroundColor = RGBCOLOR(72, 72, 74);
        
        button.layOuttype = @"Horizontal";
    }else{
//        [button setBackgroundColor:MAIN_TINT_COLOT];
        self.backgroundColor = RGBCOLOR(72, 72, 74);
    }
    
    NSString *name;
    if (self.layoutType == WSDockTypeHorizontal) {
//         name = [icon stringByAppendingString:@"_bai"];
        name = [icon stringByReplacingOccurrencesOfString:@"_h" withString:@"_c"];
    }else{
         name = [icon stringByReplacingOccurrencesOfString:@"_h" withString:@"_c"];
    }

    [button setImage:[UIImage imageNamed:name] forState:UIControlStateSelected];
    [button setTitle:title forState:UIControlStateNormal];
    if (self.layoutType == WSDockTypeHorizontal) {
//        [button setTitleColor:WSColor(131, 31, 19) forState:UIControlStateNormal];
//        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        
        [button setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [button setTitleColor:MAIN_TINT_COLOT forState:UIControlStateSelected];

    }else{
        [button setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [button setTitleColor:MAIN_TINT_COLOT forState:UIControlStateSelected];
    }
    
    [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchDown];
    [self addSubview:button];
    [self.btns addObject:button];
}

- (void)buttonClick:(WSMediaOptionBtn *)button
{
    if (button == self.selectedButton) return;
    
    button.Choosed = YES;
    self.selectedButton.Choosed = NO;
    
    if ([self.delegate respondsToSelector:@selector(dock:didSelectButtonFrom:to:)]) {
        [self.delegate dock:self didSelectButtonFrom:(int)self.selectedButton.tag to:(int)button.tag];
    }
    
    self.selectedButton.selected = NO;
    button.selected = YES;
    self.selectedButton = button;
    
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    if (_layoutType == WSDockTypeHorizontal) {
        CGFloat btnHeight = self.height / self.btns.count - 2;
        for (int i = 0; i < _btns.count; i++) {
            WSMediaOptionBtn *moBtn = _btns[i];
            moBtn.frame = CGRectMake(0, i * (btnHeight + 2), self.width, btnHeight);
        }
    }else if (_layoutType == WSDockTypeVertical){
    
        CGFloat btnWidth = (self.width - self.btns.count) /(9 + 1);
        CGFloat space = 0 ;  // 除了第一、二个位置，其他按钮的x值要加
        
        if (self.btns.count < 9) {
            space = (9 - self.btns.count ) / 2 * btnWidth;
        }
        
        for (int i = 0; i < _btns.count; i++) {
             WSMediaOptionBtn *moBtn = _btns[i];
            
            CGRect rect;
            if (i == 0) {
                rect = CGRectMake(i * btnWidth , 0 , btnWidth + 9, self.height);
            }else if (i == 1){
                
          
                if ([_isShowRichMediaHome isEqualToString:@"1"]) {
                    rect = CGRectMake(i * btnWidth , 0 , btnWidth , self.height);
                }else{
                    rect =  CGRectMake((i + 1) * btnWidth  + space, 0 , btnWidth, self.height);

                }

            }
            else{
                rect =  CGRectMake((i + 1) * btnWidth + space , 0 , btnWidth, self.height);
            }
           moBtn.frame = rect;
        }
    }
    
}




-(NSMutableArray *)btns
{
    if (!_btns) {
        _btns = [NSMutableArray array];
    }
    return _btns;
}

//-(UIImageView *)outImageView
//{
//    if (_outImageView) {
//        _outImageView = [[UIImageView alloc] initWithImage:[UIImage imageForName:@"richMedia_checked"]];
//        [self addSubview:_outImageView];
//        [_outImageView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(-4, -2, 0, -10)];
//    }
//    return _outImageView;
//}
@end
