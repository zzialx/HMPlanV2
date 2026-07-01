//
//  WSTableView.m
//  WinSFA
//
//  Created by winchannel on 15/7/28.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSBaseTableView.h"
#import "I_W_DataSource.h"
#import "WSStoreTableViewCell.h"
#import "WSStoreBean.h"
#import "WSInterAction.h"


@implementation WSBaseTableView
@synthesize table_data;
@synthesize hiddendetail;
-(id)initWithFrame:(CGRect)frame{

    self = [super initWithFrame:frame];

    if (self) {
        
        [self buildDisplayContent];
        
        return self;
    }
    return nil;
}

-(void)loadBuildInfo:(NSObject<I_W_BuildInfo> *)buildInfo{
    
    [super loadBuildInfo:buildInfo];
}


-(void)buildDisplayContent{
    
    if (!([[UIDevice currentDevice] systemVersionByFloat] < 7.0)  ) {
        
        table_view= [[UITableView alloc]initWithFrame:self.bounds style:UITableViewStyleGrouped];
    
    } else {
        
        table_view= [[UITableView alloc]initWithFrame:self.bounds style:UITableViewStylePlain];
    
    }
    
    [table_view setBackgroundColor:[UIColor whiteColor]];
    
    table_view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    table_view.delegate =self;
    
    [self addSubview:table_view];
    
    
}

#pragma mark -
#pragma mark UITableViewDataSource method
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell   *tcell =  [self tableView:table_view cellForRowAtIndexPath:indexPath];
    
    return   tcell.frame.size.height;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if ([table_data count]<=0) {
        
        return 0;
    }
    
    return [table_data count];
}



-(UITableViewCell  *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *cell_key = @"cell_key";
    
    WSStoreTableViewCell *tcell  = [tableView dequeueReusableCellWithIdentifier:cell_key];
    
    if (tcell==nil) {
        
        tcell = [[WSStoreTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cell_key andCellWidth:tableView.frame.size.width];
        tcell.delegate = self ;
    }
    
    tcell.delegate = self;
    
    WSStoreBean  *storeBean = [table_data objectAtIndex:[indexPath row]];
    
    [tcell clearDataContent];
    tcell.shortCutArray = self.shortCutArray ;
    
    [tcell setTagFrame:CGRectZero withContentWidth:0 withContent:nil withShortCutArray:self.shortCutArray andRow:1];
    [tcell showShortCutPanel:self.shortCutArray withStorBean:storeBean];
    
    [tcell loadDisplayContent:storeBean];
    
    if (hiddendetail) {
        
        [tcell showAccessButton:@"0"];
    }
    
    return tcell;
    
}


#pragma mark -
#pragma mark UITableViewDelegate method

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];//选中后的反显颜色即刻消失
    
    WSStoreBean  *storeBean = [table_data objectAtIndex:[indexPath row]];
    
    WSInterAction *interaction  = [[WSInterAction alloc] init];
    
    [interaction setInner_id:@"ws_service_jump_to_store"];
    
    [interaction setExecute_class:@"WSStoreService"];
    
    [interaction setDirect_type:DIRECT_TYPE_SERVICE_METHOD];
    
    [interaction setExecute_method_param:interaction];
    
    [interaction setInner_param:storeBean];
    
    [interaction setExecute_method_ns:@"generateJumpInfo:"];
    
    if ([self.delegate respondsToSelector:@selector(executeAnyOperationWith:)]) {
        
        
        [self.delegate executeAnyOperationWith:interaction];
        
    }
    
    
}


-(void)loadDataSource:(NSObject<I_W_DataSource> *)datasource{
    
    [super loadDataSource:datasource];
    
    NSMutableArray *datacontent = (NSMutableArray *)[xdataSource getDataSourceFor:xbuildInfo];
    
    [self loadContent:datacontent];
    
}

-(void)loadContent:(NSObject *)content{
    
    [self loadData:content];

}


-(void)loadData:(NSObject *)content{
    
    table_data = (NSMutableArray *)content;
    
    table_view.dataSource = self;
    
    table_view.delegate = self;
    
    [table_view reloadData];
    
}

#pragma mark -
#pragma mark  WSStoreTableViewCellDelegate method

-(void)sendDetailInfo:(NSObject<I_W_Cell> *)obj{
    
    if ([self.delegate respondsToSelector:@selector(executeAnyOperationWith:)]) {
    
        WSInterAction  *interaction =[[WSInterAction alloc] init];
        
        [interaction setInner_id:@"ws_service_view_detail_Info"];
        
        [interaction setExecute_class:@"WSStoreVisitViewController"];
        
        [interaction  setDirect_type:0];
        
        [interaction setExecute_method_param:interaction];
        
        [interaction setInner_param:obj];
        
        [interaction setExecute_method_ns:@"viewDetailInfo:"];
        
        [self.delegate executeAnyOperationWith:interaction];
        
    }
    
    
}
- (void)selectListTableViewCell:(WSStoreTableViewCell *)cell withSlectFunsbean:(WSFuncsBean *)bean withStoreBean:(WSStoreBean *)storeBean{
    [self.delegate selectWithShortCutFunsbean:bean withStoreBean:storeBean];

}

@end
