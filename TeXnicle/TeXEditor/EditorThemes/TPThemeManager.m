//
//  TPThemeManager.m
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

#import "TPThemeManager.h"
#import "MABSupportFolder.h"
#import "TPTheme.h"
#import "NSDictionary+Theme.h"
#import "externs.h"
#import "NSArray+Color.h"
#import "NSColor+ContrastingLabelExtensions.h"

NSString * const TPThemeSelectionChangedNotification = @"TPThemeSelectionChangedNotification";


@interface TPThemeManager ()

@property (strong) TPTheme *selectedTheme;
@property (strong) NSDictionary *themeMap;
@property (strong) NSMutableArray *themes;
@property (strong) NSSortDescriptor *themeSortDescriptor;

@end

@implementation TPThemeManager

+(NSArray*)builtinThemeNames
{
  return @[@"texnicle", @"texnicle dark", @"blackboard", @"dusk", @"humane", @"earthworm", @"quiet light", @"solarize light"];
}

+ (TPTheme*) currentTheme
{
  TPThemeManager *tm = [TPThemeManager sharedManager];
  return tm.currentTheme;
}

+ (TPThemeManager*)sharedManager
{
  static TPThemeManager *sharedInstance = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedInstance = [[TPThemeManager alloc] init];
    
    [sharedInstance loadThemeMap];
    [sharedInstance loadThemes];
    
    sharedInstance.themeSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *selectedThemeName = [defaults valueForKey:TPSelectedTheme];
    
    if (selectedThemeName == nil) {
      sharedInstance.selectedTheme = [sharedInstance themeNamed:@"texnicle"];
    } else {
      sharedInstance.selectedTheme = [sharedInstance themeNamed:selectedThemeName];
    }
    
    // if we didn't get the theme (perhaps the selected one has been deleted), choose default
    if (sharedInstance.selectedTheme == nil) {
      sharedInstance.selectedTheme = [sharedInstance themeNamed:@"texnicle"];
    }
    
  });
  return sharedInstance;
}

