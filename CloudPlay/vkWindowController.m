//
//  vkWindowController.m
//  CloudPlay
//
//  Created by varg on 06.09.12.
//  Copyright (c) 2012 varg. All rights reserved.
//

#import "vkWindowController.h"

//@interface vkWindowController ()

//@end

@implementation vkWindowController
@synthesize songData;
@synthesize myTableView;
@synthesize myContentArray;
@synthesize localProgressIndicator;
@synthesize playLoads;
@synthesize playButton;
@synthesize fwdButton;
@synthesize prevButton;

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self)
    {
        network = [[vkNetworkController alloc] init];
        models = [[vkModels alloc] init];
        cclose = NO;
    }
    
    return self;
}
- (void)awakeFromNib
{
    NSLog(@"AWAKE");
    //progressIndicator = localProgressIndicator;
    //[localProgressIndicator all]
}

- (void) startPlaying
{
    NSError *error;
    
    player = [[AVAudioPlayer alloc] initWithData:songData error:&error];
    player.numberOfLoops = 0;
    if(error)
    {
        NSLog(@"%@", [error localizedDescription]);
        NSLog(@"%@",[error localizedFailureReason]);
    }

    if(error.code == kAudioFileUnsupportedFileTypeError)
    {
        NSLog(@"song type failed");
    }
    //player = av;
    //[player setDelegate:self];
    [player play];
    [NSTimer scheduledTimerWithTimeInterval:1.0
                                                         target:self
                                                       selector:@selector(updateTimeLeft)
                                                       userInfo:nil
                                                        repeats:YES];

    [playButton setTitle:@"❙❙"];
}

- (void)updateTimeLeft {
    NSTimeInterval timeLeft = player.duration - player.currentTime;
    [playLoads setDoubleValue:player.currentTime];
    NSLog(@"%f",timeLeft);
    if(player.isPlaying && timeLeft < 1)
    {
        NSLog(@"The next song");
        [self nextOnClick:@"Next"];
    }
    if(!player.isPlaying && timeLeft > 1)
    {
        [player play];
    }

    // update your UI with timeLeft
    //NSLog([NSString stringWithFormat:@"%f seconds left", timeLeft]);
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    NSLog(@"load main window");
    list = [models getPlaylist];
    

    NSUInteger pageCount = [list count];
	//NSLog (@"%u", pageCount);
	if(pageCount != 0)
	{
		NSLog(@"%ld", pageCount);

        for (int i=0; i<pageCount; i++)
        {
            id userobj = [list objectAtIndex:i];

            //id userobjs = [array objectAtIndex:i];
            NSString *duration = [userobj valueForKey:@"duration"];
            NSString *title = [userobj valueForKey:@"title"];
            NSString *artist = [userobj valueForKey:@"artist"];
            NSString *ids = [userobj valueForKey:@"ids"];
           
            
            //NSScrollView.set
            //NSLog (@"The %@ is: %@", aid, title);*/

            NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                         title, @"Title",
                                         artist, @"Name",
                                         duration, @"Time",
                                         ids, @"Id",
                                         nil];
            [myContentArray addObject: dict];

        }
        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:0];
        [myTableView selectRowIndexes:indexSet byExtendingSelection:YES];
        
        
        
    }
    [myTableView setTarget: self];
    [myTableView setDoubleAction: @selector(doubleAction:)];
    

    [playButton setTarget:self];
    [playButton setAction:@selector(playOnClick:)];
    [fwdButton setTarget:self];
    [fwdButton setAction:@selector(nextOnClick:)];
    [prevButton setTarget:self];
    [prevButton setAction:@selector(prevOnClick:)];
    [playLoads setAction:@selector(slideDuration:)];


}



- (void) playOnClick:(id) sender
{
    NSLog(@"Play: %ld", [myTableView selectedRow]);
    if([player prepareToPlay])
    {
        if([player isPlaying])
        {
            [sender setTitle:@"►"];
            [player pause];
            
        }
        else
        {
            [sender setTitle:@"❙❙"];
            [player play];
        }
    }
    else
    {
        long nind = [myTableView selectedRow];
        [self __startPlay:nind];
    }
}

