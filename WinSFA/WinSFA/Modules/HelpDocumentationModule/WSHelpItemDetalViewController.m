//
//  WSHelpItemDetalViewController.m
//  WinSFA
//
//  Created by heju on 3/7/14.
//  Copyright (c) 2014 WinChannel. All rights reserved.
//

#import "WSHelpItemDetalViewController.h"

@interface WSHelpItemDetalViewController ()
@property (nonatomic ,strong)WSFuncsBean *funcsBean;
@property (nonatomic ,strong)WSHelpDocumentItemView *itemView;
@property (nonatomic ,strong)WSHelpDocument *helpDocument;
@property (nonatomic ,strong)UIScrollView *scrollView;
@property (nonatomic ,strong)UIPageControl *pageControl;
@property (nonatomic ,assign)CGSize size;
@property (nonatomic ,strong)MBProgressHUD *detailImageHud;

- (void)createDetailSubViews;

@end

@implementation WSHelpItemDetalViewController

@synthesize funcsBean = _funcsBean;
@synthesize itemView = _itemView;
@synthesize helpDocument = _helpDocument;
@synthesize scrollView = _scrollView;
@synthesize pageControl = _pageControl;
@synthesize size = _size;

/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.view.backgroundColor = [UIColor whiteColor];
    }
    return self;
}
*/
- (id)initWithFuncs:(WSFuncsBean *)funcs helpDocument:(WSHelpDocument *)helpDocument itemView:(WSHelpDocumentItemView *)itemView {
    if(funcs == nil)
        return nil;
    
    self = [super init];
    if(self)
    {
        self.funcsBean = funcs;
        self.helpDocument = helpDocument;
        self.itemView = itemView;
        return self;
    }
    return nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    _detailImageHud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:_detailImageHud];
    
    _detailImageHud.labelText = NSLocalizedString(@"image_loading", nil);;
    [_detailImageHud show:YES];

    [self performSelectorOnMainThread:@selector(createDetailSubViews) withObject:nil waitUntilDone:NO];
    
}

- (void)createDetailSubViews {
    [self addScrollView];
    [self addPageControl];
    [_detailImageHud hide:YES];
}

-  (void)addScrollView
{
    _size = self.view.frame.size;
    _scrollView=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 0,  _size.width,_size.height )];
    _scrollView.contentSize=CGSizeMake([self.helpDocument.items count]*_size.width,_size.height);
    _scrollView.delegate=self;
    _scrollView.showsHorizontalScrollIndicator=NO;
    _scrollView.showsVerticalScrollIndicator=NO;
    _scrollView.bounces = NO;
    _scrollView.scrollEnabled=YES;
    _scrollView.pagingEnabled = YES;
    [self.view addSubview:_scrollView];
    
    for(int i=0;i<[self.helpDocument.items count];i++){
        WSHelpDocumentItem *documentItem = [self.helpDocument.items objectAtIndex:i];
        CGRect itemViewRect = CGRectMake(_size.width*i, 0, _size.width, _size.height);
        WSHelpDocumentItemView *itemView = [[WSHelpDocumentItemView alloc]initWithFrame:itemViewRect item:documentItem showDescript:YES];
        [_scrollView addSubview:itemView];
        
    }
    
}

- (void)addPageControl
{
    _pageControl=[[UIPageControl alloc]initWithFrame:CGRectMake((_size.width - 100)/2,_size.height*4/5 - 20 , 100, 20)];
    
    _pageControl.numberOfPages=[self.helpDocument.items count];
    
    _pageControl.currentPage=self.itemView.tag;
    

    
    [_pageControl addTarget:self action:@selector(changePage:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_pageControl];
}

-(void)changePage:(id)sender{
    NSInteger page=_pageControl.currentPage;
    [_scrollView setContentOffset:CGPointMake(_size.width*page, 0) animated:YES];
}


- (void)scrollViewDidScroll:(UIScrollView *)sender
{
    CGFloat pageWidth =  _size.width;
    int page = floor((_scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
     _pageControl.currentPage = page;
    WSHelpDocumentItem *helpItem = [self.helpDocument.items objectAtIndex:page];
    self.title = helpItem.descript;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
