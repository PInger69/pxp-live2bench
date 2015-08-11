//
//  PxpFilterFootballTabViewController.m
//  Live2BenchNative
//
//  Created by andrei on 2015-08-06.
//  Copyright © 2015 DEV. All rights reserved.
//

#import "PxpFilterFootballTabViewController.h"

@interface PxpFilterFootballTabViewController (){
}

@end

@implementation PxpFilterFootballTabViewController

@synthesize tabImage;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Football";
        tabImage =  [UIImage imageNamed:@"settingsButton"];
        
    }
    
    
    return self;
}

- (void)UIUpdate:(NSNotification*)note {
    PxpFilter * filter = (PxpFilter *) note.object;
    _filteredTagLabel.text = [NSString stringWithFormat:@"Filtered Tag(s): %lu",(unsigned long)filter.filteredTags.count];
    _totalTagLabel.text = [NSString stringWithFormat:@"Total Tag(s): %lu",(unsigned long)2147483647*2+1];
}

- (void)addButtonTo:(PxpFilterButtonView*)view withLabel:(NSString*)label withPositionX:(NSInteger)positionX withPositionY:(NSInteger)positionY withWidth:(NSInteger)width withHeight:(NSInteger)height withPredicate:(NSPredicate*)predicate{
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          label, @"Label",
                          [NSNumber numberWithInteger:positionX], @"PositionX",
                          [NSNumber numberWithInteger:positionY], @"PositionY",
                          [NSNumber numberWithInteger:width], @"Width",
                          [NSNumber numberWithInteger:height],  @"Height",
                          predicate, @"Predicate",
                          nil];
    [view addButtonToPool:dict];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    //PxpFilterButtonView Testing
    
    int leftMargin = 20;
    int upMargin = 20;
    int margin = 20;
    
    int lineButtonWidth = 20;
    int lineButtonHeight = 60;
    
    NSArray *Lines = @[@"L1", @"L2", @"L3", @"L4"];
    
    //Offense Line Buttons
    
    int offsetX = leftMargin;
    int offsetY = upMargin + 20;
    
    for(int i=0;i<Lines.count;i++){
        NSString *Label = [NSString stringWithFormat:Lines[i],i+1];
        [self addButtonTo:_leftButtonView withLabel:Label
          withPositionX:i*(lineButtonWidth+margin)+offsetX
          withPositionY:offsetY
              withWidth:lineButtonWidth
             withHeight:lineButtonHeight
          withPredicate:[NSPredicate predicateWithFormat:@"%K == %@", @"name",Label]];
    }
    
    //Defense Line Buttons
    
    offsetX = leftMargin;
    offsetY = (upMargin + 20) * 2 + lineButtonHeight;
    
    for(int i=0;i<Lines.count;i++){
        NSString *Label = [NSString stringWithFormat:Lines[i],i+1];
        [self addButtonTo:_leftButtonView withLabel:Label withPositionX:i*(lineButtonWidth+margin)+offsetX withPositionY:offsetY withWidth:lineButtonWidth withHeight:lineButtonHeight withPredicate:[NSPredicate predicateWithFormat:@"%K == %@", @"name",Label]];
    }
    
    
    //Build all the buttons added to the pool (Otherwise the buttons will not be shown
    [_leftButtonView buildButtons];
    self.modules = [[NSMutableArray alloc]initWithObjects: _leftButtonView, _middleUserInputView, nil];
    
    [_middleUserInputView loadView];
    
    // Do any additional setup after loading the view from its nib
    
}
- (IBAction)clearButtonPressed:(id)sender {
    if(!self.modules)return;
    for(id<PxpFilterModuleProtocol> module in self.modules){
        [module reset];
    }
}

- (void)show{
}

- (void)hide{

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
