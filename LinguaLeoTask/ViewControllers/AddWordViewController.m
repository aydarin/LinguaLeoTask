//
//  AddWordViewController.m
//  LinguaLeoTask
//
//  Created by Aydar Mukhametzyanov on 26/11/14.
//  Copyright (c) 2014 Aydar Mukhametzyanov. All rights reserved.
//

#import "AddWordViewController.h"
#import "ApiManager.h"
#import "DataManager.h"
#import "NavigationManager.h"
#import "WordsListViewController.h"

@interface AddWordViewController ()

@end

@implementation AddWordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"TRANSLATE_TITLE", nil);
    [self.translateButton setTitle:NSLocalizedString(@"TRANSLATE_BUTTON", nil) forState:UIControlStateNormal];
    _translateTextView.text = @"";
    _textField.delegate = self;
    _activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    _activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"LIST_TITLE", nil) style:UIBarButtonItemStylePlain target:self action:@selector(toWordsListClicked:)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_activityIndicator];
    
    self.isLoading = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setIsLoading:(BOOL)isLoading
{
    _isLoading = isLoading;
    
    _activityIndicator.hidden = !_isLoading;
    _translateButton.enabled = !_isLoading;
    
    if (_isLoading) [_activityIndicator startAnimating];
    else [_activityIndicator stopAnimating];
}

#pragma mark - Actions

- (void)toWordsListClicked:(id)sender
{
    WordsListViewController* wordsListVC = [[WordsListViewController alloc] initWithNibName:@"WordsListViewController" bundle:nil];
    [[NavigationManager shared] pushViewController:wordsListVC animated:YES];
}

- (IBAction)translateClicked:(id)sender
{
    NSString* word = [self textToTranslate];
    
    if (word.length > 0)
    {
        __weak typeof(self) wself = self;
        
        self.isLoading = YES;
        
        [API translateWord:word
                  fromLang:nil
                    toLang:@"ru"
           completionBlock:^(NSArray *result, NSError *error) {
               
               typeof(self) sself = wself;
               sself.isLoading = NO;
               
               if (error)
               {
                   if (error.domain == NSURLErrorDomain && error.code == -1009)
                   {
                       [[NavigationManager shared] showAlertWithText:NSLocalizedString(@"NO_INTERNET_CONNECTION", nil)];
                   }
                   else
                   {
                       [[NavigationManager shared] showAlertWithText:NSLocalizedString(@"TRANSLATE_ERROR_MESSAGE", nil)];
                   }
               }
               else
               {
                   [sself didTranslateWord:word result:result];
               }
           }];
    }
}

#pragma mark - Utils

- (NSString*)textToTranslate
{
    return [[_textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] lowercaseString];
}

- (void)didTranslateWord:(NSString*)word result:(NSArray*)result
{
    NSString* text = [result componentsJoinedByString:@"\n"];
    
    if ([[self textToTranslate] isEqualToString:word])
    {
        _translateTextView.text = [text stringByAppendingString:[self tailForTranslation]];
    }
    
    if (text.length > 0)
    {
        [[DataManager shared] saveWord:word translation:text completion:^(BOOL success) {
            if (!success)
            {
                [[NavigationManager shared] showAlertWithText:NSLocalizedString(@"SAVING_ERROR", nil)];
            }
        }];
    }
}

- (NSString*)tailForTranslation
{
    return @"\n\nПереведено сервисом «Яндекс.Перевод»\nhttp://translate.yandex.ru/";
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    _translateTextView.text = @"";
    
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    _translateTextView.text = @"";
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (_translateButton.enabled) [self translateClicked:nil];
    
    return YES;
}

@end
