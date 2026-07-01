//
//  ProdViewController.m
//  WinChannelFrameWork
//
//  Created by winchannel on 12-1-12.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "WSProdViewController.h"
#import "DataGridComponent.h"
#import "WSFuncsBean.h"
#import "WSFuncsBean_Param.h"
#import "WSAppData.h"
#import "WSStoreBean.h"
#import "WSStoreBean_prod.h"
#import "WSDictBean.h"
#import "WSReasonViewController.h"
#import "WSCurrentTime.h"
#import "WSProdBean.h"
#import "WSProdBeanArray.h"
#import "WSFuncsBean_opt.h"
//#import "ConfigFileController.h"
@implementation WSProdViewController

UITextField *prodTextField = nil;

- (void)closeKeyboard{
    if (prodTextField) {
        [prodTextField resignFirstResponder];
    }
}

- (void)checkBoxPressed: (id)sender{
    if ([sender isKindOfClass:[UIButton class]]) {
        if (((UIButton *)sender).selected) {
            [(UIButton *)sender setSelected:NO];
        }else{
            [(UIButton *)sender setSelected:YES];
        }
    }
}

- (void)textWatcher:(id)sender
{
    prodTextField = sender;
}

-(NSInteger)getSpecIndexbyParam:(WSFuncsBean_Param*)param
{
    NSArray* spec = [WSAppData getObjectbyKey:PRODSPEC];
    int index = 0;
    for(NSString* col in spec)
    {
        if([col isEqualToString:param.col])
            return index;
        index++;
    }
    return 100;
}

-(NSString*)getDisbyParam:(WSFuncsBean_Param*)param Prod:(WSProdBean*)prod
{
    NSArray* spec = [WSAppData getObjectbyKey:PRODSPEC];
    for(WSStoreBean_prod *prodcell in self.currentStore.prodArray)
    {
        NSString* sbp = [NSString stringWithValue:prodcell.pid];
        NSString* pb = [NSString stringWithValue:prod.Id];
        
        if([sbp isEqualToString:pb])
        {   
            int index = 0;
            for(NSString* col in spec)
            {
                if([col isEqualToString:param.col])
                {
                    if([prodcell.item count]>0)
                        return [prodcell.item objectAtIndex:index];
                    else
                        return nil;
                }
                index++;
            }
        }
        
    }
    
    return nil;
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
    NSString* item =  NSLocalizedString(@"table_dict_title_project",nil); //项目
    if ([self.currentFuncs.opt.name isKindOfClass:[NSString class]]) {
        item = self.currentFuncs.opt.name;
    } else if ([self.currentFuncs.opt.title isKindOfClass:[NSString class]]) {
        item = self.currentFuncs.opt.title;
    }
    [self.titles addObject:item];
    
    for(NSInteger i = 0 ; i < paramCount; i++)
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
    
    NSMutableArray* prodArray = [[NSMutableArray alloc]init];

    for(int i = 0 ; i < [self.currentStore.prodArray count];i++)
    {
        WSStoreBean_prod* s_prod = [self.currentStore.prodArray objectAtIndex:i];
        WSProdBeanArray* p_Array = [WSAppData getObjectbyKey:PRODS];
        for(int m = 0 ; m < [p_Array.prodArray count];m++)
        {
            WSProdBean* pb = [p_Array.prodArray objectAtIndex:m];
            if([s_prod.pid isEqualToString:pb.Id])
            {
                [prodArray addObject:pb];
                break;
            }
        }
    }
    for (int i = 0; i < [prodArray count]; i++) {
        NSMutableArray *row = [[NSMutableArray alloc] 
                                initWithCapacity:[self.titles count]];
        
        //first column
        UILabel *firstcol = [[UILabel alloc] 
                             initWithFrame:CGRectMake(0,0,79,29)];
        WSProdBean* pb = [prodArray objectAtIndex:i];
        firstcol.text = pb.name;
        firstcol.font = [UIFont systemFontOfSize:12.0f];
        firstcol.textAlignment = NSTextAlignmentCenter;
        [row insertObject:firstcol atIndex:0];
        
        for (int j = 0; j < [self.titles count]-1; j++) {
            WSFuncsBean_Param *param = [self.currentFuncs.paramArray objectAtIndex:j];
            
            if ([param.tpy
                 isEqualToString:COL_TYPNUM]){
                UITextField *textfield = [[UITextField alloc] 
                                          initWithFrame:CGRectMake(0, 0, 0, 0)];
                if(100 != [self getSpecIndexbyParam:param])
                    textfield.tag = [self getSpecIndexbyParam:param];
                textfield.placeholder = [self getDisbyParam:param Prod:[prodArray objectAtIndex:i]];
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
                check.tag = [self getSpecIndexbyParam:param];
                check.frame = CGRectMake(0, 0, 29, 29);
                [check addTarget:self action:@selector(checkBoxPressed:) forControlEvents:UIControlEventTouchUpInside];
                
                [check setImage:[UIImage imageNamed:@"icn_check"] forState:UIControlStateSelected];
                
//                [check setImage:[UIImage imageNamed:@"checkbox-pressed"] forState:UIControlStateHighlighted];
                
                [check setImage:[UIImage imageNamed:@"icn_nocheck"] forState:UIControlStateNormal];
                [row addObject:check];
            }else if([param.tpy 
                      isEqualToString:COL_TYPBUTTON]){
                UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
                button.tag = [self getSpecIndexbyParam:param];
                NSString *tmpString = NSLocalizedString(@"abnormal_reason",nil);
                [button setTitle:tmpString forState:UIControlStateNormal];
                [button addTarget:self action:@selector(productReason:) forControlEvents:UIControlEventTouchUpInside];
                [row addObject:button];
            }
            
        }
        
        [self.datas addObject:row];
    }
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
    
    [self addFuncsOtherBeanView];
    [self addOptView];

    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(closeKeyboard) name:TOUCH_EVENT object:nil];
    
    [self dealWithParam];
    DataGridComponentDataSource *comData = [[DataGridComponentDataSource alloc] 
                                            init];
    
    comData.titles = self.titles;
    comData.data = self.datas;
    comData.columnWidth = self.colWidth;
    
    //    [self.titles release];
    //    [datas release];
    //    [colWidth release];
    //NSLog(@"row is %d",self.currentFuncs.maxRow);
    int heiht = (self.currentFuncs.maxRow+1)* 20 + 5;
    DataGridComponent *compView = [[DataGridComponent alloc] 
                                   initWithFrame:
                                   CGRectMake(10, self.y_point, 300, heiht) data:comData];
    
    [self.contentScrollView addSubview:compView];
    self.y_point+= heiht;
    
    self.contentScrollView.contentSize = CGSizeMake(self.view.bounds.size.width, self.y_point);
    
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
