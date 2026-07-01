//
//  WSContactViewController.m
//  WinSFA
//
//  Created by winchannel on 15/3/23.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSContactViewController.h"

#import "WSContactView.h"
#import "WSContactDataSource.h"
#import "ContactSearcher.h"
#import "I_W_ContactDisplay.h"
#import "WSInterAction.h"


@interface WSContactViewController () <WSContactViewDelegate,WSContactDataSourceDelegate,ContactSearcherDelegate>

@end

@implementation WSContactViewController
@synthesize contactview;
@synthesize datasource;
@synthesize contactsearcher;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        
        
    }
    
    return self;
}


-(void)viewWillAppear:(BOOL)animated{
    
    
    
    
    
}




- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    UIButton  *cancelbtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    
    cancelbtn.frame = CGRectMake(0.0, 0.0, 100, 50);
    
    [cancelbtn setTitle:@"cancel_label" forState:UIControlStateNormal];
    
    [cancelbtn setTitle:@"cancel_label" forState:UIControlStateNormal];
    
    [cancelbtn addTarget:self action:@selector(cancelSelectUser) forControlEvents:UIControlEventTouchUpInside];
    
    
    UIButton  *confirmbtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    
    [confirmbtn setTitle:@"confirm" forState:UIControlStateNormal];
    
    [confirmbtn setTitle:@"confirm" forState:UIControlStateNormal];
    
    [confirmbtn addTarget:self action:@selector(doChooseUser) forControlEvents:UIControlEventTouchUpInside];
    
    confirmbtn.frame = CGRectMake(0.0, 0.0, 100, 50);
    
    
    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc] initWithCustomView:cancelbtn];
    
    
    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc] initWithCustomView:confirmbtn];
    
    
    contactview =[[WSContactView alloc] initWithFrame:CGRectMake(0.0, 0.0,self.view.frame.size.width,self.view.frame.size.height)];
    
    contactview.contact_delegate = self;
    
    [self.view addSubview:contactview];
    
    [self performSelector:@selector(loadContactList) withObject:nil afterDelay:0.5f];

}



-(void)loadContactList{
    
    datasource = [[WSContactDataSource alloc] init];
    
    
    datasource.delegate=self;
    
    
    [datasource loadData];
    
    
    contactsearcher=[ContactSearcher shareSearcher];
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}


-(void)searchWithContact:(NSString *)contact{
    
    
    contactsearcher.delegate =self;
    
    [contactsearcher searchContact:contact];
    
}



#pragma mark -
#pragma mark WSContactDataSourceDelegate method

-(void)notifyData:(NSMutableArray *)array anddict:(NSMutableDictionary *)dict{
    
    [contactview loadContactDict:dict];
    

}

-(void)executeRight{
    
}





-(void)cancelSelectUser{
    
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
    
}

// iOS6前
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return [super shouldAutorotateToInterfaceOrientation:toInterfaceOrientation];
}

// iOS6及以后
- (BOOL)shouldAutorotate
{
    return [super shouldAutorotate];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return [super supportedInterfaceOrientations];
}


#pragma mark -
#pragma mark ContactSearcherDelegate method

-(void)sendSearchResultSuccess:(NSArray *)array{
    
    [contactview loadSearchContent:[array mutableCopy]];
    
    contactsearcher.delegate =nil;
    
    
    
}


-(void)doChooseUser{
    
   
    NSMutableString *backcontent = [[NSMutableString alloc] initWithString:@""];
    
    NSMutableArray  *array = [contactview invitearray];

    for (int i=0; i<[array count]; i++) {
        
        NSObject<I_W_ContactDisplay> *contact = [array objectAtIndex:i];
        if ([[contact getContactMobile] length]>0) {
            
       
        if (i==[array count]-1) {
            
            [backcontent appendFormat:@"%@",[contact getContactMobile]];
        
        }else{
        
            [backcontent appendFormat:@"%@,",[contact getContactMobile]];
        }
      
      }
    }
    
    
    [self.executeParam  setExecute_result:backcontent];
    
    if ([self.wcBaseViewdelegate respondsToSelector:@selector(callBackWhenFinishTask:)]) {
        
        [self.wcBaseViewdelegate callBackWhenFinishTask:self.executeParam];
    }
    
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}


@end
