//
//  TeleViewController.h
//  Live2BenchNative
//
//  Created by DEV on 2013-01-28.
//  Copyright (c) 2013 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BorderButton.h"
#import "TeleView.h"

@class FullScreenViewController;
@class TeleView;

@interface TeleViewController : UIViewController
{
    UIButton *lineButton;
    UIButton *arrowButton;
    UIButton *focusButton;
//    Globals *globals;
    CGPoint lastPoint;
    CGPoint lastPoint2;
    CGPoint currentPoint;
    CGFloat red;
    CGFloat green;
    CGFloat blue;
    CGFloat brush;
    CGFloat opacity;
    BOOL mouseSwiped;
    UIButton *_cancelButton;
    CustomButton *_teleButton;
    UIBezierPath *path;
    BOOL isStraight;
    CGPoint touchStart;
    CGPoint touchCurrent;
    CGPoint savedShapeStartpoint;
    CGPoint savedShapeEndpoint;
    NSString *documentsDirectory;
    CGPoint originPoint;
    UIImage *teleImage;
}

//-(void)saveTelesCallback:(id)jsonArr;
- (id)initWithController:(id)firstVC;
-(void)colorPicked:(id)sender;
-(void) startTelestration;
-(void) forceCloseTele;
//-(void)cancel:(id)sender;
- (void)saveTeles;
- (void)checkUndoState;

@property (nonatomic,strong)CustomButton *teleButton;
//@property (nonatomic,strong)Live2BenchViewController *l2bVC;
@property (nonatomic, strong) FullScreenViewController *fullScreenViewController;
@property (nonatomic,strong)TeleView *teleView;
@property (nonatomic,strong)UIView *colourIndicator;
//@property (nonatomic)CMTime pausedTime;
//@property (nonatomic,strong)ListViewController *lvController;
//@property (nonatomic,strong)BookmarkViewController *bmvController;
@property (nonatomic,strong) UIButton *saveButton;
@property (nonatomic,strong) UIButton *clearButton;
@property (nonatomic,strong) UIButton *undoButton;
//off set time. The reason for this property is sometimes the start time of video player we obtain from avplayer is negative, this value will cause telestration not accurate
@property (nonatomic)float offsetTime;
//time scale
@property (nonatomic)int timeScale;
@property (nonatomic,strong) UIImage *currentImage;
//image view for display the screenshot image
@property (nonatomic,strong) UIImageView *thumbImageView;
@end
