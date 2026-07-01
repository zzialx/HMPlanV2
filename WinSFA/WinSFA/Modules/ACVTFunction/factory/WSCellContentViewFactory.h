//
//  WSCellContentViewFactory.h
//  WinSFA
//
//  Created by winchannel on 15/5/6.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>


@class WSCellContentView;

@interface WSCellContentViewFactory : NSObject{
    
    NSMutableDictionary  *cellViewConfig;
    
    NSString  *parentAcvtType;
    
    NSMutableDictionary *key_type_dict;
    
    CGFloat default_width;
}


+(id)shareInstance;

-(void)setParentAcvtType:(NSString *)parentType;


-(void)setDefaultWidth:(CGFloat)width;


-(WSCellContentView *)createWidgetByWidgetInfo:(NSMutableArray *)cellcontents;

@end
