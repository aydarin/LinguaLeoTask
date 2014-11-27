//
//  WordsListViewController.m
//  LinguaLeoTask
//
//  Created by Aydar Mukhametzyanov on 27/11/14.
//  Copyright (c) 2014 Aydar Mukhametzyanov. All rights reserved.
//

#import "WordsListViewController.h"
#import "DataManager.h"
#import "TranslationPair.h"

@interface WordsListViewController ()
{
    NSArray* _words;
}

@end

@implementation WordsListViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = NSLocalizedString(@"LIST_TITLE", nil);
    
    _textField.delegate = self;
    _wordsTable.delegate = self;
    _wordsTable.dataSource = self;
    _words = [[NSArray alloc] init];
    
    [_wordsTable reloadData];
    [self performSearchWord:@""];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(wordsDataDidChange:) name:NSManagedObjectContextDidSaveNotification object:nil];
}

- (void)performSearchWord:(NSString*)word
{
    typeof(self) wself = self;
    
    [[DataManager shared] findWordsFor:word
                            completion:^(NSArray *results, NSError *error) {
                                typeof(self) sself = wself;
                                
                                if (sself)
                                {
                                    if (!error)
                                    {
                                        NSString* currentText = [sself correctTextToFind:sself.textField.text];
                                        
                                        if ([word isEqualToString:currentText])
                                        {
                                            sself->_words = results;
                                            [sself.wordsTable reloadData];
                                        }
                                    }
                                }
                            }];
}

- (NSString*)correctTextToFind:(NSString*)text
{
    return text ? [[text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] lowercaseString] : @"";
}

#pragma mark - Notifications

- (void)wordsDataDidChange:(NSNotification*)not
{
    [self performSearchWord:[self correctTextToFind:_textField.text]];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString* oldText = textField.text ? textField.text : @"";
    NSString* newText = [oldText stringByReplacingCharactersInRange:range withString:string];
    
    [self performSelector:@selector(performSearchWord:) withObject:[self correctTextToFind:newText] afterDelay:0.1];
    
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    [self performSelector:@selector(performSearchWord:) withObject:@"" afterDelay:0];
    
    return YES;
}

#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _words.count;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* reuseIdentifier = @"WordCell";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    
    if (!cell) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    
    TranslationPair* pair = _words[indexPath.row];
    cell.textLabel.text = pair.original;
    cell.detailTextLabel.text = pair.translated;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.textField resignFirstResponder];
}

@end
