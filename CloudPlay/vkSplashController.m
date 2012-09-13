//
//  vkSplashController.m
//  CloudPlay
//
//  Created by varg on 06.09.12.
//  Copyright (c) 2012 varg. All rights reserved.
//

#import "vkSplashController.h"
#import "vkWindowController.h"

@interface vkSplashController ()
//@property (assign) vkNetworkController *vkNetworkController;
//@property (assign) vkModels *vkModels;
//@property (assign) vkWindowController *WindowController;

@end

@implementation vkSplashController
@synthesize viewWeb;

- (void)windowDidLoad
{
    [super windowDidLoad];
    while (1) {
        if([super isWindowLoaded])
        {
            NSLog(@"LOADED");
            
            break;
        }
    }

    
}



- (void)windowWillClose:(NSNotification *)notification
{
    NSLog(@"killme");
    [parent loadMainWindow:windows];
    
}

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self)
    {
        // Initialization code here.
        network = [[vkNetworkController alloc] init];
        models = [[vkModels alloc] init];
        windows = [[vkWindowController alloc] initWithWindowNibName:@"vkWindowController"];
        [network setWeb:viewWeb];


        

    }
    
    return self;
}



- (IBAction)showWindow:(id)sender;
{
    [super showWindow:sender];
    parent = sender;
    NSLog(@"load window splash");
    [self __getData];


    
    
}


- (void) __getData
{
    NSTimeInterval timeZoneOffset = [[NSTimeZone systemTimeZone] secondsFromGMT];
	NSString *utocken =  [models getSettingsKey:@"access_token"];
	NSString *uid =  [models getSettingsKey:@"user_id"];
	NSDate *gmtDate = [models getSettingsKey:@"expires_in"];

    float dt = -1;

	if(utocken != @"NotFound")
		accessToken = utocken;

	if(uid != @"NotFound")
		userId = uid;
    if(gmtDate != @"NotFound")
    {
        NSTimeInterval timeInMiliseconds = [gmtDate timeIntervalSinceReferenceDate];
        dt = (timeInMiliseconds-[self __getDateNow]);
        NSLog(@"NOW %@",[NSDate dateWithTimeIntervalSinceReferenceDate:[self __getDateNow]]);
        NSLog(@"STORE %@",[NSDate dateWithTimeIntervalSinceReferenceDate:timeInMiliseconds]);
        NSLog(@"DATE %f", (timeInMiliseconds-[self __getDateNow]));
    }

	if(utocken == @"NotFound" || uid == @"NotFound" || dt < 0)
	{
        NSLog(@" TRY TO TAKE TOCKEN");
		NSString *res = [network getToken];

        NSString *fullURL = res;
        NSURL *url = [NSURL URLWithString:fullURL];
        NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
        [[viewWeb mainFrame] loadRequest:requestObj];
        
        if(![network getAuth])
        {
            NSLog(@"AUthed");
            [self __responseParser:res];
        }
        else
            [viewWeb setHidden:NO];
	}
    else
    {
        [network setUid:userId];
        [network setToken:accessToken];
        NSLog(@"TOCKEN: %@ UID: %@ DATE: %@", accessToken, userId, gmtDate);
        
        //
    }
    if(![network getAuth])
    {
        [self __getPlayList];
    }
    
}

- (void) __getPlayList
{
    NSLog(@"Load Playlist");

	NSArray *array = [models getPlaylist];
	int pageCount = [array count];
    if(pageCount < 1)
    {
        NSLog(@"Playlist not uploaded");
        [self __loadList];
    }
    else
    {
        
    }
    [self close];
}

- (void) __loadList
{
    NSString *result = [network getPlayList];
    NSLog(@"PLAYLIST::%@", result);
    [self __savePlayList:result];

}


- (void) __responseParser:(NSString *) responseUrl
{
    NSURL *url = [NSURL URLWithString:responseUrl];
    NSString *fragments = [NSString stringWithFormat:@"%@", url.fragment];

    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    for (NSString *param in [fragments componentsSeparatedByString:@"&"])
    {
        NSArray *elts = [param componentsSeparatedByString:@"="];
        [params setObject:[elts objectAtIndex:1] forKey:[elts objectAtIndex:0]];
    }

    NSLog(@"URL::: %@", params);

    NSString *keys = [models getSettingsKey: @"access_token"];
    if(keys==@"NotFound" || keys==NULL)
    {
        [models setEntitys:@"INSERT"];
    }
    else
    {
        [models setEntitys:@"UPDATE"];
    }
    
    NSLog(@"TRY TO SAVE");
    accessToken = [models setSettings:@"access_token" setValue:[params objectForKey:@"access_token"]];
    userId = [models setSettings:@"user_id" setValue:[params objectForKey:@"user_id"]];
    [network setUid:userId];
    [network setToken:accessToken];
    
    NSLog(@"SAVED");

    NSTimeInterval timeInMiliseconds = [self __getDateNow];
    timeInMiliseconds += [[params objectForKey:@"expires_in"] integerValue];
    NSDate *gmtDate = [NSDate dateWithTimeIntervalSinceReferenceDate:timeInMiliseconds];
    [models setSettings:@"expires_in" setValue:gmtDate];
    
    
}




- (void) __savePlayList: (NSString *) jsonData
{
    NSError *error = nil;

    NSData *data = [jsonData dataUsingEncoding:NSUTF8StringEncoding];

    NSMutableDictionary *jsonArray = [NSJSONSerialization JSONObjectWithData: data options: 0 error: &error];

    if (!jsonArray)
    {
        NSLog(@"Error parsing JSON: %@", error);
    }
    else
    {
        NSDictionary *responseData = [jsonArray objectForKey:@"response"];
        long sort = 1;
        for (NSMutableDictionary *list in responseData)
        //for(int 1 = 0; i < [responseData count]; i++)
        {
            NSMutableDictionary *myDictionary = [[NSMutableDictionary alloc] init];
            [myDictionary setDictionary:list];
            
            NSNumber *nextValue = [NSNumber numberWithInt:sort];
            [myDictionary setObject:nextValue  forKey:@"sort"];
            [models savePlayList:myDictionary];
            sort++;
            
        }
    }
}



//////////////////////////////////////
- (NSTimeInterval) __getDateNow
{
    //NSDate *now = [NSDate date];
    NSTimeInterval timeZoneOffset = [[NSTimeZone systemTimeZone] secondsFromGMT];
    NSTimeInterval timeInMiliseconds = ([[NSDate date] timeIntervalSinceReferenceDate] + timeZoneOffset);
    return timeInMiliseconds;
}


@end
