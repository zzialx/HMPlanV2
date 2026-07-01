//
//  WSHomeProDetails.m
//  WinSFA
//
//  Created by huzepei on 16/9/10.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSHomeProDetails.h"
#import "WSSuggestHome.h"

@interface WSHomeProDetails()


@property (weak, nonatomic) IBOutlet UILabel *attributeLabelOne;
@property (weak, nonatomic) IBOutlet UILabel *attributeLabelTwo;

@property (weak, nonatomic) IBOutlet UILabel *unitLabelOne;

@property (weak, nonatomic) IBOutlet UILabel *unitLabelTwo;

@end

@implementation WSHomeProDetails

+ (instancetype)homeProductDetailView
{
    return [[[NSBundle mainBundle] loadNibNamed:@"WSHomeProDetails" owner:self options:nil] lastObject];
}

-(void)setType:(NSString *)type
{
    if ([type isEqualToString:@"1"]) { //菜式
        
        _attributeLabelOne.text = @"* 单位成本";
        _unitLabelOne.text = @"* 产品属性";
        
    }
    if ([type isEqualToString:@"2"]){
        
        _attributeLabelOne.text = @"* 单位成本";
        _unitLabelOne.text = @"* 产品属性";
    }
    
    if([type isEqualToString:@"3"]){
        
        _attributeLabelOne.text = @"* 总成本（元）";
        _unitLabelOne.text = @"* 产品属性";
    }
}

-(void)setSp:(WSSuggestHomePro *)sp
{
    _sp = sp;
    if (_sp.memo4.length != 0) {
        _unitLabelTwo.text = _sp.memo4;
    }else{
        _unitLabelTwo.text = @"empty_instruction_sheet_label";
    }
    
    _attributeLabelTwo.text = [NSString stringWithFormat:@"%@元",_sp.homeCost];
}

-(void)setFormulaSp:(WSSuggestHomePro *)formulaSp
{
    _formulaSp = formulaSp;
    
    if (_formulaSp.memo4.length != 0) {
        _unitLabelTwo.text = _formulaSp.memo4;
    }else{
        _unitLabelTwo.text = @"empty_instruction_sheet_label";
    }
    _attributeLabelTwo.text = [NSString stringWithFormat:@"%@元",_formulaSp.homeCost];

}
//自制配方的模型
-(void)setRecipesSp:(WSSuggestHomePro *)recipesSp
{
    _recipesSp = recipesSp;
    
    if (_recipesSp.memo4.length != 0) {
        _unitLabelTwo.text = _recipesSp.memo4;
    }else{
        _unitLabelTwo.text = @"empty_instruction_sheet_label";
    }
    
    _attributeLabelTwo.text = [NSString stringWithFormat:@"%@元",_recipesSp.sumCost];
}

@end
