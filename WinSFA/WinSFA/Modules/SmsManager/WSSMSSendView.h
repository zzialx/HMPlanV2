//
//  WSSMSSendView.h
//  WinSFA
//
//  Created by mac on 16/12/14.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WSSMSSendView : UIView

@property (nonatomic , copy) void(^sendSMS)(NSString * detail , NSArray * phones);


-(instancetype)initWithFrame:(CGRect)frame phones:(NSString *)phones;
-(void)selectAllPhone;
@end
