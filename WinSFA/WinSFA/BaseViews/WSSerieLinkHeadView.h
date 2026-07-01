//
//  WSSerieLinkHeadView.h
//  WinSFA
//
//  Created by heju on 15/3/4.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WSSerieLinkHeadViewDelegate;

@interface WSSerieLinkHeadView : UIView

@property (nonatomic,strong) UILabel *headLabel;
@property (nonatomic,strong) UIButton *headMarkButton;


@property (nonatomic,strong) UIView *sperateView;
@property (nonatomic,weak) id<WSSerieLinkHeadViewDelegate> delegate;
@property (nonatomic,assign) BOOL superViewDisplay;

- (id)initWithFrame:(CGRect)frame;

- (void)changeSelectedNormal;

- (void)changeMarkImageViewDown;

- (void)changeHeadLableText:(NSString *)text;

- (void)isReadonly:(BOOL)readonly;

@end

@protocol WSSerieLinkHeadViewDelegate <NSObject>

- (void)serieLinkHeadView:(WSSerieLinkHeadView *)serieLinkHeadView superViewWillDisplay:(BOOL)dispaly;


@end
