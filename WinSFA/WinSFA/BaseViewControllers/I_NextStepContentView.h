//
//  I_NextStepContentView.h
//  WinSFA
//
//  Created by Stephanie on 16/8/22.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol I_NextStepContentView <NSObject>

@optional

- (void)nextStepContentViewClearData;

- (BOOL)nextStepContentViewValidateData;

- (void)nextStepContentViewUploadData;

@end
