//
//  ContactSearcher.h
//  LuckyBee
//
//  Created by 李 振杰 on 13-7-28.
//  Copyright (c) 2013年 新视星空. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ContactSearcherDelegate <NSObject>

@optional
-(void)sendSearchResultSuccess:(NSArray *)array;

@end

@interface ContactSearcher : NSObject{
    
    NSMutableArray   *contactarray;
    
    
    NSMutableDictionary   *contactdict;
    
    NSMutableArray        *namearray;
    
    NSMutableArray        *phonearray;
    
    __unsafe_unretained id<ContactSearcherDelegate> delegate;
    
    
}

@property (nonatomic,retain) NSMutableArray   *contactarray;
@property (nonatomic,retain) NSMutableDictionary   *contactdict;
@property (nonatomic,retain) NSMutableArray        *namearray;
@property (nonatomic,retain) NSMutableArray        *phonearray;
@property (nonatomic,assign) id<ContactSearcherDelegate> delegate;

+(ContactSearcher  *)shareSearcher;

-(void)searchContact:(NSString *)contact;
@end
