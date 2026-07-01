//
//  CurrentVisitViewController.m
//  WinChannelFrameWork
//
//  Created by wdy on 12-3-20.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WSCurrentVisitViewController.h"
#import "WSStoredDictDisArray.h"
#import "WSStoredDictDisBean.h"
//#import "ConfigFileController.h"
#import "WSStoredDictDisArray.h"
#import "WSStoredDictDisBean.h"
#import "WSBaseDictsDBService.h"

@implementation WSCurrentVisitViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}



- (void)upload
{
    NSString *FUNCSDETAIL = [NSString stringWithFormat:@"%@%@",@"funcsDetail", self.currentFuncs.fc]; 
//    WSRequestHelper *uploadMgr = [WSRequestHelper shareInstance];

    NSString *postData = [WSJSONBuilder buildDictDetailbyFuncs:self.currentFuncs 
                                                     isPhoto:NO datas:self.datas 
                                                     dataIDs:self.m_dataSources 
                                                       Store:self.currentStore 
                                                         md5:self.md5 
                                                        memo:self.memoData
                                                   otherInfo:nil];
    
    [self insertUploadData:postData URL:URL_UPLOAD MD5:self.md5 IsPhoto:NO NotifyName:FUNCSDETAIL];
    
    [self backToParent];
}




//获取数据库的内容
-(NSString*)getDatasFromDataBaseWithParam:(WSFuncsBean_Param*)aParam Data:(WSDictBean*)aDict
{
    return nil;
    
}


-(NSString*)getDefaultDataWithParam:(WSFuncsBean_Param*)aParam Others:(WSDictBean*)aDict
{
    if (!aParam.redis)
    {
        if (aParam.idefault != nil && [aParam.idefault isKindOfClass:[NSString class]]) {
            return aParam.idefault;
        }else{
            return @"";
        }
    }
    WSStoredDictDisArray *storedDictArray = [WSAppData getObjectbyKey:STOREDICTDIS];
    NSMutableArray *storedictArray = [[NSMutableArray alloc] init];
    for (WSStoredDictDisBean *item in storedDictArray.storedDictDisArray)
    {
        if ([[item.m_p firstObject] isEqualToString:self.currentStore.Id])
        {
            [storedictArray addObject:item];
        }
    }
    NSString *dictIdAndFC = [NSString stringWithFormat:@"%@@%@",aDict.Id,self.currentFuncs.fc];
    for (WSStoredDictDisBean *item in storedictArray)
    {
        if ([[item.m_p objectAtIndex:1] isEqualToString:dictIdAndFC])
        {
            if ([aParam.redis isEqualToString:@"1"])
            {
                int index = [[aParam.col substringFromIndex:aParam.col.length-1] intValue] + 1;
                return [item.m_p objectAtIndex:index];
            }
            else
            {
                int index = [[aParam.redis substringFromIndex:aParam.redis.length-1] intValue] + 1;
                return [item.m_p objectAtIndex:index];
            }
        }
    }
    return @"";
}


-(NSString*)getDataSourcesWithIndex:(NSNumber*)aIndex Other:(NSArray*)aDicts
{
    WSDictBean* l_dict = [aDicts objectAtIndex:[aIndex intValue]];
    return l_dict.name;
}


-(NSArray*)getDatasSources
{
    WSBaseDictsDBService *service = [[WSBaseDictsDBService alloc] init];
    NSArray *filterArray = [service queryDictsForAcvtGridWithFilter:self.currentFuncs.filter];
    
    return filterArray;
}


-(NSArray*)getDataBaseDatas
{
    
    return nil;
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
