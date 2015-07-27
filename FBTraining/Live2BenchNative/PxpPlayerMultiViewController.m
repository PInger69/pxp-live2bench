//
//  PxpPlayerMultiViewController.m
//  PxpPlayer
//
//  Created by Nico Cvitak on 2015-07-02.
//  Copyright © 2015 Nicholas Cvitak. All rights reserved.
//

#import "PxpPlayerMultiViewController.h"

#import "PxpPlayerControlBar.h"

@implementation PxpPlayerMultiViewController
{
    __nonnull PxpPlayerControlBar *_controlBar;
    
    void *_playerObserverContext;
    void *_companionViewHiddenObserverContext;
    void *_companionViewZoomObserverContext;
    void *_telestrationObserverContext;
}

- (void)initMultiViewController {
    _telestrationViewController = [[PxpTelestrationViewController alloc] init];
    _controlBar = [[PxpPlayerControlBar alloc] init];
    
    _playerObserverContext = &_playerObserverContext;
    _companionViewHiddenObserverContext = &_companionViewHiddenObserverContext;
    _companionViewZoomObserverContext = &_companionViewZoomObserverContext;
    _telestrationObserverContext = &_telestrationObserverContext;
    
    [self addChildViewController:_telestrationViewController];
    
    [self addObserver:self forKeyPath:@"multiView.context.mainPlayer" options:0 context:_playerObserverContext];
    [self addObserver:self forKeyPath:@"multiView.companionView.hidden" options:0 context:_companionViewHiddenObserverContext];
    [self addObserver:self forKeyPath:@"multiView.companionView.zoomLevel" options:0 context:_companionViewZoomObserverContext];
    [self addObserver:self forKeyPath:@"telestrationViewController.telestration" options:0 context:_telestrationObserverContext];
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
    [self removeObserver:self forKeyPath:@"multiView.companionView.hidden" context:_companionViewHiddenObserverContext];
    [self removeObserver:self forKeyPath:@"multiView.companionView.zoomLevel" context:_companionViewZoomObserverContext];
    [self removeObserver:self forKeyPath:@"telestrationViewController.telestration" context:_telestrationObserverContext];
}

- (void)loadView {
    self.view = [[PxpPlayerMultiView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
    
    [self.view addSubview:self.telestrationViewController.view];
    [self.view addSubview:_controlBar];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.telestrationViewController.view.frame = self.view.bounds;
    self.telestrationViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    
    _controlBar.frame = CGRectMake(0, self.view.bounds.size.height - 44.0, self.view.bounds.size.width, 44.0);
    _controlBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    _controlBar.player = self.multiView.context.mainPlayer;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateTeleVisibiliy {
    BOOL hidden = self.multiView.companionView.hidden || self.multiView.companionView.zoomLevel != 1.0;
    _telestrationViewController.view.hidden = hidden;
}

- (void)observeValueForKeyPath:(nullable NSString *)keyPath ofObject:(nullable id)object change:(nullable NSDictionary *)change context:(nullable void *)context {
    if (context == _playerObserverContext) {
        _controlBar.player = self.multiView.context.mainPlayer;
    } else if (context == _companionViewHiddenObserverContext) {
        [self updateTeleVisibiliy];
    } else if (context == _companionViewZoomObserverContext) {
        [self updateTeleVisibiliy];
    } else if (context == _telestrationObserverContext) {
        self.multiView.companionView.zoomEnabled = !self.telestrationViewController.telestration;
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
