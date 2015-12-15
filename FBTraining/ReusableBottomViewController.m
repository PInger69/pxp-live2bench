//
//  BottomViewController.m
//  MultipleButtonsWithPopovers
//
//  Created by dev on 2015-01-28.
//  Copyright (c) 2015 Avoca Technologies. All rights reserved.
//

#import "ReusableBottomViewController.h"

@interface ReusableBottomViewController ()

@property (strong, nonatomic) NSDictionary *dataDictionary;
@property (strong, nonatomic) NSDictionary *plistDictionary;


@end

@implementation ReusableBottomViewController

-(instancetype) init{
    
    self = [super init];
    if(self){
        self.arrayOfAllComponents = [[NSMutableArray alloc]init];
        self.arrayOfAllObservers = [[NSMutableArray alloc] init];
         
        __block ReusableBottomViewController *weakself = self;
        NSNotification *thatNotification = [NSNotification notificationWithName:@"BottomViewControllerInit"
                                      object:self
                                    userInfo:@{@"Block": ^void(NSDictionary *dataDictionary, NSDictionary *plistDictionary){
                                            if(dataDictionary == nil){
                                                //weakself.dataDictionary = dataDictionary;
                                                weakself.plistDictionary = plistDictionary;
                                            }else{
                                                weakself.dataDictionary = dataDictionary;
                                            }
                                            }
           }
         ];
        
        [[NSNotificationCenter defaultCenter]postNotification: thatNotification];
        
        UISwitch *durationSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(50, 600, 100, 30)];
        [durationSwitch setOnTintColor:PRIMARY_APP_COLOR];
        [durationSwitch setTintColor:PRIMARY_APP_COLOR];
        [durationSwitch setThumbTintColor:[UIColor grayColor]];
        [durationSwitch setOn:YES];
        [durationSwitch addTarget:self action:@selector(switchPressed:) forControlEvents:UIControlEventValueChanged];
        [self.view addSubview:durationSwitch];
        UILabel *durationLabel = [[UILabel alloc]initWithFrame:CGRectMake(50, 565, 125, 30)];
        [durationLabel setText:@"Dur/Event"];
        [self.view addSubview:durationLabel];
        

    }
    
    return self;
}

#pragma mark- Setter Methods

-(void)setPlistDictionary:(NSDictionary *)plistDictionary{
    _plistDictionary = plistDictionary;
    if(_plistDictionary &&_dataDictionary){
        for(int i = 0; i < [_plistDictionary count]; ++i){
            
            NSString *componentKey = [NSString stringWithFormat: @"Component %i", i+1 ];
            NSDictionary *componentDictionary = _plistDictionary[componentKey];
            NSString *componentType = componentDictionary[@"ComponentType"];
            NSString *componentName = componentDictionary[@"Name"];
            id <AbstractComponentClassProtocol> aComponent = [[NSClassFromString(componentType) alloc]initWithDataDictionary: _dataDictionary[componentName] andPlistDictionary: componentDictionary];
            aComponent.type = (int)componentDictionary[@"Type"];
            aComponent.parentView = self.view;
            [self addComponent:aComponent];
            
        }
        _dataDictionary = nil;
        _plistDictionary = nil;
    }
    
}

-(void)setDataDictionary:(NSDictionary *)dataDictionary{
    _dataDictionary = dataDictionary;
    if(_plistDictionary &&_dataDictionary){
        
        for(int i = 0; i < [_plistDictionary count]; ++i){
            
                NSString *componentKey = [NSString stringWithFormat: @"Component %i", i+1 ];
                NSDictionary *componentDictionary = _plistDictionary[componentKey];
                NSString *componentType = componentDictionary[@"ComponentType"];
                NSString *componentName = componentDictionary[@"Name"];
                id <AbstractComponentClassProtocol> aComponent = [[NSClassFromString(componentType) alloc]initWithDataDictionary: _dataDictionary[componentName] andPlistDictionary: componentDictionary];
                aComponent.type = (int)componentDictionary[@"Type"];
                aComponent.parentView = self.view;
                [self addComponent:aComponent];
        }
        _dataDictionary = nil;
        _plistDictionary = nil;
    }
}

-(void) addComponent: (id <AbstractComponentClassProtocol>) component{
    [self.arrayOfAllComponents addObject:component];
    id ob = [[NSNotificationCenter defaultCenter] addObserverForName:@"Notification" object:nil queue:nil usingBlock:^(NSNotification *theNotification){
        NSLog(@"The user info is %@", theNotification.userInfo);
        
    }];
    [self.arrayOfAllObservers addObject: ob];
}


-(void)dealloc{
    for (id object in self.arrayOfAllObservers){
        [[NSNotificationCenter defaultCenter] removeObserver:object];
    }
    for (id<AbstractComponentClassProtocol> component in self.arrayOfAllComponents){
        [component removeFromSuperview];
    }
}

-(void) compileInformation{
    NSMutableDictionary *sendingDictionary = [[NSMutableDictionary alloc] init];
    for ( id <AbstractComponentClassProtocol> component in self.arrayOfAllComponents){
        [sendingDictionary setObject:component.dataDictionary forKey: component.name];
    }
    NSNotification *sendingNotification = [NSNotification notificationWithName:@"BottomViewController" object:self userInfo: sendingDictionary];
    [[NSNotificationCenter defaultCenter] postNotification:sendingNotification];
}


-(void)notificationReceived: (NSNotification *) receivingNotification{
    int type = (int)receivingNotification.userInfo[@"type"];
    
    for (id <AbstractComponentClassProtocol> component in self.arrayOfAllComponents){
        if (component.type == type) {
            [component notificationAction: receivingNotification.userInfo[@"name"]];
        }
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
    //self.arrayOfAllComponents[3].frame = CGRectMake(400, 600, 45, 30);
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    //
    //self.arrayOfAllComponents
    
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    float red = (arc4random() % 100) / 100.0;
    float green = (arc4random() % 100) / 100.0;
    float blue = (arc4random() % 100) / 100.0;
    NSNotification *postingNotification = [NSNotification notificationWithName:@"ToastObserver"
                                                                        object:self
                                                                      userInfo:@{@"Name": @"ToastIsReady", @"Colour": [UIColor colorWithRed:red green:green blue:blue alpha:1.0]}];
    
    [[NSNotificationCenter defaultCenter] postNotification:postingNotification];
}


-(void) switchPressed: (id) sender{
    for (id <AbstractComponentClassProtocol> component in self.arrayOfAllComponents) {
        if ( [component isMemberOfClass: [ButtonViewManager class]]){
            component.selectable = !component.selectable;
        }
    }
}

@end



