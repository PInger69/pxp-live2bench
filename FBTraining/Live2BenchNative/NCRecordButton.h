//
//  RecordButton.h
//  Live2BenchNative
//
//  Created by Nico Cvitak on 2015-05-20.
//  Copyright (c) 2015 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NCRecordButton;

@protocol NCRecordButtonDelegate

- (void)recordingDidStartInRecordButton:(nonnull NCRecordButton *)recordButton;
- (void)recordingDidFinishInRecordButton:(nonnull NCRecordButton *)recordButton withDuration:(NSTimeInterval)duration;
- (void)recordingTimeDidUpdateInRecordButton:(nonnull NCRecordButton *)recordButton;
- (void)recordingDidTerminateInRecordButton:(nonnull NCRecordButton *)recordButton;

@end

@interface NCRecordButton : UIButton

@property (weak, nonatomic, nullable) id<NCRecordButtonDelegate> delegate;

@property (nonatomic) BOOL displaysTime;

@property (readonly, nonatomic) BOOL isRecording;
@property (readonly, nonatomic) NSTimeInterval recordingTime;
@property (readonly, nonatomic, nonnull) NSString *recordingTimeString;

- (void)terminate;

@end
