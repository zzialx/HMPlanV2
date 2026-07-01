//
//  WSTableView.h
//  WinSFA
//
//  Created by winchannel on 15/4/17.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSWidget.h"

@class WSTableViewCell;


typedef NS_ENUM(NSUInteger, TableViewSelectMode){
    
    singleSelect,
    mutableSelect
    
};


@protocol WSTableViewDelegate <WSWidgetDelegate>

@optional
-(void)sendSelectedCell:(WSTableViewCell *)mycell andSelectedItem:(NSObject *)item;

-(void)sendSelectedCell:(WSTableViewCell *)mycell andSelectedItemArray:(NSArray *)itemArray;

@end


@interface WSTableView : WSWidget<UITableViewDataSource,UITableViewDelegate,WSWidgetDelegate>{
    
    
    UITableView   *tableview;
    
    NSMutableDictionary  *cellmapping;
    
    NSMutableArray   *dataarray;
    
    __unsafe_unretained  id<WSTableViewDelegate>   tabledelegate;
    
    NSString   *acvtType;
    
}
@property (nonatomic,retain)  UITableView   *tableview;
@property (nonatomic,retain)  NSString  *acvtType;

@property (nonatomic,assign) id<WSTableViewDelegate>  tabledelegate;

@property (nonatomic,assign) TableViewSelectMode selectMode;

@property (nonatomic,strong) NSMutableArray* filterArray;

@property (nonatomic,strong)  NSMutableArray   *dataarray;

@end
