//
//  WCMultipleChoiceViewController.h
//  WinChannelFrameWork
//
//  Created by xiaotang.wang on 7/17/13.
//
//

#import <UIKit/UIKit.h>

@protocol WSMultipleChoiceDelegate <NSObject>

@optional

- (void)multipleChoiceViewController:(UIViewController *)aVc withResults:(NSArray *)aChoices;

@end


@interface WSMultipleChoiceViewController : UIViewController


@property (nonatomic, weak)id<WSMultipleChoiceDelegate> delegate;
@property (nonatomic, copy)NSString *iTitle;
@property (nonatomic, strong)UIView *iSourceView;

- (id)initWithSourceArray:(NSArray *)aSourceArray andResultsArray:(NSMutableArray *)aResultsArray;


@end
