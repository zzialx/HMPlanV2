//
//  WSBaseNestedAcvtPanel.h
//  WinSFA
//
//  Created by yang on 16/1/8.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSSingleTitlePanel.h"
#import "WSEmbeddedAcvtViewControllerDelegate.h"


@interface WSBaseNestedAcvtPanel : WSSingleTitlePanel<WSEmbeddedAcvtViewControllerDelegate>

@property (nonatomic, strong) WSAcvtBean *nestedAcvtBean;

@property (nonatomic, strong) UIImageView *rightArrowImageView;

@property (nonatomic, strong) NSMutableArray *acvtDataArray;

@property (nonatomic, strong) NSMutableArray *acvtMd5Array;

@property (nonatomic, strong) NSMutableArray *deleteMD5Array;

@property (nonatomic, strong) NSMutableArray *anNewAddMD5Array;

@property (nonatomic, assign) BOOL isEmbeddedAcvtConfirmedData;


- (void)loadRedisDataWithValue:(NSString *)value;


@end
