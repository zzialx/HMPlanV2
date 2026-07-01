//
//  WSSelectPeoplePanel.m
//  WinSFA
//
//  Created by zhangke on 15/4/29.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSSelectPeoplePanel.h"
#import "WSInterAction.h"
#import "I_W_BuildInfo.h"
#import "WSTableViewCell.h"
#import "WSConstant.h"
#import "WSAcvtTempView.h"
#import "WSPeopleListCell.h"
#import "WSPeopleContentView.h"


@interface WSSelectPeoplePanel ()<UITableViewDataSource,UITableViewDelegate>{
    NSArray* _selectArray;
    UITableView* tableview;
}

@end



@implementation WSSelectPeoplePanel

-(id)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    
    if (self) {
        _selectArray=[NSArray array];
        
        return self;
    }
    return nil;
}


-(void)buildDisplayContent{
    
    [super buildDisplayContent];
    
    UIButton* button=[UIButton buttonWithType:UIButtonTypeSystem];
    
    [button setTitle:@"选择" forState:UIControlStateNormal];
    
    button.frame=CGRectMake(self.frame.size.width-120, titleLabel.origin.y, 100, titleLabel.height);
    
    [self addSubview:button];
    
    [button addTarget:self action:@selector(gotoSelectPeopleVC) forControlEvents:UIControlEventTouchUpInside];
    
    
    tableview =[[UITableView alloc] initWithFrame:CGRectMake(0, self.height-10, self.width, 0) style:UITableViewStylePlain];
    tableview.delegate=self;
    tableview.dataSource=self;
    [self addSubview:tableview];
    tableview.scrollEnabled=NO;

    
}



#pragma mark -
#pragma mark UITableViewDataSource mehtod
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_selectArray==nil) {
        
        return 0;
    }
    
    return [_selectArray count];
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *cellkey=@"cellkey";
    
    WSTableViewCell  *tableviewcell =[tableView dequeueReusableCellWithIdentifier:cellkey];
    
    if (tableviewcell==nil) {
        
        tableviewcell = [[WSTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellkey andAcvtType:QST_TYPE_DA];
        tableviewcell.selectionStyle=UITableViewCellSelectionStyleNone;
    }
    
    [tableviewcell clearDisplayContent];
    
    
    NSObject<I_W_Cell> *displaycontent =[_selectArray objectAtIndex:[indexPath row]];
    
    [tableviewcell setCellContent:nil];
    
    [tableviewcell setCell_delegate:self];
    
    [tableviewcell loadDisplayContent:displaycontent];
    
    
    WSPeopleContentView* contentView=[tableviewcell getContentView];
    contentView.actionButton.hidden=NO;
    
    
    return tableviewcell;
}


-(void)revealCurrentViewWithAlph:(float)alph viewFrame:(CGRect)frame andParentViewFrame:(CGRect)pframe resizeHight:(CGFloat)hight andNeedResize:(BOOL)needResize forRise:(BOOL)forrise{
    
    [tableview setAlpha:alph];
    self.frame = frame;
    self.superview.frame = pframe;
    
    
    [(WSAcvtTempView *)self.superview  setRisehight:hight];
    
    [(WSAcvtTempView *)self.superview setISneedlayout:needResize];
    
    [(WSAcvtTempView *)self.superview  setIsrise:forrise];
    
    [(WSAcvtTempView *)self.superview  setResizeview:self];
    
    [self.superview layoutSubviews];
}




-(void)gotoSelectPeopleVC
{
    WSInterAction  *interaction =[[WSInterAction alloc] init];
    
    [interaction setAcvt_qust_id:[xbuildInfo getAcvtQstId]];
    
    [interaction setExecute_class:@"WSSelectInformationViewController"];
    
    [interaction setDirect_type:DIRECT_TYPE_PUSH];
    
    if ([delegate respondsToSelector:@selector(executeAnyOperationWith:)]) {
     
        [delegate performSelector:@selector(executeAnyOperationWith:) withObject:interaction];
    
    }
    
    
}

- (void)loadComputeResult:(WSInterAction *)interAction{
    
    NSInteger cellNum=[(NSArray*)interAction.execute_result count]-_selectArray.count;
    
    _selectArray=[NSArray arrayWithArray:interAction.execute_result];
    
    
    CGRect rect=self.frame;
    rect.size.height=self.height+44*cellNum;
    
    CGRect rectsuper=self.superview.frame;
    rectsuper.size.height=self.superview.height+44*cellNum;

    CGRect recttable=  tableview.frame;
    recttable.size.height=tableview.height+44*cellNum;
    tableview.frame=recttable;
    
    [self revealCurrentViewWithAlph:1 viewFrame:rect andParentViewFrame:rectsuper resizeHight:44*cellNum andNeedResize:YES forRise:YES];
    
    [tableview reloadData];

    
}

-(void)executeInterAction:(WSInterAction *)interaction{
    
    
    if ([delegate respondsToSelector:@selector(executeAnyOperationWith:)]) {
        
        [delegate executeAnyOperationWith:interaction];
    }
    
}


@end
