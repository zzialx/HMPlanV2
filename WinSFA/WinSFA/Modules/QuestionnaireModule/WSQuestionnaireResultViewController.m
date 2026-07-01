//
//  QuestionnaireResultViewController.m
//  WinChannelFrameWork
//
//  Created by ygs on 3/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WSQuestionnaireResultViewController.h"
#import "WSAcvtBean_qst.h"
#import "WSAcvtBean_qst_opt.h"
#import "WSAppData.h"
#import "WSCurrentTime.h"
#import "WSRequestBase.h"
#import "WinSFA.h"
#import "WSJSONBuilder.h"
#import "WSRequestHelper.h"
#import "WSBaseAcvtDBService.h"

@implementation WSQuestionnaireResultViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
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
-(id)initWithFuncs:(WSFuncsBean*)funcs
{
    WSBaseAcvtDBService *baseAcvtDBService = [[WSBaseAcvtDBService alloc] init];
    NSArray *l_acvts = [baseAcvtDBService queryAcvtsWithStoreId:self.currentStore.Id filter:funcs.filter];
    
    WSAcvtBean* l_acvt;
    if([l_acvts count]>0)
        l_acvt = [l_acvts objectAtIndex:0];
    else
        return nil;
    self = [super initWithAcvt:l_acvt Funcs:funcs Store:nil];
    
    if(self)
    {
        return self;
    }
    return nil;
}
@end
