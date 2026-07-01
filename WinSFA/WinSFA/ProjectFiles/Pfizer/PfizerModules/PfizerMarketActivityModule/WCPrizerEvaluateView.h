//
//  WCPrizerEvaluateView.h
//  WinChannelFrameWork
//
//  Created by xiaotang.wang on 7/3/13.
//
//

#import <UIKit/UIKit.h>

@class WCPrizerEvaluateView;
@class WSSpbaInfoBean;

@protocol WCPrizerEvaluateViewDelegate <NSObject>

//- (void)evaluateView:(WCPrizerEvaluateView *)aView checkboxClicked:(id)sender;
//
//- (void)evaluateView:(WCPrizerEvaluateView *)aView evaluateButtonClicked:(id)sender;

- (void)evaluateView:(WCPrizerEvaluateView *)aView checkboxClicked:(id)sender withSpbaInfoBean:(WSSpbaInfoBean *)aBean;

- (void)evaluateView:(WCPrizerEvaluateView *)aView evaluateButtonClicked:(id)sender withSpbaInfoBean:(WSSpbaInfoBean *)aBean;

@end

@interface WCPrizerEvaluateView : UIView

@property (nonatomic, weak)id<WCPrizerEvaluateViewDelegate> iDelegate;

- (id)initWithFrame:(CGRect)frame withName:(NSString *)aName;
- (id)initWithFrame:(CGRect)frame withSpbaInfoBean:(WSSpbaInfoBean *)aBean;
- (id)initWithFrame:(CGRect)frame withSpbaInfoBean:(WSSpbaInfoBean *)aBean withEvaluatePerson:(NSDictionary *)aEvaluateDic;

@end
