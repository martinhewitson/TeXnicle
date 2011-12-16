//
//  MHStrokedFiledView.h
//  TeXnicle
//
//  Created by Martin Hewitson on 28/08/11.
//  Copyright 2011 bobsoft. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MHStrokedFiledView : NSView {
@private
  NSColor *fillColor;
  NSColor *strokeColor;
  BOOL strokeSides;
}

@property (retain) NSColor *fillColor;
@property (retain) NSColor *strokeColor;
@property (assign) BOOL strokeSides;

@end
