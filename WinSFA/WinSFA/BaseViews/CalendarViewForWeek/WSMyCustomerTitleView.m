//
//  WSMyCustomerTitleView.m
//  WinSFA
//
//  Created by zhiqing on 16/7/27.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSMyCustomerTitleView.h"
#import "PureLayout.h"
#import "WSDictBean.h"
#import "WSSearchBar.h"

#define k_View_Space 15

@interface WSMyCustomerTitleView ()<UISearchBarDelegate>
{
    UISegmentedControl * segment;
    WSSearchBar * searchbar;
    UIButton * customerAudit;
    WSMyCustomerTitleViewStyle _style;
    NSArray * _dictArray;
}
@end

@implementation WSMyCustomerTitleView

-(instancetype)initWithFrame:(CGRect)frame style:(WSMyCustomerTitleViewStyle)style withItems:(NSArray *)items{
    
    if (self = [super initWithFrame:frame]) {
        _style = style;
       
        _dictArray = [[NSArray alloc]init];
        _dictArray = items;
        [self setUpSubViews];
    }
    return self;
}


-(void)setUpSubViews{
    NSMutableArray * items = [NSMutableArray arrayWithCapacity:_dictArray.count];
    for (WSDictBean *dict in _dictArray) {
        [items addObject:dict.name];
    }
    segment = [[UISegmentedControl alloc]initWithItems:items];
    segment.tintColor = [UIColor colorWithRed:251/255.0 green:216/255.0 blue:203/255.0 alpha:1];
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithRed:137/255.0 green:12/255.0 blue:4/255.0 alpha:1],
                          NSForegroundColorAttributeName,
                          [UIFont boldSystemFontOfSize:14],
                          NSFontAttributeName,nil];
    
    NSDictionary *dic1 = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithRed:240/255.0 green:98/255.0 blue:38/255.0 alpha:1],
                         NSForegroundColorAttributeName,
                         [UIFont boldSystemFontOfSize:14],
                         NSFontAttributeName,nil];
    
//    if (!IOS7_OR_LATER) {
//        dic = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithRed:137/255.0 green:12/255.0 blue:4/255.0 alpha:1],
//               UITextAttributeTextColor,
//               [UIFont boldSystemFontOfSize:14],
//               UITextAttributeFont,nil];
//
//        dic1 = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithRed:240/255.0 green:98/255.0 blue:38/255.0 alpha:1],
//                UITextAttributeTextColor,
//                [UIFont boldSystemFontOfSize:14],
//                UITextAttributeFont,
//                [UIColor clearColor],
//                UITextAttributeTextShadowColor,nil];
//        
//        [segment setBackgroundImage:[UIImage imageFromColor:[UIColor colorWithRed:251/255.0 green:216/255.0 blue:203/255.0 alpha:1] with:CGRectMake(0, 0, 300, 40)] forState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
//    }
    
    [segment setTitleTextAttributes:dic forState:UIControlStateNormal];
    [segment setTitleTextAttributes:dic1 forState:UIControlStateSelected];
    
    [segment addTarget:self action:@selector(segmentValueChange:) forControlEvents:UIControlEventValueChanged];
    
    segment.layer.borderColor = [UIColor colorWithRed:253/255.0 green:164/255.0 blue:142/255.0 alpha:1].CGColor;
    segment.layer.borderWidth = 1.5;
    segment.layer.cornerRadius = 6;
    segment.clipsToBounds = YES;

    searchbar = [[WSSearchBar alloc]init];
 //   searchbar.delegate = self;

    
    
    [self addSubview:segment];
    [self addSubview:searchbar];
    if (_style == WSMyCustomerTitleViewStyleMyCustomer)
    {
      //  searchbar.placeholder = @"请输入关键字搜索";
        
//        customerAudit = [UIButton buttonWithType:UIButtonTypeCustom];
//        [customerAudit setBackgroundImage:[UIImage imageNamed:@"button_khshjl"] forState:UIControlStateNormal];
//        [self addSubview:customerAudit];
        
        [segment autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(k_View_Space, k_View_Space, k_View_Space, 0) excludingEdge:ALEdgeRight];
        [segment autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self withMultiplier:0.125];
        
        [searchbar autoPinEdge:ALEdgeLeading toEdge:ALEdgeTrailing ofView:segment withOffset:k_View_Space];
        [searchbar autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:k_View_Space];
        [searchbar autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:k_View_Space];
        [searchbar autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self withMultiplier:0.25];
        
//        [customerAudit autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:k_View_Space];
//        [customerAudit autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:k_View_Space];
//        [customerAudit autoPinEdgeToSuperviewEdge:ALEdgeTrailing withInset:k_View_Space];
//        [customerAudit autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self withMultiplier:0.125];
    }else if (_style == WSMyCustomerTitleViewStyleAddNewVisit)
    {
      //  searchbar.placeholder = @"输入编码 / 名称 / 地区";
        [searchbar autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:k_View_Space];
        [searchbar autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:k_View_Space];
        [searchbar autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:k_View_Space];
        [searchbar autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self withMultiplier:0.7];
        
        [segment autoPinEdge:ALEdgeLeading toEdge:ALEdgeTrailing ofView:searchbar withOffset:k_View_Space];
        [segment autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:k_View_Space];
        [segment autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:k_View_Space];
        [segment autoPinEdgeToSuperviewEdge:ALEdgeTrailing withInset:k_View_Space];
        
    }
    
    [searchbar resetViews];
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    // 模糊查找
    [self queryConditions];

}

-(void)segmentValueChange:(UISegmentedControl *)sender{
    
    NSLog(@"根据条件搜索");
    [self queryConditions];
    
}

-(void)queryConditions{

    NSString *searchString ;
//    if (searchbar.text.length == 0) {
//        searchString = @"";
//    }else{
//        searchString = searchbar.text;
//    }
    
    WSDictBean * currentSelectedBean ;
    NSString * segmentCondition ;
    if (segment.selectedSegmentIndex>= 0) {
        currentSelectedBean = _dictArray[segment.selectedSegmentIndex];
        segmentCondition = currentSelectedBean.Id;
    }else{
        segmentCondition = @"";
    }
    
    NSString * condition = [NSString stringWithFormat:@"%@;%@",segmentCondition,searchString];
    if ([self.delegate respondsToSelector:@selector(queryStoresFromDBWithConditions:)]) {
        [self.delegate queryStoresFromDBWithConditions:condition];
    }
}

@end
