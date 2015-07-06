//
//  BonjourModule.m
//  Live2BenchNative
//
//  Created by dev on 2015-06-30.
//  Copyright © 2015 DEV. All rights reserved.
//

#import "BonjourModule.h"
#import "netinet/in.h"
#import <arpa/inet.h>


// THIS CLASS IS UNDERCONSTRUCTION

@implementation BonjourModule
{
    NSNetServiceBrowser         * serviceBrowser;   //serviceBrowser searches for services
    NSMutableArray              * services;         //array of netservices which are detected
}


@synthesize dictOfIPs,delegate;
@synthesize searching = _searching;

- (instancetype)initWithDelegate:(id <BonjourModuleDelegate>)aDelegate
{
    self = [super init];
    if (self) {
        dictOfIPs               = [[NSMutableDictionary alloc]init];
        services                = [[NSMutableArray alloc]init];
        serviceBrowser          = [NSNetServiceBrowser new] ;
        serviceBrowser.delegate = self;
        _searching              = NO;
        delegate                = aDelegate;
       [serviceBrowser searchForServicesOfType:@"_pxp._udp" inDomain:@""];
    }
    return self;
}


-(void)netServiceBrowser:(NSNetServiceBrowser *)aBrowser didFindService:(NSNetService *)aService moreComing:(BOOL)more {
    [services addObject:aService];
    [self resolveIPAddress:aService];
}

//---services removed from the network---
-(void)netServiceBrowser:(NSNetServiceBrowser *)aBrowser didRemoveService:(NSNetService *)aService moreComing:(BOOL)more {
    [services removeObject:aService];
}

//---resolve the IP address of a service---
-(void) resolveIPAddress:(NSNetService *)service {
    NSNetService *remoteService = service;
    remoteService.delegate = self;
    [remoteService resolveWithTimeout:0];
}

//---managed to resolve---
-(void)netServiceDidResolveAddress:(NSNetService *)service {
    if (!self.searching)return;
    
    NSString *name          = nil;
    NSData *address         = nil;
    struct sockaddr_in *socketAddress = nil;
    NSString *ipString      = nil;
    int port;
    BOOL isSameNetwork      = TRUE;
    NSString *deviceIP      = [Utility getIPAddress];
    
    NSArray *parseLocalIP   = [[NSArray alloc]initWithArray:[deviceIP componentsSeparatedByString:@"."]]; //split the local ip of the device into an array of each number -- used to compare to remote ip(test if on the same network
    
    for(int i=0;i < [[service addresses] count]; i++ )
    {
        name                    = [service name];//retrieve unique name of bonjservice
        address                 = [[service addresses] objectAtIndex: i];
        socketAddress           = (struct sockaddr_in *) [address bytes];
        ipString                = [NSString stringWithFormat: @"%s", inet_ntoa(socketAddress->sin_addr)];
        NSArray *parseRemoteIP  = [[NSArray alloc]initWithArray:[ipString componentsSeparatedByString:@"."]]; //parse remote ip into an array to compare with local ip
        
        for(NSString *subIP in parseRemoteIP)
        {
            NSUInteger i = [parseRemoteIP indexOfObject:subIP];
            if(![subIP isEqualToString:[parseLocalIP objectAtIndex:i]]&&i<3)//compare only the first 3 numbers in the ip address
            {
                isSameNetwork=FALSE; // if the numbers don't equal each other then we don't want it, set the bool to false
            }
        }
        
        port = socketAddress->sin_port; // grab port
        
        if(isSameNetwork)
        {
            NSArray *arrayOfStrings = [name componentsSeparatedByString:@" - "];
            [dictOfIPs setValue:[NSString stringWithFormat:@"http://%@:%d",ipString,htons(port)] forKey:[arrayOfStrings objectAtIndex:0]];
            //globals.URL=[NSString stringWithFormat:@"http://%@:%d",ipString,htons(port)];//set the global url parameter to our ipstring:port -- we need to use htons to flip the bytes returned by the port
            //globals.CURRENT_PLAYBACK_EVENT=[NSString stringWithFormat:@"%@/events/live/video/list.m3u8",globals.URL];
            
            NSString *hostName = [service hostName];
            if ([[service hostName] hasSuffix:@".local."]){
                hostName = [[service hostName] stringByReplacingOccurrencesOfString:@".local." withString:@""];
            }
            [dictOfIPs setValue:[NSString stringWithFormat:@"http://%@:%d",ipString,htons(port)] forKey:hostName];
            if (delegate){
                [delegate registerEncoder:hostName ip:ipString];
            }
        }
    }

    
}

//---did not managed to resolve---
-(void)netService:(NSNetService *)service didNotResolve:(NSDictionary *)errorDict {
    
}


-(BOOL)searching
{
    return _searching;
}

-(void)setSearching:(BOOL)searching
{
    if (searching == _searching)return;
    if (searching) {
        [serviceBrowser searchForServicesOfType:@"_pxp._udp" inDomain:@""];
        PXPLog(@"BonjourModule: ON");
    } else{
        [serviceBrowser stop];
        PXPLog(@"BonjourModule: OFF");
    }
    [self willChangeValueForKey:@"searchForEncoders"];
    _searching = searching;
    [self didChangeValueForKey:@"searchForEncoders"];
}

-(void)reset
{
    if (!serviceBrowser){
        serviceBrowser          = [NSNetServiceBrowser new] ;
        serviceBrowser.delegate = self;
        [serviceBrowser searchForServicesOfType:@"_pxp._udp" inDomain:@""];
    }
}

-(void)clear
{
    serviceBrowser              = nil ;
    [services removeAllObjects];
}

@end
