//
//  WSNestedAcvtModel.h
//  WinSFA
//
//  Created by yang on 16/1/8.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSAcvtModel.h"

@interface WSNestedAcvtModel : WSAcvtModel

@property (nonatomic, strong) WSAcvtModel *parentModel;

@end
