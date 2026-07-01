//
//  WSCenterView.m
//  WinSFA
//
//  Created by winchannel on 2017/7/3.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSCenterView.h"
#import "WSShareItem.h"
#import "WSCustomButton.h"
#import "UIView+WSAnimation.h"


#define kCustomBtnYoffSet ((15 / [UIScreen mainScreen].bounds.size.height) * [UIScreen mainScreen].bounds.size.height)
@interface WSCenterView ()

@property (nonatomic,strong) NSMutableArray * visableBtnArray;
@property (nonatomic,strong) NSMutableArray * homeBtns;
@property (nonatomic,assign) BOOL btnCanceled;

@end

@implementation WSCenterView

-(NSMutableArray *)homeBtns
{
    if (!_homeBtns) {
        _homeBtns = [NSMutableArray array];
    }
    return _homeBtns;
}

-(NSMutableArray *)visableBtnArray
{
    if (!_visableBtnArray) {
        _visableBtnArray = [NSMutableArray array];
    }
    return _visableBtnArray;
}

- (void)reloadData{
    
    NSAssert(self.dataSource, @"BHBCenterView`s dataSource was nil.");
    NSAssert([self.dataSource respondsToSelector:@selector(numberOfItemsWithCenterView:)], @"BHBCenterView`s was unimplementation numberOfItemsWithCenterView:.");
    NSAssert([self.dataSource respondsToSelector:@selector(itemWithCenterView:item:)], @"BHBCenterView`s was unimplementation itemWithCenterView:item:.");
    [self.homeBtns makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.homeBtns removeAllObjects];
    NSUInteger count = [self.dataSource numberOfItemsWithCenterView:self];
    NSMutableArray * items = [NSMutableArray array];
    
    for (int i = 0; i < count; i ++) {
        [items addObject:[self.dataSource itemWithCenterView:self item:i]];
    }
    [self layoutBtnsWith:items isMore:NO];
    //[self btnPositonAnimation:NO];
}

