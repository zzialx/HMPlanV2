//
//  NewStarContactDataSource.h
// 
//
//  Created by 李 振杰 on 13-7-17.
//  Copyright (c) 2013年 新视星空. All rights reserved.
//
#import <Foundation/Foundation.h>

@protocol WSContactDataSourceDelegate <NSObject>

@optional

-(void)notifyData:(NSMutableArray *)array;

-(void)notifyData:(NSMutableArray *)array anddict:(NSMutableDictionary *)dict;

@end

@interface WSContactDataSource : NSObject{
    
  
    NSMutableArray * personAry ;
    
    NSMutableDictionary * sectionDict ;
    
    NSMutableArray * sectionMutableAry;
    
    id<WSContactDataSourceDelegate> delegate;
}
@property (nonatomic,retain) NSMutableArray * personAry ;
@property (nonatomic,retain) NSMutableDictionary * sectionDict ;
@property (nonatomic,retain) NSMutableArray * sectionMutableAry;
@property (nonatomic,assign) id<WSContactDataSourceDelegate> delegate;


-(void) loadData;



@end
