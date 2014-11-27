//
//  WordsListViewController.h
//  LinguaLeoTask
//
//  Created by Aydar Mukhametzyanov on 27/11/14.
//  Copyright (c) 2014 Aydar Mukhametzyanov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WordsListViewController : UIViewController<UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UITableView *wordsTable;

@end
