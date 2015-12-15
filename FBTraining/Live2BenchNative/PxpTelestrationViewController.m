//
//  PxpTelestrationViewController.m
//  PxpTelestration
//
//  Created by Nico Cvitak on 2015-07-09.
//  Copyright © 2015 Nicholas Cvitak. All rights reserved.
//

#import "PxpTelestrationViewController.h"

#import "NCGhostView.h"

#import "PxpTelestrationCaptureArea.h"
#import "PxpTelestrationRenderView.h"

#import "PxpColorPicker.h"
#import "PxpAddButton.h"
#import "PxpUndoButton.h"
#import "PxpLineButton.h"
#import "PxpArrowButton.h"

#import "PxpTelestrationButton.h"

@interface PxpTelestrationViewController () <PxpTimeProvider, PxpTelestrationCaptureAreaDelegate>

@property (strong, nonatomic, nonnull) PxpTelestrationRenderView *renderView;
@property (strong, nonatomic, nonnull) PxpTelestrationCaptureArea *captureArea;

@property (strong, nonatomic, nonnull) UIButton *undoButton;
@property (strong, nonatomic, nonnull) UIButton *lineButton;
@property (strong, nonatomic, nonnull) UIButton *arrowButton;

@property (strong, nonatomic, nonnull) PxpColorPicker *colorPicker;
@property (strong, nonatomic, nonnull) UIButton *clearButton;

@property (strong, nonatomic, nonnull) UIButton *telestrationButton;

@property (assign, nonatomic) BOOL activeTelestration;

@property (assign, nonatomic) BOOL showsClearButton;

@end

@implementation PxpTelestrationViewController

- (nonnull instancetype)init {
    self = [super init];
    if (self) {
        _renderView = [[PxpTelestrationRenderView alloc] init];
        _captureArea = [[PxpTelestrationCaptureArea alloc] init];
        
        _undoButton = [[PxpUndoButton alloc] init];
        _lineButton = [[PxpLineButton alloc] init];
        _arrowButton = [[PxpArrowButton alloc] init];
        
        _colorPicker = [[PxpColorPicker alloc] init];
        _clearButton = [[PxpAddButton alloc] init];
        
        _telestrationButton = [[PxpTelestrationButton alloc] init];
        
        _showsControls = YES;
        _showsClearButton = YES;
    }
    return self;
}

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        _renderView = [[PxpTelestrationRenderView alloc] init];
        _captureArea = [[PxpTelestrationCaptureArea alloc] init];
        
        _undoButton = [[PxpUndoButton alloc] init];
        _lineButton = [[PxpLineButton alloc] init];
        _arrowButton = [[PxpArrowButton alloc] init];
        
        _colorPicker = [[PxpColorPicker alloc] init];
        _clearButton = [[PxpAddButton alloc] init];
        
        _telestrationButton = [[PxpTelestrationButton alloc] init];
        
        _showsControls = YES;
        _showsClearButton = YES;
    }
    return self;
}

