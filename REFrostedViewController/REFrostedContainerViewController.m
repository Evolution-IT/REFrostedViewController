//
// REFrostedContainerViewController.m
// REFrostedViewController
//
// Copyright (c) 2013 Roman Efimov (https://github.com/romaonthego)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

#import "REFrostedContainerViewController.h"
#import "UIImage+REFrostedViewController.h"
#import "UIView+REFrostedViewController.h"
#import "UIViewController+REFrostedViewController.h"
#import "REFrostedViewController.h"
#import "RECommonFunctions.h"

@interface REFrostedContainerViewController ()

@property (strong, readwrite, nonatomic) UIImageView *backgroundImageView;
@property (strong, readwrite, nonatomic) NSMutableArray *backgroundViews;
@property (strong, readwrite, nonatomic) UIView *containerView;
@property (assign, readwrite, nonatomic) CGPoint containerOrigin;

@end

@interface REFrostedViewController ()

@property (assign, readwrite, nonatomic) BOOL visible;
@property (assign, readwrite, nonatomic) CGSize calculatedMenuViewSize;

@end

@implementation REFrostedContainerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.backgroundViews = [NSMutableArray array];
    //self.yposition = 0;
    for (NSInteger i = 0; i < 4; i++) {
        UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectNull];
        backgroundView.backgroundColor = [UIColor blackColor];
        backgroundView.alpha = 0.0f;
        [self.view addSubview:backgroundView];
        [self.backgroundViews addObject:backgroundView];
        
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureRecognized:)];
        [backgroundView addGestureRecognizer:tapRecognizer];
    }
    
    self.containerView = [[UIView alloc] initWithFrame:CGRectMake(0, _yposition, self.view.frame.size.width, self.view.frame.size.height)];
    self.containerView.clipsToBounds = NO;
    [self.view addSubview:self.containerView];
    
//    if (self.frostedViewController.liveBlur) {
//        UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:self.view.bounds];
//        toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//        toolbar.barStyle = (UIBarStyle)self.frostedViewController.liveBlurBackgroundStyle;
//        [self.containerView addSubview:toolbar];
//    } else {
//        self.backgroundImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
//        [self.containerView addSubview:self.backgroundImageView];
//    }

    if (self.frostedViewController.menuViewController) {
        [self addChildViewController:self.frostedViewController.menuViewController];
        self.frostedViewController.menuViewController.view.frame = self.containerView.bounds;
        [self.containerView addSubview:self.frostedViewController.menuViewController.view];
        [self.frostedViewController.menuViewController didMoveToParentViewController:self];
    }
    
    [self.view addGestureRecognizer:self.frostedViewController.panGestureRecognizer];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (!self.frostedViewController.visible) {

        self.backgroundImageView.image = self.screenshotImage;
        self.backgroundImageView.frame = self.view.bounds;
        self.frostedViewController.menuViewController.view.frame = self.containerView.bounds;

        CGRect frame = CGRectMake(-self.frostedViewController.calculatedMenuViewSize.width,
                                   _yposition,
                                   self.frostedViewController.calculatedMenuViewSize.width,
                                   self.frostedViewController.calculatedMenuViewSize.height);

        [self setContainerFrame:frame];
        
        if (self.animateApperance) {
            [self show];
        }
    }
}

- (void)setContainerFrame:(CGRect)frame
{
    UIView *leftBackgroundView = self.backgroundViews[0];
    UIView *topBackgroundView = self.backgroundViews[1];
    UIView *bottomBackgroundView = self.backgroundViews[2];
    UIView *rightBackgroundView = self.backgroundViews[3];
    
    leftBackgroundView.frame = CGRectMake(0, 0, frame.origin.x, self.view.frame.size.height);
    rightBackgroundView.frame = CGRectMake(frame.size.width + frame.origin.x,
                                           0,
                                           self.view.frame.size.width - frame.size.width - frame.origin.x,
                                           self.view.frame.size.height);
    
    topBackgroundView.frame = CGRectMake(frame.origin.x, 0, frame.size.width, frame.origin.y);
    bottomBackgroundView.frame = CGRectMake(frame.origin.x,
                                            frame.size.height + frame.origin.y,
                                            frame.size.width,
                                            self.view.frame.size.height);
    
    self.containerView.frame = frame;
    self.backgroundImageView.frame = CGRectMake(-frame.origin.x,
                                                -frame.origin.y,
                                                self.view.bounds.size.width,
                                                self.view.bounds.size.height);
}

- (void)setBackgroundViewsAlpha:(CGFloat)alpha
{
    for (UIView *view in self.backgroundViews) {
        view.alpha = alpha;
    }
}

- (void)resizeToSize:(CGSize)size
{
    [UIView animateWithDuration:self.frostedViewController.animationDuration animations:^{
        CGRect frame = CGRectMake(0, 0, size.width, size.height);
        [self setContainerFrame:frame];
        [self setBackgroundViewsAlpha:self.frostedViewController.backgroundFadeAmount];
    } completion:nil];
}

- (void)showWithSpeed:(double)speed
{
    NSTimeInterval dur = self.frostedViewController.animationDuration - speed;

    [UIView animateWithDuration:dur animations:^{
        CGRect frame = CGRectMake(0,
                                  self.yposition,
                                  self.frostedViewController.calculatedMenuViewSize.width,
                                  self.frostedViewController.calculatedMenuViewSize.height);
        [self setContainerFrame:frame];
        [self setBackgroundViewsAlpha:self.frostedViewController.backgroundFadeAmount];

    } completion:^(BOOL finished) {

        __weak id<REFrostedViewControllerDelegate> delegate = self.frostedViewController.delegate;

        if ([delegate conformsToProtocol:@protocol(REFrostedViewControllerDelegate)]
            && [delegate respondsToSelector:@selector(frostedViewController:didShowMenuViewController:)]) {

            [delegate frostedViewController:self.frostedViewController
                  didShowMenuViewController:self.frostedViewController.menuViewController];
        }
    }];
}

