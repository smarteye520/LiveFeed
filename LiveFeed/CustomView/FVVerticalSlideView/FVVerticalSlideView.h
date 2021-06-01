//
//  FVVerticalSlideView.h
//  LiveFeed
//
//  Created by echoLive on 11/20/20.
//  Copyright © 2020 Smart Eye. All rights reserved.
//


#import <UIKit/UIKit.h>

@protocol FVVerticalSliderViewDelegate <NSObject>

@optional
-(void) startMovingSliderView;
-(void) movingSliderView:(float)calculatedPosition;
-(void) stopMovingSliderView:(float)calculatedPosition;


-(void) closeTopPositionSliderView:(float)calculatedPosition;
-(void) closeBottomPositionSliderView:(float)calculatedPosition;

@end


typedef enum {
    FVStatusTop,
    FVStatusBottom
} FVSlideViewStatus;


@interface FVVerticalSlideView : UIView


@property(nonatomic, weak) IBOutlet id<FVVerticalSliderViewDelegate> delegate;

-(id) initWithTop:(CGFloat)top bottom:(CGFloat)bottom translationView:(UIView *)view;
-(void) setTranslationView:(UIView *)tView;
-(void) setTopY:(CGFloat )tY;
-(void) setBotY:(CGFloat )bY;

-(void) slideToBottom;
-(void) slideToTop;

-(FVSlideViewStatus) slideViewStatus;

@end
