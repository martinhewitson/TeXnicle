//
//  TPEditorTheme.m
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

#import "TPTheme.h"
#import "NSDictionary+Theme.h"
#import "NSColor+ContrastingLabelExtensions.h"
#import "externs.h"

@interface TPTheme ()


@end

@implementation TPTheme

+ (TPTheme*) themeWithPath:(NSString*)aPath
{
  return [[TPTheme alloc] initWithThemeFile:[NSURL fileURLWithPath:aPath]];
}

- (id) initWithThemeFile:(NSURL*)aURL
{
  self = [super init];
  if (self) {
    self.url = aURL;
    self.builtIn = NO;
    self.documentColors = [NSDictionary dictionary];
    self.syntaxColors = [NSDictionary dictionary];
    self.outlineColors = [NSDictionary dictionary];
    self.fonts = [NSDictionary dictionary];
    self.themeDescription = @"New Theme";
    self.colorMultilineArguments = @NO;
    [self loadTheme];
  }
  
  return self;
}

- (id) init
{
  self = [self initWithThemeFile:nil];
  return self;
}


- (void) save
{
  NSMutableDictionary *dict = [NSMutableDictionary dictionary];
 
  // description
  [dict setValue:self.themeDescription forKey:@"ThemeDescription"];
  
  // color multi-line arguments
  [dict setValue:self.colorMultilineArguments forKey:@"ColorMultilineArguments"];
  
  // current line
  [dict setValue:self.highlightCurrentLine forKey:@"HighlightCurrentLine"];
  [dict setValue:[self.currentLineColor stringArray] forKey:@"CurrentLineColor"];
  
  // matching words
  [dict setValue:self.highlightMatchingWords forKey:@"HighlightMatchingWords"];
  [dict setValue:[self.matchingWordsColor stringArray] forKey:@"MatchingWordsColor"];
  
  // fonts
  [dict setValue:self.fonts forKey:@"TeXnicleFonts"];
  
  // document
  [dict setValue:self.documentColors forKey:@"TeXnicleDocumentColors"];

  // outline
  [dict setValue:self.outlineColors forKey:@"TeXnicleOutlineColors"];

  // syntax
  [dict setValue:self.syntaxColors forKey:@"TeXnicleSyntaxColors"];
    
  // write
  if ([dict writeToURL:self.url atomically:YES] == NO) {
    NSLog(@"Failed to write theme at %@", self.url);
  }
  
  // post notification
  NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
  NSDictionary *userinfo = @{@"ThemeName" : self.name};
  [nc postNotificationName:TPThemeSelectionChangedNotification object:self userInfo:userinfo];
  
}

- (void) loadTheme
{
  if (self.url) {
    NSDictionary *themePlist = [NSDictionary dictionaryWithContentsOfURL:self.url];
    
    // sub dictionaries
    self.documentColors = [themePlist valueForKey:@"TeXnicleDocumentColors"];
    self.syntaxColors   = [themePlist valueForKey:@"TeXnicleSyntaxColors"];
    self.outlineColors  = [themePlist valueForKey:@"TeXnicleOutlineColors"];
    self.fonts          = [themePlist valueForKey:@"TeXnicleFonts"];
    
    // name, description
    self.themeDescription = [themePlist valueForKey:@"ThemeDescription"];
    
    // multi-line arguments
    self.colorMultilineArguments = [themePlist valueForKey:@"ColorMultilineArguments"];
    
    // current line
    self.highlightCurrentLine = [themePlist valueForKey:@"HighlightCurrentLine"];
    if (self.highlightCurrentLine == nil) {
      self.highlightCurrentLine = @YES;
    }
    self.currentLineColor = [themePlist colorForKey:@"CurrentLineColor"];
    if (self.currentLineColor == nil) {
      self.currentLineColor = [self.documentEditorBackgroundColor highlightWithLevel:0.2];
      if (self.currentLineColor == nil) {
        self.currentLineColor = [NSColor colorWithDeviceWhite:0.95 alpha:1.0];
      }
    }
    
    // matching words
    self.highlightMatchingWords = [themePlist valueForKey:@"HighlightMatchingWords"];
    if (self.highlightMatchingWords == nil) {
      self.highlightMatchingWords = @YES;
    }
    self.matchingWordsColor = [themePlist colorForKey:@"MatchingWordsColor"];
    if (self.matchingWordsColor == nil) {
      self.matchingWordsColor = [[NSColor selectedTextBackgroundColor] highlightWithLevel:0.6];
    }
    
    [self save];
  }
}

