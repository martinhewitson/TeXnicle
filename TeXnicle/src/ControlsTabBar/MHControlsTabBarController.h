//
//  MHControlsTabBarController.h
//  TeXnicle
//
//  Created by Martin Hewitson on 27/05/11.
//  Copyright 2011 bobsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const TPControlsTabSelectionDidChangeNotification;

@interface MHControlsTabBarController : NSObject <NSTabViewDelegate> {
@private
  NSArray *buttons;
  NSButton *projectButton;
  NSButton *palletButton;
  NSButton *libraryButton;
  NSButton *outlineButton;
  NSButton *findButton;
  NSButton *bookmarksButton;
  NSTabView *tabView;
}

@property (assign) IBOutlet NSButton *projectButton;
@property (assign) IBOutlet NSButton *palletButton;
@property (assign) IBOutlet NSButton *libraryButton;
@property (assign) IBOutlet NSButton *outlineButton;
@property (assign) IBOutlet NSButton *findButton;
@property (assign) IBOutlet NSButton *bookmarksButton;

@property (assign) IBOutlet NSTabView *tabView;

- (void) toggleOn:(id)except;
- (NSInteger) indexOfSelectedTab;

@end
