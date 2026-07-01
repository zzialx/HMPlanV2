//
//  ProductSectionHeaderView.h
//  WinChannelFrameWork
//
//  Created by winchannel on 11-12-6.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WSProductSectionHeaderViewDelegate;

@interface WSProductSectionHeaderView : UIView {}
@property (nonatomic, strong) UILabel                               *titleLabel;
@property (nonatomic, strong) UIButton                              *disclosureButton;
@property (nonatomic, assign) NSInteger                             section;
@property (nonatomic, assign) BOOL                                  opened;
@property (nonatomic, weak) id <WSProductSectionHeaderViewDelegate> delegate;

- (id)initWithFrame:(CGRect) frame title:(NSString *)title section:(NSInteger) sectionNumber opened:(BOOL) isOpened delegate:(id <WSProductSectionHeaderViewDelegate>)delegate;

@end

@protocol WSProductSectionHeaderViewDelegate <NSObject>
@optional
- (void)sectionHeaderView:(WSProductSectionHeaderView *)sectionHeaderView sectionClosed:(NSInteger)section;

- (void)sectionHeaderView:(WSProductSectionHeaderView *)sectionHeaderView sectionOpened:(NSInteger)section;
@end
