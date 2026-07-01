//
//  CollectionViewController.m
//  WinChannelFrameWork
//
//  Created by winchannel on 11-12-7.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "WSCollectionViewController.h"
#import "WSAcvtBean.h"
#import "WSAppData.h"
#import "WSFuncsBean.h"
#import "WSAcvtBean_qst.h"
#import "WSBaseAcvtDBService.h"

@implementation WSCollectionViewController
@synthesize collectionArray = _collectionArray;

-(void)dealWithds
{
    
    WSBaseAcvtDBService *baseAcvtDBService = [[WSBaseAcvtDBService alloc] init];
    NSArray *filtersArray = [baseAcvtDBService queryAcvtsWithStoreId:self.currentStore.Id filter:self.currentFuncs.filter];
    [self.collectionArray addObjectsFromArray:filtersArray];
    
    
}
-(id)initWithFuncs:(WSFuncsBean *)funcs Store:(WSStoreBean *)store
{
    if(funcs==nil)
        return nil;
    self = [super initWithFuncs:funcs Store:store];

    if(self != nil)
        {
            NSMutableArray* array = [[NSMutableArray alloc]init];
            self.collectionArray = array;
            [self dealWithds];
            return self;
        }
    return nil;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
}

#pragma mark - View lifecycle


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    [super loadView];
    
    NSInteger Acvtcount = [self.collectionArray count];
    //目前就返回1个acvt 如果以后返回多个再改
    WSAcvtBean* ab;
    if(Acvtcount > 0)
     ab = [self.collectionArray objectAtIndex:0];
    else
        return;
    
    NSInteger count = [ab.qsts count];
    WSAcvtBean_qst* qst;
    for(int i = 0 ; i < count ; i ++)
    {
        qst = [ab.qsts objectAtIndex:i];
        if([qst.qstType isEqualToString:QST_TYPE_L])
        {
            UILabel* lable = [[UILabel alloc]initWithFrame:CGRectMake(20, self.y_point, 320, 30)];
            lable.text = qst.qstName;
            lable.backgroundColor = [UIColor clearColor];
            [lable setAdjustsFontSizeToFitWidth:YES];
            [self.view addSubview:lable];
            self.y_point +=30;
        }
        
        if([qst.qstType isEqualToString:QST_TYPE_N])
        {
            UILabel* moneyLable = [[UILabel alloc]initWithFrame:CGRectMake(20, self.y_point, 200, 30)];
            moneyLable.text = qst.qstName;
            moneyLable.backgroundColor = [UIColor clearColor];
            [self.view addSubview:moneyLable];
            UITextField* tf = [[UITextField alloc]initWithFrame:CGRectMake(180, self.y_point, 100, 30)];
            tf.backgroundColor = [UIColor whiteColor];
            [self.view addSubview:tf];
            self.y_point+=30;
        }
    }
    
    [self addFuncsOtherBeanView];
    [self addOptView];

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
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
