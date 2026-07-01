//
//  WSPhotoBrowserView.m
//  WinSFA
//
//  Created by admin on 16/1/26.
//  Copyright © 2016年 WinChannel. All rights reserved.
//


#import "WSImageBrowserView.h"
#import "WSViewForWebImage.h"

@interface WSImageBrowserView () <UIScrollViewDelegate>

@property (nonatomic,strong)  NSArray *imageArray;
@property (nonatomic,strong)  UIScrollView * scrollView;

@property (nonatomic, strong)UILabel *titleLabel;
@property (nonatomic, strong)UIPageControl * pageControl;
@end

#define kWhith 64      //预留高度
@implementation WSImageBrowserView

- (id)initWithFrame:(CGRect)frame andImage:(NSArray *)imageArr andImageIndex:(NSInteger)imageIndex;
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor blackColor];
//        self.alpha = 0.8;
        _scrollView=[[UIScrollView alloc]initWithFrame:frame];
        self.scrollView.pagingEnabled = YES;
        self.scrollView.showsHorizontalScrollIndicator = NO;
        self.scrollView.showsVerticalScrollIndicator = NO;
        self.scrollView.scrollsToTop = NO;
        self.scrollView.delegate = self;
        self.scrollView.contentOffset = CGPointMake(frame.size.width * imageIndex, 0);
        
        /*
         //默认偏移量，需要时设置
         [self.scrollView setContentOffset:CGPointMake(0, 0)];
         */
        
        [self addSubview:self.scrollView];
        self.scrollView.backgroundColor = [UIColor blackColor];

        
        NSMutableArray *tempArray=[[NSMutableArray alloc] initWithArray:imageArr];
        
        _imageArray=[[NSArray alloc] initWithArray:tempArray];
        
        NSUInteger imgCount = [_imageArray count];
        
        /******设置scrollView的contentSize******/
        self.scrollView.contentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width *self.imageArray.count, 0);
        
        
        for (int i=0; i<imgCount; i++) {
            
            CGRect frame = CGRectMake(self.frame.size.width*i, 0,self.frame.size.width, self.frame.size.height);
            
            WSViewForWebImage *s = [[WSViewForWebImage alloc] initWithFrame:frame];
            s.backgroundColor = [UIColor clearColor];
            s.contentSize = CGSizeMake(self.frame.size.width, self.frame.size.height- kWhith);
            s.delegate = self;
            s.minimumZoomScale = 1.f;
            s.maximumZoomScale = 3.f;
            [s setZoomScale:1.f];
            s.userInteractionEnabled = YES;
            s.showsVerticalScrollIndicator = NO;
            s.showsHorizontalScrollIndicator = NO;
            
            //            NSString *imgName = self.imageArray[i];
            
            s  =  [s initWithFrame:frame andImage:self.imageArray[i] andUrl:nil];
            [_scrollView addSubview:s];
        }
        if (imageArr.count > 1) {
            UILabel * titleLable = [[UILabel alloc] initWithFrame:CGRectMake((self.scrollView.width - 40)/ 2, 20, 40, 30)];
            titleLable.backgroundColor = [UIColor clearColor];
            titleLable.textColor = [UIColor whiteColor];
            titleLable.text = [NSString stringWithFormat:@"%ld/%lu",(long)imageIndex + 1,(unsigned long)imageArr.count];
            self.titleLabel = titleLable;
            [self addSubview:titleLable];
        }
    }
    return self;
}
#pragma mark  ------   UIScrollViewDelegate

/******设置图片大小滚动还原******/
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    CGFloat offset;
    offset = 0.0;
    
    if (scrollView == _scrollView){
        CGFloat x = scrollView.contentOffset.x;
        if (x==offset){
            
        }
        else {
            offset = x;
            for (UIScrollView *s in scrollView.subviews){
                if ([s isKindOfClass:[UIScrollView class]]){
                    [s setZoomScale:1.f];
                }
            }
        }
    }
}

-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    
    for (UIView *v in scrollView.subviews){
        
        return v;
    }
    return nil;
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat pageWidth = scrollView.frame.size.width;
    int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    int currentPage = page;
    if (_imageArray.count > 1) {
        self.titleLabel.text = [NSString stringWithFormat:@"%d/%lu", currentPage + 1, (unsigned long)[self.imageArray count]];
    }
    self.pageControl.currentPage = currentPage;
    
}
@end
