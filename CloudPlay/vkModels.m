//
//  vkModels.m
//  CloudPlay
//
//  Created by varg on 06.09.12.
//  Copyright (c) 2012 varg. All rights reserved.
//

#import "vkModels.h"

@implementation vkModels

@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize managedObjectContext = __managedObjectContext;

- (id) init
{
    NSLog(@"--init models");
    //id ids = [super init];
    context = [self managedObjectContext];
	request = [[NSFetchRequest alloc] init];
    [self persistentStoreCoordinator];
    return self;
}

- (NSURL *)applicationFilesDirectory
{
	NSLog(@"app dir");
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *appSupportURL = [[fileManager URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask] lastObject];
    return [appSupportURL URLByAppendingPathComponent:@"varg.vk.CloudPlay"];
}

// Creates if necessary and returns the managed object model for the application.
- (NSManagedObjectModel *)managedObjectModel
{
	NSLog(@"app db");
    if (__managedObjectModel) {
        return __managedObjectModel;
    }

    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"vkCloudPlay" withExtension:@"momd"];
    NSLog(@"app db URL:%@", modelURL);
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return __managedObjectModel;
}

// Returns the persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. (The directory for the store is created, if necessary.)
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
	NSLog(@"Initialize Storage Coordinator");
    if (__persistentStoreCoordinator) {
        return __persistentStoreCoordinator;
    }

    NSManagedObjectModel *mom = [self managedObjectModel];
    if (!mom) {
        NSLog(@"%@:%@ No model to generate a store from", [self class], NSStringFromSelector(_cmd));
        return nil;
    }

    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *applicationFilesDirectory = [self applicationFilesDirectory];
    NSError *error = nil;

    NSDictionary *properties = [applicationFilesDirectory resourceValuesForKeys:[NSArray arrayWithObject:NSURLIsDirectoryKey] error:&error];

    if (!properties) {
        BOOL ok = NO;
        if ([error code] == NSFileReadNoSuchFileError) {
            ok = [fileManager createDirectoryAtPath:[applicationFilesDirectory path] withIntermediateDirectories:YES attributes:nil error:&error];
        }
        if (!ok) {
            [[NSApplication sharedApplication] presentError:error];
            return nil;
        }
    } else {
        if (![[properties objectForKey:NSURLIsDirectoryKey] boolValue]) {
            // Customize and localize this error.
            NSString *failureDescription = [NSString stringWithFormat:@"Expected a folder to store application data, found a file (%@).", [applicationFilesDirectory path]];

            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setValue:failureDescription forKey:NSLocalizedDescriptionKey];
            error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:101 userInfo:dict];

            [[NSApplication sharedApplication] presentError:error];
            return nil;
        }
    }

    NSURL *url = [applicationFilesDirectory URLByAppendingPathComponent:@"CloudPlay.storedata"];
    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];
    NSLog(@"Store URL:%@", url);
    if (![coordinator addPersistentStoreWithType:NSXMLStoreType configuration:nil URL:url options:nil error:&error]) {
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    __persistentStoreCoordinator = coordinator;

    return __persistentStoreCoordinator;
}

// Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
- (NSManagedObjectContext *)managedObjectContext
{
    if (__managedObjectContext) {
        return __managedObjectContext;
    }

    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:@"Failed to initialize the store" forKey:NSLocalizedDescriptionKey];
        [dict setValue:@"There was an error building up the data file." forKey:NSLocalizedFailureReasonErrorKey];
        NSError *error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    __managedObjectContext = [[NSManagedObjectContext alloc] init];
    [__managedObjectContext setPersistentStoreCoordinator:coordinator];

    return __managedObjectContext;
}






//////////////////////////////////

- (void) setEntitys: (NSString *) ent
{
    
    if(ent==@"INSERT")
    {
        NSLog(@"Set Entity to %@", ent);
        [request setEntity:[NSEntityDescription insertNewObjectForEntityForName:@"Settings" inManagedObjectContext:context]];
    }
        
}

- (NSArray *) getPlaylist
{
    NSError *error;
	request.entity = [NSEntityDescription entityForName:@"Playlist" inManagedObjectContext:context];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"ids" ascending:YES];

    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [request setSortDescriptors:sortDescriptors];

	NSArray *array = [context executeFetchRequest:request error:&error];
    return array;
}

- (NSString *) setSettings:(NSString *) key setValue: (NSString *) value
{
	NSError *error;
    NSLog(@"Save setings %@=%@", key, value);
    [request setEntity:[NSEntityDescription entityForName:@"Settings" inManagedObjectContext:context]];
    NSArray *results = [context executeFetchRequest:request error:nil];
    if([results count] == 1)
    {
        NSManagedObject *object = [results lastObject];
        [object setValue:value forKey:key];
    }
    else
    {
        [request.entity setValue: value forKey: key];
    }
	[context save: &error ];
	if(error)
		NSLog(@"save error");

	return value;
}

- (NSDictionary *) savePlayList: (NSDictionary *) list
{

    NSError *error = nil;
    
    request.entity = [NSEntityDescription insertNewObjectForEntityForName:@"Playlist" inManagedObjectContext:context];
    NSTimeInterval timeZoneOffset = [[NSTimeZone systemTimeZone] secondsFromGMT];
    NSTimeInterval timeInMiliseconds = ([[NSDate date] timeIntervalSinceReferenceDate] + timeZoneOffset);

    NSLog(@"Item: %@", list);
    NSDate *gmtDate = [NSDate dateWithTimeIntervalSinceReferenceDate:timeInMiliseconds];
    [request.entity setValue: [list objectForKey:@"sort"] forKey: @"ids"];
    [request.entity setValue: [list objectForKey:@"aid"] forKey: @"aid"];
    [request.entity setValue: [list objectForKey:@"artist"] forKey: @"artist"];
    [request.entity setValue: [list objectForKey:@"duration"] forKey: @"duration"];
    [request.entity setValue: [list objectForKey:@"lyrics_id"] forKey: @"lyrics_id"];
    [request.entity setValue: [list objectForKey:@"owner_id"] forKey: @"owner_id"];
    [request.entity setValue: [list objectForKey:@"title"] forKey: @"title"];
    [request.entity setValue: [list objectForKey:@"url"] forKey: @"url"];
    [request.entity setValue: gmtDate  forKey: @"add_date"];

    [context save: &error ];
    if(error)
        NSLog(@"save error");

    return list;
}

- (NSString *) getSettingsKey: (NSString *) key
{
	NSLog(@"Get settings key %@", key);

	NSError *error;
	request.entity = [NSEntityDescription entityForName:@"Settings" inManagedObjectContext:context];

	NSArray *array = [context executeFetchRequest:request error:&error];
	NSUInteger pageCount = [array count];
	//NSLog (@"%u", pageCount);
	if(pageCount != 0)
	{
        NSMutableArray *value_key= [array valueForKey:key];
        //NSString *ids = [array key];
        NSString *userobj = [value_key objectAtIndex:0];
        for (int i=0; i<pageCount; i++) {
            userobj = [value_key objectAtIndex:i];
            if((NSNull *)userobj!=[NSNull null])
            {
                //NSManagedObject *object = [array lastObject];
                break;
            }
        }

        //NSLog (@"%lu", [userobj length]);
		if((NSNull *)userobj==[NSNull null])
        {
            NSLog (@"NONONONONONO");
            return @"NotFound";
        }
        else
            NSLog (@"The %@ is: %@", key, userobj);

		return userobj;
	}
	else
	{
		NSLog(@"NO %@", key);
	}

	return @"NotFound";
}
@end
