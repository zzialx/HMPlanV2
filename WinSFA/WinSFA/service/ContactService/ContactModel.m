//
//  ContactModel.m
//  
//
//  Created by 李 振杰 on 13-7-17.
//  Copyright (c) 2013年 新视星空. All rights reserved.
//
#import "ContactModel.h"



@implementation ContactModel
@synthesize PersonID;
@synthesize PersonName;
@synthesize PhoneLabelAry;
@synthesize PersonImageData;
@synthesize PersonNameFirstLetter;
@synthesize PersonNameLetter;
- (id)init
{
    self = [super init];
    if (self) {
        
        self.PhoneLabelAry = [NSMutableArray array];
    }
    return self;
}

- (void)dealloc
{
    [PersonNameLetter release];
    [PersonNameFirstLetter release];
    [PersonImageData release];
    [PersonName release];
    [PhoneLabelAry release];
    [super dealloc];
}

-(NSString *)getContactMobile{
    
    for (int i=0; i<[self.PhoneLabelAry count] ; i++) {
        PhoneAndLabel *pl=[self.PhoneLabelAry objectAtIndex:i];
        if ([[pl phoneLabel]isEqualToString:@"mobile"]) {
            
            return [pl phoneNum];
        }
    }
    
    if ([self.PhoneLabelAry count]<=0) {
        
        return @"";
    }
    return [[self.PhoneLabelAry objectAtIndex:0] phoneNum];
}

-(NSMutableArray *)getContactMobileList{
    
    if (self.PhoneLabelAry==nil) {
        
        return nil;
    }
    
    NSMutableArray *phones=[[[NSMutableArray alloc] init] autorelease];
    
    
    for (int i=0; i<[self.PhoneLabelAry count] ; i++) {
        PhoneAndLabel *pl=[self.PhoneLabelAry objectAtIndex:i];
            [phones addObject: [pl phoneNum]];
       
    }
    return phones;
}
-(NSString *)getContactName{
    
    
    return PersonName;
}

-(NSData *)getContactImageData{
    
    
    return PersonImageData;
}
@end

@implementation PhoneAndLabel
@synthesize phoneLabel;
@synthesize phoneNum;

- (void)dealloc
{
    
    [phoneNum release];
    [phoneLabel release];
    [super dealloc];
}
@end