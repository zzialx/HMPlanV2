//
//  WCMKCallOutAnnotationView.m
//  WinChannelFrameWork
//
//  Created by xiaotang.wang on 5/10/13.
//
//

#import "WSMKCallOutAnnotationView.h"
#import <QuartzCore/QuartzCore.h>

#define  KArrowHeight 15

@implementation WSMKCallOutAnnotationView

@synthesize iContentView = _iContentView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithAnnotation:(id <MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.canShowCallout = NO;
        self.centerOffset = CGPointMake(0, -75);
        self.frame = CGRectMake(0, 0, 240, 110);
        self.iContentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height-KArrowHeight)];
        self.iContentView.backgroundColor = [UIColor clearColor];
        [self addSubview:self.iContentView];
    }
    return self;
}

- (void)layoutSubviews
{
    CGRect rect = self.bounds;
    self.iContentView.frame = CGRectMake(0, 0, rect.size.width, rect.size.height-KArrowHeight);
}

- (void)prepareForReuse
{
    NSArray *subViews = [self.iContentView subviews];
    for (UIView *item in subViews) {
        [item removeFromSuperview];
    }
}


-(void)drawInContext:(CGContextRef)context
{
	
    CGContextSetLineWidth(context, 2.0);
    //    [[[UIColor blackColor] colorWithAlphaComponent:.6] setStroke];
    CGContextSetFillColorWithColor(context, [[UIColor blackColor] colorWithAlphaComponent:.6].CGColor);
    [self getDrawPath:context];
    CGContextFillPath(context);
}
- (void)getDrawPath:(CGContextRef)context
{
    CGRect rrect = self.bounds;
	CGFloat radius = 6.0;
    
	CGFloat minx = CGRectGetMinX(rrect),
    midx = CGRectGetMidX(rrect),
    maxx = CGRectGetMaxX(rrect);
	CGFloat miny = CGRectGetMinY(rrect),
    // midy = CGRectGetMidY(rrect),
    maxy = CGRectGetMaxY(rrect)-KArrowHeight;
    CGContextMoveToPoint(context, midx+KArrowHeight, maxy);
    CGContextAddLineToPoint(context,midx, maxy+KArrowHeight);
    CGContextAddLineToPoint(context,midx-KArrowHeight, maxy);
    
    CGContextAddArcToPoint(context, minx, maxy, minx, miny, radius);
    CGContextAddArcToPoint(context, minx, minx, maxx, miny, radius);
    CGContextAddArcToPoint(context, maxx, miny, maxx, maxx, radius);
    CGContextAddArcToPoint(context, maxx, maxy, midx, maxy, radius);
    CGContextClosePath(context);
}



// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
	[self drawInContext:UIGraphicsGetCurrentContext()];
    self.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.layer.shadowOpacity = 1.0;
    self.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
}


@end
