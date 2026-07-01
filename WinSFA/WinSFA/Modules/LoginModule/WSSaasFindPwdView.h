//
//  WSSaasFindPwdView.h
//  WinSFA
//
//  Created by Alicia on 2017/10/27.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WSLoginTextFieldView.h"

@protocol WSLoginReterivePwdDelegate <NSObject>

- (void)getWebAddressByUserName:(NSString *)username orgName:(NSString *)orgName;

@end

@interface WSSaasFindPwdView : UIView

@property (nonatomic, weak) id <WSLoginReterivePwdDelegate> delegate;

@end