- (void)loadView {
    self.view = [[NCGhostView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.clipsToBounds = YES;
    
    self.renderView.frame = self.view.bounds;
    self.captureArea.frame = self.view.bounds;
    self.renderView.backgroundColor = [UIColor clearColor];
    
    // make sure we run the setters :)
    self.showsClearButton = self.showsClearButton;
    self.showsControls = self.showsControls;
    self.telestrating = NO;
    self.telestration = nil;
    
    [self.undoButton addTarget:self action:@selector(undoAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.lineButton addTarget:self action:@selector(lineAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.arrowButton addTarget:self action:@selector(arrowAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.clearButton addTarget:self action:@selector(clearAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.telestrationButton addTarget:self action:@selector(telestrationAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:self.renderView];
    [self.view addSubview:self.captureArea];
    
    [self.view addSubview:self.undoButton];
    [self.view addSubview:self.lineButton];
    [self.view addSubview:self.arrowButton];
    
    [self.view addSubview:self.colorPicker];
    [self.view addSubview:self.clearButton];
    
    [self.view addSubview:self.telestrationButton];
    
    self.renderView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.captureArea.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    self.undoButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin;
    self.lineButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
    self.arrowButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
    
    self.colorPicker.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
    self.clearButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin;
    
    self.renderView.timeProvider = self;
    self.captureArea.timeProvider = self;
    self.captureArea.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.showsControls = self.showsControls;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.telestration = nil;
}

#pragma mark - Getters / Setters

- (void)setTelestrating:(BOOL)telestrating {
    [self setTelestrating:telestrating animated:NO];
}

- (void)setTelestration:(nullable PxpTelestration *)telestration {
    _telestration = telestration;
    
    self.renderView.telestration = telestration;
    [self.captureArea bindTelestration:telestration];
    
    if (!telestration) self.telestrating = NO;
}

- (void)setShowsControls:(BOOL)showsControls {
    _showsControls = showsControls;
    
    if (showsControls) {
        self.telestrationButton.hidden = NO;
        self.lineButton.hidden = NO;
        self.arrowButton.hidden = NO;
        self.colorPicker.hidden = NO;
        self.undoButton.hidden = NO;
        self.clearButton.hidden = !self.showsClearButton;
        
        self.telestrating = self.telestrating;
    } else {
        self.telestrationButton.hidden = YES;
        self.lineButton.hidden = YES;
        self.arrowButton.hidden = YES;
        self.colorPicker.hidden = YES;
        self.undoButton.hidden = YES;
        self.clearButton.hidden = YES;
        
        self.telestrating = NO;
    }
    
}

- (void)setShowsClearButton:(BOOL)showsClearButton {
    _showsClearButton = showsClearButton;
    
    self.clearButton.hidden = !showsClearButton;
}

- (void)setStillMode:(BOOL)stillMode {
    _stillMode = stillMode;
    
    self.showsClearButton = !stillMode;
}

#pragma mark - Buttons

- (void)undoAction:(UIButton *)button {
    [self.renderView.telestration popAction];
}

- (void)lineAction:(UIButton *)button {
    self.lineButton.selected = !self.lineButton.selected;
}

- (void)arrowAction:(UIButton *)button {
    self.arrowButton.selected = !self.arrowButton.selected;
}

- (void)clearAction:(UIButton *)button {
    if (self.telestration.actionStack.count) {
        [self.telestration pushAction:[PxpTelestrationAction clearActionAtTime:self.currentTimeInSeconds]];
    }
}

- (void)telestrationAction:(UIButton *)button {
    self.telestrationButton.selected = !self.telestrationButton.selected;
    [self setTelestrating:self.telestrationButton.selected animated:YES];
}

#pragma mark - PxpCaptureAreaDelegate

- (nonnull UIColor *)strokeColorInCaptureArea:(nonnull PxpTelestrationCaptureArea *)captureArea {
    return self.colorPicker.color;
}

- (CGFloat)strokeWidthInCaptureArea:(nonnull PxpTelestrationCaptureArea *)captureArea {
    return 5.0;
}

- (PxpTelestrationActionType)actionTypeInCaptureArea:(nonnull PxpTelestrationCaptureArea *)captureArea {
    PxpTelestrationActionType type = PxpDraw;
    type |= self.lineButton.selected ? PxpLine : 0;
    type |= self.arrowButton.selected ? PxpArrow : 0;
    return type;
}

- (NSTimeInterval)currentTimeInSeconds {
    return self.timeProvider.currentTimeInSeconds;
}

#pragma mark - Private Methods

- (void)setTelestrating:(BOOL)telestrating animated:(BOOL)animated {
    
    [self willChangeValueForKey:@"telestrating"];
    _telestrating = telestrating;
    
    self.captureArea.captureEnabled = self.telestrationButton.selected;
    if (telestrating) {
        
        if (!self.activeTelestration) {
            self.activeTelestration = YES;
            
            PxpTelestration *telestration = [[PxpTelestration alloc] initWithSize:CGSizeMake(960, 540)];
            telestration.isStill = _stillMode;
            
            self.telestration = telestration;
            self.telestration.isStill = self.stillMode;
            [self.delegate telestration:self.telestration didStartInViewController:self];
        }
        
        
        if (animated) {
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:0.2];
        }
        
        self.undoButton.frame = CGRectMake(10.0f, self.view.bounds.size.height - 55.0f - 44.0f, 45.0f, 45.0f);
        self.clearButton.frame = CGRectMake(10.0f, self.view.bounds.size.height - 120.0f - 44.0f, 45.0f, 45.0f);
        
        self.colorPicker.frame = CGRectMake(self.view.bounds.size.width - 120.0f, self.view.bounds.size.height - 120.0f - 44.0f, 110.0f, 110.0f);
        
        self.lineButton.frame = CGRectMake(self.view.bounds.size.width - 165.0f, self.view.bounds.size.height - 55.0f - 44.0f, 45.0f, 45.0f);
        self.arrowButton.frame = CGRectMake(self.view.bounds.size.width - 165.0f, self.view.bounds.size.height - 120.0f - 44.0f, 45.0f, 45.0f);
        
        self.telestrationButton.frame = CGRectMake(self.view.bounds.size.width - 220.0f, self.view.bounds.size.height - 87.5f - 44.0f, 45.0f, 45.0f);
        self.telestrationButton.selected = YES;
        
        if (animated) {
            [UIView commitAnimations];
        }
    } else {
        if (animated) {
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:0.2];
        }
        
        const CGFloat offset = 165.0f;
        
        self.undoButton.frame = CGRectMake(10.0f - offset, self.view.bounds.size.height - 55.0f - 44.0f, 45.0f, 45.0f);
        self.clearButton.frame = CGRectMake(10.0f - offset, self.view.bounds.size.height - 120.0f - 44.0f, 45.0f, 45.0f);
        
        self.colorPicker.frame = CGRectMake(self.view.bounds.size.width - 120.0f + offset, self.view.bounds.size.height - 120.0f - 44.0f, 110.0f, 110.0f);
        
        self.lineButton.frame = CGRectMake(self.view.bounds.size.width - 165.0f + offset, self.view.bounds.size.height - 55.0f - 44.0f, 45.0f, 45.0f);
        self.arrowButton.frame = CGRectMake(self.view.bounds.size.width - 165.0f + offset, self.view.bounds.size.height - 120.0f - 44.0f, 45.0f, 45.0f);
        
        self.telestrationButton.frame = CGRectMake(self.view.bounds.size.width - 220.0f + offset, self.view.bounds.size.height - 87.5f - 44.0f, 45.0f, 45.0f);
        self.telestrationButton.selected = NO;
        
        if (animated) {
            [UIView commitAnimations];
        }
        
        if (self.activeTelestration) {
            self.activeTelestration = NO;
            [self.delegate telestration:self.telestration didFinishInViewController:self];
            self.telestration = nil;
        }
        
    }
    
    [self didChangeValueForKey:@"telestrating"];
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
