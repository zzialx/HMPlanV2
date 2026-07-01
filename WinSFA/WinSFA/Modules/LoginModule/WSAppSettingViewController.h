//
//  AppSettingViewController.h
//  WinChannelIPhone
//
//  Created by Chen Angus on 11-8-15.
//  Copyright 2011年 Winchannel. All rights reserved.
//

#import "WCBaseViewController.h"

#import <UIKit/UIKit.h>

@interface WSAppSettingViewController :WCBaseViewController
                                      <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate,UIAlertViewDelegate>{
    UITableView     *mTableView;
    UILabel         *label;
    UILabel         *URLlabel;
                                          
}

@property (nonatomic, strong) UITableView   *mTableView;
@property (nonatomic, strong) UILabel       *label;
@property (nonatomic, strong) UILabel       *URLlabel;

- (id)initAppSetting;

@end
