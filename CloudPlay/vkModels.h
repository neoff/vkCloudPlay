//
//  vkModels.h
//  CloudPlay
//
//  Created by varg on 06.09.12.
//  Copyright (c) 2012 varg. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface vkModels : NSObject
{
    NSManagedObjectContext *context;
	NSFetchRequest *request;
    NSEntityDescription *entity;
}

@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (void) setEntitys: (NSString *) ent;
- (NSString *) setSettings:(NSString *) key setValue: (NSString *) value;
- (NSString *) getSettingsKey: (NSString *) key;
- (NSDictionary *) savePlayList: (NSDictionary *) list;
- (NSArray *) getPlaylist;
@end
