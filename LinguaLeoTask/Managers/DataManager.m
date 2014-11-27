//
//  DataManager.m
//  LinguaLeoTask
//
//  Created by Aydar Mukhametzyanov on 26/11/14.
//  Copyright (c) 2014 Aydar Mukhametzyanov. All rights reserved.
//

#import "DataManager.h"
#import "TranslationPair.h"

@implementation DataManager

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

+ (instancetype)shared
{
    static DataManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

#pragma mark - Initialization


- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil)
    {
        return _managedObjectModel;
    }
    
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"LinguaLeoTask" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil)
    {
        return _persistentStoreCoordinator;
    }
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"LinguaLeoTask.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error])
    {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil)
    {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    
    if (!coordinator)
    {
        return nil;
    }
    
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Saving

- (NSError*)saveContext
{
    return [self saveContext:self.managedObjectContext];
}

- (NSError*)saveContext:(NSManagedObjectContext*)context
{
    NSManagedObjectContext *managedObjectContext = context;
    
    if (managedObjectContext != nil)
    {
        NSError *error = nil;
        
        if ([managedObjectContext hasChanges]) [managedObjectContext save:&error];
        
        return error;
    }
    
    return nil;
}

- (void)saveWord:(NSString*)word translation:(NSString*)text completion:(void(^)(BOOL success))completion
{
    if (word.length > 0 && text.length > 0)
    {
        [self performBlockInBackground:^(NSManagedObjectContext *privateContext) {
            
            __block NSArray* existedWords;
            
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self findWordsFor:word performCompletionInMain:NO waitUntilDone:YES completion:^(NSArray *results, NSError *error) {
                    existedWords = results;
                }];
            });
            
            TranslationPair* pairToRewrite;
            TranslationPair* newPair;
            
            for (TranslationPair* existedWord in existedWords)
            {
                if ([existedWord.original isEqualToString:word])
                {
                    pairToRewrite = existedWord;
                    break;
                }
            }
            
            if (pairToRewrite)
            {
                pairToRewrite.translated = text;
            }
            else
            {
                newPair = [self createPairItemInContext:privateContext];
                newPair.original = word;
                newPair.translated = text;
            }
            
            NSError* savingError = [self saveContext:privateContext];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) completion((newPair || pairToRewrite) && !savingError);
            });
        }
                         waitUntilDone:NO];
    }
}

- (TranslationPair*)createPairItemInContext:(NSManagedObjectContext*)context
{
    if (self.managedObjectContext != nil)
    {
        TranslationPair* pair = [NSEntityDescription insertNewObjectForEntityForName:@"TranslationPair" inManagedObjectContext:context];
        
        return pair;
    }
    else {
        return nil;
    }
}

#pragma mark - Fetching

- (void)findWordsFor:(NSString*)word completion:(void(^)(NSArray* results, NSError* error))completion
{
    [self findWordsFor:word performCompletionInMain:YES waitUntilDone:NO completion:completion];
}

- (void)findWordsFor:(NSString*)word
performCompletionInMain:(BOOL)performCompletionInMain
       waitUntilDone:(BOOL)waitUntilDone
          completion:(void(^)(NSArray* results, NSError* error))completion
{
    if (!word)
    {
        if (completion) completion(nil, [NSError errorWithDomain:@"com.aydarmukh.LinguaLeoTask" code:-1 userInfo:@{@"description" : @"Word can not be nil"}]);
    }
    
    NSManagedObjectContext* mainContext = self.managedObjectContext;
    
    [self performBlockInBackground:^(NSManagedObjectContext *privateContext) {
        NSFetchRequest* request = [[NSFetchRequest alloc] initWithEntityName:@"TranslationPair"];
        NSPredicate *predicate;
        
        if (word.length > 0)
        {
            predicate = [NSPredicate predicateWithFormat:@"(original CONTAINS[cd] %@) OR (translated CONTAINS[cd] %@)", word, word];
        }
        
        request.predicate = predicate;
        NSError* error;
        NSArray* results = [privateContext executeFetchRequest:request error:&error];
        NSMutableArray* correctResults = [[NSMutableArray alloc] init];
        
        if (!error)
        {
            typeof(mainContext) wMainContext = mainContext;
            
            [mainContext performBlockAndWait:^{
                for (NSManagedObject* pair in results)
                {
                    NSManagedObjectID* objectID = [pair objectID];
                    NSManagedObject* correctObject = [wMainContext objectWithID:objectID];
                    if (correctObject) [correctResults addObject:correctObject];
                }
            }];
        }
        
        [correctResults sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            TranslationPair* pair1 = obj1;
            TranslationPair* pair2 = obj2;
            
            return [pair1.original compare:pair2.original];
        }];
        
        if (performCompletionInMain)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) completion(correctResults, error);
            });
        }
        else
        {
            if (completion) completion(correctResults, error);
        }
    } waitUntilDone:waitUntilDone];
}

#pragma mark - Utils

- (void)performBlockInBackground:(void(^)(NSManagedObjectContext* privateContext))block waitUntilDone:(BOOL)waitUntilDone
{
    if (!block) return;
    
    NSManagedObjectContext* privateManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [privateManagedObjectContext setParentContext:self.managedObjectContext];
    
    typeof(privateManagedObjectContext) wContext = privateManagedObjectContext;
    
    if (waitUntilDone)
    {
        [privateManagedObjectContext performBlockAndWait:^{
            typeof(privateManagedObjectContext) sContext = wContext;
            if (sContext) block(sContext);
        }];
    }
    else
    {
        [privateManagedObjectContext performBlock:^{
            typeof(privateManagedObjectContext) sContext = wContext;
            if (sContext) block(sContext);
        }];
    }
}

@end
