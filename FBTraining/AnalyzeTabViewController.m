//
//  AnalyzeTabViewController.m
//  Live2BenchNative
//
//  Created by dev on 2015-12-10.
//  Copyright © 2015 DEV. All rights reserved.
//

#import "AnalyzeTabViewController.h"
#import "AnalyzeLoader.h"
#import "EncoderManager.h"
#import "RicoPlayer.h"
#import "RicoPlayerViewController.h"
#import "RicoPlayerControlBar.h"
#import "RicoZoomContainer.h"
#import "RicoJogDial.h"
#import "Clip.h"

#import "BorderButton.h"

@interface AnalyzeTabViewController () <AnalyzeLoaderDelegate, RicoJogDialJogDialDelegate>

@property (nonatomic,strong) RicoPlayerViewController   * playerViewController;
@property (nonatomic,strong) RicoPlayerControlBar       * playerControlBar;
@property (nonatomic,strong) RicoZoomContainer          * mainPlayerContainer;
@property (nonatomic,strong) RicoJogDial                * jogDial;
@property (nonatomic,strong) NSMutableArray             * buttonList;

@property (nonatomic,strong) UIView                     * bottomBar;



@property (nonatomic,strong) NSMutableDictionary        * sourcebuttonList;
@property (nonatomic,strong) NSMutableArray             * sourceButtons;
@property (nonatomic,strong) Clip                       * currentClip;

@end

@implementation AnalyzeTabViewController

NSString* const AnalyzeWillProcessTagNotification                   = @"AnalyzeWillProcessTagNotification";
NSString* const AnalyzeWillPlayClipNotification                     = @"AnalyzeWillPlayClipNotification";
NSString* const AnalyzeDidFinishLoadingSetNotification              = @"AnalyzeDidFinishLoadingSetNotification";



static NSMutableArray * analyzedClips;

+(void)initialize
{
    analyzedClips = [NSMutableArray new];


}

-(id)initWithAppDelegate:(AppDelegate *)mainappDelegate
{
    self = [super initWithAppDelegate:mainappDelegate];
    if (self) {

        [self setMainSectionTab:@"Analyze" imageName:@""];
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onProcessTag:) name:AnalyzeWillProcessTagNotification object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onPlayClip:)   name:AnalyzeWillPlayClipNotification object:nil];

        
    }
    
    return self;
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    CGFloat width   = [UIScreen mainScreen].bounds.size.width;
    CGFloat height  = [UIScreen mainScreen].bounds.size.height;
    
    self.playerViewController   = [RicoPlayerViewController new];


    self.jogDial                        = [[RicoJogDial alloc]initWithFrame:CGRectMake(0, height -60-50 , width , 50)];
    self.jogDial.sensitivity            = 0.8;
    self.jogDial.delegate               = self;
    [self.jogDial setBackgroundColor:[UIColor grayColor]];
    
    
    
    self.mainPlayerContainer    = [[RicoZoomContainer alloc]initWithFrame:CGRectMake(0, 115,width , CGRectGetMidY(self.jogDial.frame)-115-30)];
    [self.mainPlayerContainer setBackgroundColor:[UIColor blackColor]];
    // Do any additional setup after loading the view.
    
    self.buttonList             = [NSMutableArray new];
    self.sourcebuttonList       = [NSMutableDictionary new];
    self.sourceButtons          = [NSMutableArray new];
    
    
    self.bottomBar = [[UIView alloc]initWithFrame:CGRectMake(0, height-60, width, 60)];
    [self.bottomBar setBackgroundColor:[UIColor greenColor]];
  
    [self.view addSubview:self.mainPlayerContainer];
    [self.view addSubview:self.jogDial];
    [self.view addSubview:self.bottomBar];
    
    [self populateAnalyzeButtons];
}

-(void)buildSourceButtons:(NSDictionary*)dict
{


    CGFloat x = self.view.frame.size.width - 50;
    CGFloat y;
    
    NSArray * keys = [dict allKeys];
    
//    if ([keys count] > 1) return ;
    NSInteger c =0;
    
    for (NSInteger i=[keys count]-1 ; i >= 0 ; i--) {
        NSString * key = keys[i];
        c++;
        CGFloat bottom = CGRectGetMaxY(self.mainPlayerContainer.frame);
        
        BorderButton * nButton = [[BorderButton alloc]initWithFrame:CGRectMake(x, bottom - (50*c), 40, 40)];
        nButton.tag = i;
        if (i==0) nButton.selected = YES;
        [nButton setTitle:[NSString stringWithFormat:@"%ld",(long)nButton.tag+1] forState:UIControlStateNormal];

        [nButton addTarget:self action:@selector(pickSource:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:nButton];
        
        [self.sourceButtons addObject:nButton];
        [self.sourcebuttonList setObject:key forKey:[NSString stringWithFormat:@"%ld",(long)nButton.tag]];
    }
    
    
    
}

#pragma mark - Buttons methods
-(void)pickSource:(id)sender
{
    for (UIButton * abutton in self.sourceButtons) {
        abutton.selected = NO;
    }
    
    
    UIButton * button = sender;
    button.selected = YES;
    NSString * tag = [NSString stringWithFormat:@"%ld",(long)button.tag];
    
    NSString * key = self.sourcebuttonList[tag];
    RicoPlayer*   rPlayer = [self.playerViewController.players objectForKey:key];
    [self.mainPlayerContainer addToContainer:rPlayer];

}



-(void)onMovement:(RicoJogDial *)dial value:(CGFloat)value
{
    static NSInteger i = 0;
    NSInteger stepAmount = 1;
    CGFloat absVal = fabs(value);
    if ( absVal > 3000) {
        stepAmount = 9;
    } else if ( absVal > 2000) {
        stepAmount = 3;
    }
    
    
    if (value>0) {
        [self.playerViewController stepByCount:stepAmount];
    } else {
        i++;
        if (i%2 )[self.playerViewController stepByCount:-stepAmount*2];
        
    }
    
}




-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}


