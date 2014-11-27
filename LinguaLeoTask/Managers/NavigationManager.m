//
//  NavigationManager.m
//  LinguaLeoTask
//
//  Created by Aydar Mukhametzyanov on 26/11/14.
//  Copyright (c) 2014 Aydar Mukhametzyanov. All rights reserved.
//

#import "NavigationManager.h"
#import "AddWordViewController.h"

@implementation NavigationManager

+ (instancetype)shared
{
    static NavigationManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

- (id)init
{
    self = [super init];
    
    if (self)
    {
        UIViewController* vc = [[AddWordViewController alloc] initWithNibName:@"AddWordViewController" bundle:nil];
        _mainNavigationController = [[UINavigationController alloc] initWithRootViewController:vc];
        _mainNavigationController.navigationBarHidden = NO;
        _mainNavigationController.navigationBar.translucent = NO;
    }
    
    return self;
}

- (void)setRootViewController:(UIViewController *)rootViewController
{
    if (rootViewController)
    {
        _rootViewController = rootViewController;
        [_mainNavigationController setViewControllers:@[rootViewController]];
    }
}

- (void)pushViewController:(UIViewController*)viewController animated:(BOOL)animated
{
    [self.mainNavigationController pushViewController:viewController animated:animated];
}

- (void)showAlertWithText:(NSString*)text
{
    [[[UIAlertView alloc] initWithTitle:@""
                                message:text
                               delegate:nil
                      cancelButtonTitle:NSLocalizedString(@"OK", nil)
                      otherButtonTitles:nil] show];
}

@end
