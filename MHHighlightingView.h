//
//  MHHighlightingView.h
//  TeXnicle
//
//  Created by Martin Hewitson on 02/02/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MHHighlightingView : NSView

- (void) handlePDFViewGainedFocusNotification:(NSNotification*)aNote;
- (void) handlePDFViewLostFocusNotification:(NSNotification*)aNote;

@property (assign) BOOL isFocused;

@end
