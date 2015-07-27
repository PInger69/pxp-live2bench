//
//  PxpPlayerMultiViewController.m
//  PxpPlayer
//
//  Created by Nico Cvitak on 2015-07-02.
//  Copyright © 2015 Nicholas Cvitak. All rights reserved.
//

#import "PxpPlayerMultiViewController.h"

#import "PxpPlayerControlBar.h"

@interface PxpPlayerMultiViewController ()

@property (strong, nonatomic, nonnull) PxpPlayerControlBar *controlBar;

@end

@implementation PxpPlayerMultiViewController
{
    void *_playerObserverContext;
}

- (void)initMultiViewController {
    _telestrationViewController = [[PxpTelestrationViewController alloc] init];
    _controlBar = [[PxpPlayerControlBar alloc] init];
    _playerObserverContext = &_playerObserverContext;
    
    [self addChildViewController:_telestrationViewController];
    
    [self addObserver:self forKeyPath:@"multiView.context.mainPlayer" options:0 context:_playerObserverContext];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self initMultiViewController];
    }
    return self;
}

- (instancetype)initWithCoder:(nonnull NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initMultiViewController];
    }
    return self;
}

- (void)dealloc {
    [self removeObserver:self forKeyPath:@"multiView.context.mainPlayer" context:_playerObserverContext];
}

- (void)loadView {
    self.view = [[PxpPlayerMultiView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
    
    [self.view addSubview:self.telestrationViewController.view];
    [self.view addSubview:self.controlBar];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.telestrationViewController.view.frame = self.view.bounds;
    self.telestrationViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    
    self.controlBar.frame = CGRectMake(0, self.view.bounds.size.height - 44.0, self.view.bounds.size.width, 44.0);
    self.controlBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    self.controlBar.player = self.multiView.context.mainPlayer;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)observeValueForKeyPath:(nullable NSString *)keyPath ofObject:(nullable id)object change:(nullable NSDictionary *)change context:(nullable void *)context {
    if (context == _playerObserverContext) {
        self.controlBar.player = self.multiView.context.mainPlayer;
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - Getters / Setters

- (void)setView:(nullable UIView *)view {
    [self willChangeValueForKey:@"multiView"];
    [super setView:view];
    [self didChangeValueForKey:@"multiView"];
}

- (void)setMultiView:(nullable PxpPlayerMultiView *)multiView {
    self.view = multiView;
}

- (nullable PxpPlayerMultiView *)multiView {
    return [self.view isKindOfClass:[PxpPlayerMultiView class]] ? (PxpPlayerMultiView *)self.view : nil;
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