-(void)onPlayClip:(NSNotification*)note
{
    // kill all current players
    NSArray * controlledPlayers =    [self.playerViewController.players allValues];
    for (RicoPlayer * p in controlledPlayers) {
        [p removeFromSuperview];
        [self.playerViewController removePlayers:p];
    }
    
    Clip * clip = note.object;
    
    // Clear buttons
    

    for (UIButton * button in self.sourceButtons) {
        [button removeFromSuperview];
    }
    [self.sourceButtons removeAllObjects];
    [self.sourcebuttonList removeAllObjects];
    
    
    
    if (!clip) return;
    

    NSArray * keys = [clip.videosBySrcKey allKeys];
    for (NSInteger i= 0; i<[keys count]; i++) {
        RicoPlayer*   ricoPlayer = [[RicoPlayer alloc]initWithFrame:CGRectMake(0, 0, self.mainPlayerContainer.frame.size.width, self.mainPlayerContainer.frame.size.height)];
        
        NSString * url = clip.videosBySrcKey[ keys[i]];

        [self.playerViewController addPlayers:ricoPlayer];
        ricoPlayer.looping          = YES;
        ricoPlayer.syncronized      = YES;
        ricoPlayer.feed             = [[Feed alloc]initWithFileURL:url];
        ricoPlayer.name             = [NSString stringWithFormat:@"Player %ld",(long)i+1];
        [ricoPlayer.debugOutput setHidden:NO];
        
        
    }
   
    RicoPlayer*   rPlayer = [[self.playerViewController.players allValues]firstObject];
    [self.mainPlayerContainer addToContainer:rPlayer];
    
    [self buildSourceButtons:self.playerViewController.players];
    

}

-(void)onProcessTag:(NSNotification*)note
{
    Tag * atag = note.object;
    
    AnalyzeLoader * loader = [[AnalyzeLoader alloc]initWithTag:atag];
    loader.delegate = self;
    [loader start];

}



#pragma mark - AnalizeLoader Delegate methods
-(void)onCompletion:(AnalyzeLoader*)analyzeLoader finalClip:(Clip*)clip
{

    
  
    [self populateAnalyzeButtons];
    
}


-(void)populateAnalyzeButtons
{
    Encoder * encoder = (Encoder *)[EncoderManager getInstance].primaryEncoder;
    
    
    
    
    NSString * eName =    encoder.event.name;
    
    NSPredicate * pred = [NSPredicate predicateWithBlock:^BOOL(id  _Nonnull evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        Clip * checkedClip = evaluatedObject;
        
        if ([checkedClip.eventName isEqualToString:eName] && [checkedClip.name isEqualToString:@"Analyze"]) {
            return YES;
        } else {
            return NO;
        }
        
        
    }];
    
    
    NSArray * analyzeClipsForLive =[[[LocalMediaManager getInstance].clips allValues] filteredArrayUsingPredicate:pred];
    
    [analyzedClips removeAllObjects];
    [analyzedClips addObjectsFromArray:analyzeClipsForLive];
    
    [[NSNotificationCenter defaultCenter]postNotificationName:AnalyzeDidFinishLoadingSetNotification object:nil];
    
    for (UIButton * button in self.sourceButtons) {
        [button removeFromSuperview];
    }
    [self.sourceButtons removeAllObjects];
    
    for (UIButton * button in self.buttonList) {
        [button removeFromSuperview];
    }
    [self.buttonList removeAllObjects];


    
    CGFloat x = 0;
    
    // build analyze buttons
    for (NSInteger i=0; i<[analyzedClips count]; i++) {
        UIButton * _button = [[UIButton alloc]initWithFrame:CGRectMake(10+(45*x), 65, 40, 40)];
        [_button setBackgroundColor:[UIColor blueColor]];
        [_button addTarget:self action:@selector(pickClip:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_button];
        [self.buttonList addObject:_button];
        x++;
    }

}



-(void)pickClip:(id)sender
{
    UIButton * _button  = sender;
    NSUInteger index    = [self.buttonList indexOfObject:_button];
    
    Clip * clip = analyzedClips[index];
    if (self.currentClip == clip) return;
    self.currentClip = clip;
    
    [[NSNotificationCenter defaultCenter]postNotificationName:AnalyzeWillPlayClipNotification object:clip];
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
