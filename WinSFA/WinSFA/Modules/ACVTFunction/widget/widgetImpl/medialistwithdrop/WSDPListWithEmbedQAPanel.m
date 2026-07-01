//
//  WSMediaListPanel.m
//  WinSFA
//
//  Created by winchannel on 15/4/20.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSDPListWithEmbedQAPanel.h"
#import "WSOpenCloseBtn.h"
#import "WSConstant.h"
#import "WSTableView.h"
#import "WSTableViewCell.h"
#import "WSAcvtTempView.h"
#import "I_W_BuildInfo.h"
#import "WidgetConstant.h"
#import "WSInterAction.h"
#import "WSCellContentView.h"
#import "WSCellContentViewFactory.h"
#import "I_W_Cell.h"
#import "WSInterActionForTableCell.h"
#import "IAttachment.h"
#import "WSEnvrionment.h"



#define TABLE_HIGHT (INTERFACE_IS_PAD ? 485.5 : 356.5)
@interface WSDPListWithEmbedQAPanel()
{
    BOOL isCompleteAllItsTask;

}
@end

@implementation WSDPListWithEmbedQAPanel

-(id)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if (self) {
        
        oldrect = frame;
        
        viewdict=[[NSMutableDictionary alloc] init];
        
        isCompleteAllItsTask = NO;
        
        
        return self;
    }
    return nil;
    
}

-(void)buildDisplayContent{
    
    [super buildDisplayContent];

    
    UIImage  *openimg = [UIImage scaledImageForName:@"downarrow" ofType:@"png"];
    
    UIImage  *closeimg = [UIImage scaledImageForName:@"uparrow" ofType:@"png"];
    
    openclosebtn=[[WSOpenCloseBtn alloc] initWithFrame:WSRect(self.frame.size.width-30.0,5.0,30.0,30.0) normalimg:closeimg hightlightimg:openimg];
    
    openclosebtn.delegate = self;
    
    [openclosebtn setTouchable:YES];
    
    [self addSubview:openclosebtn];
    
    contentview =[[UIView alloc] initWithFrame:WSRect(0.0, self.frame.size.height, self.frame.size.width, 0.0)];
    
    [self addSubview:contentview];
    
    tableview =[[WSTableView alloc] initWithFrame:WSRect(0.0,contentview.frame.origin.y+contentview.frame.size.height,self.frame.size.width,TABLE_HIGHT)];
    
    [tableview setAcvtType:[xbuildInfo getWidgetId]];//设置acvt的类型
    
    [tableview setTabledelegate:self];
    
    tableview.tabledelegate = self;
    
    [tableview setAlpha:0.0];
    
    [self addSubview:tableview];
    
    [tableview loadBuildInfo:xbuildInfo];

    [tableview buildDisplayContent];
    
    resultInterActionsMap=[[NSMutableDictionary alloc] init];
   
}

-(void)loadBuildInfo:(NSObject<I_W_BuildInfo> *)buildInfoP{
    
    [super loadBuildInfo:buildInfoP];
}

-(void)loadDataSource:(NSObject<I_W_DataSource> *)datasource{
    
    
    [super loadDataSource:datasource];
    
    [tableview loadDataSource:datasource];
    
    
}

#pragma mark -
#pragma mark WSBaseWidgetDelegate method
-(void)forOperation:(BOOL)openornot{
    
    if (openornot) {
        parentViewOldRect= self.superview.frame;
        

        [self revealCurrentViewWithAlph:1.0 viewFrame:WSRect(self.frame.origin.x, self.frame.origin.y, self.frame.size.width,self.frame.size.height+tableview.frame.size.height)
         
                     andParentViewFrame:WSRect(self.superview.frame.origin.x, self.superview.frame.origin.y, self.superview.frame.size.width, self.superview.frame.size.height+tableview.frame.size.height)
                            resizeHight:tableview.frame.size.height andNeedResize:YES forRise:YES];
        
        
    }else{

        [self revealCurrentViewWithAlph:0.0
                              viewFrame:oldrect
                     andParentViewFrame:parentViewOldRect
                            resizeHight:-tableview.frame.size.height
                          andNeedResize:YES
                                forRise:NO];
        
    }
    
}

-(void)revealCurrentViewWithAlph:(float)alph viewFrame:(CGRect)frame andParentViewFrame:(CGRect)pframe resizeHight:(CGFloat)hight andNeedResize:(BOOL)needResize forRise:(BOOL)forrise{
    
    [tableview setAlpha:alph];
    self.frame = frame;
    self.superview.frame = pframe;
    
    [self.superview layoutSubviews];
}

#pragma mark -
#pragma mark WSTableViewDelegate method