- (NSString*) name
{
  return [[self.url lastPathComponent] stringByDeletingPathExtension];
}


- (NSString*) description
{
  return [NSString stringWithFormat:@"Name: %@\nDescription: %@\n%@\n%@\n%@\n%@", self.name, self.themeDescription, self.documentColors, self.syntaxColors, self.outlineColors, self.fonts];
}

#pragma mark -
#pragma mark General Accessors

- (NSString*)activeKeyForKey:(NSString*)aKey
{
  NSArray *parts = [aKey componentsSeparatedByString:@"."];
  if ([parts count] == 4 && [parts[3] isEqualToString:@"active"]) {
    // use as is
  } else {
    aKey = [aKey stringByAppendingString:@".active"];
  }
  return aKey;
}

- (void) setState:(NSNumber*)state forKey:(NSString*)aKey
{
  aKey = [self activeKeyForKey:aKey];
  NSMutableDictionary *dict = [self.syntaxColors mutableCopy];
  [dict setValue:state
          forKey:aKey];
  self.syntaxColors = dict;
}

- (NSNumber*) activeStateForKey:(NSString*)aKey
{
  aKey = [self activeKeyForKey:aKey];
  id val = [self.syntaxColors valueForKey:aKey];  
  return val;
}

- (NSColor*) colorForKey:(NSString*)aKey
{
  NSColor *c = nil;
  
  // document
  c = [self.documentColors colorForKey:aKey];
  if (c == nil) {
    c = [self.syntaxColors colorForKey:aKey];
    if (c == nil) {
      c = [self.outlineColors colorForKey:aKey];
    }
  }
  
  return c;
}

#pragma mark -
#pragma mark Outline Color Accessors

- (NSColor*) outlineBackgroundColor
{
  NSColor *c = [self.outlineColors colorForKey:@"texnicle.outline.background"];
  if (c == nil) {
    c = [NSColor whiteColor];
  }
  
  return c;
}

- (NSColor*) outlineBeginColor
{
  NSColor *c = [self.outlineColors colorForKey:@"texnicle.outline.begin"];
  if (c == nil) {
    c = [NSColor blackColor];
  }
  
  return c;
}

- (NSColor*) outlinePartColor
{
  NSColor *c = [self.outlineColors colorForKey:@"texnicle.outline.part"];
  if (c == nil) {
    c = [NSColor blackColor];
  }
  
  return c;
}

- (NSColor*) outlineChapterColor
{
  NSColor *c = [self.outlineColors colorForKey:@"texnicle.outline.chapter"];
  if (c == nil) {
    c = [NSColor blackColor];
  }
  
  return c;
}

- (NSColor*) outlineSectionColor
{
  NSColor *c = [self.outlineColors colorForKey:@"texnicle.outline.section"];
  if (c == nil) {
    c = [NSColor redColor];
  }
  
  return c;
}

- (NSColor*) outlineSubsectionColor
{
  NSColor *c = [self.outlineColors colorForKey:@"texnicle.outline.subsection"];
  if (c == nil) {
    c = [[NSColor redColor] highlightWithLevel:0.4];
  }
  
  return c;
}

