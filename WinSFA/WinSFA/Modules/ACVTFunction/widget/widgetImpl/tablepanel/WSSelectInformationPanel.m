//
//  WSSelectPeoplePanel.m
//  WinSFA
//
//  Created by zhangke on 15/4/29.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSSelectInformationPanel.h"
#import "WSInterAction.h"
#import "I_W_BuildInfo.h"
#import "WSTableViewCell.h"
#import "WSConstant.h"
#import "WSAcvtTempView.h"
#import "WSPeopleListCell.h"
#import "WSPeopleContentView.h"
#import "I_W_DisplayValue.h"
#import "WSDataSourceManager.h"
#import "WSStoreBean.h"
#import "WSBaseModel.h"
#import "I_W_DataSource.h"
#import "WSBaseAcvtDBService.h"
#import "WSAcvtQstDisItem.h"
#import "WSVisitStoreAcvtDataTable.h"
#import "WSAcvtListDataItem.h"

@interface WSSelectInformationPanel ()<UITableViewDataSource,UITableViewDelegate,WSPeopleContentViewDelegate>{
    NSMutableArray* _selectArray;
    UITableView* tableview;
    BOOL showAction;
    NSInteger selectedIndex;
    
}
@property(nonatomic,weak)WSPeopleContentView *currentPeopleContentView;
@end



@implementation WSSelectInformationPanel
-(id)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    
    if (self) {
        
        
        
        return self;
    }
    return nil;
}


-(void)buildDisplayContent{
    
    [super buildDisplayContent];
    

    
    UIButton* button=[UIButton buttonWithType:UIButtonTypeCustom];
    
    UIImage* image=[UIImage imageForName:@"selectpeople"];
    
    [button setImage:image forState:UIControlStateNormal];
    button.frame=CGRectMake(self.width-  (INTERFACE_IS_PAD? 100 :50), 0, 40, 40);
    
    [self addSubview:button];
    
    [button addTarget:self action:@selector(gotoSelectPeopleVC) forControlEvents:UIControlEventTouchUpInside];
    
    tableview =[[UITableView alloc] initWithFrame:CGRectMake(0, self.height, self.width, 0) style:UITableViewStylePlain];
    
    tableview.delegate=self;
    
    tableview.dataSource=self;
    
    [self addSubview:tableview];
}

-(void)loadDataSource:(NSObject<I_W_DataSource> *)datasource{
    
    [super loadDataSource:datasource];
    
    _selectArray = (NSMutableArray *)[xdataSource getDataSourceFor:xbuildInfo];
  
    if (_selectArray && [_selectArray count]>0) {

        
        tableview.delegate=self;
        
        tableview.dataSource=self;
        
        [tableview reloadData];
        
        CGRect rect=self.frame;
        
        rect.size.height=self.height+44*[_selectArray count];
        
        CGRect rectsuper=self.superview.frame;
        
        rectsuper.size.height=self.superview.height+44*[_selectArray count];
        
        CGRect recttable=  tableview.frame;
        
        recttable.size.height=tableview.height+44*[_selectArray count];
        
        tableview.frame=recttable;

        [self revealCurrentViewWithAlph:1 viewFrame:rect andParentViewFrame:rectsuper resizeHight: [_selectArray count] * 44  andNeedResize:YES forRise:YES];

        
    }
    
}

-(void)loadBuildInfo:(NSObject<I_W_BuildInfo> *)buildInfo{
    
    [super loadBuildInfo:buildInfo];
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
    
    NSDictionary *displaycontent =[_selectArray objectAtIndex:[indexPath row]];
    
    [tableviewcell setCellContent:nil];
    
    [tableviewcell setCell_delegate:(id<WSWidgetDelegate>)self];
    
    WSPeopleContentView* contentView = (WSPeopleContentView*)[tableviewcell getContentView];
    
    contentView.contentViewDelegate = self;
    
    if(showAction){
   
        contentView.showAction =YES;
    
    }
    contentView.frame = WSRect(contentView.frame.origin.x, contentView.frame.origin.y, self.frame.size.width, contentView.frame.size.height);
    
    [tableviewcell loadDisplayContent:displaycontent];
    
   if(showAction){
       
        WSPeopleContentView* contentView = (WSPeopleContentView*)[tableviewcell getContentView];
        contentView.tag = [indexPath row];
        contentView.contentViewDelegate = self;
        contentView.currentStore=self.currentStore;
       
    }
    return tableviewcell;
}

-(void)generateURL:(WSPeopleContentView *)contentView
{
    selectedIndex = contentView.tag;
    
    self.currentPeopleContentView = contentView;
    
    if ([xbuildInfo getLuaScript] && [[xbuildInfo getLuaScript] length] > 0) {
        
        if ([self.delegate respondsToSelector:@selector(executeLuaScript:widget:)]) {
            
            [self.delegate executeLuaScript:xbuildInfo widget:self];
            
        }
    }
}

