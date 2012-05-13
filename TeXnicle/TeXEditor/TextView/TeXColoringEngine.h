//
//  TeXColouringEngine.h
//  TeXnicle
//
//  Created by hewitson on 27/3/11.
//  Copyright 2011 bobsoft. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//      * Redistributions of source code must retain the above copyright
//        notice, this list of conditions and the following disclaimer.
//      * Redistributions in binary form must reproduce the above copyright
//        notice, this list of conditions and the following disclaimer in the
//        documentation and/or other materials provided with the distribution.
//  
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
//  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL DAN WOOD, MIKE ABDULLAH OR KARELIA SOFTWARE BE LIABLE FOR ANY
//  DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//   LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
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
  
  BOOL colorMultilineArguments;
  
  NSColor *specialCharsColor;
  BOOL colorSpecialChars;
  
  NSColor *commandColor;
  BOOL colorCommand;
  
  NSColor *argumentsColor;
  BOOL colorArguments;
}

@property (retain) NSDate *lastHighlight;
@property (readonly) unichar commentCharacter;

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
@property (assign) BOOL colorMultilineArguments;

- (id) initWithTextView:(NSTextView*)aTextView;
+ (TeXColoringEngine*)coloringEngineWithTextView:(NSTextView*)aTextView;

- (void) readColorsAndFontsFromPreferences;
- (void) colorTextView:(NSTextView*)aTextView textStorage:(NSTextStorage*)textStorage layoutManager:(NSLayoutManager*)layoutManager inRange:(NSRange)aRange;

- (void) observePreferences;
- (void) stopObserving;

@end
