//
//  WSPDFMediaPanel.m
//  WinSFA
//
//  Created by winchannel on 15/4/15.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSPDFMediaPanel.h"
#import "ReaderConstants.h"
#import "ReaderContentView.h"
#import "ReaderDocument.h"
#import "I_Media_Info.h"
#import "I_Media.h"
#import <IAttachment.h>



#define STATUS_HEIGHT 20.0f

#define TOOLBAR_HEIGHT 44.0f
#define PAGEBAR_HEIGHT 48.0f

#define PAGE_NUMBER_VIEW_WIDTH 50.0f
#define PAGE_NUMBER_VIEW_HEIGHT 30.0f


#define TAP_AREA_SIZE 48.0f

@interface WSPDFMediaPanel () <UIScrollViewDelegate, UIGestureRecognizerDelegate>
{
    ReaderDocument *document;
    
    UIScrollView *theScrollView;
    
    NSMutableDictionary *contentViews;
    
    UIUserInterfaceIdiom userInterfaceIdiom;
    
    NSInteger currentPage, minimumPage, maximumPage;
    
    CGSize lastAppearSize;
    
    BOOL ignoreDidScroll;
    
    BOOL hasReadToEnd;
    
    float forceReadTimeForPage;
    
    NSMutableDictionary *forceReadMarkDic;
    
    NSTimer *timer;
    
    BOOL isInForceReading;
    
    UILabel *pageNumberView;
}


@end

@implementation WSPDFMediaPanel

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


-(void)loadDataSource:(NSObject<I_W_DataSource> *)datasource{
    
    [super loadDataSource:datasource];
    
    
}

-(void)loadBuildInfo:(NSObject<I_W_BuildInfo> *)buildInfo{
    
    [super loadBuildInfo:buildInfo];
    
}


-(void)buildDisplayContent{
    
    forceReadTimeForPage = -1.0;
    
    if ([media_info respondsToSelector:@selector(getForceReadTimeForPage)]) {
        if ([media_info getForceReadTimeForPage] && [[media_info getForceReadTimeForPage] length] > 0) {
            forceReadTimeForPage = [[media_info getForceReadTimeForPage] floatValue];
        }
    }
    
    
    NSString *filePath = [media_info getMediaFileSavePath];
    
    if (filePath == nil) {
        if ([self.mediaOperationDelegate respondsToSelector:@selector(currentMediaPlayError:)]) {
            [self.mediaOperationDelegate currentMediaPlayError:self];
        }
        return;
    }
    
    ReaderDocument *docRef = [ReaderDocument withDocumentFilePath:filePath password:nil];
    
    if (docRef == nil) {
        if ([self.mediaOperationDelegate respondsToSelector:@selector(currentMediaPlayError:)]) {
            [self.mediaOperationDelegate currentMediaPlayError:self];
        }
        return;
    }
    
    BOOL result = [docRef updateDocumentProperties];
    
    if (!result) {
        if ([self.mediaOperationDelegate respondsToSelector:@selector(currentMediaPlayError:)]) {
            [self.mediaOperationDelegate currentMediaPlayError:self];
        }
    }
    
    document = docRef; // Retain the supplied ReaderDocument object for our use
    
    if (forceReadTimeForPage > 0) {
        forceReadMarkDic = [[NSMutableDictionary alloc] initWithCapacity:[document.pageCount integerValue]];
    }
    
    CGRect viewRect = self.bounds; // View bounds
    
    theScrollView = [[UIScrollView alloc] initWithFrame:viewRect]; // All
    theScrollView.autoresizesSubviews = NO;
//    theScrollView.contentMode = UIViewContentModeRedraw;
    theScrollView.showsHorizontalScrollIndicator = NO;
    theScrollView.showsVerticalScrollIndicator = NO;
    theScrollView.scrollsToTop = NO;
    theScrollView.delaysContentTouches = NO;
    theScrollView.pagingEnabled = YES;
    theScrollView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    theScrollView.backgroundColor = [UIColor clearColor]; theScrollView.delegate = self;
    [self addSubview:theScrollView];
    
    UITapGestureRecognizer *singleTapOne = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    singleTapOne.numberOfTouchesRequired = 1;
    singleTapOne.numberOfTapsRequired = 1;
    singleTapOne.delegate = self;
    [self addGestureRecognizer:singleTapOne];
    
    UITapGestureRecognizer *doubleTapOne = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    doubleTapOne.numberOfTouchesRequired = 1;
    doubleTapOne.numberOfTapsRequired = 2;
    doubleTapOne.delegate = self;
    [self addGestureRecognizer:doubleTapOne];
    
    UITapGestureRecognizer *doubleTapTwo = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    doubleTapTwo.numberOfTouchesRequired = 2;
    doubleTapTwo.numberOfTapsRequired = 2;
    doubleTapTwo.delegate = self;
    [self addGestureRecognizer:doubleTapTwo];
    
    [singleTapOne requireGestureRecognizerToFail:doubleTapOne]; // Single tap requires double tap to fail
    
    contentViews = [NSMutableDictionary new];
    
    minimumPage = 1;
    maximumPage = [document.pageCount integerValue];
    
    pageNumberView = [[UILabel alloc] initWithFrame:CGRectMake((self.bounds.size.width - PAGE_NUMBER_VIEW_WIDTH)/2, self.bounds.size.height - PAGE_NUMBER_VIEW_HEIGHT - 10, PAGE_NUMBER_VIEW_WIDTH, PAGE_NUMBER_VIEW_HEIGHT)];
    pageNumberView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    pageNumberView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
    pageNumberView.textColor = [UIColor whiteColor];
    pageNumberView.font = [UIFont systemFontOfSize:14];
    pageNumberView.layer.cornerRadius = 5.0;
    pageNumberView.textAlignment = NSTextAlignmentCenter;
    [self addSubview:pageNumberView];
    
}

