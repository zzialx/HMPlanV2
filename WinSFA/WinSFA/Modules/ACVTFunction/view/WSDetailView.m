//
//  WSDetailView.m
//  WinSFA
//
//  Created by admin on 15/11/12.
//  Copyright © 2015年 WinChannel. All rights reserved.
//

#import "WSDetailView.h"
@interface WSDetailView()

@property(nonatomic,strong)UIButton * visitBtn;

@property(nonatomic,strong)UILabel * personMsg;
@property(nonatomic,strong)UILabel * storeLabel;
@end
@implementation WSDetailView

-(instancetype)initWithFrame:(CGRect)frame{

    self = [super initWithFrame:frame];
    if (self) {
        
        UIButton * btn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 50, 50)];
        btn.backgroundColor = [UIColor redColor];
        [btn.titleLabel setFont:[UIFont systemFontOfSize:10]];
        self.visitBtn = btn;
        [btn addTarget:self action:@selector(action) forControlEvents:UIControlEventTouchUpInside];
        UILabel * personLabel = [[UILabel alloc]initWithFrame:CGRectMake(50, 0, 50, 25)];
        personLabel.textAlignment = NSTextAlignmentCenter;
        self.personMsg = personLabel;
         UILabel * storeLabel = [[UILabel alloc]initWithFrame:CGRectMake(50, 25, 50, 25)];
        [storeLabel setFont:[UIFont systemFontOfSize:10]];
        storeLabel.textAlignment = NSTextAlignmentCenter;
        self.storeLabel = storeLabel;
        
        [self addSubview:btn];
        [self addSubview:personLabel];
        [self addSubview:storeLabel];
    }
    self.backgroundColor = [UIColor orangeColor];
    return self;
}

-(void)setSaleModel:(WSSalePersonModel *)saleModel{

    _saleModel = saleModel;
    
    [self.visitBtn setTitle:@"拜访轨迹" forState:UIControlStateNormal];
    //[self.visitBtn sizeToFit];
    self.personMsg.text = saleModel.name;
    self.storeLabel.text = saleModel.storeName;

}

-(void)setPersonModel:(WSPerson4Store *)personModel{
    _personModel = personModel;
    [self.visitBtn setImage:[UIImage imageNamed:personModel.icon] forState:UIControlStateNormal];
    self.personMsg.text =personModel.storeName;
    self.storeLabel.text = personModel.storeName;
    

}
-(void)action{

    NSLog(@"张三");
    NSMutableDictionary *dict = [NSMutableDictionary dictionary ];
    [dict setObject:self.saleModel forKey:@"model"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"store4message" object:nil userInfo:dict];
}
@end
