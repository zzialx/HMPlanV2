//
//  WSDetailView.h
//  WinSFA
//
//  Created by admin on 15/11/12.
//  Copyright © 2015年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WSSalePersonModel.h"
#import "WSPerson4Store.h"
@interface WSDetailView : UIView
@property(nonatomic,strong)WSSalePersonModel *saleModel;

@property(nonatomic,strong) WSPerson4Store * personModel;
@end