- (void)playTheMeida
{
    [self showDocument];
}

- (void)updateContentSize:(UIScrollView *)scrollView
{
    CGFloat contentHeight = scrollView.bounds.size.height; // Height
    
    NSLog(@"height:%f", contentHeight);
    
    CGFloat contentWidth = (scrollView.bounds.size.width * maximumPage);
    
    scrollView.contentSize = CGSizeMake(contentWidth, contentHeight);
}

- (void)updateContentViews:(UIScrollView *)scrollView
{
    [self updateContentSize:scrollView]; // Update content size first
    
    [contentViews enumerateKeysAndObjectsUsingBlock: // Enumerate content views
     ^(NSNumber *key, ReaderContentView *contentView, BOOL *stop)
     {
         NSInteger page = [key integerValue]; // Page number value
         
         CGRect viewRect = CGRectZero; viewRect.size = scrollView.bounds.size;
         
         viewRect.origin.x = (viewRect.size.width * (page - 1)); // Update X
         
         contentView.frame = viewRect;
     }
     ];
    
    NSInteger page = currentPage; // Update scroll view offset to current page
    
    CGPoint contentOffset = CGPointMake((scrollView.bounds.size.width * (page - 1)), 0.0f);
    
    if (CGPointEqualToPoint(scrollView.contentOffset, contentOffset) == false) // Update
    {
        scrollView.contentOffset = contentOffset; // Update content offset
    }
}

- (void)addContentView:(UIScrollView *)scrollView page:(NSInteger)page
{
    CGRect viewRect = CGRectZero;
    viewRect.size = scrollView.bounds.size;
    
    viewRect.origin.x = (viewRect.size.width * (page - 1));
    
    NSURL *fileURL = document.fileURL;
    NSString *phrase = document.password;
    
    ReaderContentView *contentView = [[ReaderContentView alloc] initWithFrame:viewRect fileURL:fileURL page:page password:phrase]; // ReaderContentView
    
    [contentViews setObject:contentView forKey:[NSNumber numberWithInteger:page]];
    [scrollView addSubview:contentView];
    
}

