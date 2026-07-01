//
//  WSLeftMenuView.m
//  WinSFA
//
//  Created by winchannel on 16/8/9.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSLeftMenuView.h"

#define k_CoverLayerXOffSet ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ?  :-5)
#define k_CoverLayerYOffSet ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ?  :-5)
#define k_CoverLayerWidth ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ?  :129)
#define k_CoverLayerHeight ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ?  :100)

#define kTagBase 2000

@interface WSLeftMenuView ()

@property (nonatomic, strong)NSArray *items;

@property (nonatomic, strong)UIView *ativeView;

@property (nonatomic, strong)UIButton *lastSelectedButton;

@property (nonatomic, strong)NSMutableArray *buttonArray;


@end

@implementation WSLeftMenuView

- (instancetype)initWithFrame:(CGRect)frame withFuncs:(NSArray *)aFuncs{
    
    if (self = [super initWithFrame:frame]) {
        if (aFuncs && aFuncs.count >0) {
            _items = [[NSArray alloc]initWithArray:aFuncs];
            _buttonArray = [NSMutableArray arrayWithCapacity:_items.count];
            _selectedIndex = -1;
            
            [self setUpSubViews];
        }
    }
    return self;
    
}

- (void)setUpSubViews
{
    CGFloat itemHeigt = self.frame.size.height /(_items.count);
    
    UIColor *bgColor = [UIColor colorForKey:@"LeftMenuViewBackgroudColor"];
    if (!bgColor) {
        bgColor = MAIN_TINT_COLOT;
    }
    
    self.backgroundColor = bgColor;
    self.layer.cornerRadius = 8.0f;
    
    //    UIImageView *coverlayerView = [[UIImageView alloc]initWithFrame:CGRectMake(k_CoverLayerXOffSet,  k_CoverLayerYOffSet,k_CoverLayerWidth , itemHeigt +5)];
    //     UIImage *coverlayerImage = [UIImage imageForName:@"xuanzhong"];
    //    coverlayerView.image = coverlayerImage;
    //    coverlayerView.tag = 1002;
    //    self.ativeView = coverlayerView;
    //    [self addSubview:self.ativeView];
    
    
    if (_items && _items.count >0) {
        
        itemHeigt = self.frame.size.height /(_items.count);
        
        for (int index = 0; index <_items.count; index++) {
            
            CGFloat itemY = itemHeigt *index;
            UIButton *itemBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, itemY, self.frame.size.width, itemHeigt)];
            itemBtn.tag = kTagBase + index;
            
            NSString *imageStr = [NSString stringWithFormat:@"menu_funcs%d",index +1];
            NSString *imageHLStr = [NSString stringWithFormat:@"menu_funcs%d_hl",index +1];

            [itemBtn setImage:[UIImage imageNamed:imageStr] forState:UIControlStateNormal];
            [itemBtn setImage:[UIImage imageNamed:imageHLStr] forState:UIControlStateSelected];
            [itemBtn setImage:[UIImage imageNamed:imageHLStr] forState:UIControlStateHighlighted];
            
            itemBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
            [itemBtn setTitleColor:[self getNormalTitleColor] forState:UIControlStateNormal];
            [itemBtn setTitleColor:[self getSelectedTitleColor] forState:UIControlStateSelected];
            [itemBtn setTitleColor:[self getSelectedTitleColor] forState:UIControlStateHighlighted];
            [itemBtn setTitle:[_items objectAtIndex:index] forState:UIControlStateNormal];
            [itemBtn setTitle:[_items objectAtIndex:index] forState:UIControlStateNormal];
            itemBtn.titleLabel.font = [UIFont systemFontOfSize:16];

            CGSize imageSize = itemBtn.imageView.size;
            CGSize titleSize = itemBtn.titleLabel.size;
            
            CGFloat imageOffsetX = (imageSize.width + titleSize.width) / 2 - imageSize.width / 2;
            CGFloat imageOffsetY = imageSize.height / 2;
            itemBtn.imageEdgeInsets = UIEdgeInsetsMake(-imageOffsetY, imageOffsetX, imageOffsetY, -imageOffsetX);
            
            CGFloat labelOffsetX = (imageSize.width + titleSize.width / 2) - (imageSize.width + titleSize.width) / 2;
            CGFloat labelOffsetY = titleSize.height / 2;
            itemBtn.titleEdgeInsets = UIEdgeInsetsMake(labelOffsetY + 10, -labelOffsetX, -labelOffsetY, labelOffsetX);

            
            [itemBtn addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
            
            [self addSubview:itemBtn];
            
            [self.buttonArray addObject:itemBtn];
            
            //            if (index < _items.count && index > 0) {
            //                UIView *bottomLineView = [[UIView alloc]initWithFrame:CGRectMake(5, itemY, (self.frame.size.width -10), 1)];
            //                bottomLineView.backgroundColor =MAIN_TINT_COLOT;
            //                [self addSubview:bottomLineView];
            //                
            //            }
            
        }
        
    }
}


- (void)buttonAction:(UIButton *)sender
{
    NSInteger index = sender.tag - kTagBase;
    
    BOOL shouldSelect = YES;
    if ([self.delegate respondsToSelector:@selector(leftMenusViewShouldSelectItemAtIndex:)]) {
        [sender setHighlighted:NO];
        shouldSelect = [self.delegate leftMenusViewShouldSelectItemAtIndex:index];
    }
    
    if (shouldSelect) {
        [self setSelectedIndex:index];
    }
}

- (UIColor *)getNormalTitleColor
{
    UIColor *titleColor = [UIColor colorForKey:@"LeftMenuViewCellTitleColor"];
    if (!titleColor) {
        titleColor = [UIColor grayColor];
    }
    return titleColor;
}

- (UIColor *)getSelectedTitleColor
{
    UIColor *titleColor = [UIColor colorForKey:@"LeftMenuViewCellSelectedTitleColor"];
    if (!titleColor) {
        titleColor = MAIN_TINT_COLOT;
    }
    return titleColor;
}

- (void)reloadCoverLayerScrollViewIndex:(int)indexPath{
    
    CGFloat itemHeigt = self.frame.size.height /(_items.count);
    CGFloat activeOffY = itemHeigt *indexPath;
    _ativeView.frame = CGRectMake(k_CoverLayerXOffSet, activeOffY -5,k_CoverLayerWidth , itemHeigt +5);
}

- (void)setButton:(UIButton *)button selected:(BOOL)selected
{
    button.selected = selected;
//    if (selected) {
//        [button setTintColor:[self getSelectedTitleColor]];
//    }else {
//        [button setTintColor:[self getNormalTitleColor]];
//    }
}

- (void)setSelectedIndex:(NSInteger)selectedIndex
{
    if (_selectedIndex == selectedIndex) {
        return;
    }
    
    _selectedIndex = selectedIndex;
    
    UIButton *button = self.buttonArray[selectedIndex];
    
    [self setButton:self.lastSelectedButton selected:NO];
    [self setButton:button selected:YES];
    
    self.lastSelectedButton = button;
    
    if ([self.delegate respondsToSelector:@selector(leftMenusViewDidSelectItemAtIndex:)]) {
        [self.delegate leftMenusViewDidSelectItemAtIndex:selectedIndex];
    }

}


@end
