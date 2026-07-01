//
//  WSNavigationBar.m
//  NavigationDemo
//
//  Created by melody on 13-11-25.
//  Copyright (c) 2013年 melody. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "WSNavigationBar.h"
#import "JFTakeCountButton.h"

#define kNavTitleFontSize     (INTERFACE_IS_PHONE ? 15 : 16)

///////////////////////

NSString * NTPathForBundleResource(NSString *relativePath) {
    NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
    return [resourcePath stringByAppendingPathComponent:relativePath];
}

///////////////////////

UIImage * NTLoadImageFromBundle(NSString *imageName) {
    NSString *relativePath = [NSString stringWithFormat:@"NavTab.bundle/images/%@", imageName];
    NSString *path  = NTPathForBundleResource(relativePath);
    NSData *data = [NSData dataWithContentsOfFile:path];
    return [UIImage imageWithData:data];
}




@implementation UIViewController(NavTab)



- (UIBarButtonItem *)_createBarButtonTitle:(NSString *)title target:(id)target action:(SEL)selector
{
    UIButton *btn = [[UIButton alloc] init];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    [btn.titleLabel setFont:[UIFont systemFontOfSize:kNavTitleFontSize]];
    UIColor *titleColor = [UIColor colorForKey:@"NavigationBarTitleColor"];
    if (titleColor) {
        [btn setTitleColor:titleColor forState:UIControlStateNormal];
    }
    [btn sizeToFit];
    
    UIBarButtonItem *btnItem= [[UIBarButtonItem alloc] initWithCustomView:btn];
    return btnItem;
}



