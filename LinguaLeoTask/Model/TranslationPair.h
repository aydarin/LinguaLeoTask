//
//  TranslationPair.h
//  LinguaLeoTask
//
//  Created by Aydar Mukhametzyanov on 27/11/14.
//  Copyright (c) 2014 Aydar Mukhametzyanov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface TranslationPair : NSManagedObject

@property (nonatomic, retain) NSString * original;
@property (nonatomic, retain) NSString * translated;

@end
