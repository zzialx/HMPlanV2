//
//  WSMyJPJTableViewCell.m
//  WinSFA
//
//  Created by zhiqing on 16/8/16.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSMyJPJTableViewCell.h"
#import "PureLayout.h"

#define WSMyJPJTableView_TEXT_SIZE [UIFont systemFontOfSize:15]
#define K_view_space  10
@interface WSMyJPJTableViewCell ()
{
    UILabel * _storeNameLable;
    UILabel * _visitState;
//    UILabel * _prepareState;  // 其实不需要这个也可以
    UILabel * _planOrder;
    BOOL isPopMessage;
    NSString  *_styleStr;
}

@end


@implementation WSMyJPJTableViewCell


-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withStyle:(NSString *)styleStr{

    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        _styleStr = styleStr;
        [self setupSubViews];
        
    }
    return self;

}

-(void)setupSubViews{

    _storeNameLable = [UILabel newAutoLayoutView];
    _storeNameLable.numberOfLines = 0;
    _storeNameLable.font = WSMyJPJTableView_TEXT_SIZE;
    _visitState = [UILabel newAutoLayoutView];
    _visitState.layer.cornerRadius = 5;
    _visitState.clipsToBounds = YES;
    
//    [_visitStateButton addTarget:self action:@selector(popUnusualMessage) forControlEvents:UIControlEventTouchUpInside];
//    _prepareState = [UILabel newAutoLayoutView];
//    _prepareState.layer.cornerRadius = 5;
//    _prepareState.clipsToBounds = YES;
    
    _planOrder = [UILabel newAutoLayoutView];
    _planOrder.layer.cornerRadius = 15;
    _planOrder.clipsToBounds = YES;
    _planOrder.textAlignment = NSTextAlignmentCenter;
    
    [self.contentView addSubview:_storeNameLable];
    [self.contentView addSubview:_visitState];
//    [self.contentView addSubview:_prepareState];
    
    if ([_styleStr isEqualToString:@"noPlanOrder"]) {
        [_storeNameLable autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
        [_storeNameLable autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:K_view_space];
        [_storeNameLable autoMatchDimension:ALDimensionHeight toDimension:ALDimensionHeight ofView:self];
        [_storeNameLable autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self withMultiplier:0.7] ;

        [_visitState autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
        [_visitState autoPinEdge:ALEdgeLeading toEdge:ALEdgeTrailing ofView:_storeNameLable withOffset:K_view_space];
        [_visitState autoSetDimensionsToSize:CGSizeMake(K_view_space, K_view_space)];
        
//        [_prepareState autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
//        [_prepareState autoPinEdge:ALEdgeLeading toEdge:ALEdgeTrailing ofView:_visitState withOffset:K_view_space];
//        [_prepareState autoSetDimensionsToSize:CGSizeMake(K_view_space, K_view_space)];
//      
        _planOrder.backgroundColor = MAIN_TINT_COLOT;

    }else{
        [self.contentView addSubview:_planOrder];
        [_planOrder autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(K_view_space + 5, K_view_space, K_view_space +5, K_view_space) excludingEdge:ALEdgeRight];
        [_planOrder autoSetDimension:ALDimensionWidth toSize:30];
        
        [_storeNameLable autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
        [_storeNameLable autoPinEdge:ALEdgeLeading toEdge:ALEdgeTrailing ofView:_planOrder withOffset:K_view_space];
        
        [_storeNameLable autoMatchDimension:ALDimensionHeight toDimension:ALDimensionHeight ofView:self];
        [_storeNameLable autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self withMultiplier:0.7] ;
        
        //    [_visitStateButton autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:K_view_space];
        [_visitState autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
        [_visitState autoPinEdge:ALEdgeLeading toEdge:ALEdgeTrailing ofView:_storeNameLable withOffset:K_view_space /2];
        [_visitState autoSetDimensionsToSize:CGSizeMake(K_view_space, K_view_space)];
        
//        [_prepareState autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
//        [_prepareState autoPinEdge:ALEdgeLeading toEdge:ALEdgeTrailing ofView:_storeNameLable withOffset:K_view_space /2];
//        [_prepareState autoSetDimensionsToSize:CGSizeMake(K_view_space, K_view_space)];
        _storeNameLable.textColor = [UIColor whiteColor];
        _planOrder.backgroundColor = [UIColor whiteColor];
        _planOrder.textColor = [UIColor whiteColor];


    }
    

}

-(void)setStoreDict:(NSDictionary *)storeDict{
    _storeDict = storeDict;
    _storeNameLable.text = [storeDict objectForKey:@"name"];
    NSNumber *number = storeDict[@"planOrder"];
    _planOrder.text = number.stringValue;
    // 对pjp的计划内外的门店 用不同颜色表示
    if (_planOrder.text.length > 0 && [storeDict[@"memo4"] length] >0) {
        _planOrder.backgroundColor = [UIColor orangeColor];
    }else if (_planOrder.text.length > 0 && [storeDict[@"memo4"] length] == 0){
        _planOrder.backgroundColor = [UIColor grayColor];

    }else{
        _planOrder.backgroundColor = [UIColor colorWithRed:11/255.0 green:163/255.0 blue:251/255.0 alpha:1];
    }
    
        if ([storeDict[@"memo4"] isEqualToString:@"异"])
        {
            _visitState.backgroundColor = [UIColor colorWithRed:253/255.0 green:120/255.0 blue:122/255.0 alpha:1];
//            _prepareState.backgroundColor = [UIColor clearColor];

            isPopMessage = YES;
        }
        else if([storeDict[@"memo4"] isEqualToString:@"正"])
        {
            _visitState.backgroundColor = [UIColor colorWithRed:70/255.0 green:192/255.0 blue:168/255.0 alpha:1];
//            _prepareState.backgroundColor = [UIColor clearColor];

            isPopMessage = NO;
        }else{
//            _visitState.backgroundColor = [UIColor clearColor];
            if ([storeDict[@"memo3"] isEqualToString:@"115119"]) {
                _visitState.backgroundColor = [UIColor colorWithRed:121/255.0 green:176/255.0 blue:252/255.0 alpha:1];
            }else{
                _visitState.backgroundColor = [UIColor colorWithRed:129/255.0 green:129/255.0 blue:129/255.0 alpha:1];

            }

            isPopMessage = NO;
        }

    
}
-(void)setStoreBean:(WSStoreBean *)storeBean{

    _storeBean = storeBean;
    _storeNameLable.text = storeBean.name;
    // 对pjp的计划内外的门店 用不同颜色表示
    if (storeBean.plan && storeBean.actionState.length >0 ) {
        _planOrder.text = storeBean.visitPlanMapOrder;
        _planOrder.backgroundColor = [UIColor colorWithRed:25/255.0 green:171/255.0 blue:81/255.0 alpha:1];
    }else if (storeBean.plan && storeBean.actionState.length == 0){
        _planOrder.text = @"";
        _planOrder.backgroundColor =  [UIColor colorWithRed:11/255.0 green:163/255.0 blue:251/255.0 alpha:1];
        
    }else if (!storeBean.plan && storeBean.actionState.length >0){
        _planOrder.text = storeBean.visitPlanMapOrder;
        _planOrder.backgroundColor = [UIColor orangeColor];
        
    }else {
        _planOrder.text = @"";

        _planOrder.backgroundColor = [UIColor orangeColor];
    }
    
    if ([storeBean.actionState isEqualToString:@"异"])
    {
        _visitState.backgroundColor = [UIColor colorWithRed:253/255.0 green:120/255.0 blue:122/255.0 alpha:1];
//        _prepareState.backgroundColor = [UIColor clearColor];
        
        isPopMessage = YES;
    }
    else if([storeBean.actionState isEqualToString:@"正"])
    {
        _visitState.backgroundColor = [UIColor colorWithRed:70/255.0 green:192/255.0 blue:168/255.0 alpha:1];
//        _prepareState.backgroundColor = [UIColor clearColor];
        
        isPopMessage = NO;
    }else{
//        _visitState.backgroundColor = [UIColor grayColor];
        if ([storeBean.prepareState isEqualToString:@"115120"]) {
            _visitState.backgroundColor = [UIColor colorWithRed:121/255.0 green:176/255.0 blue:252/255.0 alpha:1];
        }else{
            _visitState.backgroundColor = [UIColor clearColor];
            
        }
        
        isPopMessage = NO;
    }
    



}
-(void)popUnusualMessage{
    if (isPopMessage) {
        NSLog(@"=====>异常信息");
    }else{
        NSLog(@"=====>不提示");
    }
    
}

-(void)storePrepare{
    NSLog(@"=====>门店准备");

}
- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
    CGContextFillRect(context, rect);
    
    //上分割线，
    //    CGContextSetStrokeColorWithColor(context, [UIColor grayColor].CGColor);
    //    CGContextStrokeRect(context, CGRectMake(5, -1, rect.size.width - 10, 1));
    //
    //下分割线
    CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:212/255.0 green:212/255.0 blue:212/255.0 alpha:1].CGColor);
    CGContextStrokeRect(context, CGRectMake(0, rect.size.height, rect.size.width, 1));
}

@end
