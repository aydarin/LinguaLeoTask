//
//  ApiManager.h
//  LinguaLeoTask
//
//  Created by Aydar Mukhametzyanov on 26/11/14.
//  Copyright (c) 2014 Aydar Mukhametzyanov. All rights reserved.
//

#import <Foundation/Foundation.h>
#define API [ApiManager shared]

@interface ApiManager : NSObject

+ (instancetype)shared;

- (void)translateWord:(NSString*)word
             fromLang:(NSString*)fromLang
               toLang:(NSString*)toLang
      completionBlock:(void (^)(NSArray* result, NSError* error))completionBlock;

@end
