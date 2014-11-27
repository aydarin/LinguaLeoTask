//
//  NavigationManager.h
//  LinguaLeoTask
//
//  Created by Aydar Mukhametzyanov on 26/11/14.
//  Copyright (c) 2014 Aydar Mukhametzyanov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NavigationManager : NSObject

@property (nonatomic, retain) UINavigationController* mainNavigationController;
@property (nonatomic, retain) UIViewController* rootViewController;

+ (instancetype)shared;
- (void)pushViewController:(UIViewController*)viewController animated:(BOOL)animated;
- (void)showAlertWithText:(NSString*)text;

@end
