//
//  ThumbnailDownloader.m
//  Live2BenchNative
//
//  Created by dev on 2015-09-09.
//  Copyright © 2015 DEV. All rights reserved.
//

#import "ThumbnailDownloader.h"

@interface ThumbnailDownloader ()



@property (nonatomic,weak) ImageAssetManager   * iam;





@end



@implementation ThumbnailDownloader
{
    NSString            * thumbURL;
//    ImageAssetManager   * iam;
//    UIImageView         * imageview;
    NSMutableData       * mData;
}


- (instancetype)initImageAssetManager:(ImageAssetManager*)aIAM url:(NSString*)aUrl
{
    self = [super init];
    if (self) {
        thumbURL    = aUrl;
        _iam         = aIAM;
    }
    return self;
}

-(instancetype)initImageAssetManager:(ImageAssetManager*)aIAM url:(NSString*)aUrl imageView:(UIImageView*)aImageview
{
    self = [super init];
    if (self) {
        thumbURL    = aUrl;
        _iam         = aIAM;
        _imageview   = aImageview;
        
    }
    return self;
}



-(void)start
{
    _isFinished = NO;
    if (_iam.arrayOfClipImages[thumbURL]){
        
        self.isSuccess  = YES;
        self.isFinished = YES;
        return;
    }

    NSURLRequest    * theRequest = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:thumbURL] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:5];
    
    NSURLConnection * imageConnection = [[NSURLConnection alloc] initWithRequest: theRequest delegate:self  startImmediately:NO];
    
    [imageConnection start];

    
    
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    mData = [NSMutableData new];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [mData appendData:data];
    
}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection {

    UIImage *receivedImage = [UIImage imageWithData:mData];
    
    if (!receivedImage){
        
        self.isSuccess  = NO;
        self.isFinished = YES;
        PXPLog(@"Warning! Thumbnail Not Found! URL: %@",thumbURL);
        return;
    }
    
    [_iam.arrayOfClipImages setObject:receivedImage forKey:thumbURL];

    if (_imageview){ // && _imageview.window
     _imageview.image = receivedImage;
    }
    self.isSuccess  = YES;
    self.isFinished = YES;

}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    self.isSuccess  = NO;
    self.isFinished = YES;
    
}





@end
