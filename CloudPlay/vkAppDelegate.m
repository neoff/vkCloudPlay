//
//  vkAppDelegate.m
//  CloudPlay
//
//  Created by varg on 06.09.12.
//  Copyright (c) 2012 varg. All rights reserved.
//

#import "vkAppDelegate.h"
#import "vkSplashController.h"

@implementation vkAppDelegate

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
    if(loadMain)
    {
        NSLog(@"load complite");
        return YES;
    }
    return NO;
    
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    loadMain = NO;
    splashController = [[vkSplashController alloc] initWithWindowNibName:@"vkSplashController"];
	[splashController showWindow:self];
    //[splashController close];
    //vkWindowController *win = [splashController _closesss];
    //
}


- (void) loadMainWindow:(vkWindowController *) win
{
    [win showWindow:self];
    loadMain = YES;
    NSLog(@"bo!");
}


@end