- (void)show
{
    [self showWithSpeed:0];
}

- (void)hide
{
	[self hideWithCompletionHandler:nil];
}

- (void)hideWithCompletionHandler:(void(^)(void))completionHandler
{
    __weak id<REFrostedViewControllerDelegate> delegate = self.frostedViewController.delegate;
    
    if ([delegate conformsToProtocol:@protocol(REFrostedViewControllerDelegate)]
        && [delegate respondsToSelector:@selector(frostedViewController:willHideMenuViewController:)]) {

        [delegate frostedViewController:self.frostedViewController
             willHideMenuViewController:self.frostedViewController.menuViewController];
    }

    [UIView animateWithDuration:self.frostedViewController.animationDuration animations:^{
        CGRect frame = CGRectMake(-self.frostedViewController.calculatedMenuViewSize.width,
                                  self.yposition,
                                  self.frostedViewController.calculatedMenuViewSize.width,
                                  self.frostedViewController.calculatedMenuViewSize.height);
        [self setContainerFrame:frame];
    } completion:^(BOOL finished) {
         [self setBackgroundViewsAlpha:0];
        self.frostedViewController.visible = NO;
        [self.frostedViewController re_hideController:self];

        if ([delegate conformsToProtocol:@protocol(REFrostedViewControllerDelegate)]
            && [delegate respondsToSelector:@selector(frostedViewController:didHideMenuViewController:)]) {

            [delegate frostedViewController:self.frostedViewController
                  didHideMenuViewController:self.frostedViewController.menuViewController];
        }

        if (completionHandler) completionHandler();

    }];
}

- (void)refreshBackgroundImage
{
    self.backgroundImageView.image = self.screenshotImage;
}

#pragma mark -
#pragma mark Gesture recognizer

- (void)tapGestureRecognized:(UITapGestureRecognizer *)recognizer
{
    [self hide];
}

- (void)panGestureRecognized:(UIPanGestureRecognizer *)recognizer
{
    if (!self.frostedViewController.panGestureEnabled) return;

    __weak id<REFrostedViewControllerDelegate> delegate = self.frostedViewController.delegate;

    if ([delegate conformsToProtocol:@protocol(REFrostedViewControllerDelegate)]
        && [delegate respondsToSelector:@selector(frostedViewController:didRecognizePanGesture:)]) {

        [delegate frostedViewController:self.frostedViewController didRecognizePanGesture:recognizer];
    }

    CGPoint point = [recognizer translationInView:self.view];
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.containerOrigin = self.containerView.frame.origin;
    }
    
    if (recognizer.state == UIGestureRecognizerStateChanged)
    {
        CGRect frame =  CGRectMake(self.containerView.frame.origin.x, self.yposition
                                   , self.containerView.frame.size.width, self.containerView.frame.size.height);

        frame.origin.x = self.containerOrigin.x + point.x;

        if (frame.origin.x > 0) {

            frame.origin.x = 0;
            
            if (!self.frostedViewController.limitMenuViewSize) {
                frame.size.width = self.frostedViewController.calculatedMenuViewSize.width + self.containerOrigin.x + point.x;
                if (frame.size.width > self.view.frame.size.width)
                    frame.size.width = self.view.frame.size.width;
            }
        }

        for ( UIView *bgView in self.backgroundViews ) {
            //Limit for shadow is 50/255
            //pointX = 0 - calculatedMenuSize (50)
            //alpha = 0 - self.frostedViewController.backgroundFadeAmount (X)
            CGFloat pCentPointX;
            CGFloat pCentAlpha;
            if(point.x >= 0) {
                if (frame.origin.x >= 0) {
                    pCentAlpha = self.frostedViewController.backgroundFadeAmount;
                } else {
                    pCentPointX = point.x / (self.frostedViewController.calculatedMenuViewSize.width);
                    pCentAlpha = pCentPointX * (self.frostedViewController.backgroundFadeAmount);//30;
                }
            } else {
                pCentPointX = (point.x * -1) / (self.frostedViewController.calculatedMenuViewSize.width);
                pCentAlpha = self.frostedViewController.backgroundFadeAmount -
                (self.frostedViewController.backgroundFadeAmount * pCentPointX);
            }

            if(frame.origin.x + frame.size.width < 0 ) {
                pCentAlpha = 0;
            }

            bgView.alpha = pCentAlpha;
            if(bgView.alpha > self.frostedViewController.backgroundFadeAmount) {
                bgView.alpha = self.frostedViewController.backgroundFadeAmount;
            }
        }

        [self setContainerFrame:frame];
    }
    else if (recognizer.state == UIGestureRecognizerStateEnded)
    {

        CGFloat velX = [recognizer velocityInView:self.view].x;

        if (velX > 0) {
            [self showWithSpeed:velX / 10000];
        } else {
            [self hide];
        }
    }
}

- (void)fixLayoutWithDuration:(NSTimeInterval)duration
{
    CGRect rect = CGRectMake(0,
                             0,
                             self.frostedViewController.calculatedMenuViewSize.width,
                             self.frostedViewController.calculatedMenuViewSize.height);

    [self setContainerFrame:rect];
    [self setBackgroundViewsAlpha:self.frostedViewController.backgroundFadeAmount];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self fixLayoutWithDuration:duration];
}

@end
