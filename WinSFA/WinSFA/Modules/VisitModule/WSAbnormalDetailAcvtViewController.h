//
//  WCAbnormalDetailAcvtViewController.h
//  WinChannelFrameWork
//
//  Created by Cai Lei on 6/19/12.
//
//

#import "WSAcvtViewController.h"
#import "WSBaseGrideViewController.h"
#import "WSAcvtButtonForTB.h"

@interface WSAbnormalDetailAcvtViewController : WSAcvtViewController

@property (nonatomic, assign) NSInteger dictRow;
@property (nonatomic, weak) WSBaseGrideViewController *parentGridVC;
@property (nonatomic, strong) NSString *iIdentify;

@property (nonatomic,weak) WSAcvtButtonForTB *parentBtn;

-(id)initWithAcvt:(WSAcvtBean*)anAcvt Funcs:(WSFuncsBean*)funcs Store:(WSStoreBean*)store Section:(NSInteger)section andIdentify:(NSString *)aIdentify;

@end
