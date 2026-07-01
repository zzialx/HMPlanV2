//
//  RatingViewController.m
//  RatingController
//
//  Created by Ajay on 2/28/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "RatingView.h"

static NSString *kRatingViewFullStarImageName = @"star_selected_";      //满星星图片名称标示
static NSString *kRatingViewHalfStarImageName = @"star_halfselected_";  //半星星图片名称标示
static NSString *kRatingViewEmptyStarImageName = @"star_unselected_";   //空星星图片名称标示

@interface RatingView ()

@property (nonatomic, assign) BOOL isMoreImageState; //是否多图状态

@end


@implementation RatingView

@synthesize itemGap;

- (id)initWithFrame:(CGRect)frame andTotalStarNum:(NSInteger)totalStarNum
{
    self = [super initWithFrame:frame];
    if (self) {
        self.totalStarNum = totalStarNum;
        imageViewArray = [NSMutableArray arrayWithCapacity:self.totalStarNum];
        _isSupportHalfStatr = YES;
        _isMoreImageState = NO;
    }
    return self;
}


-(void)setImagesDeselected:(NSString *)deselectedImage
			partlySelected:(NSString *)halfSelectedImage
			  fullSelected:(NSString *)fullSelectedImage
			   andDelegate:(id<RatingViewDelegate>)d {
    
    //MMSH-7382
    UIImage *validateImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@0", kRatingViewEmptyStarImageName]];
    if (validateImage) {
        unselectedImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@0", kRatingViewEmptyStarImageName]];
        partlySelectedImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@0", kRatingViewHalfStarImageName]];
        fullySelectedImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@0", kRatingViewFullStarImageName]];
        self.isMoreImageState = YES;
    } else {
        unselectedImage = [UIImage imageNamed:deselectedImage];
        partlySelectedImage = halfSelectedImage == nil ? unselectedImage : [UIImage imageNamed:halfSelectedImage];
        fullySelectedImage = [UIImage imageNamed:fullSelectedImage];
        self.isMoreImageState = NO;
    }
	self.delegate = d;
    
    height = self.frame.size.height;
    width = height * fullySelectedImage.size.width / fullySelectedImage.size.height;
	
	starRating = 0;
	lastRating = 0;
    
    if (self.totalStarNum <= 0) {
        self.totalStarNum = 5;
    }
    
    for (int i = 0; i < self.totalStarNum; i++) {
        //MMSH-7382
        UIImage *tempImage = unselectedImage;
        if (self.isMoreImageState) {
            tempImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@%d", kRatingViewEmptyStarImageName, i]];
        }

        UIImageView *imageView = [[UIImageView alloc] initWithImage:tempImage];
        [imageView setFrame:CGRectMake(i * (width + itemGap), 0, width, height)];
        [imageView setUserInteractionEnabled:NO];
        [self addSubview:imageView];
        [imageViewArray addObject:imageView];
    }
	
	CGRect frame = [self frame];
	frame.size.width = (width + itemGap) * 5;
//	frame.size.height = height;
	[self setFrame:frame];
}

-(void)displayRating:(float)rating {
    
    for (int i = 0; i < [imageViewArray count]; i++) {
        
        //MMSH-7382
        UIImageView *imageView = [imageViewArray objectAtIndex:i];
        if (self.isMoreImageState) {
            UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"%@%d", kRatingViewEmptyStarImageName, i]];
            [imageView setImage:image];
        } else {
            [imageView setImage:unselectedImage];
        }

        if (rating > 0.3) {
            
            BOOL isHandle = NO;
            if (self.isSupportHalfStatr) {
                if (rating > i) {
                    if (self.isMoreImageState) {
                        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"%@%d", kRatingViewHalfStarImageName, i]];
                        [imageView setImage:image];
                    } else {
                        [imageView setImage:partlySelectedImage];
                    }
                }
                if (rating > (i + 0.5)) {
                    if (self.isMoreImageState) {
                        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"%@%d", kRatingViewFullStarImageName, i]];
                        [imageView setImage:image];
                    } else {
                        [imageView setImage:fullySelectedImage];
                    }
                    isHandle = YES;
                }
            }else {
                if (rating > i) {
                    if (self.isMoreImageState) {
                        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"%@%d", kRatingViewFullStarImageName, i]];
                        [imageView setImage:image];
                    } else {
                        [imageView setImage:fullySelectedImage];
                    }
                    isHandle = YES;
                }
            }
            
            if (self.isMoreImageState && isHandle) {
                NSInteger index = floor(rating);
                index = (index >= self.totalStarNum) ? (self.totalStarNum - 1) : index;
                UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"%@%ld", kRatingViewFullStarImageName, index]];
                if (image) {
                    [imageView setImage:image];
                }
            }
        }
    }
	
	starRating = rating;
	lastRating = rating;
    
    NSInteger x = rating / 1;
    if (self.isSupportHalfStatr) {
        
        if (rating > 0.3) {
            if (rating - x > 0.5) {
                rating = x + 1;
            }
            else if ((rating - x) <= 0.5 && (rating - x) > 0)
            {
                rating = x + 0.5;
            }
        }
    }else {
        if (rating > 0.3) {
            if (rating - x > 0) {
                rating = x + 1;
            }
        }
    }
    
    //MMSH-7382
    if ([self.delegate respondsToSelector:@selector(ratingView:ratingChanged:)]) {
        [self.delegate ratingView:self ratingChanged:((rating <= 0.3) ? 0.0f : rating)];
    }
}

-(void) touchesBegan: (NSSet *)touches withEvent: (UIEvent *)event
{
	[self touchesMoved:touches withEvent:event];
}

-(void) touchesMoved: (NSSet *)touches withEvent: (UIEvent *)event
{
	CGPoint pt = [[touches anyObject] locationInView:self];
	float newRating = (pt.x / (width + itemGap));
	if (newRating < 0 || newRating > 5)
		return;
	
	if (newRating != lastRating)
		[self displayRating:newRating];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
	[self touchesMoved:touches withEvent:event];
}

-(float)rating {
	return starRating;
}

@end
