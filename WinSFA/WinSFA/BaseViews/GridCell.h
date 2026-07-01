//
//  GridCell.h
//  bg
//
//  Created by Niu Zhaowang on 10/29/12.
//  Copyright (c) 2012 Niu Zhaowang. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum
{
    EGridText = 1,
    EGridNumber,
    EGridCheckBox,
    EGridButton
}GridType;

@interface GridCell : NSObject

@property(nonatomic,assign)GridType type;
@property(nonatomic,assign)BOOL readonly;
@property(nonatomic,copy)NSString *value;
@property(nonatomic,copy)NSString *redisValue;

@property(nonatomic,copy)NSString *buttonTitle;  //only for button type


//inner use
@property(nonatomic,assign)int row;
@property(nonatomic,assign)int column;
@property(nonatomic,strong)id view;

@end
