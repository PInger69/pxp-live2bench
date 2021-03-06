//
//  RicoBaseFullScreenViewController.m
//  Live2BenchNative
//
//  Created by dev on 2016-02-08.
//  Copyright © 2016 DEV. All rights reserved.
//

#import "RicoBaseFullScreenViewController.h"


@interface Zone : UIView
@end

@implementation Zone
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    if (!self.clipsToBounds && !self.hidden && self.alpha > 0) {
        for (UIView *subview in self.subviews.reverseObjectEnumerator) {
            CGPoint subPoint = [subview convertPoint:point fromView:self];
            UIView *result = [subview hitTest:subPoint withEvent:event];
            if (result != nil) {
                return result;
            }
        }
    }
    
    return [super hitTest:point withEvent:event];;
}

@end




@implementation RicoBaseFullScreenViewController
{
    UIView * __nonnull _playerContainer;
    UIView * __nonnull _movingView;
    UIView * __nullable _targetView;
    NSUInteger _targetIndex;
    CGRect _targetFrame;
}



-(instancetype)initWithView:(UIView*)view
{
    self = [super init];
    if (self) {
        _contentView        = [[Zone alloc] init];
        _playerContainer    = [[Zone alloc] init];
        _topBar             = [[Zone alloc] init];
        _bottomBar          = [[Zone alloc] init];
        _movingView         = view;
        _animated           = YES;
    }
    return self;


}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self.view addSubview:_contentView];
    [_contentView addSubview:_playerContainer];
    [_contentView addSubview:_topBar];
    [_contentView addSubview:_bottomBar];

    self.view.backgroundColor       = [UIColor blackColor];
    _playerContainer.backgroundColor = [UIColor darkGrayColor];
    
    self.fullscreen = NO;
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    // contentView
    
    //    _contentView.frame = CGRectMake(0.0, 55.0, self.view.bounds.size.width, self.view.bounds.size.height - 55.0);
    _contentView.frame = CGRectMake(0.0, 55.0, 1024,713);
    const CGFloat contentWidth = _contentView.bounds.size.width, contentHeight = _contentView.bounds.size.height;
    
    // player
    const CGFloat playerWidth = contentWidth, playerHeight = playerWidth / (16.0 / 9.0);
    const CGFloat playerX = 0.0, playerY = (contentHeight - playerHeight) / 2.0;
    
    _playerContainer.frame = CGRectMake(playerX, playerY, playerWidth, playerHeight);
    _topBar.frame = CGRectMake(0.0, 0.0, playerWidth, playerY);
    

    
    _bottomBar.frame = CGRectMake(0.0, (playerY + playerHeight)-46, playerWidth, 200);

    if ([_movingView isDescendantOfView:_playerContainer]) {
        _movingView.frame = _playerContainer.bounds;
    }

    // button size
//    const CGFloat buttonHeight = contentHeight - playerY - playerHeight;
    
    // seek buttons
//    const CGFloat seekButtonY = playerY + playerHeight;
    
    
    // bottom bar buttons
//    const CGFloat margin = 8.0;
    

}




- (void)setFullscreen:(BOOL)fullscreen animated:(BOOL)animated {
    if (self.view.hidden == fullscreen) {
        
        if (!fullscreen) {
//            if (self.delegate) {
//                [self.delegate onFullScreenLeave:self];
//            }
            
        } else  {
            _targetView = _movingView.superview;
            _targetIndex = [_targetView.subviews indexOfObject:_movingView];
            _targetFrame = _movingView.frame;
            [_movingView removeFromSuperview];
            self.view.frame = _targetFrame;
            _movingView.frame = _playerContainer.bounds;
            [_playerContainer addSubview:_movingView];
            self.view.hidden = NO;
        }
        
        [self.view layoutIfNeeded];
        
        [UIView animateWithDuration:animated ? 0.2 : 0.0 animations:^() {
            if (!fullscreen) {
                self.view.frame = _targetFrame;
            } else {
                self.view.frame = self.view.superview.bounds;
            }
            
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            if (!fullscreen) {
                
//                [_playerViewController removeFromParentViewController];
                if ([_movingView isDescendantOfView:_playerContainer]) {
                    [_movingView removeFromSuperview];
                    _movingView.frame = _targetFrame;
                    [_targetView insertSubview:_movingView atIndex:_targetIndex];
                }
                self.view.hidden = YES;
                _fullscreen = NO;
                if (self.delegate) {
                    [self.delegate onFullScreenLeave:self];
                }
                
            } else {
                _fullscreen = YES;
                if (self.delegate) {
                    [self.delegate onFullScreenShow:self];
                }
            }
        }];
        
    }
}


- (void)fullscreenResponseHandler:(nullable id<PxpFullscreenResponder>)sender {
    if ([sender conformsToProtocol:@protocol(PxpFullscreenResponder)]) {
        if (sender.fullscreenResponse == PxpFullscreenResponseLeave) {
            [self setFullscreen:NO animated:_animated];
        } else if (sender.fullscreenResponse == PxpFullscreenResponseEnter) {
            [self setFullscreen:YES animated:_animated];
        }
    }
}

- (void)setFullscreen:(BOOL)fullscreen {
    [self setFullscreen:fullscreen animated:NO];
}



- (BOOL)hidden {
    return self.view.hidden;
}


@end
