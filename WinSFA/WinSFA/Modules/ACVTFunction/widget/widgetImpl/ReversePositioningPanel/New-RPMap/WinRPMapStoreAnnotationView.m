//
//  WinRPMapStoreAnnotationView.m
//  WinSFA
//
//  Created by yuanji on 2019/7/10.
//  Copyright © 2019 WinChannel. All rights reserved.
//

#import "WinRPMapStoreAnnotationView.h"
#import "WinRPMapCalloutView.h"
//=================================================================================================================================

#pragma mark - RP地图商户大头针 延展(内部)
@interface WinRPMapStoreAnnotationView ()

@property (nonatomic, strong) WinRPMapCalloutView *calloutView; //标注视图

@end
//=================================================================================================================================

#pragma mark - RP地图商户大头针
@implementation WinRPMapStoreAnnotationView

#pragma mrk - 重写initWithAnnotation:reuseIdentifier:方法
- (id)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier {
    
    if (self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier]) {
        
        self.clipsToBounds = NO;
        self.canShowCallout = NO;
        self.image = [UIImage imageNamed:@"search_point_icon"];
        
        _calloutView = [[WinRPMapCalloutView alloc] initWithFrame:CGRectZero];
        _calloutView.backgroundColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.6f];
        _calloutView.layer.borderWidth = 1.0f;
        _calloutView.layer.borderColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.8f].CGColor;
        _calloutView.layer.cornerRadius = 5.0f;
        [self addSubview:_calloutView];
        _calloutView.hidden = YES;
    }
    
    return self;
}

#pragma mark - 重载用户大头针方法
- (void)setAnnotation:(id<MKAnnotation>)annotation {
    
    [super setAnnotation:annotation];
    
    CGFloat width = [UIScreen mainScreen].bounds.size.width - (15.0f * 2);
    CGSize size = [WinRPMapCalloutView getCalloutViewSizeWithTitle:annotation.title
                                                          subtitle:annotation.subtitle
                                                          maxWidth:width];
    CGFloat x = (self.frame.size.width - size.width) / 2.0;
    CGFloat y = -size.height - 1.0f;
    self.calloutView.frame = CGRectMake(x, y, size.width, size.height);
    [self.calloutView setCalloutViewWithTitle:annotation.title subtitle:annotation.subtitle];
}

#pragma mark - 隐藏标注视图方法
- (void)hideCalloutView {
    
    self.calloutView.hidden = YES;
}

#pragma mark - 显示标注视图方法
- (void)showCalloutView {
    
    self.calloutView.hidden = NO;
}

@end
//=================================================================================================================================
