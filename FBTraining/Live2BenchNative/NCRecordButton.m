//
//  RecordButton.m
//  Live2BenchNative
//
//  Created by Nico Cvitak on 2015-05-20.
//  Copyright (c) 2015 DEV. All rights reserved.
//

#import "NCRecordButton.h"

@interface NCRecordButton ()

@property (strong, nonatomic, nullable) NSTimer *timer;

@property (assign, nonatomic) NSTimeInterval startTime;

@end

@implementation NCRecordButton

@synthesize isRecording = _isRecording;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        _isRecording = NO;
        [self setTitle:@"00:00:00" forState:UIControlStateNormal];
        self.titleLabel.font = [UIFont systemFontOfSize:14.0];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        [self addTarget:self action:@selector(startRecording) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return self;
}

- (void)dealloc
{
    if (self.timer) {
        [self.timer invalidate];
    }
}

#pragma mark Getter / Setter overrides

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    if (self.isRecording) {
        [self setBackgroundImage:[self recordingButtonWithSize:frame.size] forState:UIControlStateNormal];
    } else {
        [self setBackgroundImage:[self readyToRecordButtonWithSize:frame.size] forState:UIControlStateNormal];
    }
    
}

- (void)setDisplaysTime:(BOOL)displaysTime {
    self.titleLabel.alpha = displaysTime;
}

- (BOOL)displaysTime {
    return self.titleLabel.alpha != 0;
}

- (NSTimeInterval)recordingTime {
    NSTimeInterval currentTime = self.timeProvider ? self.timeProvider.currentTimeInSeconds : CACurrentMediaTime();
    return self.isRecording ? currentTime - self.startTime : 0.0;
}

- (NSString *)recordingTimeString {
    NSUInteger second = 00;
    NSUInteger minute = 00;
    NSUInteger hour = 00;
    
    second = (NSUInteger) self.recordingTime;
    if (second >= 60 && second < 3600) {
        minute = second / 60;
        second = second % 60;
    } else if (second >= 3600){
        hour = second / 3600;
        minute = second % 3600 / 60;
        second = minute % 60;
    }
    
    return [NSString stringWithFormat:@"%02lu:%02lu:%02lu",(unsigned long) hour, (unsigned long) minute, (unsigned long)second];
}

#pragma mark - Actions

- (void)startRecording {
    self.startTime = self.timeProvider ? self.timeProvider.currentTimeInSeconds : CACurrentMediaTime();
    
    [self removeTarget:self action:@selector(startRecording) forControlEvents:UIControlEventTouchUpInside];
    [self addTarget:self action:@selector(stopRecording) forControlEvents:UIControlEventTouchUpInside];
    
    [self setBackgroundImage:[self recordingButtonWithSize:self.frame.size] forState:UIControlStateNormal];
    
    self.timer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(update:) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];
    
    _isRecording = YES;
    
    if (self.delegate) {
        [self.delegate recordingDidStartInRecordButton:self];
    }
}

- (void)stopRecording {
    NSTimeInterval duration = self.recordingTime;
    
    [self removeTarget:self action:@selector(stopRecording) forControlEvents:UIControlEventTouchUpInside];
    [self addTarget:self action:@selector(startRecording) forControlEvents:UIControlEventTouchUpInside];
    
    [self setTitle:@"00:00:00" forState:UIControlStateNormal];
    [self setBackgroundImage:[self readyToRecordButtonWithSize:self.frame.size] forState:UIControlStateNormal];
    
    [self.timer invalidate];
    self.timer = nil;
    
    _isRecording = NO;
    
    if (self.delegate) {
        [self.delegate recordingTimeDidUpdateInRecordButton:self];
        [self.delegate recordingDidFinishInRecordButton:self withDuration:duration];
    }
}

- (void)update:(NSTimer *)timer {
    [self setTitle:self.recordingTimeString forState:UIControlStateNormal];
    
    if (self.delegate) {
        [self.delegate recordingTimeDidUpdateInRecordButton:self];
    }
}

#pragma mark - Start / Stop image generation methods

- (UIImage *)readyToRecordButtonWithSize: (CGSize) buttonSize {
    if (buttonSize.width > 0.0 && buttonSize.height > 0.0) {
        UIGraphicsBeginImageContextWithOptions(buttonSize, NO, [UIScreen mainScreen].scale);
        
        UIBezierPath *whiteCirclePath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(buttonSize.width/2, buttonSize.height/2) radius: (buttonSize.width/2 - 5) startAngle:0 endAngle: 2 *M_PI clockwise:NO];
        whiteCirclePath.lineWidth = (buttonSize.width / 10) /2 ;
        
        [[UIColor whiteColor] setStroke];
        [whiteCirclePath stroke];
        
        UIBezierPath *innerRedCircle = [UIBezierPath bezierPathWithArcCenter:CGPointMake(buttonSize.width/2, buttonSize.height/2) radius: (buttonSize.width/2 - whiteCirclePath.lineWidth - 5 ) startAngle:0 endAngle: 2 *M_PI clockwise:NO];
        
        [[UIColor redColor] setFill];
        
        [innerRedCircle fill];
        
        
        UIImage *recordButtonImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return recordButtonImage;
    } else {
        return nil;
    }
}

- (UIImage *)recordingButtonWithSize: (CGSize) buttonSize{
    if (buttonSize.width > 0.0 && buttonSize.height > 0.0) {
        UIGraphicsBeginImageContextWithOptions(buttonSize, NO, [UIScreen mainScreen].scale);
        
        UIBezierPath *whiteCirclePath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(buttonSize.width/2, buttonSize.height/2) radius: (buttonSize.width/2 - 5) startAngle:0 endAngle: 2 *M_PI clockwise:NO];
        whiteCirclePath.lineWidth = (buttonSize.width / 10) /2 ;
        
        [[UIColor whiteColor] setStroke];
        [whiteCirclePath stroke];
        
        CGRect innerSquareFrame = CGRectMake(buttonSize.width* 0.149096 + whiteCirclePath.lineWidth/2, buttonSize.height* 0.149096 + whiteCirclePath.lineWidth/2, buttonSize.width - 2 * (buttonSize.width* 0.149096 + whiteCirclePath.lineWidth/2), buttonSize.height - 2 *( buttonSize.width* 0.149096+ whiteCirclePath.lineWidth/2));
        UIBezierPath *innerSquarePath = [UIBezierPath bezierPathWithRoundedRect:innerSquareFrame cornerRadius:buttonSize.width / 10 + whiteCirclePath.lineWidth + 2];
        
        [[UIColor redColor] setFill];
        
        [innerSquarePath fill];
        
        
        UIImage *recordButtonImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return recordButtonImage;
    } else {
        return nil;
    }
}

- (void)terminate {
    
    [self removeTarget:self action:@selector(stopRecording) forControlEvents:UIControlEventTouchUpInside];
    [self addTarget:self action:@selector(startRecording) forControlEvents:UIControlEventTouchUpInside];
    
    [self setTitle:@"00:00:00" forState:UIControlStateNormal];
    [self setBackgroundImage:[self readyToRecordButtonWithSize:self.frame.size] forState:UIControlStateNormal];
    
    [self.timer invalidate];
    self.timer = nil;
    
    _isRecording = NO;
    
    if (self.delegate) {
        [self.delegate recordingDidTerminateInRecordButton:self];
        [self.delegate recordingTimeDidUpdateInRecordButton:self];
    }
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
