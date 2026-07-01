//
//  WSAcvtManagementObj.h
//  WinSFA
//
//  Created by winchannel on 15/8/25.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WSAcvtBean;


@interface WSAcvtManagementObj : NSObject{
    
    NSString  *nestedId;
    
    NSString  *filterGenIds;
    
    WSAcvtBean  *acvtBean;
    
    NSString    *fc;
    
    NSString    *fv;
    
    NSString    *empId;
    
    WSStoreBean *storeBean;
    
    NSString  *parentGenId;
    
}

@property (nonatomic,strong) WSAcvtBean  *acvtBean;
@property (nonatomic,strong) NSString *fc;
@property (nonatomic,strong) NSString *fv;
@property (nonatomic,strong) NSString  *nestedId;
@property (nonatomic,strong) NSString  *filterGenIds;
@property (nonatomic,strong) NSString  *empId;
@property (nonatomic,strong)  WSStoreBean *storeBean;
@property (nonatomic,strong) NSString  *parentGenId;
@end
