//
//  ModifyPasswdViewController.h
//  WinChannelIPhone
//
//  Created by Chen Angus on 11-7-15.
//  Copyright 2011年 dumbrock. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WCBaseViewController.h"

typedef enum {
    ModifyPWForID = 0,
    ModifyPWForOldPW,
    ModifyPWForNewPW,
    ModifyPWForConfirmPW
} ModifyPW;

@interface WSModifyPasswdViewController : WCBaseViewController <UITextFieldDelegate>{
    UIActivityIndicatorView *aiv;
    NSMutableArray          *textFields;
    NSArray                 *tableCellTitle;
    NSArray                 *tableCellPlaceholder;
}
@property (nonatomic, strong) NSMutableArray    *textFields;
@property (nonatomic, strong) NSArray           *tableCellTitle;
@property (nonatomic, strong) NSArray           *tableCellPlaceholder;

@property (nonatomic, strong) NSString          *modifyUserName;


// 一下两个方法  addBy wangdongyan
- (BOOL)infoValue:(NSString *)aSource aDest:(NSString *)aDestion aMsg:(NSString *)aMessage;
- (BOOL)infoValid:(NSMutableArray *)textFieldList;
@end