+ (void) migrateDefaultsToTheme
{
  NSColor *c = nil;
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  
  if ([[defaults valueForKey:TPThemeDidMigrate] boolValue] == YES) {
    return;
  }
  
  if ([TPThemeManager createThemesDir] == NO) {
    return;
  }
  
  TPTheme *theme = [[TPTheme alloc] init];
  theme.themeDescription = @"Migrated Color Settings";
  theme.colorMultilineArguments = [defaults valueForKey:TESyntaxColorMultilineArguments];
  
  // current line
  theme.highlightCurrentLine = [defaults valueForKey:TEHighlightCurrentLine];
  theme.currentLineColor = [[defaults valueForKey:TEHighlightCurrentLineColor] colorValue];
  
  // matching words
  theme.highlightMatchingWords = [defaults valueForKey:TEHighlightMatchingWords];
  theme.matchingWordsColor = [[defaults valueForKey:TEHighlightMatchingWordsColor] colorValue];
  
  // fonts
  NSFont *editorFont = [NSUnarchiver unarchiveObjectWithData:[defaults valueForKey:TEDocumentFont]];
  [theme setEditorFont:editorFont];
  NSFont *consoleFont = [NSUnarchiver unarchiveObjectWithData:[defaults valueForKey:TEConsoleFont]];
  [theme setConsoleFont:consoleFont];
  
  // outline
  c = [[defaults valueForKey:TEDocumentBackgroundColor] colorValue];
  [theme setColor:c forKey:@"texnicle.outline.background"];
  c = [[defaults valueForKey:TPOutlineDocumentColor] colorValue];
  [theme setColor:c forKey:@"texnicle.outline.begin"];
  c = [[defaults valueForKey:TPOutlinePartColor] colorValue];
  [theme setColor:c forKey:@"texnicle.outline.part"];
  c = [[defaults valueForKey:TPOutlineChapterColor] colorValue];
  [theme setColor:c forKey:@"texnicle.outline.chapter"];
  c = [[defaults valueForKey:TPOutlineSectionColor] colorValue];
  [theme setColor:c forKey:@"texnicle.outline.section"];
  c = [[defaults valueForKey:TPOutlineSubsectionColor] colorValue];
  [theme setColor:c forKey:@"texnicle.outline.subsection"];
  c = [[defaults valueForKey:TPOutlineSubsubsectionColor] colorValue];
  [theme setColor:c forKey:@"texnicle.outline.subsubsection"];
  c = [[defaults valueForKey:TPOutlineParagraphColor] colorValue];
  [theme setColor:c forKey:@"texnicle.outline.paragraph"];
  c = [[defaults valueForKey:TPOutlineSubparagraphColor] colorValue];
  [theme setColor:c forKey:@"texnicle.outline.subparagraph"];

  // syntax
  
  c = [[defaults valueForKey:TESyntaxArgumentsColor] colorValue];
  [theme setColor:c forKey:@"texnicle.syntax.arguments"];
  [theme setState:[defaults valueForKey:TESyntaxColorArguments] forKey:@"texnicle.syntax.arguments.active"];
  
  c = [[defaults valueForKey:TESyntaxCommentsColor] colorValue];
  [theme setColor:c forKey:@"texnicle.syntax.comments1"];
  [theme setState:[defaults valueForKey:TESyntaxColorComments] forKey:@"texnicle.syntax.comments1.active"];
  
  c = [[defaults valueForKey:TESyntaxCommentsL2Color] colorValue];
  [theme setColor:c forKey:@"texnicle.syntax.comments2"];
  [theme setState:[defaults valueForKey:TESyntaxColorCommentsL2] forKey:@"texnicle.syntax.comments2.active"];
  
  c = [[defaults valueForKey:TESyntaxCommentsL3Color] colorValue];
  [theme setColor:c forKey:@"texnicle.syntax.comments3"];
  [theme setState:[defaults valueForKey:TESyntaxColorCommentsL3] forKey:@"texnicle.syntax.comments3.active"];

  c = [[defaults valueForKey:TESyntaxMarkupL1Color] colorValue];
  [theme setColor:c forKey:@"texnicle.syntax.markup1"];
  [theme setState:[defaults valueForKey:TESyntaxColorMarkupL1] forKey:@"texnicle.syntax.markup1.active"];

  c = [[defaults valueForKey:TESyntaxMarkupL2Color] colorValue];
  [theme setColor:c forKey:@"texnicle.syntax.markup2"];
  [theme setState:[defaults valueForKey:TESyntaxColorMarkupL2] forKey:@"texnicle.syntax.markup2.active"];
  
  c = [[defaults valueForKey:TESyntaxMarkupL3Color] colorValue];
  [theme setColor:c forKey:@"texnicle.syntax.markup3"];
  [theme setState:[defaults valueForKey:TESyntaxColorMarkupL3] forKey:@"texnicle.syntax.markup3.active"];
  
  c = [[defaults valueForKey:TESyntaxSpecialCharsColor] colorValue];
  [theme setColor:c forKey:@"texnicle.syntax.specialcharacters"];
  [theme setState:[defaults valueForKey:TESyntaxColorSpecialChars] forKey:@"texnicle.syntax.specialcharacters.active"];
  
  c = [[defaults valueForKey:TESyntaxDollarCharsColor] colorValue];
  [theme setColor:c forKey:@"texnicle.syntax.dollar"];
  [theme setState:[defaults valueForKey:TESyntaxColorDollarChars] forKey:@"texnicle.syntax.dollar.active"];
  
  c = [[defaults valueForKey:TESyntaxCommandColor] colorValue];
  [theme setColor:c forKey:@"texnicle.syntax.commands"];
  [theme setState:[defaults valueForKey:TESyntaxColorCommand] forKey:@"texnicle.syntax.commands.active"];
  
  // document
  c = [[defaults valueForKey:TESyntaxTextColor] colorValue];
  [theme setColor:c forKey:@"texnicle.document.text"];
  
  c = [[defaults valueForKey:TEDocumentBackgroundColor] colorValue];
  [theme setColor:c forKey:@"texnicle.document.editorbackground"];
  
  c = [[defaults valueForKey:TEDocumentBackgroundMarginColor] colorValue];
  [theme setColor:c forKey:@"texnicle.document.editormargin"];
  
  c = [[defaults valueForKey:TEDocumentCursorColor] colorValue];
  [theme setColor:c forKey:@"texnicle.document.cursor"];
  
  c = [[defaults valueForKey:TESelectedTextColor] colorValue];
  [theme setColor:c forKey:@"texnicle.document.selectedtext"];

  c = [[defaults valueForKey:TESelectedTextBackgroundColor] colorValue];
  [theme setColor:c forKey:@"texnicle.document.selectedtextbackground"];
  
  // save theme
  NSString *themesDir = [TPThemeManager themesDir];
  
  // make name (checking existing names)
  NSString *name = @"migrated";
  
  // make new path
  NSString *themePath = [[themesDir stringByAppendingPathComponent:name] stringByAppendingPathExtension:[TPThemeManager themeExtension]];
  
  theme.url = [NSURL fileURLWithPath:themePath];
  
  // write dictionary to new path
  [theme save];
  
  // set fact that migration occurred
  [defaults setValue:@YES forKey:TPThemeDidMigrate];
  [defaults setValue:name forKey:TPSelectedTheme];
  [defaults synchronize];
  
  NSAlert *alert = [NSAlert alertWithMessageText:@"Theme Created"
                                   defaultButton:@"OK"
                                 alternateButton:nil
                                     otherButton:nil
                       informativeTextWithFormat:@"A new theme named '%@' was created from your old syntax color settings. To view and edit the theme, go to the 'Fonts & Colors' panel in the preferences.", name];
  [alert runModal];
}

