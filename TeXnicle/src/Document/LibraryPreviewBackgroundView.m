//
//  LibraryPreviewBackgroundView.m
//  TeXnicle
//
//  Created by Martin Hewitson on 02/06/11.
//  Copyright 2011 AEI Hannover . All rights reserved.
//

#import "LibraryPreviewBackgroundView.h"


@implementation LibraryPreviewBackgroundView

- (id)initWithFrame:(NSRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    // Initialization code here.
  }
  
  return self;
}

- (void)dealloc
{
  [super dealloc];
}

- (void)drawRect:(NSRect)dirtyRect
{
  // Drawing code here.
  [[NSColor whiteColor] set];
  NSRectFill([self bounds]);
}

@end
