//
//  SocialSharingManager.m
//  Live2BenchNative
//
//  Created by dev on 2015-03-13.
//  Copyright (c) 2015 DEV. All rights reserved.
//

#import "SocialSharingManager.h"
#import "SocialProgressView.h"

@interface SocialSharingManager ()

@property (strong, nonatomic) id <SocialSharingProtocol> currentSocialObject;
@property (strong, nonatomic) NSMutableDictionary *socialSharingObjects;
@property (strong, nonatomic) NSMutableDictionary *progressViewsDictionary;

@end

static SocialSharingManager *commonManager = nil;

@implementation SocialSharingManager

-(instancetype)initWithSocialOptions: (NSArray *) socialSharingOptions{
    self = [self init];
    if(self){
        for (NSString *socialSharingObject in socialSharingOptions) {
            NSString *classString = [socialSharingObject stringByAppendingString:@"Share"];
            id <SocialSharingProtocol> socialShareObject = [[NSClassFromString(classString) alloc]init];
            [(NSObject *)socialShareObject addObserver:self forKeyPath:@"tasksToComplete" options:NSKeyValueObservingOptionNew context:nil];
            [(NSObject *)socialShareObject addObserver:self forKeyPath:@"tasksCompleted" options:NSKeyValueObservingOptionNew context:nil];
            [self.socialSharingObjects setObject:socialShareObject forKey:socialSharingObject];
        }
    }
    commonManager = [SocialSharingManager commonManager];
    commonManager = self;
    return self;
}

+(instancetype) commonManager{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        commonManager = [[self alloc] init];
    });
    
    return commonManager;
}

-(instancetype)init{
    self = [super init];
    if(self){
        self.socialSharingObjects = [[NSMutableDictionary alloc]init];
        self.progressViewsDictionary = [[NSMutableDictionary alloc]init];
    }
    return self;
}

-(NSArray *) arrayOfIcons{
    NSMutableArray *arrayToReturn = [[NSMutableArray alloc]init];
    for (id <SocialSharingProtocol> socialSharingObject in [self.socialSharingObjects allValues]) {
        [arrayToReturn addObject: socialSharingObject.icon];
    }
    
    return arrayToReturn;
}

-(NSArray *) arrayOfSelectedIcons{
    NSMutableArray *arrayToReturn = [[NSMutableArray alloc]init];
    for (id <SocialSharingProtocol> socialSharingObject in [self.socialSharingObjects allValues]) {
        [arrayToReturn addObject: socialSharingObject.selectedIcon];
    }
    
    return arrayToReturn;
}

-(NSArray *) arrayOfSocialOptions{
    return  [self.socialSharingObjects allKeys];
}

-(void)shareItems:(NSArray *)itemsToShare forSocialObject: (NSString *) socialObject inViewController: (UIViewController *) viewController withProgressFrame: (CGRect) progressFrame{
    
    //The string social object is used as the key to retrieve the object from the dictionary
    id <SocialSharingProtocol> sharingObject = self.socialSharingObjects[socialObject];
    // Once the object is retrieved, it is enough to call this method on it
    [sharingObject shareItems:itemsToShare inViewController:viewController ];
    
    // Next a progress view needs to be added to the view controller, however if there is already a progress view there,
    // then one should not be added
    if(![self.progressViewsDictionary objectForKey: NSStringFromClass([viewController class]) ]){
        //If there isnt a progress view already there, then one needs to be instantiated
        SocialProgressView *progressView = [[SocialProgressView alloc] initWithFrame:progressFrame];
        [viewController.view addSubview: progressView];
        [self.progressViewsDictionary setObject:progressView forKey:NSStringFromClass([viewController class])];
    }
    
    
}

//-(void)shareItems:(NSArray *)itemsToShare{
//    [self.currentSocialObject shareItems:itemsToShare];
//    
//}

-(void)setCurrentSocialObject: (NSString *) socialObject inViewController: (UIViewController *) viewController{
    self.currentSocialObject = self.socialSharingObjects[@"socialObject"];
}

-(void) linkSocialObject: (NSString *)socialObject inViewController: (UIViewController *)viewController{
    [self.socialSharingObjects[socialObject] linkInViewController:viewController];
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    NSArray *allProgressViews = [self.progressViewsDictionary allValues];
    
    if ([keyPath isEqualToString:@"tasksToComplete"]){
        for (SocialProgressView *progressView in allProgressViews) {
            progressView.tasksToComplete++;
        }
    }else{
        for (SocialProgressView *progressView in allProgressViews) {
            progressView.tasksCompleted++;
        }
    }
}
@end
