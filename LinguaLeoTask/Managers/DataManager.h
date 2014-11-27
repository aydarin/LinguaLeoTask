//
//  DataManager.h
//  LinguaLeoTask
//
//  Created by Aydar Mukhametzyanov on 26/11/14.
//  Copyright (c) 2014 Aydar Mukhametzyanov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface DataManager : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+ (instancetype)shared;

- (NSError*)saveContext;
- (NSURL *)applicationDocumentsDirectory;
- (void)saveWord:(NSString*)word translation:(NSString*)text completion:(void(^)(BOOL success))completion;
- (void)findWordsFor:(NSString*)word completion:(void(^)(NSArray* results, NSError* error))completion;

@end
