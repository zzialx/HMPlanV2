//
//  WCInventoryandSalesReportViewController.h
//  WinChannelFrameWork
//
//  Created by xiaotang.wang on 7/8/13.
//
//

#import "WSOutPlanViewController.h"

@interface WCInventoryandSalesReportViewController : UIViewController

@property (nonatomic, strong) WSFuncsBean *currentFuncs;

- (id)initWithFuncs:(WSFuncsBean *)funcs;

@end