- (NSColor*) outlineSubsubsectionColor
{
  NSColor *c = [self.outlineColors colorForKey:@"texnicle.outline.subsubsection"];
  if (c == nil) {
    c = [[NSColor redColor] highlightWithLevel:0.7];
  }
  
  return c;
}

- (NSColor*) outlineParagraphColor
{
  NSColor *c = [self.outlineColors colorForKey:@"texnicle.outline.paragraph"];
  if (c == nil) {
    c = [NSColor lightGrayColor];
  }
  
  return c;
}

- (NSColor*) outlineSubparagraphColor
{
  NSColor *c = [self.outlineColors colorForKey:@"texnicle.outline.subparagraph"];
  if (c == nil) {
    c = [NSColor darkGrayColor];
  }
  
  return c;
}


#pragma mark -
#pragma mark Syntax Color Accessors

- (NSColor*) syntaxCommandColor
{
  NSColor *c = [self.syntaxColors colorForKey:@"texnicle.syntax.commands"];
  if (c == nil) {
    c = [NSColor purpleColor];
  }
  
  return c;
}

- (BOOL) shouldColorCommand
{
  return [[self.syntaxColors valueForKey:@"texnicle.syntax.commands.active"] boolValue];
}

- (NSColor*) syntaxSpecialCharactersColor
{
  NSColor *c = [self.syntaxColors colorForKey:@"texnicle.syntax.specialcharacters"];
  if (c == nil) {
    c = [NSColor redColor];
  }
  
  return c;
}

- (BOOL) shouldColorSpecialCharacters
{
  return [[self.syntaxColors valueForKey:@"texnicle.syntax.specialcharacters.active"] boolValue];
}

- (NSColor*) syntaxDollarColor
{
  NSColor *c = [self.syntaxColors colorForKey:@"texnicle.syntax.dollar"];
  if (c == nil) {
    c = [NSColor redColor];
  }
  
  return c;
}

- (BOOL) shouldColorDollar
{
  return [[self.syntaxColors valueForKey:@"texnicle.syntax.dollar.active"] boolValue];
}

- (NSColor*) syntaxArgumentsColor
{
  NSColor *c = [self.syntaxColors colorForKey:@"texnicle.syntax.arguments"];
  if (c == nil) {
    c = [NSColor blueColor];
  }
  
  return c;
}

- (BOOL) shouldColorArguments
{
  return [[self.syntaxColors valueForKey:@"texnicle.syntax.arguments.active"] boolValue];
}

- (NSColor*) syntaxMarkup1Color
{
  NSColor *c = [self.syntaxColors colorForKey:@"texnicle.syntax.markup1"];
  if (c == nil) {
    c = [NSColor magentaColor];
  }
  
  return c;
}

- (BOOL) shouldColorMarkup1
{
  return [[self.syntaxColors valueForKey:@"texnicle.syntax.markup1.active"] boolValue];
}

- (NSColor*) syntaxMarkup2Color
{
  NSColor *c = [self.syntaxColors colorForKey:@"texnicle.syntax.markup2"];
  if (c == nil) {
    c = [NSColor magentaColor];
  }
  
  return c;
}

- (BOOL) shouldColorMarkup2
{
  return [[self.syntaxColors valueForKey:@"texnicle.syntax.markup2.active"] boolValue];
}

- (NSColor*) syntaxMarkup3Color
{
  NSColor *c = [self.syntaxColors colorForKey:@"texnicle.syntax.markup3"];
  if (c == nil) {
    c = [NSColor magentaColor];
  }
  
  return c;
}

- (BOOL) shouldColorMarkup3
{
  return [[self.syntaxColors valueForKey:@"texnicle.syntax.markup3.active"] boolValue];
}

- (NSColor*) syntaxComments1Color
{
  NSColor *c = [self.syntaxColors colorForKey:@"texnicle.syntax.comments1"];
  if (c == nil) {
    c = [NSColor grayColor];
  }
  
  return c;
}

