//
//  WSInterActionForTableCell.h
//  WinSFA
//
//  Created by winchannel on 15/4/29.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSInterAction.h"

@interface WSInterActionForTableCell : WSInterAction{
    
    NSInteger  row;  //第几行
    
    //这个地方的考虑还不够全面
    NSString   *subacvtId; //子问题编号



}

@property (nonatomic,assign) NSInteger row;
@property (nonatomic,strong) NSString  *subacvtId;

@end
