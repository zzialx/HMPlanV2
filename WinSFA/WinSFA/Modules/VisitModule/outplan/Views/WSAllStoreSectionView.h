//
//  WSAllStoreSectionView.h
//  WinSFA
//
//  Created by donghong on 2018/4/26.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^MapResult)(NSInteger index);

@interface WSAllStoreSectionView : UIView<UIGestureRecognizerDelegate>

@property (nonatomic,copy) MapResult resultIndex;

@property(nonatomic,strong) NSString *address;

@property(nonatomic,strong) UILabel * titleLabel;
@property(nonatomic,strong) UIButton   *leftButton;
@property(nonatomic,strong) UIButton   *rightButton;
@property(nonatomic,assign) NSInteger loadNum;  //下载数量



-(id)initWithFrame:(CGRect)frame andAddress:(NSString*)address;


-(id)initWithFrame:(CGRect)frame andLoadNum:(NSInteger)loadNum;
@end