- (void) nextOnClick:(id) sender
{
    long ob=[list count];
    ob--;
    //NSLog(@"Count - %d", ob);
    long nind = [myTableView selectedRow];
    //[myTableView deselectRow:[myTableView selectedRow]];
    if(nind==ob)
        nind=0;
    else
        nind++;
    NSLog(@"Next: %ld", nind);
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:nind];
    [myTableView selectRowIndexes:indexSet byExtendingSelection:NO];
    [myTableView scrollRowToVisible:nind];
    [self __startPlay:nind];
}

- (void) prevOnClick:(id) sender
{
    long ob=[list count];
    ob--;
    
    long nind = [myTableView selectedRow];
    //[myTableView deselectRow:[myTableView selectedRow]];
    if(nind == 0)
        nind = ob;
    else
        nind--;
    NSLog(@"Prev: %ld", nind);
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:nind];
    [myTableView selectRowIndexes:indexSet byExtendingSelection:NO];
    [myTableView scrollRowToVisible:nind];
    [self __startPlay:nind];
}

- (void)doubleAction:(id)sender
{
    NSLog(@"Double click was detected...");

    long ind = [sender selectedRow];
    NSLog(@"Get list id: %ld",ind);
    [self __startPlay:ind];
    

}

- (void) slideDuration:(id) sender
{
     NSLog(@"Slide was detected...");
    //[playLoads setDoubleValue:player.currentTime];
    NSLog(@"%f", [playLoads doubleValue]);
    [player setCurrentTime:[playLoads doubleValue]];
}

-(void) __startPlay:(long) ind
{
    NSDictionary *dict = [list objectAtIndex: ind];
    NSString *url = [dict valueForKey:@"url"];
    NSLog(@"Set url:%@", url);

    [playLoads setMaxValue:[[dict valueForKey:@"duration"] intValue]];
    [self __play:url];
}



- (void) __play:(NSString *) urldata
{
    //NSError *error;
    NSLog(@"Start playing url:%@", urldata);
    
    if(player.isPlaying == YES)
    {
        NSLog(@"Stop the song");
        start_playing = false;
        [player stop];
        [player setCurrentTime:0];
        [songData setLength:0];
    }
    
    // -- build the request
    songData = [self getSD:urldata];

}

- (NSMutableData *) getSD:(NSString *) urldata
{
    NSLog(@"Starting call");
    NSURL *url = [NSURL URLWithString:urldata];
    NSURLRequest *theRequest = [NSMutableURLRequest requestWithURL:url];
    NSMutableData *d;
    NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
    
    if (theConnection)
    {
        return [NSMutableData data];
    }
    return d;
}


- (void)connection:(NSURLConnection *)conn didReceiveData:(NSData *)data
{
    //[super connection:conn didReci]
    if(cclose && start_playing)
    {
        cclose = NO;
        [conn cancel];
        
        NSLog(@"CLOSE CONN_ID: %@",[conn self]);
    }
    //[connection cancel];
    
    [songData appendData:data];
    [localProgressIndicator setDoubleValue:[songData length]];
    //NSLog(@"Appending data - %lu", [songData length]);
    
    if(player.isPlaying == NO && [songData length] > 100000)
    {
        NSLog(@"START CONN_ID: %@",[connection self]);
        NSLog(@"Starting the song");
        [self startPlaying];
    }
}



- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    cclose=false;
    start_playing = NO;
    [localProgressIndicator setMinValue:0];
    [songData setLength:0];
    NSNumber *filesize = [NSNumber numberWithLongLong:[response expectedContentLength]];
    NSLog(@"content-length: %@ bytes", filesize);
    [localProgressIndicator setMaxValue:[filesize doubleValue]];

    
}

- (void)connection:(NSURLConnection *)conn didFailWithError:(NSError *)error
{
    cclose = NO;
    //start_playing = NO;
    NSLog(@"Connection failed! Error - %@ %@", [error localizedDescription], [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)conn
{
    cclose = NO;
    NSLog(@"Succeeded! Received %ld bytes of data",[songData length]);
    [conn cancel];
    //[songData release];
}

@end
