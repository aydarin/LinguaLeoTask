//
//  AddWordViewController.h
//  LinguaLeoTask
//
//  Created by Aydar Mukhametzyanov on 26/11/14.
//  Copyright (c) 2014 Aydar Mukhametzyanov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddWordViewController : UIViewController<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UITextView *translateTextView;
@property (weak, nonatomic) IBOutlet UIButton *translateButton;
@property (nonatomic, retain) UIActivityIndicatorView* activityIndicator;
@property (nonatomic) BOOL isLoading;

- (IBAction)translateClicked:(id)sender;

@end
