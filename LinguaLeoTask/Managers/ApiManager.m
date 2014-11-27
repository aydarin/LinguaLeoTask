//
//  ApiManager.m
//  LinguaLeoTask
//
//  Created by Aydar Mukhametzyanov on 26/11/14.
//  Copyright (c) 2014 Aydar Mukhametzyanov. All rights reserved.
//

#import "ApiManager.h"
#import "AFNetworking.h"

#define YANDEX_API_KEY @"trnsl.1.1.20141126T181517Z.b690842e0876678d.13ce5a49571fa9f0b07f577dea46c07e72c3fedc"

@implementation ApiManager

+ (instancetype)shared
{
    static ApiManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

- (void)translateWord:(NSString*)word
             fromLang:(NSString*)fromLang
               toLang:(NSString*)toLang
      completionBlock:(void (^)(NSArray* result, NSError* error))completeBlock
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.stringEncoding = NSUTF8StringEncoding;
    
    NSString* langParam = toLang;
    
    if (fromLang)
    {
        langParam = [NSString stringWithFormat:@"%@-%@", fromLang, toLang];
    }
    
    NSDictionary *params = @{@"key": YANDEX_API_KEY,
                             @"text": word,
                             @"lang": langParam};
    
    NSString* urlString = @"https://translate.yandex.net/api/v1.5/tr.json/translate";
    
    [manager GET:urlString
      parameters:params
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                 if (completeBlock) completeBlock(responseObject[@"text"], nil);
             }];
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             if (completeBlock) completeBlock(nil, error);
         }];
}

@end
