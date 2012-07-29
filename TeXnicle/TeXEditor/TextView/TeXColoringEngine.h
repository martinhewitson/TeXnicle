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
//  DISCLAIMED. IN NO EVENT SHALL MARTIN HEWITSON OR BOBSOFT SOFTWARE BE LIABLE FOR ANY
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
  NSTextView *__unsafe_unretained textView;
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
  
  BOOL colorMarkupL1;
  BOOL colorMarkupL2;
  BOOL colorMarkupL3;
  
  NSColor *markupL1Color;
  NSColor *markupL2Color;
  NSColor *markupL3Color;
  
  BOOL colorMultilineArguments;
  
  NSColor *specialCharsColor;
  BOOL colorSpecialChars;
  
  NSColor *dollarColor;
  BOOL colorDollarChars;
  
  NSColor *commandColor;
  BOOL colorCommand;
  
  NSColor *argumentsColor;
  BOOL colorArguments;
}

@property (strong) NSDate *lastHighlight;
@property (readonly) unichar commentCharacter;

@property (unsafe_unretained) IBOutlet NSTextView *textView;

@property (strong) NSColor *textColor;
@property (strong) NSFont *textFont;

@property (strong) NSColor *commentColor;
@property (strong) NSColor *commentL2Color;
@property (strong) NSColor *commentL3Color;
@property (assign) BOOL colorComments;
@property (assign) BOOL colorCommentsL2;
@property (assign) BOOL colorCommentsL3;


@property (assign) BOOL colorMarkupL1;
@property (assign) BOOL colorMarkupL2;
@property (assign) BOOL colorMarkupL3;

@property (strong) NSColor *markupL1Color;
@property (strong) NSColor *markupL2Color;
@property (strong) NSColor *markupL3Color;

@property (strong) NSColor *specialCharsColor;
@property (assign) BOOL colorSpecialChars;

@property (strong) NSColor *dollarColor;
@property (assign) BOOL colorDollarChars;

@property (strong) NSColor *commandColor;
@property (assign) BOOL colorCommand;

@property (strong) NSColor *argumentsColor;
@property (assign) BOOL colorArguments;
@property (assign) BOOL colorMultilineArguments;

- (id) initWithTextView:(NSTextView*)aTextView;
+ (TeXColoringEngine*)coloringEngineWithTextView:(NSTextView*)aTextView;

- (void) readColorsAndFontsFromPreferences;
- (void) colorTextView:(NSTextView*)aTextView textStorage:(NSTextStorage*)textStorage layoutManager:(NSLayoutManager*)layoutManager inRange:(NSRange)aRange;

- (void) observePreferences;
- (void) stopObserving;

@end
