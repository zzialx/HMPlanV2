//
//  WSPfizerEtripDisplayedViewController.m
//  WinSFA
//
//  Created by zhangke on 14-5-14.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//

#import "WSPfizerEtripDisplayedViewController.h"
#import "WSEmpInfoBeanArray.h"
#import "WSEmpInfoBean.h"
#import "UITapGestureRecognizer+Additions.h"
#import "WCDownLoadingAndShowingImageView.h"
#import "WSVisitStoreActionTable.h"
#import "WSRequestHelper.h"
#import "JFDEntryObject.h"

#define kImageViewWidth 248
#define kImageViewHeight 186
#define kLabelHeight 40

#define kGap 20


@interface WSPfizerEtripDisplayedViewController ()

@property (nonatomic, strong) NSMutableArray* dataArray;

@end

@implementation WSPfizerEtripDisplayedViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initData];
    [self initUITab];

    if (self.currentVisitAction) {
        [[WSVisitStoreActionTable sharedTable]  updateAction:self.currentVisitAction toStatus:ActionDone];
    }
}

-(void)initData
{
    self.dataArray=[NSMutableArray array];
    WSEmpInfoBeanArray *empArray = [WSAppData getObjectbyKey:@"empInfo"];
    for (WSEmpInfoBean *bean in empArray.empInfoBeanArray) {
        if ([bean.typ isEqualToString:self.currentFuncs.filter]) {
            NSArray* col_valueArray=[bean.col_value componentsSeparatedByString:@","];
            
            for(NSString* string in col_valueArray){
                
                NSMutableString* string_mutable=[NSMutableString stringWithString:string];
                NSRange range={0,string_mutable.length};
                [string_mutable replaceOccurrencesOfString:@"\\" withString:@"/" options:NSCaseInsensitiveSearch range:range];
                
                NSMutableString *ServerString =[NSMutableString stringWithString:[WSPlistHelper valueForKey:kServerIP withPlistName:kConfilgFileName]];
                if ([JFDEntryObject getInstance].debugServerIp) {
                    ServerString = [NSMutableString stringWithString:[JFDEntryObject getInstance].debugServerIp];
                }
                NSRange range_server={0,ServerString.length};
                [ServerString replaceOccurrencesOfString:@"/mobile/" withString:@"" options:NSCaseInsensitiveSearch range:range_server];
                
                NSString* imagePath=[ServerString stringByAppendingString:string_mutable];
                NSURL* url=[NSURL URLWithString:imagePath];
                
                NSDictionary* dic=[NSDictionary dictionaryWithObjectsAndKeys:url,@"url",bean.col_name, @"name",nil];
                [self.dataArray addObject:dic];
            }
        }
    }
}

-(void)initUITab
{
    UIScrollView* scrollView=[[UIScrollView alloc] initWithFrame:self.view.bounds];
    scrollView.backgroundColor=[UIColor clearColor];
    scrollView.autoresizingMask=UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:scrollView];

    
    NSInteger num=0;
    NSInteger row=0;
    NSInteger line=0;
    for(NSDictionary* dic in self.dataArray){
        
        CGRect imageViewFrame,labelFrame;
        
        if (INTERFACE_IS_PAD) {
            line=num%3;
            row=num/3;
            
            imageViewFrame = CGRectMake(kGap+(kImageViewWidth+kGap*2)*line, kGap+(kImageViewHeight+kGap*2+kLabelHeight)*row, kImageViewWidth, kImageViewHeight);
            labelFrame = CGRectMake(kGap+(kImageViewWidth+kGap*2)*line, (imageViewFrame.origin.y + imageViewFrame.size.height), kImageViewWidth, kLabelHeight);
        }else {
            imageViewFrame = CGRectMake((self.view.bounds.size.width - kImageViewWidth)/2, kGap+(kImageViewHeight+kGap*2+kLabelHeight) * num, kImageViewWidth, kImageViewHeight);
            labelFrame = CGRectMake(imageViewFrame.origin.x, (imageViewFrame.origin.y + imageViewFrame.size.height), kImageViewWidth, kLabelHeight);
        }
        
        
        
        UIImageView* imageView=[[UIImageView alloc] initWithFrame:imageViewFrame];
        imageView.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageForName:@"photoViewbg"]];
        
        
        MBProgressHUD *hubView = [[MBProgressHUD alloc] initWithView:imageView];
        [hubView setMode:MBProgressHUDModeDeterminate];
        [hubView setOpacity:0.2f];
        [hubView show:YES];
        [imageView addSubview:hubView];

        __weak UIImageView* tempView=imageView;
        
        
        [[WSRequestHelper shareInstance] downloadImageWithUrl:[NSString stringWithValue:[dic objectForKey:@"url"]] imageView:imageView placeholderImage:nil progress:^(NSInteger receivedSize, NSInteger expectedSize) {
            hubView.progress = (float)receivedSize/expectedSize;

        } completed:^(UIImage *image, NSError *error, NSURL *imageURL) {

            [hubView hide:YES];
            if(error){
                tempView.image=[UIImage imageForName:@"picture_loading_failed"];
            }
        }];

        [scrollView addSubview:imageView];
        
        UILabel* label=[[UILabel alloc] initWithFrame:labelFrame];
        label.backgroundColor=[UIColor clearColor];
        label.text=[dic objectForKey:@"name"];
        label.textAlignment=NSTextAlignmentCenter;
        label.font=[UIFont systemFontOfSize:20];
        [scrollView addSubview:label];
        
        UITapGestureRecognizer* tap=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewTap:)];
        tap.url=[dic objectForKey:@"url"];
        [imageView addGestureRecognizer:tap];
        imageView.userInteractionEnabled=YES;
        
        num++;
    }
    
    CGFloat contentHeight;
    if (INTERFACE_IS_PAD) {
        contentHeight = (kImageViewHeight+kGap*2+kLabelHeight)*(row+1);
    }else {
        contentHeight = (kImageViewHeight+kGap*2+kLabelHeight)*num;
    }
    
    
    scrollView.contentSize=CGSizeMake(scrollView.contentSize.width, contentHeight);
}

-(void)imageViewTap:(UITapGestureRecognizer*)tap
{
    UIImageView* imageView=(UIImageView*)[tap view];
    if(imageView.image){
        WCDownLoadingAndShowingImageView *view = [[WCDownLoadingAndShowingImageView alloc] initWithFrame:self.view.bounds  andImage:imageView.image];
        [self.view addSubview:view];
    }
}




@end