-(void)sendSelectedCell:(WSTableViewCell *)mycell andSelectedItem:(NSObject *)item{
   
    if (selectedContentView != nil) {
        
        [viewdict removeObjectForKey:[selectedContentView assignedViewId]];
        
        [selectedContentView removeFromSuperview];
        
    }
    
    resultobject = item;
    
    NSObject<I_W_Cell> *buildInfo= (NSObject<I_W_Cell> *)resultobject;
    
    [[WSCellContentViewFactory shareInstance] setParentAcvtType:[xbuildInfo getWidgetId]];
    
    [[WSCellContentViewFactory shareInstance] setDefaultWidth:self.frame.size.width];
    
    selectedContentView = [[WSCellContentViewFactory shareInstance] createWidgetByWidgetInfo:(NSMutableArray *)[buildInfo getCellContentArray]];
    
    [selectedContentView setFrame:WSRect(0, 0, self.frame.size.width, selectedContentView.frame.size.height)];
    
    [selectedContentView loadDisplayContent:buildInfo];
    
    selectedContentView.delegate  = self;
    
    contentview.frame =WSRect(contentview.frame.origin.x, titleLabel.frame.origin.y+titleLabel.frame.size.height+1.0, selectedContentView.frame.size.width, selectedContentView.frame.size.height);
  
    [contentview addSubview:selectedContentView];
    
    [selectedContentView resetViewContent];
    
    [viewdict setObject:selectedContentView forKey:[selectedContentView assignedViewId]];
    
    float risehight =0.0;
    
    self.frame = WSRect(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, titleLabel.frame.origin.y+titleLabel.frame.size.height+selectedContentView.frame.size.height);
    
    if (oldrect.size.height<self.frame.size.height) {
        
         risehight = tableview.frame.size.height-(self.frame.size.height-oldrect.size.height)+10.0;
    
    }else{
        
        risehight = tableview.frame.size.height-(oldrect.size.height-self.frame.size.height)+10.0;
    
    }
    
    oldrect = self.frame;
    
    parentViewOldRect= WSRect(parentViewOldRect.origin.x, parentViewOldRect.origin.y, parentViewOldRect.size.width, parentViewOldRect.size.height+risehight);
    
    tableview.frame =WSRect(0.0,contentview.frame.origin.y+contentview.frame.size.height,self.frame.size.width,TABLE_HIGHT);
        [openclosebtn setIsOpen:YES];

    [self revealCurrentViewWithAlph:0.0
                          viewFrame:oldrect
                 andParentViewFrame:parentViewOldRect
                        resizeHight:risehight
                      andNeedResize:YES forRise:NO];

       
    if ([selectedContentView respondsToSelector:@selector(onChangeEvent)]) {
            
            [selectedContentView onChangeEvent]; //发生改变时调用
            
    }
}

-(void)updateContent:(NSObject *)content{
            
    WSInterAction  *interaction = (WSInterAction *)content;
    
    WSCellContentView  *contentView= [viewdict objectForKey:[interaction viewId]];

    if (contentview!=nil) {
                
       [contentView updateContent:content];
                
    }
    
}

-(void)loadComputeResult:(WSInterAction *)interAction{

    [super loadComputeResult:interAction];
    
    //需要重构
    [resultInterActionsMap setObject:interAction forKey:[(WSInterActionForTableCell *)interAction subacvtId]];
    
    if ([self needTrigRelationInfo]) {
        
        [self completeAllItsTask];
    
    }
}

#pragma mark -
#pragma mark WSTableViewDelegate method

-(void)executeInterAction:(WSInterAction *)interaction{
    
    [interaction setAcvt_qust_id:[xbuildInfo getAcvtQstId]];
    
        
    if ([delegate respondsToSelector:@selector(executeInterAction:)]) {
        
        [delegate executeInterAction:interaction];
        
    }

    
}


-(WSCellContentView *)findSubViewByViewId:(NSString *)viewId{
    
    NSArray  *array = [contentview subviews];
    
    for (int i=0; i<[array count]; i++) {
        
        WSCellContentView  *contentView =[array objectAtIndex:i];
        
        if ([[contentView  assignedViewId] isEqualToString:viewId]) {
            
            return contentView;
        }
    }
    
    return nil;
}

-(void) completeAllItsTask{

    isCompleteAllItsTask = YES;
    
    UIAlertView  *alertview =[[UIAlertView alloc] initWithTitle:@"" message:@"沟通结束，请选择人员进行答题" delegate:self cancelButtonTitle:nil otherButtonTitles:@"confirm", nil];
    [alertview show];

}

- (NSString *) getState
{
    if (isCompleteAllItsTask) {
        
        return @"1";
    }
    return @"0";
}

-(void)resetFrame:(CGRect)frame{
    oldrect = frame;
}

//一个非常临时的解决方案，没有想好其中策略，高度定制化，需要重新设计 ---add by jimmy lee
-(BOOL)needTrigRelationInfo{
    
    if ([[resultInterActionsMap allKeys] count]<=0) {
        
        return NO;
    
    }
    
    int resultcount=0;
    for (int i=0; i<[[resultInterActionsMap allKeys] count]; i++) {
        
        NSString *key = [[resultInterActionsMap allKeys] objectAtIndex:i];
        
        WSInterActionForTableCell *interaction =[resultInterActionsMap valueForKey:key];
        
        NSObject<IAttachment> *attachment = (NSObject<IAttachment> *)[interaction execute_result];
        
        if ([attachment getIsExplored]) {
            
            resultcount ++;
        }
        
    }
    
    if (resultcount == [tableview.dataarray count]) {
        
        return YES;
    }
   
    return NO;
}

//获得结果，也需要重构，不能一味和下拉单选在一起，这是一类定制化需求。---add by jimmy lee
-(NSObject *)getResultDirectly{
    
    NSMutableDictionary *resultdict= [[NSMutableDictionary alloc] init];
    
    for (int i=0; i<[[resultInterActionsMap allKeys] count]; i++) {
        
        NSString *key = [[resultInterActionsMap allKeys] objectAtIndex:i];
        
        WSInterActionForTableCell *interaction =[resultInterActionsMap valueForKey:key];
        
         NSObject<IAttachment> *attachment = (NSObject<IAttachment> *)[interaction execute_result];
        
        [resultdict setValue:[NSString stringWithFormat:@"%d",[attachment getIsExplored]] forKey:[interaction subacvtId]];
  
    }
    
    return resultdict;
}

#pragma mark -
#pragma mark 
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if ([xbuildInfo getLuaScript] && [[xbuildInfo getLuaScript] length] > 0) {
        
        if ([self.delegate respondsToSelector:@selector(executeLuaScript:widget:)]) {
            
            [self.delegate executeLuaScript:xbuildInfo widget:self];
            
        }
    }
}

@end
