//
//  WCEvaluatePersonViewController.h
//  WinChannelFrameWork
//
//  Created by xiaotang.wang on 6/28/13.
//
//

#import <UIKit/UIKit.h>

@interface WCEvaluatePersonViewController : UIViewController

- (id)initWithObject:(id)aObject;
//- (id)initWithPersonId:(int)aPersonId andResultArray:(NSMutableArray *)aResultArray;
- (id)initWithPersonId:(NSString *)aPersonId withResultDictory:(NSMutableDictionary *)aResultDictory;

@end