+ (NSString*)themeExtension
{
  return @"txtheme";
}

+ (NSString*)themesDir
{
  MABSupportFolder *sf = [MABSupportFolder sharedController];
  //  NSLog(@"Support folder %@", [sf supportFolder]);
  return [[sf supportFolder] stringByAppendingPathComponent:@"themes"];
}

+ (BOOL) createThemesDir
{
  NSFileManager *fm = [NSFileManager defaultManager];
  NSString *themesDir = [TPThemeManager themesDir];
  if (![fm fileExistsAtPath:themesDir]) {
    NSError *error = nil;
    BOOL success = [fm createDirectoryAtPath:themesDir withIntermediateDirectories:YES attributes:nil error:&error];
    if (success == NO) {
      [NSApp presentError:error];
      NSAlert *alert = [NSAlert alertWithMessageText:@"Themes Installation Failed"
                                       defaultButton:@"OK"
                                     alternateButton:nil
                                         otherButton:nil
                           informativeTextWithFormat:@"No themes have been installed because the themes directory could not be created at %@. This means TeXnicle will use a default built-in theme.", themesDir];
      [alert runModal];
      return NO;
    }
    
    //NSLog(@"Created themes directory at %@", themesDir);
  }
  
  return YES;
}

+ (void) installThemes
{
  NSMutableArray *themePaths = [NSMutableArray array];
  
  for (NSString *name in [TPThemeManager builtinThemeNames]) {
    //    NSLog(@"Adding engine %@", name);
    NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:[TPThemeManager themeExtension]];
    //    NSLog(@"Adding path %@", path);
    if (path) {
      [themePaths addObject:path];
    }
  }
  
  // create themes folder
  if ([TPThemeManager createThemesDir] == NO) {
    return;
  }
  
  NSError *error = nil;
  NSString *themesDir = [TPThemeManager themesDir];
  NSFileManager *fm = [NSFileManager defaultManager];
  for (NSString *themePath in themePaths) {
    error = nil;
    
    NSString *target = [themesDir stringByAppendingPathComponent:[themePath lastPathComponent]];
    //    NSLog(@"Installing %@ to %@", engine, target);
    BOOL success = YES;
    if ([fm fileExistsAtPath:target]) {
      error = nil;
      success = [fm removeItemAtPath:target error:&error];
    }
    if (success == NO) {
      [NSApp presentError:error];
    } else {
      success = [fm copyItemAtPath:themePath toPath:target error:&error];
      if (success == NO) {
        [NSApp presentError:error];
        NSAlert *alert = [NSAlert alertWithMessageText:@"Theme Installation Failed"
                                         defaultButton:@"OK"
                                       alternateButton:nil
                                           otherButton:nil
                             informativeTextWithFormat:@"Installation of theme %@ failed.", [[themePath lastPathComponent] stringByDeletingPathExtension]];
        [alert runModal];
      }
    } // end if file exists error...
  }
  
}

