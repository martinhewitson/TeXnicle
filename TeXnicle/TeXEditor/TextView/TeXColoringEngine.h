//
//  TeXColouringEngine.h
//  TeXEditor
//
//  Created by hewitson on 27/3/11.
//  Copyright 2011 bobsoft. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface TeXColoringEngine : NSObject <NSTextStorageDelegate, NSTextViewDelegate> {
@private
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
  BOOL colorComments;
  
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
@property (assign) BOOL colorComments;

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