- (void)layoutBtnsWith:(NSArray *)items isMore:(BOOL)isMore{

    WSShareItem * item;
    for (int i = 0; i < items.count; i ++) {
        item = items[i];
        WSCustomButton * btn = [WSCustomButton buttonWithType:UIButtonTypeCustom];
        NSString *imageStr = [NSString stringWithFormat:@"%@",item.icon];
        [btn setImage:[UIImage scaledImageForName:imageStr ofType:@"png"] forState:UIControlStateNormal];
        [btn.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [btn setTitle:item.title forState:UIControlStateNormal];
        btn.titleLabel.textAlignment = NSTextAlignmentCenter;
        [btn setTitleColor:[UIColor colorWithHexString:@"#333333"] forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:12];
        CGFloat width = 52 /*self.frame.size.width / 3.0*/;
        CGFloat height = ((72 / [UIScreen mainScreen].bounds.size.height) * [UIScreen mainScreen].bounds.size.height) /*self.frame.size.height / 2*/;
        CGFloat x = 0.0;
        if (items.count == 1) {
            x = (self.frame.size.width - width) /2.0;

        }else if (items.count == 2){
            
            CGFloat leftSapce = (self.frame.size.width - width * 2 - 36.0) /2.0;
            
            if (i == 0) {
                x = leftSapce ;
            }else{
               x =  self.frame.size.width - leftSapce - width;
            }
        }else if(items.count == 3){
            x = (i % 3) * self.frame.size.width / 3.0 + (self.frame.size.width / 3.0 - width) /2.0;
            
        }else if(items.count == 4){
            x = (i % 4) * self.frame.size.width / 4.0 + (self.frame.size.width / 4.0 - width) /2.0;

        }else if(items.count == 5){
            x = (i % 5) * self.frame.size.width / 5.0 + (self.frame.size.width / 5.0 - width) /2.0;
            
        }
        CGFloat y = kCustomBtnYoffSet;
        
        [self.homeBtns addObject:btn];
        

        [btn addTarget:self action:@selector(didClickBtn:) forControlEvents:UIControlEventTouchUpInside];
        [btn addTarget:self action:@selector(didTouchBtn:) forControlEvents:UIControlEventTouchDown];
        [btn addTarget:self action:@selector(didCancelBtn:) forControlEvents:UIControlEventTouchDragInside];
        [self addSubview:btn];
        btn.frame = CGRectMake(x, y, width, height);
    }
}

- (void)didTouchBtn:(WSCustomButton *)btn{
    [btn scalingWithTime:.15 andscal:1.2];
}

- (void)didCancelBtn:(WSCustomButton *)btn{
    self.btnCanceled = YES;
    [btn scalingWithTime:.15 andscal:1];
}

- (void)didClickBtn:(WSCustomButton *)btn{
    if (self.btnCanceled) {
        self.btnCanceled = NO;
        return;
    }
    
    WSShareItem * item;
    NSInteger index;
    if([self.homeBtns containsObject:btn]){
        index = [self.homeBtns indexOfObject:btn];
        item = [self.dataSource itemWithCenterView:self item:index];
    }
    
    [btn scalingWithTime:.25 andscal:1];
    [btn scalingWithTime:.25 andscal:1.7];
    [btn fadeOutWithTime:.25];
    if (!self.centerViewDelegate || ![self.centerViewDelegate respondsToSelector:@selector(didSelectItemWithCenterView:andItem:)]) {
        return;
    }
    [self.centerViewDelegate didSelectItemWithCenterView:self andItem:item];
}


- (void)dismis{
    [self btnPositonAnimation:YES];
}

- (void)removeAnimation{
    [self.visableBtnArray enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        WSCustomButton * btn = obj;
        CGFloat x = btn.frame.origin.x;
        CGFloat y = btn.frame.origin.y;
        CGFloat width = btn.frame.size.width;
        CGFloat height = btn.frame.size.height;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((self.visableBtnArray.count - idx) * 0.03 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:.8 delay:0 usingSpringWithDamping:0.9 initialSpringVelocity:5 options:0 animations:^{
                btn.alpha = 0;
                btn.frame = CGRectMake(x, [UIScreen mainScreen].bounds.size.height - self.frame.origin.y + y, width, height);
                if ([btn isEqual:[self.visableBtnArray firstObject]]) {
                    self.superview.superview.userInteractionEnabled = YES;
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"popViewHide" object:nil];
                    
                }
            } completion:^(BOOL finished) {
//                if ([btn isEqual:[self.visableBtnArray firstObject]]) {
//                    self.superview.superview.userInteractionEnabled = YES;
//                    [[NSNotificationCenter defaultCenter] postNotificationName:@"popViewHide" object:nil];
//                    
//                }
            }];
        });
        
    }];
    
}

- (void)moveInAnimation{
    
    [self.visableBtnArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        WSCustomButton * btn = obj;
        CGFloat x = btn.frame.origin.x;
        CGFloat y = btn.frame.origin.y;
        CGFloat width = btn.frame.size.width;
        CGFloat height = btn.frame.size.height;
        btn.frame = CGRectMake(x, [UIScreen mainScreen].bounds.size.height + y - self.frame.origin.y, width, height);
        btn.alpha = 0.0;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(idx * 0.03 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.25 delay:0 usingSpringWithDamping:0.75 initialSpringVelocity:25 options:UIViewAnimationOptionCurveEaseIn animations:^{
                btn.alpha = 1;
                btn.frame = CGRectMake(x, y, width, height);
            } completion:^(BOOL finished) {
                if ([btn isEqual:[self.visableBtnArray lastObject]]) {
                    self.superview.superview.userInteractionEnabled = YES;
                }
            }];
        });
        
    }];
}

- (void)btnPositonAnimation:(BOOL)isDismis{
    if (self.visableBtnArray.count <= 0) {
        [self.homeBtns enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [self.visableBtnArray addObject:obj];
        }];
    }
    self.superview.superview.userInteractionEnabled = NO;
    if (isDismis) {
        [self removeAnimation];
        //[self fadeOutWithTime:0.25];
    }else{
        [self moveInAnimation];
    }
    
}


@end
