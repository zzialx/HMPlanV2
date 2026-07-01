//
//  WSHelpDocumentationViewController.m
//  WinSFA
//
//  Created by heju on 3/6/14.
//  Copyright (c) 2014 WinChannel. All rights reserved.
//



#import "WSHelpDocumentationViewController.h"
#import "WSHelpItemDetalViewController.h"

@interface WSHelpDocumentationViewController ()

@property (nonatomic ,strong)WSHelpDocument *helpDocument;

@property (nonatomic ,strong)MBProgressHUD *iconImageHud;
- (void)createScrollView;
@end

@implementation WSHelpDocumentationViewController
@synthesize funcsBean = _funcsBean;
@synthesize helpDocument = _helpDocument;


-(id)initWithFuncs:(WSFuncsBean*)funcs
{
    if(funcs == nil)
        return nil;
    self = [super init];
    if(self)
    {
        self.funcsBean = funcs;
        self.title = funcs.name;
        return self;
    }
    return nil;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor  whiteColor];
    NSArray *helpDocArray = [WSAppData getObjectbyKey:MOBILEPICTURE];
    WSHelpDocument *helpDocment = [[WSHelpDocument alloc]initWithObject:helpDocArray];
    self.helpDocument = helpDocment;
    /*
    [self performSelectorInBackground:@selector(createScrollView) withObject:nil];
     */
    /*
    _iconImageHud = [[MBProgressHUD alloc]initWithView:self.view];
    [self.view addSubview:_iconImageHud];
    _iconImageHud.labelText = NSLocalizedString(@"thumbnail_image_loading", nil);
    [_iconImageHud show:YES];
    */
    [self performSelectorOnMainThread:@selector(createScrollView) withObject:nil waitUntilDone:NO];
   
    
    /*
    [self createScrollView];
     */
}

- (void)createScrollView {
    NSInteger row = 0;
    NSInteger imageCount =[self.helpDocument.items count];
    if (imageCount%2 ==1) {
        row = imageCount%2 + 1;
    }
    WSHelpDocumentScrollView *imagesScrollView = [[WSHelpDocumentScrollView alloc] init];
    imagesScrollView.frame = CGRectMake(0,0, self.view.frame.size.width, self.view.frame.size.height );
    if (imageCount < 4) {
        imagesScrollView.contentSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height);
    } else {
        imagesScrollView.contentSize = CGSizeMake(self.view.frame.size.width, ((self.view.frame.size.height)/2) * row);
    }
    imagesScrollView.directionalLockEnabled = YES;
    imagesScrollView.showsHorizontalScrollIndicator = NO;
    imagesScrollView.showsVerticalScrollIndicator = NO;
    [imagesScrollView setScrollEnabled:YES];
    //NO - 设置scrollView不能取消传递touch事件，此时就算手指若在subView上滑动，scrollView不滚动; YES - 设置scrollView可取消传递touch事件
    [imagesScrollView setCanCancelContentTouches:YES];
    [imagesScrollView setBounces:YES];
    
    //NO - 立即通知touchesShouldBegin:withEvent:inContentView
    [imagesScrollView setDelaysContentTouches:NO];
    [self.view addSubview:imagesScrollView];
    //
    for (NSInteger i = 0; i <  [self.helpDocument.items count]; i++) {
        WSHelpDocumentItem *item = [self.helpDocument.items objectAtIndex:i];
        CGRect itemRect = CGRectMake( (i%2)*(self.view.frame.size.width/2), (i/2)*((self.view.frame.size.height)/2), self.view.frame.size.width/2, (self.view.frame.size.height)/2);
        WSHelpDocumentItemView *itemView = [[WSHelpDocumentItemView alloc]initWithFrame:itemRect item:item showDescript:NO];
        itemView.tag = i;
        itemView.itemViewDelegate = self;
        [imagesScrollView addSubview:itemView];
    }
     [_iconImageHud hide:YES];

}

#pragma WSHelpDocumentItemViewDelegate Methods
- (void)helpDocumentItemViewCicked:(WSHelpDocumentItemView *)itemView {
    WSHelpItemDetalViewController *itemDetailVC = [[WSHelpItemDetalViewController alloc]initWithFuncs:self.funcsBean helpDocument:self.helpDocument itemView:itemView];
    [self.navigationController pushViewController:itemDetailVC animated:YES];
 
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
