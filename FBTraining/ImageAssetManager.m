
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
@property (strong, nonatomic) PxpTelestration *telestration;
@end
@implementation NSURLImageConnection

@end



@interface ImageAssetManager () <NSURLConnectionDelegate>

@property NSMutableArray *queueOfConnections;


@end



static ImageAssetManager * instance;
@implementation ImageAssetManager

@synthesize arrayOfClipImages = _arrayOfClipImages;

+(instancetype)getInstance
{
    return instance;
}

-(instancetype) init{
    self = [super init];
    if(self){
        self.timeOutInterval = (NSTimeInterval)10.0;
        instance = self;
        _arrayOfClipImages = [[NSMutableDictionary alloc]init];
    }
    return self;
}

- (void)imageForURL:(NSString *)imageURLString atImageView:(UIImageView *)viewReference {
    [self imageForURL:imageURLString atImageView:viewReference withTelestration:nil];
}

-(void)imageForURL: (NSString *) imageURLString atImageView: (UIImageView *) viewReference withTelestration:(nullable PxpTelestration *)telestration {
    NSURL *imageURL =[NSURL URLWithString:imageURLString];
    viewReference.image = [UIImage imageNamed:@"live.png"];

    UIImage *theImage;
    
    if (imageURLString != nil) {
        theImage = [self checkImageCacheForImageURL:imageURLString];
    }
    //UIImage *theImage = [self checkImageCacheForImageURL:imageURLString];
    if(theImage){
        
        if (telestration && (telestration)) {
            CGFloat ratio = theImage.size.width / theImage.size.height;
            CGSize bounds = viewReference.bounds.size;
            CGSize size = bounds.width > bounds.height ? CGSizeMake(bounds.width, bounds.width / ratio) : CGSizeMake(bounds.height * ratio, bounds.height);
            
            UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
            
            [theImage drawInRect:CGRectMake(0.0, 0.0, size.width, size.height)];
            [telestration.thumbnail drawInRect:CGRectMake(0.0, 0.0, size.width, size.height)];
            
            theImage = UIGraphicsGetImageFromCurrentImageContext();
            
            UIGraphicsEndImageContext();
        }
        
        viewReference.image = theImage;
    }else{
        
        // load image from the server
        NSURLRequest *theRequest = [[NSURLRequest alloc] initWithURL:imageURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:(NSTimeInterval)self.timeOutInterval];

        NSURLImageConnection *imageConnection = [[NSURLImageConnection alloc] initWithRequest: theRequest delegate:self  startImmediately:NO];
               // NSURLImageConnection *imageConnection = [[NSURLImageConnection alloc]initWithRequest: theRequest delegate:self];
        
        imageConnection.imageData = [[NSMutableData alloc]init];
        imageConnection.imageViewReference = viewReference;
        imageConnection.telestration = telestration;
        [self.queueOfConnections addObject: imageConnection ];
       // [imageConnection start];
        
        [imageConnection scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
        [imageConnection start];

        
    }
    
    
}

-(UIImage *) checkImageCacheForImageURL: (NSString *) imageURL{
    //NSString *filePath = [self.pathForFolderContainingImages stringByAppendingString: imageURL];
    //UIImage *returningImage = [UIImage imageWithContentsOfFile:filePath];
    UIImage *returningImage = _arrayOfClipImages[imageURL];
    return returningImage;
}


- (void)connection:(NSURLImageConnection *)connection didReceiveData:(NSData *)data {
    [connection.imageData appendData:data];
    
}

- (void)connectionDidFinishLoading:(NSURLImageConnection *)connection {
    UIImage *receivedImage = [UIImage imageWithData:connection.imageData];
    //[connection.imageViewReference stopAnimating];
    
    if (connection.telestration) {
        CGFloat ratio = receivedImage.size.width / receivedImage.size.height;
        CGSize bounds = connection.imageViewReference.bounds.size;
        CGSize size = bounds.width > bounds.height ? CGSizeMake(bounds.width, bounds.width / ratio) : CGSizeMake(bounds.height * ratio, bounds.height);
        
        UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
        
        [receivedImage drawInRect:CGRectMake(0.0, 0.0, size.width, size.height)];
        [connection.telestration.thumbnail drawInRect:CGRectMake(0.0, 0.0, size.width, size.height)];
        
        receivedImage = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
    }
    
    if (receivedImage) {
        [_arrayOfClipImages setObject:receivedImage forKey:[connection.originalRequest.URL absoluteString]];
        
        [connection.imageViewReference setImage: receivedImage];
    }
    
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



