
//
//  ImageAssetManager.m
//  ImageAssetManager
//
//  Created by dev on 2015-02-02.
//  Copyright (c) 2015 Avoca Technologies. All rights reserved.
//

#import "ImageAssetManager.h"

// PRIVATE CLASS
@interface NSURLImageConnection : NSURLConnection
@property (weak, nonatomic) UIImageView *imageViewReference;
@property (strong, nonatomic) NSMutableData *imageData;
@end
@implementation NSURLImageConnection

@end



@interface ImageAssetManager () <NSURLConnectionDelegate>

@property NSMutableArray *queueOfConnections;

@end




@implementation ImageAssetManager

-(instancetype) init{
    self = [super init];
    if(self){
        self.timeOutInterval = (NSTimeInterval)10.0;
    }
    return self;
}

-(void)imageForURL: (NSString *) imageURLString atImageView: (UIImageView *) viewReference{
    NSURL *imageURL =[NSURL URLWithString:imageURLString];
    /*viewReference.animationImages = [NSArray arrayWithObjects:
                                              [UIImage imageNamed:@"tmp-0.gif"],
                                              [UIImage imageNamed:@"tmp-1.gif"],
                                              [UIImage imageNamed:@"tmp-2.gif"],
                                              [UIImage imageNamed:@"tmp-3.gif"],
                                            [UIImage imageNamed:@"tmp-4.gif"],
                                            [UIImage imageNamed:@"tmp-5.gif"],
                                            [UIImage imageNamed:@"tmp-6.gif"],
                                            [UIImage imageNamed:@"tmp-7.gif"],nil];*/
    //viewReference.animationDuration = 1.5f;
    //[viewReference startAnimating];
    UIImage *theImage = [self checkImageCacheForImageURL:imageURLString];
    if(theImage){
        viewReference.image = theImage;
    }else{
        
        // load image from the server
        NSURLRequest *theRequest = [[NSURLRequest alloc] initWithURL:imageURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:(NSTimeInterval)self.timeOutInterval];
        
        NSURLImageConnection *imageConnection = [[NSURLImageConnection alloc]initWithRequest: theRequest delegate:self];
        imageConnection.imageData = [[NSMutableData alloc]init];
        imageConnection.imageViewReference = viewReference;
        [self.queueOfConnections addObject: imageConnection ];
        
    }
    
    
}

-(UIImage *) checkImageCacheForImageURL: (NSString *) imageURL{
    NSString *filePath = [self.pathForFolderContainingImages stringByAppendingString: imageURL];
    UIImage *returningImage = [UIImage imageWithContentsOfFile:filePath];
    return returningImage;
}


- (void)connection:(NSURLImageConnection *)connection didReceiveData:(NSData *)data {
    [connection.imageData appendData:data];
    
}

- (void)connectionDidFinishLoading:(NSURLImageConnection *)connection {

    UIImage *receivedImage = [UIImage imageWithData:connection.imageData];
    //[connection.imageViewReference stopAnimating];
    connection.imageViewReference.image = receivedImage;
    [self.queueOfConnections removeObject:connection];

}

- (void)connection:(NSURLImageConnection *)connection didFailWithError:(NSError *)error{
    //NSLog(@"the error is received");
    //NSLog(@"%@",error.userInfo);
    //[connection.imageViewReference stopAnimating];
    connection.imageViewReference.image = [UIImage imageNamed:@"imageNotAvailable.png"];
    [self.queueOfConnections removeObject:connection];
}

@end



