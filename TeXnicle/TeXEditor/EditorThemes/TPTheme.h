//
//  TPEditorTheme.h
//  TeXnicle
//
//  Created by Martin Hewitson on 21/7/13.
//  Copyright (c) 2013 bobsoft. All rights reserved.
//
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

@interface TPTheme : NSObject

@property (readonly) NSString *name;
@property (copy) NSString *themeDescription;
@property (strong) NSURL *url;

@property (assign, getter = isBuiltIn) BOOL builtIn;

@property (strong) NSNumber *colorMultilineArguments;
@property (strong) NSDictionary *fonts;
@property (strong) NSDictionary *documentColors;
@property (strong) NSDictionary *syntaxColors;
@property (strong) NSDictionary *outlineColors;


#pragma mark Outline Color Accessors

@property (readonly) NSColor *outlineBeginColor;
@property (readonly) NSColor *outlinePartColor;
@property (readonly) NSColor *outlineChapterColor;
@property (readonly) NSColor *outlineSectionColor;
@property (readonly) NSColor *outlineSubsectionColor;
@property (readonly) NSColor *outlineSubsubsectionColor;
@property (readonly) NSColor *outlineParagraphColor;
@property (readonly) NSColor *outlineSubparagraphColor;


#pragma mark Syntax Color Accessors

@property (readonly) NSColor *syntaxCommandColor;
@property (readonly) BOOL shouldColorCommand;
@property (readonly) NSColor *syntaxSpecialCharactersColor;
@property (readonly) BOOL shouldColorSpecialCharacters;
@property (readonly) NSColor *syntaxDollarColor;
@property (readonly) BOOL shouldColorDollar;
@property (readonly) NSColor *syntaxArgumentsColor;
@property (readonly) BOOL shouldColorArguments;
@property (readonly) NSColor *syntaxMarkup1Color;
@property (readonly) BOOL shouldColorMarkup1;
@property (readonly) NSColor *syntaxMarkup2Color;
@property (readonly) BOOL shouldColorMarkup2;
@property (readonly) NSColor *syntaxMarkup3Color;
@property (readonly) BOOL shouldColorMarkup3;
@property (readonly) NSColor *syntaxComments1Color;
@property (readonly) BOOL shouldColorComments1;
@property (readonly) NSColor *syntaxComments2Color;
@property (readonly) BOOL shouldColorComments2;
@property (readonly) NSColor *syntaxComments3Color;
@property (readonly) BOOL shouldColorComments3;


#pragma mark Document Color Accessors

@property (readonly) NSColor *documentTextColor;
@property (readonly) NSColor *documentEditorBackgroundColor;
@property (readonly) NSColor *documentEditorMarginColor;
@property (readonly) NSColor *documentEditorCursorColor;
@property (readonly) NSColor *documentEditorSelectionColor;
@property (readonly) NSColor *documentEditorSelectionBackgroundColor;

#pragma mark font accessors

@property (strong) NSFont *editorFont;
@property (readonly) NSString *editorFontLabel;
@property (strong) NSFont *consoleFont;
@property (readonly) NSString *consoleFontLabel;

+ (TPTheme*) themeWithPath:(NSString*)aPath;

#pragma mark -
#pragma mark General Accessors

- (void) setState:(NSNumber*)state forKey:(NSString*)aKey;
- (NSNumber*) activeStateForKey:(NSString*)aKey;

- (NSColor*) colorForKey:(NSString*)aKey;
- (void) setColor:(NSColor*)aColor forKey:(NSString *)key;

- (void) save;

@end
