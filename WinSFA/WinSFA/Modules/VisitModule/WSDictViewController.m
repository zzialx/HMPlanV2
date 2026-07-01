//
//  DictViewController.m
//  WinChannelFrameWork
//
//  Created by winchannel on 11-12-15.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "WSDictViewController.h"
#import "DataGridComponent.h"
#import "WSFuncsBean.h"
#import "WSFuncsBean_Param.h"
#import "WSAppData.h"
#import "WSStoreBean.h"
#import "WSStoreBean_prod.h"
#import "WSDictBean.h"
#import "WSFuncsBean_opt.h"
//#import "ConfigFileController.h"
@implementation WSDictViewController


-(void)productReason:(id)sender
{

}
-(void)dealWithParam
{
    if([self.currentFuncs.paramArray count] < 1)
        return;
    
    //titles
    if(self.titles == nil)
    {
        NSMutableArray* titleArray =[[NSMutableArray alloc]init];
        self.titles = titleArray;
    }
    NSInteger paramCount = [self.currentFuncs.paramArray count];
    NSString* item =  NSLocalizedString(@"table_dict_title_project",nil);
    if ([self.currentFuncs.opt.name isKindOfClass:[NSString class]]) {
        item = self.currentFuncs.opt.name;
    } else if ([self.currentFuncs.opt.title isKindOfClass:[NSString class]]) {
        item = self.currentFuncs.opt.title;
    }
    [self.titles addObject:item];
    //NSLog(@"titles count is %d",paramCount);
    
    for(int i = 0 ; i < paramCount; i++)
    {
        WSFuncsBean_Param* fb_Param = [self.currentFuncs.paramArray objectAtIndex:i ];
        [self.titles addObject:fb_Param.name];
    }
    
    if(self.colWidth==nil)
    {
        NSMutableArray* colArray = [[NSMutableArray alloc]init];
        self.colWidth = colArray;
    }
    //colwith  
    [self.colWidth addObject:@"100"];
    
    for(int i = 0 ; i < paramCount; i++)
    {
        [self.colWidth addObject:@"100"];
        //以下是配置
        //        FuncsBean_Param* fb_Param = [self.currentFuncs.paramArray objectAtIndex:i ];
        //        NSNumber* width = [NSNumber numberWithInteger:fb_Param.wcol];
        //        [self.colWidth addObject:[width stringValue]];
    }
    
    if(self.datas == nil)
    {
        NSMutableArray* dataArray = [[NSMutableArray alloc]init];
        self.datas = dataArray;
    }
    //datas
    
    for (int i = 0; i < [self.currentStore.prodArray count]; i++) {
        NSMutableArray *row = [[NSMutableArray alloc] 
                                initWithCapacity:[self.titles count]];
        WSStoreBean_prod *prodcell = [self.currentStore.prodArray objectAtIndex:i];
        //first column
        UILabel *firstcol = [[UILabel alloc] 
                             initWithFrame:CGRectMake(0,0,79,29)];
        firstcol.text = prodcell.pid;
        firstcol.font = [UIFont systemFontOfSize:12.0f];
        firstcol.textAlignment = NSTextAlignmentCenter;
        [row insertObject:firstcol atIndex:0];
        
        for (int j = 0; j < [self.titles count]-1; j++) {
            WSFuncsBean_Param *param = [self.currentFuncs.paramArray objectAtIndex:j];
            
            if ([param.tpy
                 isEqualToString:COL_TYPNUM]){
                UITextField *textfield = [[UITextField alloc] 
                                          initWithFrame:CGRectMake(0, 0, 79, 29)];
                textfield.font = [UIFont systemFontOfSize:12.0f];
                textfield.textAlignment = NSTextAlignmentLeft;
                textfield.delegate = self;
                textfield.keyboardType = UIKeyboardTypeNumberPad;
                
                [textfield addTarget:self
                              action:@selector(textWatcher:)
                    forControlEvents:UIControlEventEditingChanged];
                
                [row addObject:textfield];                
            }else if ([param.tpy 
                       isEqualToString:COL_TYPCHECKBOX]){
                UIButton *check = [UIButton buttonWithType:UIButtonTypeCustom];
                check.frame = CGRectMake(0, 0, 29, 29);
                [check addTarget:self action:@selector(checkBoxPressed:) forControlEvents:UIControlEventTouchUpInside];
                
                [check setImage:[UIImage imageNamed:@"icn_check"] forState:UIControlStateSelected];
                
//                [check setImage:[UIImage imageNamed:@"checkbox-pressed"] forState:UIControlStateHighlighted];
                
                [check setImage:[UIImage imageNamed:@"icn_nocheck"] forState:UIControlStateNormal];
                [row addObject:check];
            }else if([param.tpy 
                      isEqualToString:COL_TYPBUTTON]){
                UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
                NSString *tmpString = NSLocalizedString(@"abnormal_reason",nil);
                [button setTitle:tmpString forState:UIControlStateNormal];
                [button addTarget:self action:@selector(productReason:) forControlEvents:UIControlEventTouchUpInside];
                [row addObject:button];
            }
            
        }
        
        [self.datas addObject:row];
    }
}


-(id)initWithFuncs:(WSFuncsBean *)funcs Store:(WSStoreBean *)store
{
    if(funcs == nil||store == nil)
        return nil;
    
    self = [super initWithFuncs:funcs Store:store];
    if(self != nil)
    {
        [self dealWithParam];
        return self;
    }
    return nil;
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    [super loadView];
    DataGridComponentDataSource *comData = [[DataGridComponentDataSource alloc] 
                                            init];
    
    comData.titles = self.titles;
    comData.data = self.datas;
    comData.columnWidth = self.colWidth;
    
    int heiht = (self.currentFuncs.maxRow+1)* 20 + 5;
    DataGridComponent *compView = [[DataGridComponent alloc] 
                                   initWithFrame:
                                   CGRectMake(10, self.y_point, 300, heiht) data:comData];
    
    [self.view addSubview:compView];
    self.y_point+= heiht;
    
}


/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
