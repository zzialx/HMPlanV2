//
//  NewStarContactDataSource.m
//  
//
//  Created by 李 振杰 on 13-7-17.
//  Copyright (c) 2013年 新视星空. All rights reserved.
//

#import "WSContactDataSource.h"
#import "ContactReadTool.h"
#import "ContactModel.h"


@implementation WSContactDataSource
@synthesize personAry ;
@synthesize sectionDict ;
@synthesize sectionMutableAry;
@synthesize delegate;


- (id)init
{
    self = [super init];
    
    if (self) {

     
    }
   
    return self;
}




-(void) loadData{

    
    ContactReadTool * readTool = [ContactReadTool getContactReadTool];
    
    [readTool reReadContact];
    
    sectionDict= [[NSMutableDictionary alloc] init];
    
    sectionMutableAry = [[NSMutableArray alloc] init];
    
    personAry = readTool.PersonAry;
    
    
    personAry = (NSMutableArray *)[personAry sortedArrayUsingComparator:^NSComparisonResult(ContactModel *obj1, ContactModel *obj2) {
    
        return [obj1.PersonNameFirstLetter compare:obj2.PersonNameFirstLetter];
    
    }];
    
    for (ContactModel * contactModel in personAry) {
        
        
        NSMutableArray* section = [sectionDict objectForKey:contactModel.PersonNameFirstLetter];
        
        if (!section) {
            
            section = [NSMutableArray array];
            [sectionDict setObject:section forKey:contactModel.PersonNameFirstLetter];
            [sectionMutableAry addObject:contactModel.PersonNameFirstLetter];
        
        }
        
        [section addObject:contactModel];
    }
    
   
    if ([delegate respondsToSelector:@selector(notifyData:)]) {
        
        [delegate notifyData:personAry];
    }
    
    if ([delegate respondsToSelector:@selector(notifyData:anddict:)]) {
        
       
        [delegate notifyData:personAry anddict:sectionDict];
    }
 
}



@end
