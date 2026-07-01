//
//  WSPopUpSuggestStyleViewController.m
//  WinSFA
//
//  Created by HZH on 16/9/7.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSPopUpSuggestStyleViewController.h"
#import "WSSuggestTableInstance.h"
#import "UIView+Shake.h"

#define MainTintColor MAIN_TINT_COLOT
#define HPOPVIEWWIDTH 450
#define HPOPVIEWHEIGHT 164

@interface WSPopUpSuggestStyleViewController () <UITextFieldDelegate>
{
    UISegmentedControl *_styleSC;
    UITextField *_nameTF;
    // 模板类型 [01:菜式应用  02:配方应用]
    NSString *_sStyle;
}
@property (nonatomic, assign) CGSize viewSize;


@end

@implementation WSPopUpSuggestStyleViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = [UIColor whiteColor];
    _viewSize = CGSizeMake(0, 0);
    
    if ([_sType isEqualToString:@"01"]) {
        
        _viewSize = CGSizeMake(HPOPVIEWWIDTH, HPOPVIEWHEIGHT + 50);
        
    }else if ([_sType isEqualToString:@"02"]) {
        _viewSize = CGSizeMake(HPOPVIEWWIDTH, HPOPVIEWHEIGHT + 50);
        
    }
    
    if ([[[UIDevice currentDevice]systemVersion] floatValue] >= 8.0) {
        
        self.preferredContentSize = _viewSize;
        
    }else{
        
        self.view.superview.center = CGPointMake(550 , 1024 / 2);
        self.view.superview.size = _viewSize;
    }
    
    [self buildUIWithType:_sType];
    
    //默认sstype为0
    _sStyle = HSuggestTableForHomeModelStyleDish;
    
}

/**
 *  根据type创建不同的建议单
 */
