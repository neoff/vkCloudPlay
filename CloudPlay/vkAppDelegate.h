//
//  vkAppDelegate.h
//  CloudPlay
//
//  Created by varg on 06.09.12.
//  Copyright (c) 2012 varg. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class vkSplashController, vkWindowController;
@interface vkAppDelegate : NSObject 
{
    vkSplashController *splashController;
    vkWindowController *windowController;
    bool *loadMain;
}
- (void) loadMainWindow:(vkWindowController *) win;
@end
