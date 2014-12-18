//
//  AVPlayerRewindableItem.m
//  Live2BenchNative
//
//  Created by dev on 2014-05-13.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import "AVPlayerRewindableItem.h"

@implementation AVPlayerRewindableItem

-(id)initWithURL:(NSURL *)URL{
    if (self = [super initWithURL:URL]){
        
    }
    return self;
}

-(BOOL)canPlayFastForward {
    return TRUE;
}
-(BOOL)canPlaySlowForward {
    return TRUE;
}
-(BOOL)canStepForward {
    return TRUE;
}
-(BOOL)canPlayFastReverse {
    return TRUE;
}
-(BOOL)canPlayReverse {
    return TRUE;
}
-(BOOL)canPlaySlowReverse {
    return TRUE;
}
-(BOOL)canStepBackward {
    return TRUE;
}

@end
