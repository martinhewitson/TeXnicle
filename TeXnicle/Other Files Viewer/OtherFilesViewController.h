//
//  OtherFilesViewController.h
//  TeXnicle
//
//  Created by Martin Hewitson on 27/4/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TPSourceFile.h"
#import "TPSourceDirectory.h"
#import "TPOtherFilesOutlineView.h"

@class OtherFilesViewController;

@protocol OtherFilesViewControllerDelegate <NSObject>

- (BOOL) otherFilesViewer:(OtherFilesViewController*)anOtherFilesViewer shouldIncludeItemAtPath:(NSURL*)aURL;

@end

@interface OtherFilesViewController : NSViewController <TPSourceDirectoryDelegate, NSOutlineViewDataSource, NSOutlineViewDelegate> {
@private
  id<OtherFilesViewControllerDelegate> delegate;
  NSURL *root;
  TPSourceDirectory *tree;
  TPOtherFilesOutlineView *outlineView;
}

@property (assign) id<OtherFilesViewControllerDelegate> delegate;
@property (retain) NSURL *root;
@property (retain) TPSourceDirectory *tree;
@property (assign) IBOutlet TPOtherFilesOutlineView *outlineView;

- (id)initWithURL:(NSURL*)aURL delegate:(id<OtherFilesViewControllerDelegate>)aDelegate;

- (void) reloadData;

@end
