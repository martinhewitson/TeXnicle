//
//  TeXColouringEngine.h
//  TeXEditor
//
//  Created by hewitson on 27/3/11.
//  Copyright 2011 bobsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kHighlightInterval 0.2

@interface TeXColoringEngine : NSObject <NSTextStorageDelegate, NSTextViewDelegate> {
@protected
  NSTextView *textView;
	// Character sets
	NSCharacterSet *newLineCharacterSet;
	NSCharacterSet *whitespaceCharacterSet;
  NSCharacterSet *specialChars;
  NSArray *keys;
  NSDate *lastHighlight;
  
  NSColor *textColor;
  NSFont *textFont;
  
  NSColor *commentColor;
  NSColor *commentL2Color;
  NSColor *commentL3Color;
  BOOL colorComments;
  BOOL colorCommentsL2;
  BOOL colorCommentsL3;
  
  NSColor *specialCharsColor;
  BOOL colorSpecialChars;
  
  NSColor *commandColor;
  BOOL colorCommand;
  
  NSColor *argumentsColor;
  BOOL colorArguments;
}

@property (retain) NSDate *lastHighlight;

@property (assign) IBOutlet NSTextView *textView;

@property (retain) NSColor *textColor;
@property (retain) NSFont *textFont;

@property (retain) NSColor *commentColor;
@property (retain) NSColor *commentL2Color;
@property (retain) NSColor *commentL3Color;
@property (assign) BOOL colorComments;
@property (assign) BOOL colorCommentsL2;
@property (assign) BOOL colorCommentsL3;

@property (retain) NSColor *specialCharsColor;
@property (assign) BOOL colorSpecialChars;

@property (retain) NSColor *commandColor;
@property (assign) BOOL colorCommand;

@property (retain) NSColor *argumentsColor;
@property (assign) BOOL colorArguments;

- (id) initWithTextView:(NSTextView*)aTextView;
+ (TeXColoringEngine*)coloringEngineWithTextView:(NSTextView*)aTextView;

- (void) readColorsAndFontsFromPreferences;
- (void) colorTextView:(NSTextView*)aTextView textStorage:(NSTextStorage*)textStorage layoutManager:(NSLayoutManager*)layoutManager inRange:(NSRange)aRange;

- (void) observePreferences;
- (void) stopObserving;

@end
