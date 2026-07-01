//
//  WSTemplateClickController.m
//  WinSFA
//
//  Created by huzepei on 16/8/23.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSTemplateClickController.h"
#import "WSRichItemModel.h"
#import "PureLayout.h"
#import "WSSearchTableViewCell.h"

#define TemplateClickCELL @"TemplateClickCELL"

@interface WSTemplateClickController ()<UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *titleTextField;

@property (strong, nonatomic) UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIImageView *titleBar;

@end

@implementation WSTemplateClickController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    _tableView = [[UITableView alloc] init];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    [_tableView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_titleBar];
    [_tableView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeTop];
    
//    [_tableView registerClass:[WSSearchTableViewCell class] forCellReuseIdentifier:TemplateClickCELL];
    
    [_titleTextField setText:_name];
}

-(void)setName:(NSString *)name
{
    _name = name;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)shutDown:(id)sender {
    
    NSString *str = _titleTextField.text;
    if ([str isEqualToString:@""]) {
        str = _name;
    }
    
    if (_changeTitle) {
        _changeTitle(str);
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WSSearchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TemplateClickCELL];
    if(!cell){
        
        cell = [[WSSearchTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TemplateClickCELL withStyle:WSSearchTableViewCellStyleNone];
    }
    
    WSRichItemModel *im =  _dataArray[indexPath.row];
    
    cell.model = im;

    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
     return 60.0;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataArray.count;
}
@end