- (UIBarButtonItem *)_createBarButton:(NSString *)image target:(id)target action:(SEL)selector
{
    UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
    [btn addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    if (image) {
        [btn setBackgroundImage:[[UIImage imageNamed:image] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    }
    [btn sizeToFit];
    UIBarButtonItem *btnItem=[[UIBarButtonItem alloc] initWithCustomView:btn];
    return btnItem;
}


- (UIBarButtonItem *)_createBarButton:(NSString *)image target:(id)target action:(SEL)selector title:(NSString *)title
{
    UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:title forState:UIControlStateNormal];
    UIColor *navBarButtonTitleColor = [UIColor colorForKey:@"NavigationBarButtonTitleColor"];
    if (!navBarButtonTitleColor) {
        navBarButtonTitleColor = [UIColor colorWithRed:63.0/255.0 green:175.0/255.0 blue:246.0/255.0 alpha:1.0];;
    }
    [btn setTitleColor:navBarButtonTitleColor forState:UIControlStateNormal];
    btn.titleEdgeInsets = UIEdgeInsetsMake(0, 13, 0, 10);
    [btn addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    if (image) {
        UIImage *img = [[UIImage imageNamed:image] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        img = [img stretchableImageWithLeftCapWidth:20 topCapHeight:10];
        [btn setBackgroundImage:img forState:UIControlStateNormal];
    }
    [btn.titleLabel setFont:[UIFont systemFontOfSize:kNavTitleFontSize]];
    [btn sizeToFit];
    UIBarButtonItem *btnItem=[[UIBarButtonItem alloc] initWithCustomView:btn];
    return btnItem;
}




- (UIBarButtonItem *)_createBarButton:(NSString *)image target:(id)target action:(SEL)selector title:(NSString *)title font:(UIFont *)font buttonWidth:(CGFloat)width fontLeftWidth:(CGFloat)fontWidth
{
    UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, width, 44);
    [btn setTitle:title forState:UIControlStateNormal];
    UIColor *navBarButtonTitleColor = [UIColor colorForKey:@"NavigationBarButtonTitleColor"];
    if (!navBarButtonTitleColor) {
        navBarButtonTitleColor = [UIColor colorWithRed:63.0/255.0 green:175.0/255.0 blue:246.0/255.0 alpha:1.0];
    }
    [btn setTitleColor:navBarButtonTitleColor forState:UIControlStateNormal];
    btn.titleEdgeInsets = UIEdgeInsetsMake(0, fontWidth, 0, 0);
    [btn addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    if (image) {
        UIImage *img = [[UIImage imageNamed:image] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        img = [img stretchableImageWithLeftCapWidth:40 topCapHeight:10];
        [btn setBackgroundImage:img forState:UIControlStateNormal];
    }
    [btn.titleLabel setFont:font];
    //[btn sizeToFit];
    UIBarButtonItem *btnItem=[[UIBarButtonItem alloc] initWithCustomView:btn];
    return btnItem;
}



- (void)pop{
    [self.navigationController popViewControllerAnimated:YES];
}



- (void)popToRoot{
    [self.navigationController popToRootViewControllerAnimated:YES];
}



- (UIBarButtonItem *)barButtonItemTitle:(NSString *)title target:(id)target action:(SEL)selector{
    return [self _createBarButtonTitle:title
                                                                target:target
                                                                action:selector];
}




- (UIBarButtonItem *)barButtonItemImage:(NSString *)imageName target:(id)target action:(SEL)selector{
    
    return [self _createBarButton:imageName
                                                           target:target
                                                           action:selector];
}


- (UIBarButtonItem *)barButtonItemImage:(NSString *)imageName target:(id)target action:(SEL)selector title:(NSString *)title{
    return [self _createBarButton:imageName
                                                           target:target
                                                           action:selector
                                                            title:title];
}

- (UIBarButtonItem *)barButtonItemImage:(NSString *)imageName target:(id)target action:(SEL)selector title:(NSString *)title font:(UIFont *)font buttonWidth:(CGFloat)width fontLeftWith:(CGFloat)fontWidth{
    return [self _createBarButton:imageName
                                                          target:target
                                                          action:selector
                                                           title:title font:font buttonWidth:width fontLeftWidth:fontWidth];
}


- (void)leftItemTitle:(NSString *)title target:(id)target action:(SEL)selector{
    self.navigationItem.leftBarButtonItem=[self _createBarButtonTitle:title
                                                               target:target
                                                               action:selector];
}




- (void)leftItemImage:(NSString *)imageName target:(id)target action:(SEL)selector{
    self.navigationItem.leftBarButtonItem=[self _createBarButton:imageName
                                                          target:target
                                                          action:selector];
}


- (void)leftItemImage:(NSString *)imageName target:(id)target action:(SEL)selector title:(NSString *)title{
    self.navigationItem.leftBarButtonItem=[self _createBarButton:imageName
                                                          target:target
                                                          action:selector
                                                           title:title];
}

- (void)leftItemImage:(NSString *)imageName target:(id)target action:(SEL)selector title:(NSString *)title font:(UIFont *)font buttonWidth:(CGFloat)width fontLeftWith:(CGFloat)fontWidth{
    self.navigationItem.leftBarButtonItem=[self _createBarButton:imageName
                                                          target:target
                                                          action:selector
                                                           title:title font:font buttonWidth:width fontLeftWidth:fontWidth];
}

- (void)leftItemBack:(NSString *)imageName title:(NSString *)title{
    
    self.navigationItem.leftBarButtonItem=[self _createBarButton:imageName
                                                          target:self
                                                          action:@selector(pop)
                                                           title:title
                                           ];
    
}

- (void) backItemAction:(SEL)selector target:(id)target withDelay:(int)delaySecond
{
    if (!self.navigationController.viewControllers || self.navigationController.viewControllers.count <= 1) {
        return;
    }
    
    if (delaySecond <= 0) {
        //        [self backItemAction:selector target:target];
        [self backItemHomeAction:selector target:target];
        return;
    }
    UIColor *navBarButtonTitleColor = [UIColor colorForKey:@"NavigationBarButtonTitleColor"];
    if (!navBarButtonTitleColor) {
        navBarButtonTitleColor = [UIColor colorWithRed:63.0/255.0 green:175.0/255.0 blue:246.0/255.0 alpha:1.0];
    }
    
    UIFont *font = nil;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        font = [UIFont systemFontOfSize:18];
    }else {
        font = [UIFont systemFontOfSize:16];
    }
    
    __block JFTakeCountButton *btn = [JFTakeCountButton initWithCount:delaySecond
                                                            withTitle:nil
                                                       withTitleColor:navBarButtonTitleColor
                                                        withTitleFont:font
                                                            withBlock:^{
                                                                if (!selector || !target) {
                                                                    [btn addTarget:self action:@selector(popToRoot) forControlEvents:UIControlEventTouchUpInside];
                                                                }else {
                                                                    [btn addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
                                                                }
                                                                [btn setImage:[UIImage scaledImageForName:@"icon_home" ofType:@"png"] forState:UIControlStateNormal];
//                                                                [btn setImage:[UIImage imageForName:@"icon_back_press.png"] forState:UIControlStateHighlighted];
                                                            }];
    [btn startTakeCount];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
}

- (void) backItemHomeAction:(SEL)selector target:(id)target
{
    if (!self.navigationController.viewControllers || self.navigationController.viewControllers.count <= 1) {
        return;
    }
    UIButton *homeButton=[UIButton buttonWithType:UIButtonTypeCustom];
    homeButton.frame = CGRectMake(0, 0, MAIN_BUTTON_WH, MAIN_BUTTON_WH);
    [homeButton setTitle:nil forState:UIControlStateNormal];
    UIColor *navBarButtonTitleColor = [UIColor colorForKey:@"NavigationBarButtonTitleColor"];
    if (!navBarButtonTitleColor) {
        navBarButtonTitleColor = [UIColor colorWithRed:63.0/255.0 green:175.0/255.0 blue:246.0/255.0 alpha:1.0];
    }
    [homeButton setTitleColor:navBarButtonTitleColor forState:UIControlStateNormal];
    if (!selector || !target) {
        [homeButton addTarget:self action:@selector(pop) forControlEvents:UIControlEventTouchUpInside];
    }else {
        [homeButton addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    }
    
    [homeButton setImage:[[UIImage imageForName:@"icon_home.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [homeButton setImage:[UIImage imageForName:@"icon_home_press.png"] forState:UIControlStateHighlighted];
    
    
    UIFont *font = nil;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        font = [UIFont systemFontOfSize:18];
    }else {
        font = [UIFont systemFontOfSize:16];
    }
    [homeButton.titleLabel setFont:font];
    //[btn sizeToFit];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:homeButton];
}

- (void) backItemAction:(SEL)selector target:(id)target
{
    WCBaseViewController * con;
    if ([target isKindOfClass:[WCBaseViewController class]]) {
        con = (WCBaseViewController *)target;
    }
    if (!self.navigationController.viewControllers || self.navigationController.viewControllers.count <= 1) {
        return;
    }
    
    UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, MAIN_BUTTON_WH, MAIN_BUTTON_WH);
    [btn setTitle:nil forState:UIControlStateNormal];
    UIColor *navBarButtonTitleColor = [UIColor colorForKey:@"NavigationBarButtonTitleColor"];
    if (!navBarButtonTitleColor) {
        navBarButtonTitleColor = [UIColor colorWithRed:63.0/255.0 green:175.0/255.0 blue:246.0/255.0 alpha:1.0];
    }
    [btn setTitleColor:navBarButtonTitleColor forState:UIControlStateNormal];
    if (!selector || !target) {
        [btn addTarget:self action:@selector(pop) forControlEvents:UIControlEventTouchUpInside];
    }else {
        // SFA-13264  如果是登录弹出的页面，则不需要添加返回键
        if (!(con && con.currentFuncs.isloginRedirectFcWillShow)) {
            [btn addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
        }
        
    }
    
    UIImage *image ;
     if (!(con && con.currentFuncs.isloginRedirectFcWillShow)) {
        image = [[UIImage scaledImageForName:@"icon_back" ofType:@"png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
     }
    [btn setImage:image forState:UIControlStateNormal];
    
//    [btn setImage:[UIImage imageForName:@"icon_back_press.png"] forState:UIControlStateHighlighted];
    
    UIFont *font = nil;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        font = [UIFont systemFontOfSize:18];
    }else {
        font = [UIFont systemFontOfSize:16];
    }
    [btn.titleLabel setFont:font];
    //[btn sizeToFit];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
}


- (void)clearRightItem{
    self.navigationItem.rightBarButtonItem=nil;
}


- (void)clearLeftItem{
    self.navigationItem.leftBarButtonItem = nil;
}


- (void)navBarHidden:(BOOL)hide
{
    [self.navigationController setNavigationBarHidden:hide];
}


- (void) tabBarHidden:(BOOL) hidden{
    float cHeight=self.tabBarController.tabBar.frame.size.height;
    for(UIView *view in self.tabBarController.view.subviews)
    {
        if([view isKindOfClass:[UITabBar class]])
        {
            if (hidden) {
                [view setFrame:CGRectMake(view.frame.origin.x, 480, view.frame.size.width, view.frame.size.height)];
            } else {
                [view setFrame:CGRectMake(view.frame.origin.x, 480 - cHeight, view.frame.size.width, view.frame.size.height)];
            }
        }
        else
        {
            
            if (hidden) {
                [view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, 480)];
            } else {
                [view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, 480 - cHeight)];
            }
        }
    }
}


- (void) tabBarHiddenAnimated:(BOOL) hidden{
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.35];
    float cHeight=self.tabBarController.tabBar.frame.size.height;
    for(UIView *view in self.tabBarController.view.subviews)
    {
        if([view isKindOfClass:[UITabBar class]])
        {
            if (hidden) {
                [view setFrame:CGRectMake(view.frame.origin.x, 480, view.frame.size.width, view.frame.size.height)];
            } else {
                [view setFrame:CGRectMake(view.frame.origin.x, 480 - cHeight, view.frame.size.width, view.frame.size.height)];
            }
        }
        else
        {
            if (hidden) {
                [view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, 480)];
            } else {
                [view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, 480 - cHeight)];
            }
        }
    }
    [UIView commitAnimations];
    
}


@end


@implementation UINavigationBar (LazyNavigationBar)

+ (Class)class {
    return NSClassFromString(@"CustomNavigationBar");
}

@end

@implementation UINavigationItem (NaviItemCategory)

- (void)setLeftBarButtonItem:(UIBarButtonItem *)leftBarButtonItem{
    if(leftBarButtonItem == nil){
        self.leftBarButtonItems = nil;
        return;
    }
    UIBarButtonItem *spaceButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    spaceButtonItem.width = -12;
    if (IOS7_OR_LATER) {
        if (leftBarButtonItem){
            [self setLeftBarButtonItems:@[spaceButtonItem, leftBarButtonItem]];
        }  else {
            [self setLeftBarButtonItems:@[spaceButtonItem]];
        }
    }else {
        [self setLeftBarButtonItems:@[leftBarButtonItem]];
    }
    
}

@end

@implementation CustomNavigationBar

-(void) setBackgroundWith:(UIImage*)backgroundImage
{
    _image=backgroundImage;
    [self setNeedsDisplay];
}

-(void)setShadow:(BOOL)shadow
{
    isShadow=shadow;
    [self setNeedsDisplay];
}


//-(void)drawRect:(CGRect)rect {
//    if(_image==nil){
//        [super drawRect:rect];
//    }else{
//        if(isShadow){
//            self.tintColor = [UIColor colorWithRed:46.0 / 255.0 green:149.0 / 255.0 blue:206.0 / 255.0 alpha:1.0];
//            // draw shadow
//            self.layer.masksToBounds = NO;
//            self.layer.shadowOffset = CGSizeMake(0, 3);
//            self.layer.shadowOpacity = 0.6;
//            self.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.bounds].CGPath;
//        }else{
//            
//            
//        }
//        [_image drawInRect:rect];
//    }
//}

@end






@implementation UITabBarController(NavTabRoot)


- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item{
    if([self.tabBar viewWithTag:9999]!=nil){
        [UIView animateWithDuration:0.5 animations:^{
            NSArray *array=tabBar.items;
            float x = self.tabBar.frame.size.width/[array count]*item.tag;
            [[self.tabBar viewWithTag:9999] setFrame:CGRectMake(x, 0, tabBar.frame.size.width/[array count], tabBar.frame.size.height)];
            
        }];
    }else if([self.tabBar viewWithTag:1000]!=nil){
        NSArray *array=tabBar.items;
        for(int i=0;i<[array count];i++){
            [[self.tabBar viewWithTag:i+10000] setHidden:NO];
            [[self.tabBar viewWithTag:i+1000] setHidden:YES];
        }
        [[self.tabBar viewWithTag:item.tag+10000] setHidden:YES];
        [[self.tabBar viewWithTag:item.tag+1000] setHidden:NO];
        
    }
}

- (void)setIndicatorImage:(UIImage *)indicatorImage animated:(BOOL)animated{
    if(animated==YES){
        [self.tabBar setSelectionIndicatorImage:NTLoadImageFromBundle(@"null.png")];
        NSArray *array=self.tabBar.items;
        UIImageView *imageView=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.tabBar.frame.size.width/[array count], self.tabBar.frame.size.height)];
        imageView.image=indicatorImage;
        imageView.tag=9999;
        [self.tabBar addSubview:imageView];
    }else{
        [self.tabBar setSelectionIndicatorImage:indicatorImage];
    }
}


- (void) setSelectColor:(UIColor *)selectColor bgColor:(UIColor *)bgColor{
    [self.tabBar setSelectedImageTintColor:selectColor];
    [self.tabBar setTintColor:bgColor];
}


- (void) setBackgroundWith:(UIImage *)image{
    self.tabBar.backgroundImage=image;
}

- (void) setNViewControllers:(NSArray*)controllers{
    NSMutableArray *nArray=[NSMutableArray  arrayWithCapacity:10];
    for(int i=0;i<[controllers count];i++){
        UINavigationController *nav=[[UINavigationController alloc] initWithRootViewController:[controllers objectAtIndex:i]];
        [nArray addObject:nav];
    }
    [self setViewControllers:nArray];
}

- (void) setTitles:(NSArray *)titles imageNames:(NSArray *)imageNames{
    BOOL setTitle=YES;
    if(titles==nil||[titles count]!=[imageNames count]){
        setTitle=NO;
    }
    NSMutableArray *array=[NSMutableArray arrayWithCapacity:10];
    for(int i=0;i<[imageNames count];i++){
        UITabBarItem *item=nil;
        if(setTitle){
            item = [[UITabBarItem alloc] initWithTitle: [titles objectAtIndex:i] image:[UIImage imageNamed: [imageNames objectAtIndex:i]] tag: i];
            
        }else{
            item = [[UITabBarItem alloc] initWithTitle: nil image:[UIImage imageNamed: [imageNames objectAtIndex:i]]  tag: i];
        }
        [array addObject:item];
    }
    if([self.viewControllers count]!=[array count]){
        return;
    }
    for(int i=0;i<[self.viewControllers count];i++){
        [[self.viewControllers objectAtIndex:i] setTabBarItem:[array objectAtIndex:i]];
    }
}

//- (void) setSelectImageNames:(NSArray *)selectImageNames unSelectImageNames:(NSArray *)unSelectImageNames {
//    NSMutableArray *array=[NSMutableArray arrayWithCapacity:10];
//    for(int i=0;i<[selectImageNames count];i++){
//        UITabBarItem* item=[[UITabBarItem alloc]init];
//        item.tag=i;
//        [item setFinishedSelectedImage:[UIImage imageNamed: [selectImageNames objectAtIndex:i]] withFinishedUnselectedImage:[UIImage imageNamed: [unSelectImageNames objectAtIndex:i]]];
//        [array addObject:item];
//    }
//    if([self.viewControllers count]!=[array count]){
//        return;
//    }
//    for(int i=0;i<[self.viewControllers count];i++){
//        [[self.viewControllers objectAtIndex:i] setTabBarItem:[array objectAtIndex:i]];
//    }
//}

- (void) setMDSelectImageNames:(NSArray *)selectImageNames unSelectImageNames:(NSArray *)unSelectImageNames selectIndex:(int)index{
    
    NSMutableArray *array=[NSMutableArray arrayWithCapacity:10];
    
    CGRect frame=self.tabBar.frame;
    float cWidth=frame.size.width/[self.viewControllers count];
    float cHeight=frame.size.height;
    
    for(int i=0;i<[self.viewControllers count];i++){
        UITabBarItem* item= item = [[UITabBarItem alloc] initWithTitle: @" "  image:NTLoadImageFromBundle(@"null.png") tag: i];
        [array addObject:item];
        UIImageView *selImageView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:[selectImageNames objectAtIndex:i]]];
        selImageView.frame=CGRectMake(cWidth*i, 0, cWidth, cHeight);
        selImageView.tag=i+1000;
        if(i==index){
            selImageView.hidden=NO;
        }else{
            selImageView.hidden=YES;
        }
        [self.tabBar addSubview:selImageView];
        UIImageView *unSelImageView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:[unSelectImageNames objectAtIndex:i]]];
        unSelImageView.frame=CGRectMake(cWidth*i, 0, cWidth, cHeight);
        unSelImageView.tag=i+10000;
        if(i==index){
            unSelImageView.hidden=YES;
        }else{
            unSelImageView.hidden=NO;
        }
        [self.tabBar addSubview:unSelImageView];
    }
    if([self.viewControllers count]!=[array count]){
        return;
    }
    for(int i=0;i<[self.viewControllers count];i++){
        [[self.viewControllers objectAtIndex:i] setTabBarItem:[array objectAtIndex:i]];
    }
    self.selectedIndex=index;
}


@end