- (BOOL) shouldColorComments1
{
  return [[self.syntaxColors valueForKey:@"texnicle.syntax.comments1.active"] boolValue];
}

- (NSColor*) syntaxComments2Color
{
  NSColor *c = [self.syntaxColors colorForKey:@"texnicle.syntax.comments2"];
  if (c == nil) {
    c = [NSColor grayColor];
  }
  
  return c;
}

- (BOOL) shouldColorComments2
{
  return [[self.syntaxColors valueForKey:@"texnicle.syntax.comments2.active"] boolValue];
}

- (NSColor*) syntaxComments3Color
{
  NSColor *c = [self.syntaxColors colorForKey:@"texnicle.syntax.comments3"];
  if (c == nil) {
    c = [NSColor grayColor];
  }
  
  return c;
}

- (BOOL) shouldColorComments3
{
  return [[self.syntaxColors valueForKey:@"texnicle.syntax.comments3.active"] boolValue];
}


#pragma mark -
#pragma mark Document Color Accessors

- (NSColor*) documentTextColor
{
  NSColor *c = [self.documentColors colorForKey:@"texnicle.document.text"];
  if (c == nil) {
    c = [NSColor blackColor];
  }
  
  return c;
}

- (NSColor*)documentEditorBackgroundColor
{
  NSColor *c = [self.documentColors colorForKey:@"texnicle.document.editorbackground"];
  if (c == nil) {
    c = [NSColor whiteColor];
  }
  
  return c;
}

- (NSColor*)documentEditorMarginColor
{
  NSColor *c = [self.documentColors colorForKey:@"texnicle.document.editormargin"];
  if (c == nil) {
    c = [NSColor lightGrayColor];
  }
  
  return c;
}

- (NSColor*)documentEditorCursorColor
{
  NSColor *c = [self.documentColors colorForKey:@"texnicle.document.cursor"];
  if (c == nil) {
    c = [NSColor blackColor];
  }
  
  return c;
}

- (NSColor*)documentEditorSelectionColor
{
  NSColor *c = [self.documentColors colorForKey:@"texnicle.document.selectedtext"];
  if (c == nil) {
    c = [NSColor selectedTextColor];
  }
  
  return c;
}

- (NSColor*)documentEditorSelectionBackgroundColor
{
  NSColor *c = [self.documentColors colorForKey:@"texnicle.document.selectedtextbackground"];
  if (c == nil) {
    c = [NSColor selectedTextBackgroundColor];
  }
  
  return c;
}


#pragma mark -
#pragma mark Font Accessors

- (void) setNavigatorFont:(NSFont *)font
{
  NSString *fontDesc = [NSString stringWithFormat:@"%@ - %0.0f", [font displayName], [font pointSize]];
  NSMutableDictionary *fontDict = [self.fonts mutableCopy];
  [fontDict setValue:fontDesc forKey:@"texnicle.font.navigator"];
  self.fonts = fontDict;
}

- (NSFont*)navigatorFont
{
  if (self.fonts == nil) {
    [self loadTheme];
  }
  
  NSString *fontDesc = [self.fonts valueForKey:@"texnicle.font.navigator"];
  NSArray *parts = [fontDesc componentsSeparatedByString:@" - "];
  NSFont *f = [NSFont fontWithName:parts[0] size:[parts[1] doubleValue]];
  if (f == nil) {
    f = [NSFont systemFontOfSize:12];
  }
  return f;
}

+ (NSSet*)keyPathsForValuesAffectingNavigatorFont
{
  return [NSSet setWithObject:@"fonts"];
}

- (NSString*)navigatorFontLabel
{
  NSFont *f = [self navigatorFont];
  return [NSString stringWithFormat:@"%@ - %0.0f pt", [f displayName], [f pointSize]];
}

+ (NSSet*)keyPathsForValuesAffectingNavigatorFontLabel
{
  return [NSSet setWithObject:@"navigatorFont"];
}

