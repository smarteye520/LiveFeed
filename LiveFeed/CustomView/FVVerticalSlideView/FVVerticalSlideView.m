//
//  FVVerticalSlideView.m
//  LiveFeed
//
//  Created by echoLive on 11/20/20.
//  Copyright © 2020 Smart Eye. All rights reserved.
//

#import "FVVerticalSlideView.h"

@implementation FVVerticalSlideView
{
    UIView *translationView;
    FVSlideViewStatus status;
    CGFloat topY;
    CGFloat bottomY;
}
 
-(id) initWithTop:(CGFloat)top bottom:(CGFloat)bottom translationView:(UIView *)view
 {
     self = [super initWithFrame:CGRectMake(0,
                                            view.frame.size.height-bottom,
                                            view.frame.size.width,
                                            view.frame.size.height-top)];
     self.layer.cornerRadius = 5.0f;
     translationView = view;
     bottomY = bottom;
     
     UIPanGestureRecognizer* pgr = [[UIPanGestureRecognizer alloc]
                                    initWithTarget:self
                                    action:@selector(handlePanGesture:)];
     
     [self addGestureRecognizer:pgr];
     
     return self;
}

-(void) setTranslationView:(UIView *)tView
{
    self.translationView = tView;
}

-(void) setTopY:(CGFloat )tY
{
    topY = tY;
}

-(void) setBotY:(CGFloat )bY
{
    bottomY = bY;
}


- (void)handlePanGesture:(UIPanGestureRecognizer *)gesture
{
    static CGPoint lastTranslate;   // the last value
    static CGPoint prevTranslate;   // the value before that one
    static NSTimeInterval lastTime;
    static NSTimeInterval prevTime;
    
    CGPoint translate = [gesture translationInView:translationView];
    CGPoint origin = gesture.view.frame.origin;
        
    if (gesture.state == UIGestureRecognizerStateBegan)
    {
        lastTime = [NSDate timeIntervalSinceReferenceDate];
        lastTranslate = translate;
        prevTime = lastTime;
        prevTranslate = lastTranslate;
        
        if(_delegate != nil)
            [_delegate startMovingSliderView];
    }
    else if (gesture.state == UIGestureRecognizerStateChanged)
    {
        prevTime = lastTime;
        prevTranslate = lastTranslate;
        lastTime = [NSDate timeIntervalSinceReferenceDate];
        lastTranslate = translate;
        
        if(_delegate != nil)
            [_delegate movingSliderView:(origin.y + translate.y)];
        
        
        if(origin.y + translate.y < topY) //determine top Y
        {
            origin = CGPointMake(origin.x, topY);
            CGRect frame = gesture.view.frame;
            frame.origin =origin;
            gesture.view.frame=frame;
        }
        else if(origin.y + translate.y > (translationView.frame.size.height-bottomY)) //determine bottom Y
        {
            origin = CGPointMake(origin.x, translationView.frame.size.height-bottomY);
            CGRect frame = gesture.view.frame;
            frame.origin =origin;
            gesture.view.frame=frame;
        }
        else
        {
            origin = CGPointMake(origin.x, origin.y + translate.y);
            CGRect frame = gesture.view.frame;
            frame.origin =origin;
            gesture.view.frame=frame;
            [gesture setTranslation:CGPointZero inView:gesture.view];
        }
        
        
        if(origin.y + translate.y < (translationView.frame.size.height*1/4+topY)) //Top part
        {
            if(_delegate != nil)
                [_delegate closeTopPositionSliderView:(origin.y + translate.y)];
        }
        else //Bottom part
        {
            if(_delegate != nil)
                [_delegate closeBottomPositionSliderView:(origin.y + translate.y)];
        }
    }
    else if (gesture.state == UIGestureRecognizerStateEnded)
    {
        CGPoint swipeVelocity = CGPointZero;
        
        NSTimeInterval seconds = [NSDate timeIntervalSinceReferenceDate] - prevTime;
        if (seconds)
        {
            swipeVelocity = CGPointMake((translate.x - prevTranslate.x) / seconds, (translate.y - prevTranslate.y) / seconds);
        }
        
        if(_delegate != nil){
            CGFloat value = (self.frame.size.height - self.frame.origin.y + topY)/self.frame.size.height;
            [_delegate stopMovingSliderView:(value)];
//            [_delegate stopMovingSliderView:(origin.y + translate.y)];
        }
        
        
        float inertiaSeconds = 1.0;
        
        CGPoint center = gesture.view.center;
        
        if(swipeVelocity.y > 0) //Scrolling to top
        {
            if(swipeVelocity.y > 100.0f)
            {
                if (translate.y <= 0 && prevTranslate.y <= 0)
					[self slideToTop];
            }
            else if((center.y + translate.y + swipeVelocity.y * inertiaSeconds) < (translationView.frame.size.height+topY))
            {
                [self slideToTop];
            }
            else
            {
                [self slideToBottom];
            }
            

        }
        else //Scrolling to bottom
        {
            if(swipeVelocity.y < -100.0f)
            {
                if (translate.y >= 0 && prevTranslate.y >= 0)
                    [self slideToBottom];
            }
            else if((center.y + translate.y + swipeVelocity.y * inertiaSeconds) > (translationView.frame.size.height+topY))
            {
                [self slideToBottom];
            }
            else
            {
                [self slideToTop];
            }

        }
    }
    
}

-(void) slideToBottom
{
//    [UIView animateWithDuration:0.4 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
//        CGRect frame = self.frame;
//        frame.origin.y = translationView.frame.size.height-bottomY;
//        self.frame = frame;
//
//    } completion:^(BOOL finished) {
//        if(_delegate != nil)
//            [_delegate closeBottomPositionSliderView:topY];
//
//        status = FVStatusBottom;
//    }];
}

-(void) slideToTop
{
//    [UIView animateWithDuration:0.4 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
//        CGRect frame = self.frame;
//        frame.origin.y = topY;
//        self.frame = frame;
//
//    } completion:^(BOOL finished) {
//        if(_delegate != nil)
//            [_delegate closeTopPositionSliderView:topY];
//
//        status = FVStatusTop;
//    }];
}

-(FVSlideViewStatus) slideViewStatus
{
    return status;
}


@end
