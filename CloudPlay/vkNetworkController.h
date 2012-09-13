//
//  vkNetworkController.h
//  CloudPlay
//
//  Created by varg on 06.09.12.
//  Copyright (c) 2012 varg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>
#import "vkModels.h"

@interface vkNetworkController : NSObject
{
    NSString *appId;
	NSString *userId;
	NSString *urlStr;
	NSString *accessToken;
    NSString *playUrl;

    WebView *viewWeb;

    Boolean authMe;


    vkModels *models;

}

- (void) setToken: (NSString *) utoken;
- (void) setUid: (NSString *) data;
- (void) setWeb: (WebView *) data;
- (Boolean) getAuth;
- (id) initObject;
- (NSString *) getToken;
- (NSString *) getPlayList;
@end
