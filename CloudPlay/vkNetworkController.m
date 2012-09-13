//
//  vkNetworkController.m
//  CloudPlay
//
//  Created by varg on 06.09.12.
//  Copyright (c) 2012 varg. All rights reserved.
//

#import "vkNetworkController.h"

@implementation vkNetworkController

- (id) init
{
    id ids = [super init];
    NSLog(@"---init network");
    appId =  @"2761591";
	playUrl = @"https://api.vk.com/method/audio.get?uid=%@&access_token=%@";
    authMe = NO;

    return ids;

}

- (void) setModels: (vkModels *) model
{
    models = model;
    //request = [model getRequest];
}

- (void) setToken: (NSString *) utoken
{
    accessToken = utoken;
}

- (void) setUid: (NSString *) data
{
    userId = data;
}

- (void) setWeb: (WebView *) data
{
    viewWeb = data;
}

- (Boolean) getAuth
{
    return authMe;
}

- (NSString *) getToken
{
    NSString *vkRedirect = @"http://oauth.vk.com/blank.html";
	NSString *vkAccess = @"friends,audio";

	NSString *vkResponse = @"token";
	NSString *vkDisplay = @"touch";

	NSString *urlvkAuthString = @"http://oauth.vk.com/authorize?client_id=%@&scope=%@&redirect_uri=%@&display=%@&response_type=%@";


	NSString *vkAuthString = [NSString stringWithFormat:urlvkAuthString, appId, vkAccess, vkRedirect, vkDisplay, vkResponse];


	NSString *result = [self sendRequest:vkAuthString];
	NSLog(@"RESPONSE:%@", result);
	return result;
}


- (NSString *) getPlayList
{
    NSMutableURLRequest *request;
    NSHTTPURLResponse *httpResponse;
    NSURLResponse *response;
    NSError *error;

    NSString *urlStrs = [NSString stringWithFormat:playUrl, self->userId, self->accessToken];
    //NSLog(urlStr);
    //NSLog(self->userId);
    request = [NSMutableURLRequest requestWithURL: [NSURL URLWithString:urlStrs]];

	[request setHTTPMethod: @"GET"];

	httpResponse = (NSHTTPURLResponse *)response;
	NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&httpResponse error:&error];

    NSString *result = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    //NSLog(@"LIST RESPONSE:%@", result);
    //[self __savePlayList:result];
    return result;
    
}


- (NSString *) sendRequest: (NSString *) connstring
{
	NSLog(@"REQUEST:%@", connstring);
	NSString *urlStrs = connstring;
	NSMutableURLRequest *request;
	NSError *error;
	NSURLResponse *response;
	NSHTTPURLResponse *httpResponse;

	request = [NSMutableURLRequest requestWithURL: [NSURL URLWithString:urlStrs]];

	[request setHTTPMethod: @"GET"];

	httpResponse = (NSHTTPURLResponse *)response;
	NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&httpResponse error:&error];

    
    if([responseData length] > 3000)
    {
        authMe = YES;
        
        //NSString *result = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        //return result;
    }
   // NSLog(@"%lu", [responseData length]);
    NSString *responseUrl = [NSString stringWithFormat:@"%@", [httpResponse URL]];

	NSInteger statusCode = [httpResponse statusCode];

	//NSLog(@"HTTP Response Headers %@", [httpResponse allHeaderFields]);
	NSLog(@"HTTP Status code: %ld", statusCode);



	// End debug.
	if(statusCode == 200)
	{
        NSLog(@"HTTP Response URL %@", responseUrl);

        return responseUrl;
	}

	return [NSString stringWithFormat:@"%ld", statusCode];
	
}






@end
