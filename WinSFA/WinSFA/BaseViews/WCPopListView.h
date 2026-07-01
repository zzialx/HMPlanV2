//
//  WCPopListView.h
//  LeveyPopListViewDemo
//
//  Created by xiaotang.wang on 3/13/13.
//  Copyright (c) 2013 Levey. All rights reserved.
//

#import <UIKit/UIKit.h>

#define WCPOPLISTMAXWIDTH   280
#define WCPOPLISTWIDTH  (INTERFACE_IS_PAD ? 200.0f:120)
#define WCPOPLISTHIGHT 90.0f
#define WCROWHEIGHT    40.0f
#define WCPOPFONT      [UIFont systemFontOfSize:[UIFont systemFontSize]]

enum{
    WCPopListMultiselected = 0,
    WCPopListSigleSelected
};

typedef NSInteger WCPopListSelectedMode;

typedef NS_ENUM(NSInteger, WCPopListAnimationType){
    WCPopListAnimationTypeZoom,
    WCPopListAnimationTypeFromPoint
};


@protocol WCPopListViewDelegate;

@interface WCPopListView : UIView

@property (nonatomic, weak)id<WCPopListViewDelegate> iDelegate;

@property (nonatomic, assign)CGPoint animationPoint;

@property (nonatomic, assign)BOOL autoHideWhenSelect;

- (id)initWithTotalArry:(NSArray *)aTotalArray selectedArray:(NSArray *)aSelectedArray withSelectedMode:(WCPopListSelectedMode) aMode;
- (id)initWithTotalArry:(NSArray *)aTotalArray selectedArray:(NSArray *)aSelectedArray withSelectedMode:(WCPopListSelectedMode)aMode animationType:(WCPopListAnimationType)animationType maxHeight:(CGFloat)maxHeight;

- (void)showInView:(UIView *)aView animated:(BOOL)animated;
- (void)showViewFromRect:(CGRect) aRect inView:(UIView *)aView animated:(BOOL)animated;
- (void)showViewFromView:(UIView *)aFromView inView:(UIView *)aView animated:(BOOL)animated;
- (UIView *)getFromView;
- (NSArray *)getSelectedArray;
- (void)setPopListViewColor:(UIColor *)aColor;
- (void)showSpecialInView:(UIView *)aView animated:(BOOL)animated;
- (CGFloat)getMaxWidth;
- (void)setRowHeight:(CGFloat)height;
- (void)setBackgroundImage:(UIImage *)image;
- (void)setITableViewTextColor:(UIColor *)color;

@end

@protocol WCPopListViewDelegate <NSObject>

@optional

- (void)popListView:(WCPopListView *)popListView didSelectedIndex:(NSInteger)anIndex;
- (void)popListView:(WCPopListView *)popListView didSelectedArray:(NSArray *)aItems;
- (void)popListViewDidCancel;
- (void)popListViewDidSelectedEnd:(WCPopListView *)popListView;

@end
