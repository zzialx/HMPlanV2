//
//  ContactModel.h
//  
//
//  Created by 李 振杰 on 13-7-17.
//  Copyright (c) 2013年 新视星空. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "I_W_ContactDisplay.h"
@interface ContactModel : NSObject<I_W_ContactDisplay>
@property (nonatomic,assign) NSInteger PersonID;
@property (nonatomic,retain) NSString * PersonName;
@property (nonatomic,retain) NSMutableArray * PhoneLabelAry;
@property (nonatomic,retain) NSData * PersonImageData;
@property (nonatomic,retain) NSString * PersonNameFirstLetter;
@property (nonatomic,retain) NSString * PersonNameLetter;
@end



@interface PhoneAndLabel : NSObject
@property (nonatomic,retain) NSString * phoneNum;
@property (nonatomic,retain) NSString * phoneLabel;

@end
