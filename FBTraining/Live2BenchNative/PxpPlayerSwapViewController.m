//
//  PxpPlayerSwapViewController.m
//  Live2BenchNative
//
//  Created by Nico Cvitak on 2015-07-21.
//  Copyright © 2015 DEV. All rights reserved.
//

#import "PxpPlayerSwapViewController.h"
#import "PxpPlayerControlBar.h"

@interface PxpPlayerSwapViewController ()

@property (strong, nonatomic, nonnull) PxpPlayerControlBar *controlBar;

@end

@implementation PxpPlayerSwapViewController
{
    void *_playerObserverContext;
}

- (nonnull instancetype)init {
    self = [super init];
    if (self) {
        _controlBar = [[PxpPlayerControlBar alloc] init];
        _playerObserverContext = &_playerObserverContext;
        
        [self addObserver:self forKeyPath:@"swapView.context.mainPlayer" options:0 context:_playerObserverContext];
    }
    return self;
}

- (void)dealloc {
    [self removeObserver:self forKeyPath:@"swapView.context.mainPlayer" context:_playerObserverContext];
}

- (void)loadView {
    self.view = [[PxpPlayerSwapView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
    
    [self.view addSubview:self.controlBar];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.controlBar.frame = CGRectMake(0, self.view.bounds.size.height - 44.0, self.view.bounds.size.width, 44.0);
    self.controlBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    self.controlBar.player = self.swapView.context.mainPlayer;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)observeValueForKeyPath:(nullable NSString *)keyPath ofObject:(nullable id)object change:(nullable NSDictionary *)change context:(nullable void *)context {
    if (context == _playerObserverContext) {
        self.controlBar.player = self.swapView.context.mainPlayer;
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - Getters / Setters

- (void)setView:(nullable UIView *)view {
    [self willChangeValueForKey:@"swapView"];
    [super setView:view];
    [self didChangeValueForKey:@"swapView"];
}

- (void)setSwapView:(nullable PxpPlayerSwapView *)swapView {
    self.view = swapView;
}

- (nullable PxpPlayerSwapView *)swapView {
    return [self.view isKindOfClass:[PxpPlayerSwapView class]] ? (PxpPlayerSwapView *)self.view : nil;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
