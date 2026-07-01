//
//  ContactReadTool.h
//  
//
//
//  Created by 李 振杰 on 13-7-17.
//  Copyright (c) 2013年 新视星空. All rights reserved.
//

#import <AddressBook/AddressBook.h>
 
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface ContactReadTool : NSObject<UIAlertViewDelegate>
@property (nonatomic,retain) NSMutableArray * PersonAry ;
+(ContactReadTool *) getContactReadTool;
- (void)reReadContact;

@end
