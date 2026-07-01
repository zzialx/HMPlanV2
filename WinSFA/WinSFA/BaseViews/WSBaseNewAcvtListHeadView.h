//
//  WSBaseNewAcvtListHeadView.h
//  WinSFA
//
//  Created by heju on 2016/12/5.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WSBaseNewAcvtListHeadViewDelegate;

@interface WSBaseNewAcvtListHeadView : UIView

@property (nonatomic,weak) id <WSBaseNewAcvtListHeadViewDelegate> delegate;

- (id)initWithFrame:(CGRect)frame currentFuncs:(WSFuncsBean *)currentFuncs addAcvtArray:(NSArray *)acvtArray;

- (void)reloadCalendarSubViewIcons:(NSDictionary *)dictionary;

@end

@protocol WSBaseNewAcvtListHeadViewDelegate <NSObject>

- (void)headView:(WSBaseNewAcvtListHeadView *)headView selectedAcvtBean:(WSAcvtBean *)selectedAcvtBean;

- (void)headView:(WSBaseNewAcvtListHeadView *)headView selectedDates:(NSArray *)selectedDates;

- (void)headView:(WSBaseNewAcvtListHeadView *)headView changeToHeight:(CGFloat)height;

- (void)headView:(WSBaseNewAcvtListHeadView *)headView changeToMonth:(NSInteger)month;

@end
