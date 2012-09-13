//
//  vkSplashController.h
//  CloudPlay
//
//  Created by varg on 06.09.12.
//  Copyright (c) 2012 varg. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
#import "vkAppDelegate.h"
#import "vkWindowController.h"
#import "vkNetworkController.h"
#import "vkModels.h"

@class vkWindowController;

@interface vkSplashController : NSWindowController <NSWindowDelegate>
{

	NSString *accessToken;
    NSString *userId;
    NSManagedObjectContext *context;
	NSFetchRequest *request;
    
    vkWindowController *windows;
    vkNetworkController *network;
    vkModels *models;
    vkAppDelegate *parent;

}
@property(nonatomic,retain) IBOutlet WebView *viewWeb;
@end