- (void) setEditorFont:(NSFont *)editorFont
{
  NSString *fontDesc = [NSString stringWithFormat:@"%@ - %0.0f", [editorFont displayName], [editorFont pointSize]];
  NSMutableDictionary *fontDict = [self.fonts mutableCopy];
  [fontDict setValue:fontDesc forKey:@"texnicle.font.editor"];
  self.fonts = fontDict;
}

- (NSFont*)editorFont
{
  if (self.fonts == nil) {
    [self loadTheme];
  }
  
  NSString *fontDesc = [self.fonts valueForKey:@"texnicle.font.editor"];
  NSArray *parts = [fontDesc componentsSeparatedByString:@" - "];
  NSFont *f = [NSFont fontWithName:parts[0] size:[parts[1] doubleValue]];
  if (f == nil) {
    f = [NSFont systemFontOfSize:12];
  }
  return f;
}

+ (NSSet*)keyPathsForValuesAffectingEditorFont
{
  return [NSSet setWithObject:@"fonts"];
}

- (NSString*)editorFontLabel
{
  NSFont *f = [self editorFont];
  return [NSString stringWithFormat:@"%@ - %0.0f pt", [f displayName], [f pointSize]];
}

+ (NSSet*)keyPathsForValuesAffectingEditorFontLabel
{
  return [NSSet setWithObject:@"editorFont"];
}

- (void) setColor:(NSColor*)aColor forKey:(NSString *)key
{
  NSArray *parts = [key componentsSeparatedByString:@"."];
  NSString *section = parts[1];
  NSMutableDictionary *dict = nil;
  if ([section isEqualToString:@"outline"]) {
    dict = [self.outlineColors mutableCopy];
  } else if ([section isEqualToString:@"document"]) {
    dict = [self.documentColors mutableCopy];
  } else if ([section isEqualToString:@"syntax"]) {
    dict = [self.syntaxColors mutableCopy];
  } else {
    NSLog(@"Error: this shouldn't happen. But we seem to have a theme section that we can't match [%@]", section);
    return;
  }

  // set color
  [dict setValue:[aColor stringArray] forKey:key];

  if ([section isEqualToString:@"outline"]) {
    self.outlineColors = dict;
  } else if ([section isEqualToString:@"document"]) {
    self.documentColors = dict;
  } else if ([section isEqualToString:@"syntax"]) {
    self.syntaxColors = dict;
  } else {
    NSLog(@"Error: this shouldn't happen. But we seem to have a theme section that we can't match [%@]", section);
    return;
  }
}

- (void) setConsoleFont:(NSFont *)consoleFont
{
  NSString *fontDesc = [NSString stringWithFormat:@"%@ - %0.0f", [consoleFont displayName], [consoleFont pointSize]];
  NSMutableDictionary *fontDict = [self.fonts mutableCopy];
  [fontDict setValue:fontDesc forKey:@"texnicle.font.console"];
  self.fonts = fontDict;
}


- (NSFont*)consoleFont
{
  if (self.fonts == nil) {
    [self loadTheme];
  }
  
  NSString *fontDesc = [self.fonts valueForKey:@"texnicle.font.console"];
  NSArray *parts = [fontDesc componentsSeparatedByString:@" - "];
  NSFont *f = [NSFont fontWithName:parts[0] size:[parts[1] doubleValue]];
  if (f == nil) {
    f = [NSFont userFixedPitchFontOfSize:12];
  }
  return f;
}

+ (NSSet*)keyPathsForValuesAffectingConsoleFont
{
  return [NSSet setWithObject:@"fonts"];
}

- (NSString*)consoleFontLabel
{
  NSFont *f = [self consoleFont];
  return [NSString stringWithFormat:@"%@ - %0.0f pt", [f displayName], [f pointSize]];
}

+ (NSSet*)keyPathsForValuesAffectingConsoleFontLabel
{
  return [NSSet setWithObject:@"consoleFont"];
}

@end
