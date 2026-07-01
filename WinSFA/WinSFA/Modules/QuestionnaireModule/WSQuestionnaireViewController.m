//
//  QuestionnaireViewController.m
//  WinChannelFrameWork
//
//  Created by ygs on 3/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WSQuestionnaireViewController.h"

@implementation WSQuestionnaireViewController

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

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/
//选中Cell响应事件
//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//    [tableView deselectRowAtIndexPath:indexPath animated:YES];//选中后的反显颜色即刻消失
//    if(self.currentFuncs.funcsArray == nil|| [self.currentFuncs.funcsArray count]==0)
//        return;
//    
//    FuncsBean* fb = [self.currentFuncs.funcsArray objectAtIndex:indexPath.row];
//    
//    //NSLog(@"fb is %@",fb.ds);
//    
//    UIViewController* vc = 
//    [[NSClassFromString(
//                        [PropertyManager getPropertybyKey:fb.fv]) alloc] initWithFuncs:fb];
//    
//    if(vc==nil)
//    {
//        vc = [[NSClassFromString(
//                                 [PropertyManager getPropertybyKey:fb.ds]) alloc] initWithFuncs:fb];
//    }
//    [self setHidesBottomBarWhenPushed:YES];
//    
//    [self.navigationController pushViewController:vc animated:YES];
//    
//    [vc release];
//}

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
