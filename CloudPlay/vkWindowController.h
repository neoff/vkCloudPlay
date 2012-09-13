//
//  vkWindowController.h
//  CloudPlay
//
//  Created by varg on 06.09.12.
//  Copyright (c) 2012 varg. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "vkNetworkController.h"
#import "vkModels.h"
#import "vkAppDelegate.h"
#import<AVFoundation/AVFoundation.h>
#import<AudioToolbox/AudioToolbox.h>

@interface vkWindowController : NSWindowController
{
    

    //NSProgressIndicator *progressIndicator;

    NSString *accessToken;
    NSString *userId;
    NSManagedObjectContext *context;
	NSFetchRequest *request;

    NSArray *list;
    
    NSURLConnection *connection;
    bool *cclose;
    Boolean *start_playing;

    AVAudioPlayer *player;
    vkNetworkController *network;
    vkModels *models;
    vkAppDelegate *parent;

}
@property (nonatomic, retain) NSMutableData *songData;
@property (nonatomic, retain) IBOutlet NSTableView		*myTableView;
@property (nonatomic, retain) IBOutlet NSArrayController	*myContentArray;
@property (nonatomic, retain) IBOutlet NSProgressIndicator *localProgressIndicator;
@property (nonatomic, retain) IBOutlet NSSlider *playLoads;
@property (nonatomic, retain) IBOutlet NSButton *playButton;
@property (nonatomic, retain) IBOutlet NSButton *fwdButton;
@property (nonatomic, retain) IBOutlet NSButton *prevButton;
@property (nonatomic, retain) IBOutlet NSSlider *playSlide;
- (void) doubleClick:(id)sender;
- (void) playOnClick:(id) sender;
- (void) nextOnClick:(id) sender;
- (void) prevOnClick:(id) sender;
- (void) slideDuration:(id) sender;
@end
