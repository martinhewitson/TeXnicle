//
//  MHPDFThumbnailView.m
//  TeXnicle
//
//  Created by Martin Hewitson on 18/03/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
//

#import "MHPDFThumbnailView.h"

@implementation MHPDFThumbnailView

- (void) awakeFromNib
{
  [self setPostsFrameChangedNotifications:YES];
  
  NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
  [nc addObserver:self
         selector:@selector(handleFrameChangeNotification:) 
             name:NSViewFrameDidChangeNotification
           object:self];
  
}

- (void) dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [super dealloc];
}

- (void) handleFrameChangeNotification:(NSNotification*)aNote
{
//  NSLog(@"Frame changed: %@", NSStringFromRect([self frame]));
  NSRect frame = [self frame];
  CGFloat w = frame.size.width;
  [self setThumbnailSize:NSMakeSize(w, w)];
}

@end