- (void)buildUIWithType:(NSString *)type
{
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, _viewSize.width, 44)];
    titleLabel.backgroundColor = [UIColor grayColor];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font = [UIFont boldSystemFontOfSize:18.0];
    titleLabel.text = @"创建建议单";
    titleLabel.textAlignment = NSTextAlignmentCenter;
    
    
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 64, (_viewSize.width - 40)/3, 30)];
    nameLabel.backgroundColor = [UIColor clearColor];
    nameLabel.textColor = UIColorFromRGBWithAlpha(POP_STATIC_FONT_COLOR, 1);
    nameLabel.font = [UIFont systemFontOfSize:16.0];
    nameLabel.text = @"*  建议单名称:";
    
    _nameTF = [[UITextField alloc] initWithFrame:CGRectMake((_viewSize.width - 40)/3 + 20, 114, (_viewSize.width - 40)/3 * 2, 30)];
    UIView *blankView = [[UIView alloc] initWithFrame:CGRectMake(_nameTF.frame.origin.x,_nameTF.frame.origin.y, 8.0, _nameTF.frame.size.height)];
    _nameTF.leftView = blankView;
    _nameTF.leftViewMode =UITextFieldViewModeAlways;  // 这里是用来设置leftView的实现时机的
    
    _nameTF.placeholder = @"请输入名称";
    _nameTF.background = [UIImage imageNamed:@"input"];
    _nameTF.tintColor = UIColorFromRGBWithAlpha(POP_MAIN_THEME_COLOR, 1);
    
    
    if ([type isEqualToString:@"01"]) {
        
        
        UILabel *staticLabel01 = [[UILabel alloc] initWithFrame:CGRectMake(20, 64, (_viewSize.width - 40)/3, 30)];
        staticLabel01.backgroundColor = [UIColor clearColor];
        staticLabel01.textColor = UIColorFromRGBWithAlpha(POP_STATIC_FONT_COLOR, 1);
        staticLabel01.font = [UIFont systemFontOfSize:16.0];
        staticLabel01.text = @"    选择模板:";
        
        _styleSC = [[UISegmentedControl alloc] initWithFrame:CGRectMake((_viewSize.width - 40)/3 + 20, 64, (_viewSize.width - 40)/3 * 2, 30)];
        
        _styleSC.tintColor = UIColorFromRGBWithAlpha(POP_MAIN_THEME_COLOR, 1);
        NSDictionary *dic1 = [NSDictionary dictionaryWithObjectsAndKeys:UIColorFromRGBWithAlpha(POP_MAIN_THEME_COLOR, 1),
                              NSForegroundColorAttributeName,
                              [UIFont boldSystemFontOfSize:16],
                              NSFontAttributeName,nil];
        
        [_styleSC setTitleTextAttributes:dic1 forState:UIControlStateNormal];
        [_styleSC insertSegmentWithTitle:@"菜式应用" atIndex:0 animated:NO];
        [_styleSC insertSegmentWithTitle:@"配方应用" atIndex:1 animated:NO];
        _styleSC.selectedSegmentIndex = 0;
        [_styleSC addTarget:self action:@selector(styleSegmentControlValueChanged:) forControlEvents:UIControlEventValueChanged];
        
        [self.view addSubview:_styleSC];
        [self.view addSubview:staticLabel01];
        
        [nameLabel setFrame:CGRectMake(20, 114, (_viewSize.width - 40)/3, 30)];
        [_nameTF setFrame:CGRectMake((_viewSize.width - 40)/3 + 20, 114, (_viewSize.width - 40)/3 * 2, 30)];
        
    }else if ([type isEqualToString:@"02"]){
        
        UILabel *staticLabel01 = [[UILabel alloc] initWithFrame:CGRectMake(20, 64, (_viewSize.width - 40)/3, 30)];
        staticLabel01.backgroundColor = [UIColor clearColor];
        staticLabel01.textColor = UIColorFromRGBWithAlpha(POP_STATIC_FONT_COLOR, 1);
        staticLabel01.font = [UIFont systemFontOfSize:16.0];
        staticLabel01.text = @"    选择模板:";
        
        _styleSC = [[UISegmentedControl alloc] initWithFrame:CGRectMake((_viewSize.width - 40)/3 + 20, 64, (_viewSize.width - 40)/3 * 2, 30)];
        
        _styleSC.tintColor = UIColorFromRGBWithAlpha(POP_MAIN_THEME_COLOR, 1);
        NSDictionary *dic1 = [NSDictionary dictionaryWithObjectsAndKeys:UIColorFromRGBWithAlpha(POP_MAIN_THEME_COLOR, 1),
                              NSForegroundColorAttributeName,
                              [UIFont boldSystemFontOfSize:16],
                              NSFontAttributeName,nil];
        
        [_styleSC setTitleTextAttributes:dic1 forState:UIControlStateNormal];
        [_styleSC insertSegmentWithTitle:@"批发" atIndex:0 animated:NO];
        [_styleSC insertSegmentWithTitle:@"终端" atIndex:1 animated:NO];
        _styleSC.selectedSegmentIndex = 0;
        [_styleSC addTarget:self action:@selector(styleSegmentControlValueChanged:) forControlEvents:UIControlEventValueChanged];
        
        [self.view addSubview:_styleSC];
        [self.view addSubview:staticLabel01];
        
        [nameLabel setFrame:CGRectMake(20, 114, (_viewSize.width - 40)/3, 30)];
        [_nameTF setFrame:CGRectMake((_viewSize.width - 40)/3 + 20, 114, (_viewSize.width - 40)/3 * 2, 30)];
    }
    
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelBtn setFrame:CGRectMake(40, _viewSize.height - 50, _viewSize.width/2 - 80, 30)];
    [cancelBtn setTitle:@"cancel_label" forState:UIControlStateNormal];
    [cancelBtn setTitleColor:UIColorFromRGBWithAlpha(POP_MAIN_THEME_COLOR, 1) forState:UIControlStateNormal];
    [cancelBtn.layer setMasksToBounds:YES];
    cancelBtn.layer.borderColor = [UIColor lightGrayColor].CGColor;
    [cancelBtn.layer setBorderWidth:1.0];
    cancelBtn.layer.cornerRadius = 5.0;

    [cancelBtn addTarget:self action:@selector(cancelBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *confirmBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [confirmBtn setFrame:CGRectMake(_viewSize.width/2 + 40, _viewSize.height - 50, _viewSize.width/2 - 80, 30)];
    [confirmBtn.layer setMasksToBounds:YES];
    confirmBtn.layer.cornerRadius = 5.0;
    [confirmBtn setBackgroundColor:UIColorFromRGBWithAlpha(POP_MAIN_THEME_COLOR, 1)];
    [confirmBtn setTitle:@"confirm" forState:UIControlStateNormal];
    [confirmBtn addTarget:self action:@selector(confirmBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    
    [self.view addSubview:cancelBtn];
    [self.view addSubview:confirmBtn];
    [self.view addSubview:nameLabel];
    [self.view addSubview:_nameTF];
    [self.view addSubview:titleLabel];
}

/**
 *  标签切换
 */
- (void)styleSegmentControlValueChanged:(id)sender
{
    UISegmentedControl *sc = (UISegmentedControl *)sender;
    NSInteger selectedIndex = sc.selectedSegmentIndex;
    
    if (selectedIndex == 0) {
        _sStyle = HSuggestTableForHomeModelStyleDish;
    }else if (selectedIndex == 1){
        _sStyle = HSuggestTableForHomeModelStyleFormula;
    }
}

/**
 *  取消按钮
 */
- (void)cancelBtnClicked:(id)sender
{
    [_nameTF resignFirstResponder];
    
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}

/**
 *  确定按钮
 */
- (void)confirmBtnClicked:(id)sender
{
    
    if ([_nameTF.text isEqualToString:@""]) {
        [_nameTF shakeView];
        return;
    }
    
    [_nameTF resignFirstResponder];
    
    
    if ([_sType isEqualToString:@"01"]) {
        
        [self dismissViewControllerAnimated:YES completion:^{
            
            if (_suggestName) {
                _suggestName(_nameTF.text,_sStyle);
            }
            
        }];

    }else if ([_sType isEqualToString:@"02"]){
        
        [self dismissViewControllerAnimated:YES completion:^{
            
            if (_suggestName) {
                _suggestName(_nameTF.text,nil);
            }
            
        }];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
