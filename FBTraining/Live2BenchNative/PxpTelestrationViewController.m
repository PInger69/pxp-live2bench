//
//  PxpTelestrationViewController.m
//  PxpTelestration
//
//  Created by Nico Cvitak on 2015-07-09.
//  Copyright © 2015 Nicholas Cvitak. All rights reserved.
//

#import "PxpTelestrationViewController.h"

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
    }
    return self;
}

- (nonnull instancetype)initWithCoder:(nonnull NSCoder *)aDecoder {
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
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.clipsToBounds = YES;
    
    self.renderView.frame = self.view.bounds;
    self.captureArea.frame = self.renderView.bounds;
    self.renderView.backgroundColor = [UIColor clearColor];
    
    self.undoButton.frame = CGRectMake(20.0f, self.view.bounds.size.height + 100.0f, 45.0f, 65.0f);
    self.lineButton.frame = CGRectMake(self.view.bounds.size.width - 130.0f, self.view.bounds.size.height + 180.0f, 45.0f, 45.0f);
    self.arrowButton.frame = CGRectMake(self.view.bounds.size.width - 65.0f, self.view.bounds.size.height + 180.0f, 45.0f, 45.0f);
    
    self.colorPicker.frame = CGRectMake(self.view.bounds.size.width - 130.0f, self.view.bounds.size.height + 130.0f, 110.0f, 110.0f);
    self.clearButton.frame = CGRectMake(20.0f, self.view.bounds.size.height + 180.0f, 45.0f, 65.0f);
    
    self.telestrationButton.frame = CGRectMake(self.view.bounds.size.width - 120.0f, self.view.bounds.size.height - 120.0f, 90.0f, 90.0f);
    
    [self.undoButton addTarget:self action:@selector(undoAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.lineButton addTarget:self action:@selector(lineAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.arrowButton addTarget:self action:@selector(arrowAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.clearButton addTarget:self action:@selector(clearAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.telestrationButton addTarget:self action:@selector(telestrationAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:self.renderView];
    [self.renderView addSubview:self.captureArea];
    
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
    
    self.telestrationButton.hidden = YES;
    
    self.renderView.timeProvider = self;
    self.captureArea.timeProvider = self;
    self.captureArea.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Getters / Setters

- (void)setShowsTelestrationControls:(BOOL)showsTelestrationControls {
    [self setShowsTelestrationControls:showsTelestrationControls animated:NO];
}

- (void)setTelestration:(nullable PxpTelestration *)telestration {
    _telestration = telestration;
    
    self.renderView.telestration = telestration;
    [self.captureArea bindTelestration:telestration];
    
    if (telestration) {
        self.telestrationButton.hidden = NO;
    } else {
        self.telestrationButton.hidden = YES;
        self.showsTelestrationControls = NO;
    }
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
    [self.renderView.telestration pushAction:[PxpTelestrationAction clearActionAtTime:self.currentTime]];
}

- (void)telestrationAction:(UIButton *)button {
    self.telestrationButton.selected = !self.telestrationButton.selected;
    self.captureArea.captureEnabled = self.telestrationButton.selected;
    [self setShowsTelestrationControls:self.telestrationButton.selected animated:YES];
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

- (NSTimeInterval)currentTime {
    return self.timeProvider.currentTime;
}

#pragma mark - Private Methods

- (void)setShowsTelestrationControls:(BOOL)showsTelestrationControls animated:(BOOL)animated {
    [self willChangeValueForKey:@"showsTelestrationControls"];
    _showsTelestrationControls = showsTelestrationControls;
    
    if (showsTelestrationControls) {
        if (animated) {
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:0.2];
        }
        
        self.undoButton.frame = CGRectMake(20.0f, self.view.bounds.size.height - 100.0f, 45.0f, 65.0f);
        self.lineButton.frame = CGRectMake(self.view.bounds.size.width - 130.0f, self.view.bounds.size.height - 180.0f, 45.0f, 45.0f);
        self.arrowButton.frame = CGRectMake(self.view.bounds.size.width - 65.0f, self.view.bounds.size.height - 180.0f, 45.0f, 45.0f);
        
        self.colorPicker.frame = CGRectMake(self.view.bounds.size.width - 130.0f, self.view.bounds.size.height - 130.0f, 110.0f, 110.0f);
        self.clearButton.frame = CGRectMake(20.0f, self.view.bounds.size.height - 180.0f, 45.0f, 65.0f);
        
        self.telestrationButton.frame = CGRectMake(self.view.bounds.size.width - 120.0f, 30.0f, 90.0f, 90.0f);
        
        if (animated) {
            [UIView commitAnimations];
        }
    } else {
        if (animated) {
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:0.2];
        }
        
        self.undoButton.frame = CGRectMake(20.0f, self.view.bounds.size.height + 100.0f, 45.0f, 65.0f);
        self.lineButton.frame = CGRectMake(self.view.bounds.size.width - 130.0f, self.view.bounds.size.height + 180.0f, 45.0f, 45.0f);
        self.arrowButton.frame = CGRectMake(self.view.bounds.size.width - 65.0f, self.view.bounds.size.height + 180.0f, 45.0f, 45.0f);
        
        self.colorPicker.frame = CGRectMake(self.view.bounds.size.width - 130.0f, self.view.bounds.size.height + 130.0f, 110.0f, 110.0f);
        self.clearButton.frame = CGRectMake(20.0f, self.view.bounds.size.height + 180.0f, 45.0f, 65.0f);
        
        self.telestrationButton.frame = CGRectMake(self.view.bounds.size.width - 120.0f, self.view.bounds.size.height - 120.0f, 90.0f, 90.0f);
        
        if (animated) {
            [UIView commitAnimations];
        }
    }
    
    [self didChangeValueForKey:@"showsTelestrationControls"];
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
