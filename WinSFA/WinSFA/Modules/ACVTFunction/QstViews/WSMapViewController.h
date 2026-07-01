//
//  WSMapViewController.h
//  WinSFA
//
//  Created by admin on 15/11/12.
//  Copyright © 2015年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WSPerson4Store.h"
#import "WSSalePersonModel.h"
@interface WSMapViewController : UIViewController

@property(nonatomic,strong) WSSalePersonModel * salePerson;
@property(nonatomic,strong) WSPerson4Store * persen4store;

-(instancetype)initWithModel:(WSSalePersonModel *)SalePersonModel;
@end
