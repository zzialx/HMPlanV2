//
//  WSNextStepViewController.h
//  WinSFA
//
//  Created by winchannel on 16/8/9.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "BaseViewController.h"


@interface WSNextStepViewController : BaseViewController

@property (nonatomic, assign, readonly)NSInteger currentIndex;

@property (nonatomic, strong) NSArray *remainItemsArray;

- (id)initWithFuncs:(WSFuncsBean *)funcs Store:(WSStoreBean *)store;

- (id)initWithFuncs:(WSFuncsBean *)funcs Store:(WSStoreBean *)store currentIndex:(NSInteger)currentIndex;

- (void)nextStep;

- (void)confirmCompletion;

- (BOOL)validateAndUploadDatasForContenViewController;



@end
