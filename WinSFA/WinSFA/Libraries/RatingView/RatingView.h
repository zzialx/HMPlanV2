//
//  RatingViewController.h
//  RatingController
//
//  Created by Ajay on 2/28/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RatingView;

@protocol RatingViewDelegate <NSObject>
-(void)ratingView:(RatingView *)ratingView ratingChanged:(float)newRating;
@end


@interface RatingView : UIView {

	UIImage *unselectedImage, *partlySelectedImage, *fullySelectedImage;

	float starRating, lastRating;
	float height, width; // of each image of the star!
    
    NSMutableArray *imageViewArray;
}

@property (nonatomic, assign) float itemGap;
@property (nonatomic, assign) NSInteger totalStarNum;
@property (nonatomic, weak) id<RatingViewDelegate> delegate;
@property (nonatomic, assign) BOOL isSupportHalfStatr;   //default is YES

- (id)initWithFrame:(CGRect)frame andTotalStarNum:(NSInteger)totalStarNum;

-(void)setImagesDeselected:(NSString *)unselectedImage partlySelected:(NSString *)partlySelectedImage 
			  fullSelected:(NSString *)fullSelectedImage andDelegate:(id<RatingViewDelegate>)d;
-(void)displayRating:(float)rating;
-(float)rating;

@end
