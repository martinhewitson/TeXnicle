//
//  TPWarningsViewController.h
//  TeXnicle
//
//  Created by Martin Hewitson on 16/7/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "HHValidatedButton.h"

@class TPWarningsViewController;
@class TPSyntaxError;

@protocol TPWarningsViewDelegate <NSObject>

- (NSArray*) warningsViewlistOfFiles:(TPWarningsViewController*)warningsView;
- (NSArray*) warningsView:(TPWarningsViewController*)warningsView warningsForFile:(id)file;
- (void) warningsView:(TPWarningsViewController*)warningsView didSelectError:(TPSyntaxError*)anError;

@end

@interface TPWarningsViewController : NSViewController <NSUserInterfaceValidations, NSOutlineViewDelegate, NSOutlineViewDataSource, TPWarningsViewDelegate> {
  
  NSMutableArray *sets;
  NSOutlineView *outlineView;
  id<TPWarningsViewDelegate> delegate;
  HHValidatedButton *revealButton;
}

@property (assign) IBOutlet HHValidatedButton *revealButton;
@property (assign) id<TPWarningsViewDelegate> delegate;
@property (assign) IBOutlet NSOutlineView *outlineView;
@property (retain) NSMutableArray *sets;

- (id) initWithDelegate:(id<TPWarningsViewDelegate>)aDelegate;

- (void) updateUI;
- (IBAction)reveal:(id)sender;

@end