+ (NSArray*)themeSections
{
 return @[@"TeXnicleOutlineColors", @"TeXnicleDocumentColors", @"TeXnicleSyntaxColors"];
}

- (TPTheme*)currentTheme
{
  return self.selectedTheme;  
}

- (NSString*)descriptionForKey:(NSString*)aKey
{
  if (self.themeMap == nil) {
    [self loadThemeMap];
  }
  NSArray *subdicts = [TPThemeManager themeSections];
  for (NSString *sectionKey in subdicts) {
    NSDictionary *dict = [self.themeMap valueForKey:sectionKey];
    NSString *desc = [dict valueForKey:aKey];
    if (desc != nil) {
      return desc;
    }
  }
  return nil;
}

- (void)loadThemeMap
{
  NSString *path = [[NSBundle mainBundle] pathForResource:@"themeElementMap" ofType:@"plist"];
  self.themeMap = [NSDictionary dictionaryWithContentsOfFile:path];
}

- (void)loadThemes
{
  
  
  self.themes = [NSMutableArray array];
  NSString *themesDir = [TPThemeManager themesDir];
  
  // get contents of dir
  NSFileManager *fm = [NSFileManager defaultManager];
  
  BOOL isDir;
  BOOL dirExists = [fm fileExistsAtPath:themesDir isDirectory:&isDir];
  if (!isDir || !dirExists) {
    [TPThemeManager installThemes];
  }
  
  NSError *error = nil;
  NSArray *contents = [fm contentsOfDirectoryAtPath:themesDir error:&error];
  if (contents == nil) {
    [NSApp presentError:error];
    return;
  }
  
  // go over the contents looking for .txtheme files
  for (NSString *path in contents) {
    NSString *filepath = [themesDir stringByAppendingPathComponent:path];
    if ([fm fileExistsAtPath:filepath] && [[filepath pathExtension] isEqualToString:[TPThemeManager themeExtension]]) {
      
      TPTheme *th = [TPTheme themeWithPath:filepath];
      [self.themes addObject:th];
      for (NSString *bin in [TPThemeManager builtinThemeNames]) {
        if ([[bin lowercaseString] isEqualToString:[th.name lowercaseString]]) {
          th.builtIn = YES;
        }
      }
    }
  }
}

- (NSInteger)indexOfThemeNamed:(NSString*)name
{
  NSInteger index = 0;
  for (TPTheme *th in [self registeredThemes]) {
    if ([[th.name lowercaseString] isEqualToString:[name lowercaseString]]) {
      return index;
    }
    index++;
  }
  return NSNotFound;
}

- (TPTheme*)themeNamed:(NSString*)name
{
  if (self.themes == nil) {
    [self loadThemes];
  }
  for (TPTheme *th in [self registeredThemes]) {
    if ([[th.name lowercaseString] isEqualToString:[name lowercaseString]]) {
      return th;
    }
  }
  return nil;
}

- (NSArray*)registeredThemeNames
{
  if (self.themes == nil) {
    [self loadThemes];
  }
  
  NSMutableArray *names = [NSMutableArray array];
  for (TPTheme *t in [self registeredThemes]) {
    [names addObject:t.name];
  }
  
  return names;
}

- (NSArray*) registeredThemes
{
  return [self.themes sortedArrayUsingDescriptors:@[self.themeSortDescriptor]];
}


@end
