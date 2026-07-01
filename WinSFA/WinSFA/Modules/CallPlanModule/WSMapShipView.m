//
//  WSMapShipView.m
//  WinSFA
//
//  Created by mac on 16/10/26.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSMapShipView.h"
#define WSMyJPJTableView_TEXT_SIZE [UIFont systemFontOfSize:15]

@interface WSMapShipView ()
{
    UILabel * pjpLine;
    UILabel * pjptitle;
    
    UILabel * actureLine;
    UILabel * acturetitle;
    
}

@end


@implementation WSMapShipView
-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setupSubViews];
    }
    return self;
}

-(void)setupSubViews{
    pjpLine = [[UILabel alloc]initWithFrame:CGRectMake(0, 19, 1/15.0 *self.width , 2.5)];
    pjpLine.backgroundColor = [UIColor colorWithRed:11/255.0 green:163/255.0 blue:251/255.0 alpha:1];


    [self addSubview:pjpLine];
    
    pjptitle = [[UILabel alloc]initWithFrame:CGRectMake(pjpLine.right + 10, 5, 2/15.0 *self.width - 20, self.height - 10)];
    pjptitle.text = @"pjp线路";
    pjptitle.font = WSMyJPJTableView_TEXT_SIZE;
    [self addSubview:pjptitle];
    
    actureLine = [[UILabel alloc]initWithFrame:CGRectMake(pjptitle.right, 5, 1/15.0 *self.width , self.height - 10)];
    actureLine.text = @"·······";
    actureLine.textColor = [UIColor orangeColor];
    [self addSubview:actureLine];

    acturetitle = [[UILabel alloc]initWithFrame:CGRectMake(actureLine.right , 5, 2/15.0 *self.width + 20 , self.height - 10)];
    acturetitle.text = @"实际拜访线路";
    acturetitle.font = WSMyJPJTableView_TEXT_SIZE;

    [self addSubview:acturetitle];
    
    for (int i = 0 ; i < 3; i++) {
        UILabel * label = [[UILabel alloc]initWithFrame:CGRectMake(acturetitle.right + i * 0.2 * self.width + 10, 5, 30, self.height - 10)];
        label.layer.cornerRadius = 15;
        label.clipsToBounds = YES;
        
        UILabel * tilteLabel = [[UILabel alloc]initWithFrame:CGRectMake(label.right + 10 , 5, 2/15.0  *self.width, self.height - 10)];
        tilteLabel.font = WSMyJPJTableView_TEXT_SIZE;

        [self addSubview:label];
        [self addSubview:tilteLabel];
        if (i == 0) {
            tilteLabel.text = @"正常拜访";
            label.backgroundColor = [UIColor colorWithRed:25/255.0 green:171/255.0 blue:81/255.0 alpha:1];
            
        }else if (i == 1){
            tilteLabel.text = @"计划外拜访";
            label.backgroundColor = [UIColor orangeColor];
        }else{
            tilteLabel.text = @"计划未拜访";
            label.backgroundColor = [UIColor colorWithRed:11/255.0 green:163/255.0 blue:251/255.0 alpha:1];

        }
    }
    
}
@end