- (void)layoutContentViews:(UIScrollView *)scrollView
{
    CGFloat viewWidth = scrollView.bounds.size.width; // View width
    
    CGFloat contentOffsetX = scrollView.contentOffset.x; // Content offset X
    
    NSInteger pageB = ((contentOffsetX + viewWidth - 1.0f) / viewWidth); // Pages
    
    NSInteger pageA = (contentOffsetX / viewWidth); pageB += 2; // Add extra pages
    
    if (pageA < minimumPage) pageA = minimumPage; if (pageB > maximumPage) pageB = maximumPage;
    
    NSRange pageRange = NSMakeRange(pageA, (pageB - pageA + 1)); // Make page range (A to B)
    
    NSMutableIndexSet *pageSet = [NSMutableIndexSet indexSetWithIndexesInRange:pageRange];
    
    for (NSNumber *key in [contentViews allKeys]) // Enumerate content views
    {
        NSInteger page = [key integerValue]; // Page number value
        
        if ([pageSet containsIndex:page] == NO) // Remove content view
        {
            ReaderContentView *contentView = [contentViews objectForKey:key];
            
            [contentView removeFromSuperview]; [contentViews removeObjectForKey:key];
        }
        else // Visible content view - so remove it from page set
        {
            [pageSet removeIndex:page];
        }
    }
    
    NSInteger pages = pageSet.count;
    
    if (pages > 0) // We have pages to add
    {
        NSEnumerationOptions options = 0; // Default
        
        if (pages == 2) // Handle case of only two content views
        {
            if ((maximumPage > 2) && ([pageSet lastIndex] == maximumPage)) options = NSEnumerationReverse;
        }
        else if (pages == 3) // Handle three content views - show the middle one first
        {
            NSMutableIndexSet *workSet = [pageSet mutableCopy]; options = NSEnumerationReverse;
            
            [workSet removeIndex:[pageSet firstIndex]]; [workSet removeIndex:[pageSet lastIndex]];
            
            NSInteger page = [workSet firstIndex]; [pageSet removeIndex:page];
            
            [self addContentView:scrollView page:page];
        }
        
        [pageSet enumerateIndexesWithOptions:options usingBlock: // Enumerate page set
         ^(NSUInteger page, BOOL *stop)
         {
             [self addContentView:scrollView page:page];
         }
         ];
    }
}

- (void)handleScrollViewDidEnd:(UIScrollView *)scrollView
{
    CGFloat viewWidth = scrollView.bounds.size.width; // Scroll view width
    
    CGFloat contentOffsetX = scrollView.contentOffset.x; // Content offset X
    
    NSInteger page = (contentOffsetX / viewWidth); page++; // Page number
    
    if (page != currentPage) // Only if on different page
    {
        currentPage = page; document.pageNumber = [NSNumber numberWithInteger:page];
        
        [contentViews enumerateKeysAndObjectsUsingBlock: // Enumerate content views
         ^(NSNumber *key, ReaderContentView *contentView, BOOL *stop)
         {
             if ([key integerValue] != page) [contentView zoomResetAnimated:NO];
         }
         ];
        
    }
    
    
    
    if (forceReadTimeForPage > 0) {
        [self handleForceReadForPage:currentPage];
    }
    else {
        
        if (currentPage == maximumPage) {
            if (hasReadToEnd == NO) {
                hasReadToEnd = YES;
                if ([self.mediaOperationDelegate respondsToSelector:@selector(currentMediaPlayEnd:)]) {
                    [self.mediaOperationDelegate currentMediaPlayEnd:self];
                }
            }
        }
    }
    
    [self updatePageNumberView];
    
}

- (void)showDocumentPage:(NSInteger)page
{
    if (page != currentPage) // Only if on different page
    {
        if ((page < minimumPage) || (page > maximumPage)) return;
        
        currentPage = page; document.pageNumber = [NSNumber numberWithInteger:page];
        
        CGPoint contentOffset = CGPointMake((theScrollView.bounds.size.width * (page - 1)), 0.0f);
        
        if (CGPointEqualToPoint(theScrollView.contentOffset, contentOffset) == true)
            [self layoutContentViews:theScrollView];
        else
            [theScrollView setContentOffset:contentOffset];
        
        [contentViews enumerateKeysAndObjectsUsingBlock: // Enumerate content views
         ^(NSNumber *key, ReaderContentView *contentView, BOOL *stop)
         {
             if ([key integerValue] != page) [contentView zoomResetAnimated:NO];
         }
         ];

    }
    
    [self updatePageNumberView];
    
}

