//
//  ContactSearcher.m
//  LuckyBee
//
//  Created by 李 振杰 on 13-7-28.
//  Copyright (c) 2013年 新视星空. All rights reserved.
//

#import "ContactSearcher.h"
#import "ContactReadTool.h"
#import "ContactModel.h"
#import "SearchCoreManager.h"
@implementation ContactSearcher
@synthesize contactarray;
@synthesize contactdict;
@synthesize namearray;
@synthesize phonearray;
@synthesize delegate;
-(void)dealloc{
    
    [contactarray release];
    
    [contactdict release];
    
    [namearray release];
    
    [phonearray release];
    
    [super dealloc];
}

+(ContactSearcher *)shareSearcher{
    
    static  ContactSearcher *searcher=nil;
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        searcher =[[ContactSearcher alloc] init];
        
    });
    return searcher;
}


-(id) init{

    self =[super init];
    if (self) {
        contactdict =[[NSMutableDictionary alloc] init];
        phonearray =[[NSMutableArray alloc] init];
        namearray =[[NSMutableArray alloc] init];
        [self initWithSearchDetail];
        return self;
    }
    
    
    return nil;
}

-(void)initWithSearchDetail{
    
    
    ContactReadTool * readTool = [ContactReadTool getContactReadTool];
    
    [readTool reReadContact];
    
    contactarray = readTool.PersonAry;
    
    contactarray = (NSMutableArray *)[contactarray sortedArrayUsingComparator:^NSComparisonResult(ContactModel *obj1, ContactModel *obj2) {
        
        return [obj1.PersonNameFirstLetter compare:obj2.PersonNameFirstLetter];
    }];
    
    
    for (int i=0;i<[contactarray count];i++) {
    
        ContactModel * contactModel=[contactarray objectAtIndex:i];
            
            
            [[SearchCoreManager share] AddContact:[NSNumber numberWithInteger: [contactModel PersonID]] name:[contactModel getContactName] phone:[contactModel getContactMobileList]];
            
                [contactdict setValue:contactModel forKey:[NSString stringWithFormat:@"%ld", (long)[contactModel PersonID]]];
 
        
     }
    
    
}
-(void)searchContact:(NSString *)contact{
    
    
    NSMutableArray   *array =[[[NSMutableArray alloc] init] autorelease];
    
    [[SearchCoreManager share] Search:contact searchArray:nil nameMatch:namearray phoneMatch:phonearray];
    
    for (int i=0; i <[namearray count]; i++) {
        
        NSString   *key=[NSString stringWithFormat:@"%d",[[namearray objectAtIndex:i] intValue]];
        
        ContactModel * contactModel=[contactdict valueForKey:key];
        
        [array addObject:contactModel];
        
    
    }
    
    if ([delegate respondsToSelector:@selector(sendSearchResultSuccess:)]) {
        
        
        [delegate sendSearchResultSuccess:array];
        
    }
}

@end
