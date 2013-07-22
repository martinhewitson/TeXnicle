//
//  TPThemeEditorViewController.h
//  TeXnicle
//
//  Created by Martin Hewitson on 21/7/13.
//  Copyright (c) 2013 bobsoft. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "HHValidatedButton.h"

@interface TPThemeEditorViewController : NSViewController <NSTableViewDataSource, NSTableViewDelegate, NSUserInterfaceValidations, NSTextFieldDelegate>

- (void)revealInFinder;
- (void)duplicateTheme;

@end
