//
//  TPImageViewerController.h
//  TeXnicle
//
//  Created by Martin Hewitson on 31/7/11.
//  Copyright 2011 bobsoft. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface TPImageViewerController : NSViewController {
@private
  NSView *contentView;
  NSImageView *imageViewer;
  NSView *backgroundView;
  NSView *toolbarView;
  NSString *path;
}

@property (assign) IBOutlet NSView *contentView;
@property (assign) IBOutlet NSImageView *imageViewer;
@property (assign) IBOutlet NSView *backgroundView;
@property (assign) IBOutlet NSView *toolbarView;
@property (copy) NSString *path;

- (void) enable;
- (void) disable;
- (void) setImage:(NSImage*)anImage atPath:(NSString*)aPath;
- (IBAction)openItem:(id)sender;

@end
