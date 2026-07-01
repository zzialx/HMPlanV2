//
//  WSANNestedAcvtPanel.h
//  WinSFA
//
//  Created by yang on 16/3/11.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSBaseNestedAcvtPanel.h"

@interface WSANNestedAcvtPanel : WSBaseNestedAcvtPanel

@property(nonatomic ,strong)NSMutableArray *acvtVCArray; //+号新增的问卷控制器数组

- (void)saveDeleteWhenUpload;

- (void)deleteNewAddDatasWhenRevert;

//这一个ShowInMain类型的校验特别处理 [xbuildInfo getDisplayMode] isEqualToString:@"showInMain"
- (BOOL)executeValidateWithAcvtShowInMain;

- (void)updateANNestFrameWithWithSubview:(UIView*)sub height:(CGFloat)height;

@end
