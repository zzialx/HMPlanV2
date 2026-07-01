//
//  WSBottomPopView.m
//  WinSFA
//
//  Created by winchannel on 2017/7/3.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSBottomPopView.h"
#import "WSPopViewBar.h"
#import "WSCenterView.h"
#import "UIView+WSAnimation.h"

#define kWSCenterViewHeight ((102.5 / [UIScreen mainScreen].bounds.size.height) * [UIScreen mainScreen].bounds.size.height)

@interface WSBottomPopView ()<ZYCenterViewDelegate,ZYCenterViewDataSource>

@property (nonatomic,weak) UIImageView * background;
@property (nonatomic,weak) UIImageView * logo;
@property (nonatomic,weak) WSPopViewBar * bottomBar;
@property (nonatomic,weak) WSCenterView * centerView;

@property (nonatomic,strong) NSArray * items;
@property (nonatomic,copy) DidSelectItemBlock selectBlock;

@end

@implementation WSBottomPopView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hide) name:KPOPViewHide object:nil];

        WSCenterView * centerView = [[WSCenterView alloc]initWithFrame:CGRectMake(20, self.frame.size.height - kWSCenterViewHeight - WSBOTTOMHEIGHT - 40, self.frame.size.width - 40, kWSCenterViewHeight)];
        [self addSubview:centerView];
        [centerView showInViewUsingSpringWithDampingWithTime:0.25 withCompletion:nil];
        centerView.layer.cornerRadius = 8;
        centerView.layer.masksToBounds = YES;
        centerView.backgroundColor = [UIColor whiteColor];
        centerView.centerViewDelegate = self;
        centerView.dataSource = self;
        centerView.clipsToBounds = NO;
        self.centerView = centerView;
        
        WSPopViewBar * bar = [[WSPopViewBar alloc]initWithFrame:CGRectMake(20, frame.size.height - WSBOTTOMHEIGHT - 20, frame.size.width - 40, WSBOTTOMHEIGHT)];
        
        bar.layer.cornerRadius = 8;
        bar.layer.masksToBounds = YES;
        bar.backgroundColor = [UIColor whiteColor];
        
        __weak typeof(self) weakSelf = self;
        
        bar.closeClick = ^{
            [weakSelf.bottomBar disMissViewWithTime:0.3 withCompletion:nil];
            [weakSelf.centerView disMissViewWithTime:0.3 withCompletion:^{
                [self removeFromSuperview];
            }];
        };
        [self addSubview:bar];
        [bar showInViewUsingSpringWithDampingWithTime:0.25 withCompletion:nil];
        self.bottomBar = bar;
        

        
    }
    return self;
}

- (void)removeitemsComplete{
    self.superview.userInteractionEnabled = YES;
}


- (void)showItems{
    [self.centerView reloadData];
}

- (void)hideItems{
    [self.centerView dismis];
}


+ (ZY_INSTANCETYPE)showToView:(UIView *)view withItems:(NSArray *)array andSelectBlock:(DidSelectItemBlock)block{
    [self viewNotEmpty:view];
    WSBottomPopView * popView = [[WSBottomPopView alloc]initWithFrame:view.bounds];
    popView.backgroundColor = [UIColor colorWithWhite:.0 alpha:0.40];
    [view addSubview:popView];
    popView.selectBlock = block;
    //[popView showInViewWithTime:0.25];
    popView.items = array;
    [popView showItems];
    return popView;
}

+ (ZY_INSTANCETYPE)showToView:(UIView *)view andImages:(NSArray *)imageArray andTitles:(NSArray *)titles andSelectBlock:(DidSelectItemBlock)block{
    NSUInteger count = imageArray.count;
    NSMutableArray * items = [NSMutableArray array];
    for (int i = 0; i < count; i++) {
        WSShareItem * item = [[WSShareItem alloc]initWithTitle:titles[i] Icon:imageArray[i]];
        [items addObject:item];
    }
    return [self showToView:view withItems:items andSelectBlock:block];
}

+ (void)viewNotEmpty:(UIView *)view{
    if (view == nil) {
        view = (UIView *)[[UIApplication sharedApplication] delegate];
    }
    
}

+ (void)hideFromView:(UIView *)view{
    [self viewNotEmpty:view];
    [view.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UIView * subV = (UIView *)obj;
        [subV isKindOfClass:[self class]];
        [WSBottomPopView hideWithView:subV];
    }];
}

- (void)hide{
    [WSBottomPopView hideWithView:self];
}

+ (void)hideWithView:(UIView *)view{
    
    [view removeFromSuperview];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.bottomBar disMissViewWithTime:0.3 withCompletion:nil];
    [self.centerView disMissViewWithTime:0.3 withCompletion:^{
        [self removeFromSuperview];
    }];
}

#pragma mark centerview delegate and datasource
- (NSInteger)numberOfItemsWithCenterView:(WSCenterView *)centerView
{
    return self.items.count;
}

-(WSShareItem *)itemWithCenterView:(WSCenterView *)centerView item:(NSInteger)item
{
    return self.items[item];
}

-(void)didSelectItemWithCenterView:(WSCenterView *)centerView andItem:(WSShareItem *)item
{
    if (self.selectBlock) {
        self.selectBlock(item);
    }
    [self hide];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KPOPViewHide object:nil];
}


@end
