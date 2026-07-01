//
//  GridCell.m
//  bg
//
//  Created by Niu Zhaowang on 10/29/12.
//  Copyright (c) 2012 Niu Zhaowang. All rights reserved.
//

#import "GridCell.h"



@implementation GridCell

@synthesize row = _row;
@synthesize column = _column;
@synthesize type = _type;
@synthesize readonly = _readonly;
@synthesize value = _value;
@synthesize redisValue = _redisValue;
@synthesize view = _view;
@synthesize buttonTitle = _buttonTitle;

-(NSString *)value
{
    if (_type == EGridText)
    {
        return _value;
    }
    else if (_type == EGridNumber)
    {
        return _value;
    }
    else if (_type == EGridCheckBox)
    {
        UIButton *button = (UIButton *)_view;
        if (button.selected) {
            return @"1";
        }
        else
        {
            return @"0";
        }
    }
    else
    {
        return nil;
    }
}

@end
