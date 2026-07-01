//
//  WSTableView.m
//  WinSFA
//
//  Created by winchannel on 15/4/17.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSTableView.h"
#import "I_W_DataSource.h"
#import "I_W_BuildInfo.h"
#import "I_W_Cell.h"
#import "WSTableViewCell.h"
#import "WSConstant.h"
#import  "WSDevieceUtil.h"
#import "WSAcvtQstDisItem.h"
#import "WSAcvtListDataItem.h"


#define CELL_MAP_CONFIG  [[NSBundle mainBundle] pathForResource:@"cellMapping" ofType:@"plist"]
#define CELL_WIDTH (INTERFACE_IS_PAD ? self.frame.size.width: 320)


@implementation WSTableView
@synthesize tableview;
@synthesize tabledelegate;
@synthesize acvtType;
@synthesize dataarray;

-(id)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    
    if (self) {
        
        cellmapping =[[NSMutableDictionary alloc] initWithContentsOfFile:CELL_MAP_CONFIG];
        
        self.selectMode = singleSelect;
        
        self.filterArray=[NSMutableArray array];
        
        return self;
    }
    return nil;
}



-(void)buildDisplayContent{
    
    [super buildDisplayContent];
    
    tableview =[[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];

    [self addSubview:tableview];
    
    
    
}

-(void)loadBuildInfo:(NSObject<I_W_BuildInfo> *)buildInfoP{
    
    [super loadBuildInfo:buildInfoP];
    
}

-(void)loadDataSource:(NSObject<I_W_DataSource> *)datasource{
    
    [super loadDataSource:datasource];
    
    dataarray = (NSMutableArray *)[xdataSource getDataSourceFor:xbuildInfo];
    
    
    if([dataarray  count]>0){
    
        [tableview setDataSource:self];
    
        [tableview setDelegate:self];
        
        [tableview reloadData];
    
    }
}

-(void)loadValidator:(NSObject<I_W_Validate> *)validateobjin{
    
    [super loadValidator:validateobjin];
    
}


#pragma mark -
#pragma mark UITableViewDataSource mehtod
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (dataarray==nil) {
        
        return 0;
    }
    
    return [dataarray count];
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *cellkey=@"cellkey";
  
    WSTableViewCell  *tableviewcell =[tableview dequeueReusableCellWithIdentifier:cellkey];
    
    if (tableviewcell==nil) {
        
        tableviewcell = [[WSTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellkey andAcvtType:acvtType];
        
        tableviewcell.selectionStyle=UITableViewCellSelectionStyleNone;
        
        [tableviewcell setFrame: WSRect(tableviewcell.frame.origin.x,tableviewcell.frame.origin.y,CELL_WIDTH, tableviewcell.contentView.frame.size.height)];
    }
    
    [tableviewcell clearDisplayContent];

    
    NSObject<I_W_Cell> *displaycontent =[dataarray objectAtIndex:[indexPath row]];
    
    if([displaycontent respondsToSelector:@selector(getCellContentArray)]){
        
        [tableviewcell setCellContent:[[displaycontent getCellContentArray] mutableCopy]];
   
    }else{
    
        [tableviewcell setCellContent:nil];
    
    }
    
    [tableviewcell setCell_delegate:self];
    
    [tableviewcell loadDisplayContent:displaycontent];
  
    if ([WSDevieceUtil getOsVersionNumber]<7.0) {
        
           [tableviewcell setFrame: WSRect(tableviewcell.frame.origin.x,tableviewcell.frame.origin.y,CELL_WIDTH, tableviewcell.contentView.frame.size.height)];
    }
    
    
    tableviewcell.accessoryType=UITableViewCellAccessoryNone;
    if([self.filterArray containsObject:displaycontent]){
        tableviewcell.accessoryType=UITableViewCellAccessoryCheckmark;

    }
    
    
    return tableviewcell;
}


#pragma mark -
#pragma mark UITableViewDelegate method

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSObject  *itemobject = [dataarray objectAtIndex:indexPath.row];
    WSTableViewCell  *tcell =(WSTableViewCell  *)[tableview cellForRowAtIndexPath:indexPath];

    if(self.selectMode==singleSelect){
        
        
        if ([tabledelegate respondsToSelector:@selector(sendSelectedCell:andSelectedItem:)]) {
            
            [tabledelegate sendSelectedCell:tcell andSelectedItem:itemobject];
            
        }
    }else{
        
        
        if ([self determinedNeedToAdd:itemobject]) {
            
            
            NSPredicate* pre=[NSPredicate predicateWithFormat:@"self==%@",itemobject];
            
            NSArray* array=[self.filterArray filteredArrayUsingPredicate:pre];
            
            if(array.count==0){
                
                [self.filterArray addObject:itemobject];
                tcell.accessoryType=UITableViewCellAccessoryCheckmark;
                
            }else{
                
                [self.filterArray removeObject:itemobject];
                tcell.accessoryType=UITableViewCellAccessoryNone;
                
            }
        }
        
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    WSTableViewCell  *tcell = (WSTableViewCell  *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
    
    return tcell.frame.size.height;
    
}


#pragma mark -
#pragma mark WSWidgetDelegate method

-(void)executeInterAction:(WSInterAction *)interaction{

    if ([tabledelegate respondsToSelector:@selector(executeInterAction:)]) {
        
        [tabledelegate executeInterAction:interaction];
        
    }
}

////////////////////////////////////////////////////////////////////////////////////
-(BOOL)determinedNeedToAdd:(NSObject *)itemObject{
    
    WSAcvtListDataItem *acvtItem =(WSAcvtListDataItem *)itemObject;
    BOOL needAdd=NO;
    
        
    for (WSAcvtQstDisItem *obj in acvtItem.qstDisArray)  {
                
        if ([[obj isacvtname] isEqualToString:@"6"]) {
            
            if ([obj acvtanswer]==nil || [[obj acvtanswer] isEqualToString:@"-1"] ||  [[obj acvtanswer] isEqualToString:@""]) {
                
                return YES;
                
            }else{
                
                return NO;
            }

        }
        
    }
    
    return needAdd;
    
}
//////////////////////////////////////////////////////////////////////////////////

@end