-(NSString *)getValueForParam:(NSString*)paramString
{
    if (selectedIndex > -1 && selectedIndex < [_selectArray count]) {
         NSDictionary *displaycontent =[_selectArray objectAtIndex:selectedIndex];
        if ([paramString isEqualToString:@"mobile"]) {
            WSAcvtListDataItem *acvtItem = (WSAcvtListDataItem *)displaycontent;
            for(WSAcvtQstDisItem* object in acvtItem.qstDisArray){
                if([object.isacvtname isEqualToString:@"4"]){
                    return object.acvtanswer;
                }
            }
        }else if ([paramString isEqualToString:@"genid"]){
            return [displaycontent allKeys].firstObject;
        }else if ([paramString isEqualToString:@"storeId"]){
            if (self.currentStore) {
                return self.currentStore.Id;
            }
        }
    }
    return nil;
}
-(void)pushIntoWebview:(NSString*)paramsString
{
    [self.currentPeopleContentView pushWebControllerWithURL:paramsString];

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
    
    WSStoreBean *modelId =  [[[WSDataSourceManager sharedInstance] currentActiveModel] currentStore];
    
    [interaction setExecute_class_param:modelId];
    
    [interaction setDirect_type:DIRECT_TYPE_PUSH];
    
    
    
    if ([delegate respondsToSelector:@selector(executeAnyOperationWith:)]) {
        
        [delegate performSelector:@selector(executeAnyOperationWith:) withObject:interaction];
        
    }
    
    
}

//1.返回选择的人，2.读完课件可以考试，3. 回传考试分数结果
- (void)loadComputeResult:(WSInterAction *)interAction{
    
    NSString* param = (NSString *)interAction.inner_param;
    

    
    if([param isEqualToString:@"select"]){
    
        NSArray *addedarray =(NSMutableArray *)interAction.execute_result;
        if ([addedarray count]<=0) {
            
            return;
        }
        
        NSMutableArray *array =  [self determinWhichNeedToBeAdd:(NSMutableArray *)interAction.execute_result];
        
        [_selectArray addObjectsFromArray:array];
        
        
        NSInteger cellNum=array.count;
        
        CGRect rect=self.frame;
        
        rect.size.height=self.height+44*cellNum;
        
        CGRect rectsuper=self.superview.frame;
        
        rectsuper.size.height=self.superview.height+44*cellNum;
        
        CGRect recttable=  tableview.frame;
        
        recttable.size.height=tableview.height+44*cellNum;
        
        tableview.frame=recttable;
        
        BOOL rise=cellNum>0;
        
        [self revealCurrentViewWithAlph:1 viewFrame:rect andParentViewFrame:rectsuper resizeHight: 44*cellNum  andNeedResize:YES forRise:rise];
        
        showAction=NO;
        
    }else if([param isEqualToString:@"showAction"]){
        
        
        showAction=YES;
        
    }else{
        
        
        
        //dic ->genid:分数
        //update
     
        
        NSDictionary* dic=(NSDictionary*)interAction.execute_result;
        NSString* genid=dic.allKeys.firstObject;
        NSString* score=dic.allValues.firstObject;
        
        for(WSAcvtListDataItem *acvtItem in _selectArray){
            
            if([acvtItem.genID isEqualToString:genid]){
                
                for(WSAcvtQstDisItem* object in acvtItem.qstDisArray){
                    
                    if ([object.isacvtname isEqualToString:@"6"]){
                        
                        object.acvtanswer = score;
                        
//                        [[WSAddStoreQstTable sharedTable] updateWithNames:@[@"opt_val"] values:@[object.opt_val==nil ? @"0" : object.opt_val] whereName:@[@"ans_id",@"titletype"] whereValue:@[genid,@"6"]];
                        
                        [[WSVisitStoreAcvtDataTable sharedTable] insertOrUpdateAcvtDataByGenId:genid storeId:nil acvtId:object.acvtId acvtQstId:object.acvtQstId value:object.acvtanswer == nil ? @"0":object.acvtanswer];
                        
                        break;
                    }
                }
            }
        }
    }
    
    [tableview setDataSource:self];
    
    [tableview setDelegate:self];
    
    [tableview reloadData];
    
}


-(void)refresh
{
    
    WSInterAction  *interaction =[[WSInterAction alloc] init];
    
    [interaction setAcvt_qust_id:[self.xbuildInfo getAcvtQstId]];
    
    interaction.inner_param=@"showAction";
    
    [self loadComputeResult:interaction];
    
}


-(void)executeInterAction:(WSInterAction *)interaction{
    
    [interaction  setAcvt_qust_id:[xbuildInfo getAcvtQstId]];
    
    if ([delegate respondsToSelector:@selector(executeAnyOperationWith:)]) {
        
        [delegate executeAnyOperationWith:interaction];
    }
    
}

-(NSObject *)getResultDirectly

{
    //手机号，分数
    //下发acvtdis 分数，本地也存更新，下发存，标题是6，

    NSMutableDictionary* uploadDic=[NSMutableDictionary dictionary];
    
    for(WSAcvtListDataItem *acvtItem in _selectArray){
        
        NSString* phone=nil;
        
        NSString* score=nil;
        
        for(WSAcvtQstDisItem* object in acvtItem.qstDisArray){
            if ([object.isacvtname isEqualToString:@"6"]){
                
                score=object.acvtanswer==nil ? @"" : object.acvtanswer;
            
            }else if ([object.isacvtname isEqualToString:@"4"]){
            
                phone=object.acvtanswer;
            
            }
        }
        [uploadDic setObject:score==nil ? @"" : score  forKey:phone];
    }
    return uploadDic;

}

-(NSMutableArray *)determinWhichNeedToBeAdd:(NSMutableArray *)array{

    for (int i=0; i<[_selectArray count]; i++) {
        
        NSMutableDictionary  *compdict = [_selectArray objectAtIndex:i];
        
        for (int j=0; j<[array count]; j++) {
            NSMutableDictionary *indict =[array objectAtIndex:j];
            
            if ([(NSString *)[[compdict allKeys] firstObject] isEqualToString:(NSString *)[[indict allKeys] firstObject]]) {
                
                [array removeObjectAtIndex:j];
                
            }
        }
    }
    return array;
    
}


@end
