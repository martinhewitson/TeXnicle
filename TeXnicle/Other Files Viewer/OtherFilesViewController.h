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
  id<OtherFilesViewControllerDelegate> __unsafe_unretained delegate;
  NSURL *root;
  TPSourceDirectory *tree;
  TPOtherFilesOutlineView *__unsafe_unretained outlineView;
}

@property (unsafe_unretained) id<OtherFilesViewControllerDelegate> delegate;
@property (strong) NSURL *root;
@property (strong) TPSourceDirectory *tree;
@property (unsafe_unretained) IBOutlet TPOtherFilesOutlineView *outlineView;

- (id)initWithURL:(NSURL*)aURL delegate:(id<OtherFilesViewControllerDelegate>)aDelegate;

- (void) reloadData;

@end