- (void)showDocument
{
    [self updateContentSize:theScrollView]; // Update content size first
    
    [self showDocumentPage:[document.pageNumber integerValue]]; // Show page
    
    if (forceReadTimeForPage > 0) {
        NSString *msg = [NSString stringWithFormat:@"该文档每页阅读时间至少为%d秒", (int)forceReadTimeForPage];
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:msg tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed autoHideTime:2.5];
        
        [self handleForceReadForPage:currentPage];
    }
    
    document.lastOpen = [NSDate date]; // Update document last opened date
    
    if ([self.mediaOperationDelegate respondsToSelector:@selector(beginPlayCurrentMedia:)]) {
        [self.mediaOperationDelegate beginPlayCurrentMedia:self];
    }
    
    if ([self.mediaOperationDelegate respondsToSelector:@selector(currentMediaInPlay:)]) {
        [self.mediaOperationDelegate currentMediaInPlay:self];
    }
    
}

- (void)handleForceReadForPage:(NSInteger)page
{
    if (![forceReadMarkDic objectForKey:[NSNumber numberWithInteger:page]]) {
        
        if (page > 1) {
            for (int i = 1; i < page; i++) {
                if (![forceReadMarkDic objectForKey:[NSNumber numberWithInteger:i]]) {
                    [self showDocumentPage:i];
                    break;
                }
            }
        }
        
        [self beginForceRead];
    }
}

- (void)beginForceRead
{
    theScrollView.userInteractionEnabled = NO;
    [self beginTimer];
}

- (void)beginTimer
{
    [self endTimer];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:forceReadTimeForPage target:self selector:@selector(timerAction) userInfo:nil repeats:NO];
}

- (void)endTimer
{
    if (timer) {
        if ([timer isValid]) {
            [timer invalidate];
        }
        timer = nil;
    }
}

- (void)timerAction
{
    theScrollView.userInteractionEnabled = YES;
    [forceReadMarkDic setObject:@"1" forKey:[NSNumber numberWithInteger:currentPage]];
    
    if (currentPage == maximumPage) {
        if (hasReadToEnd == NO) {
            hasReadToEnd = YES;
            if ([self.mediaOperationDelegate respondsToSelector:@selector(currentMediaPlayEnd:)]) {
                [self.mediaOperationDelegate currentMediaPlayEnd:self];
            }
        }
    }
}

- (void)updatePageNumberView
{
    [pageNumberView setText:[NSString stringWithFormat:@"%ld/%ld", (long)currentPage,(long)maximumPage]];
}

#pragma mark - UIScrollViewDelegate methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (ignoreDidScroll == NO)
        [self layoutContentViews:scrollView];
    //NSLog(@"scrollViewDidScroll");
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self handleScrollViewDidEnd:scrollView];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    [self handleScrollViewDidEnd:scrollView];
}

#pragma mark - UIGestureRecognizerDelegate methods

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)recognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([touch.view isKindOfClass:[UIScrollView class]]) return YES;
    
    return NO;
}

#pragma mark - UIGestureRecognizer action methods

- (void)decrementPageNumber
{
    if ((maximumPage > minimumPage) && (currentPage != minimumPage))
    {
        CGPoint contentOffset = theScrollView.contentOffset; // Offset
        
        contentOffset.x -= theScrollView.bounds.size.width; // View X--
        
        [theScrollView setContentOffset:contentOffset animated:YES];
    }
}

- (void)incrementPageNumber
{
    if ((maximumPage > minimumPage) && (currentPage != maximumPage))
    {
        CGPoint contentOffset = theScrollView.contentOffset; // Offset
        
        contentOffset.x += theScrollView.bounds.size.width; // View X++
        
        [theScrollView setContentOffset:contentOffset animated:YES];
    }
}

- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateRecognized)
    {
        CGRect viewRect = recognizer.view.bounds; // View bounds
        
        CGPoint point = [recognizer locationInView:recognizer.view]; // Point
        
        CGRect areaRect = CGRectInset(viewRect, TAP_AREA_SIZE, 0.0f); // Area rect
        
        if (CGRectContainsPoint(areaRect, point) == true) // Single tap is inside area
        {
            NSNumber *key = [NSNumber numberWithInteger:currentPage]; // Page number key
            
            ReaderContentView *targetView = [contentViews objectForKey:key]; // View
            
            id target = [targetView processSingleTap:recognizer]; // Target object
            
            if (target != nil) // Handle the returned target object
            {
                if ([target isKindOfClass:[NSURL class]]) // Open a URL
                {
                    NSURL *url = (NSURL *)target; // Cast to a NSURL object
                    
                    if (url.scheme == nil) // Handle a missing URL scheme
                    {
                        NSString *www = url.absoluteString; // Get URL string
                        
                        if ([www hasPrefix:@"www"] == YES) // Check for 'www' prefix
                        {
                            NSString *http = [[NSString alloc] initWithFormat:@"http://%@", www];
                            
                            url = [NSURL URLWithString:http]; // Proper http-based URL
                        }
                    }
                    
                    if ([[UIApplication sharedApplication] openURL:url] == NO)
                    {
#ifdef DEBUG
                        NSLog(@"%s '%@'", __FUNCTION__, url); // Bad or unknown URL
#endif
                    }
                }
                else // Not a URL, so check for another possible object type
                {
                    if ([target isKindOfClass:[NSNumber class]]) // Goto page
                    {
                        NSInteger number = [target integerValue]; // Number
                        
                        [self showDocumentPage:number]; // Show the page
                    }
                }
            }
            else // Nothing active tapped in the target content view
            {
            }
            
            return;
        }
        
        CGRect nextPageRect = viewRect;
        nextPageRect.size.width = TAP_AREA_SIZE;
        nextPageRect.origin.x = (viewRect.size.width - TAP_AREA_SIZE);
        
        if (CGRectContainsPoint(nextPageRect, point) == true) // page++
        {
            [self incrementPageNumber]; return;
        }
        
        CGRect prevPageRect = viewRect;
        prevPageRect.size.width = TAP_AREA_SIZE;
        
        if (CGRectContainsPoint(prevPageRect, point) == true) // page--
        {
            [self decrementPageNumber]; return;
        }
    }
}

- (void)handleDoubleTap:(UITapGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateRecognized)
    {
        CGRect viewRect = recognizer.view.bounds; // View bounds
        
        CGPoint point = [recognizer locationInView:recognizer.view]; // Point
        
        CGRect zoomArea = CGRectInset(viewRect, TAP_AREA_SIZE, TAP_AREA_SIZE); // Area
        
        if (CGRectContainsPoint(zoomArea, point) == true) // Double tap is inside zoom area
        {
            NSNumber *key = [NSNumber numberWithInteger:currentPage]; // Page number key
            
            ReaderContentView *targetView = [contentViews objectForKey:key]; // View
            
            switch (recognizer.numberOfTouchesRequired) // Touches count
            {
                case 1: // One finger double tap: zoom++
                {
                    [targetView zoomIncrement:recognizer]; break;
                }
                    
                case 2: // Two finger double tap: zoom--
                {
                    [targetView zoomDecrement:recognizer]; break;
                }
            }
            
            return;
        }
        
        CGRect nextPageRect = viewRect;
        nextPageRect.size.width = TAP_AREA_SIZE;
        nextPageRect.origin.x = (viewRect.size.width - TAP_AREA_SIZE);
        
        if (CGRectContainsPoint(nextPageRect, point) == true) // page++
        {
            [self incrementPageNumber]; return;
        }
        
        CGRect prevPageRect = viewRect;
        prevPageRect.size.width = TAP_AREA_SIZE;
        
        if (CGRectContainsPoint(prevPageRect, point) == true) // page--
        {
            [self decrementPageNumber]; return;
        }
    }
}



@end
