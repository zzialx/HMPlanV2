//
//  WSTAAcvtDataGridViewDataSouce.h
//  WinSFA
//
//  Created by heju on 15/12/29.
//  Copyright © 2015年 WinChannel. All rights reserved.
//

#import "WSBaseDataSource.h"

#import "WSAcvtModel.h"


@interface WSTAAcvtDataGridViewDataSouce : WSBaseDataSource 

@property (nonatomic, strong)WSAcvtBean_qst<I_W_BuildInfo> *currentBuildInfo;

@property (nonatomic, strong)WSAcvtModel *acvtModel;

@property (nonatomic, strong)WSFuncsBean *currentFunc;

@property (nonatomic, strong)NSArray *qstsForColumn;

@property (nonatomic, strong)NSMutableArray *dataSource;

@property (nonatomic, strong)NSMutableArray *columnParams;

@property (nonatomic, strong)NSMutableArray *columnWidths;




@end
