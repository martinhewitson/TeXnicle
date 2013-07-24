//
//  TPEngineSettingsController.m
//  TeXnicle
//
//  Created by Martin Hewitson on 27/08/11.
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

#import "TPEngineSettingsController.h"
#import "MHStrokedFiledView.h"

NSString * const TPSpellingLanguageChangedNotification = @"TPSpellingLanguageChangedNotification";
NSString * const TPSpellingAutomaticByLanguage = @"Automatic By Language";

@implementation TPEngineSettingsController

- (id)initWithDelegate:(id<TPEngineSettingsDelegate>)aDelegate
{
  self = [super initWithNibName:@"TPEngineSettingsController" bundle:nil];
  if (self) {
    self.delegate = aDelegate;
  }
  
  return self;
}

- (void) tearDown
{
#if TEAR_DOWN
  NSLog(@"Tear down %@", self);
#endif
  self.delegate = nil;
}

- (void) awakeFromNib
{
  MHStrokedFiledView *view = (MHStrokedFiledView*)[self view];
  [view setFillColor:[NSColor controlColor]];
  [view setStrokeColor:[NSColor darkGrayColor]];
  [view setStrokeSides:YES];
  
  NSColor *color1 = [NSColor colorWithDeviceRed:231.0/255.0 green:231.0/255.0 blue:231.0/255.0 alpha:1.0];
  NSColor *color2 = [NSColor colorWithDeviceRed:221.0/255.0 green:221.0/255.0 blue:221.0/255.0 alpha:1.0];
  
  pane1.fillColor = color1;
  pane1.strokeSides = YES;
  pane2.fillColor = color1;
  pane2.strokeSides = YES;
  pane3.fillColor = color2;
  pane3.strokeSides = YES;
  pane4.fillColor = color1;
  pane4.strokeSides = YES;
  
  // set available languages
  [self setupLanguageOptions];
  
  [self performSelector:@selector(setupEngineSettings) withObject:nil afterDelay:0];
}

- (void) setupLanguageOptions
{
  [languageSelector removeAllItems];
  NSMenuItem *menuItem;
  
  [languageSelector addItemWithTitle:TPSpellingAutomaticByLanguage];
  [[languageSelector menu] addItem:[NSMenuItem separatorItem]];
  
  
  NSArray *languageIDs = [[NSSpellChecker sharedSpellChecker] userPreferredLanguages];
  for (NSString *languageID in languageIDs) {
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:languageID];
    NSString *displayNameString = [locale displayNameForKey:NSLocaleIdentifier value:languageID];
    if (displayNameString == nil) {
      displayNameString = languageID;
    }
    [languageSelector addItemWithTitle:displayNameString];
    menuItem = [languageSelector itemWithTitle:displayNameString];
    [menuItem setRepresentedObject:locale];
  }
  
  // select the current language
  NSString *languageID = [self language];
  if (languageID) {
    if ([languageID isEqualToString:TPSpellingAutomaticByLanguage]) {
      [languageSelector selectItemAtIndex:0];
    } else {
      NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:languageID];
      NSInteger index = [languageSelector indexOfItemWithRepresentedObject:locale];
      [languageSelector selectItemAtIndex:index];
    }
  }
}

- (IBAction) languageSelected:(id)sender
{
  NSMenuItem *menuItem = [languageSelector selectedItem];
  
  if ([[menuItem title] isEqualToString:TPSpellingAutomaticByLanguage]) {
    [self didSelectLanguage:[menuItem title]];
  } else {
    NSLocale *locale = [menuItem representedObject];  
    [self didSelectLanguage:[locale localeIdentifier]];
  }
}

- (void)setupEngineSettings
{
  [engineSelector removeAllItems];
  NSString *engineName = [self engineName];
  if (engineName && [engineName length]>0) {    
    [engineSelector addItemWithTitle:[self engineName]];
  }
  if ([self supportsDoBibtex]) {
    [doBibtexButton setState:[[self doBibtex] intValue]];
    [doBibtexButton setEnabled:YES];
  } else {
    [doBibtexButton setEnabled:NO];
  }
  
  if ([self supportsDoPS2PDF]) {
    [doPS2PDFButton setState:[[self doPS2PDF] intValue]];
    [doPS2PDFButton setEnabled:YES];
  } else {
    [doPS2PDFButton setEnabled:NO];
  }
  
  if ([self supportsNCompile]) {
    [nCompileTextField setIntegerValue:[[self nCompile] intValue]];
    [nCompileStepper setIntegerValue:[[self nCompile] intValue]];
    [nCompileStepper setEnabled:YES];
    [nCompileTextField setEnabled:YES];
    [nCompileLabel setTextColor:[NSColor controlTextColor]];
  } else {
    [nCompileStepper setEnabled:NO];
    [nCompileTextField setEnabled:NO];
    [nCompileLabel setTextColor:[NSColor disabledControlTextColor]];
  }
  
  [openConsoleButton setState:[[self openConsole] intValue]];
}


- (void)menuNeedsUpdate:(NSMenu *)menu
{
  if (menu == [engineSelector menu]) {
    NSArray *engines = [self registeredEngineNames];
    [menu removeAllItems];
    for (NSString *name in engines) {    
      NSMenuItem *item = [menu addItemWithTitle:name action:@selector(engineSelected:) keyEquivalent:@""];
      [item setTarget:self];
    }
    [engineSelector selectItemWithTitle:[self engineName]];
  } else if (menu == [languageSelector menu]) {
    [self setupLanguageOptions];
  }
  
}

- (IBAction)engineSelected:(id)sender
{
  [self didSelectEngineName:[sender title]];
  [self setupEngineSettings];
}

- (IBAction)selectedDoBibtex:(id)sender 
{
  if ([sender state] == NSOnState) {
    [self didSelectDoBibtex:YES];
  } else {
    [self didSelectDoBibtex:NO];
  }    
}

- (IBAction)selectedDoPS2PDF:(id)sender
{
  if ([sender state] == NSOnState) {
    [self didSelectDoPS2PDF:YES];
  } else {
    [self didSelectDoPS2PDF:NO];
  }    
}

- (IBAction)selectedOpenConsole:(id)sender
{
  if ([sender state] == NSOnState) {
    [self didSelectOpenConsole:YES];
  } else {
    [self didSelectOpenConsole:NO];
  }    
}

- (IBAction)changeNCompile:(id)sender
{
  [self didChangeNCompile:[sender integerValue]];
  [nCompileTextField setIntegerValue:[[self nCompile] integerValue]];
}


#pragma mark -
#pragma mark Delegate

- (NSString*)language
{
  if (self.delegate && [self.delegate respondsToSelector:@selector(language)]) {
    return [self.delegate language];
  }
  return nil;
}

-(NSArray*)registeredEngineNames
{
  if (self.delegate && [self.delegate respondsToSelector:@selector(registeredEngineNames)]) {
    return [self.delegate registeredEngineNames];
  }
  return @[];
}

-(void)didSelectDoBibtex:(BOOL)state
{
  if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectDoBibtex:)]) {
    [self.delegate didSelectDoBibtex:state];
  }
}


-(void)didSelectDoPS2PDF:(BOOL)state
{
  if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectDoPS2PDF:)]) {
    [self.delegate didSelectDoPS2PDF:state];
  }  
}

-(void)didSelectOpenConsole:(BOOL)state
{
  if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectOpenConsole:)]) {
    [self.delegate didSelectOpenConsole:state];
  }  
}

-(void)didChangeNCompile:(NSInteger)number
{
  if (self.delegate && [self.delegate respondsToSelector:@selector(didChangeNCompile:)]) {
    [self.delegate didChangeNCompile:number];
  }  
}

-(void)didSelectEngineName:(NSString*)aName
{
  if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectEngineName:)]) {
    [self.delegate didSelectEngineName:aName];
  }  
}

-(void)didSelectLanguage:(NSString*)aName
{
  if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectLanguage:)]) {
    [self.delegate didSelectLanguage:aName];
  }  
  
  // notify
  [[NSNotificationCenter defaultCenter] postNotificationName:TPSpellingLanguageChangedNotification object:self userInfo:nil];
}

-(NSString*)engineName
{
  if (self.delegate && [self.delegate respondsToSelector:@selector(engineName)]) {
    return [self.delegate engineName];
  }
  
  return @"";
}

-(NSNumber*)doBibtex
{
  if (self.delegate && [self.delegate respondsToSelector:@selector(doBibtex)]) {
    return [self.delegate doBibtex];
  }
  
  return @NO;  
}

-(NSNumber*)doPS2PDF
{
  if (self.delegate && [self.delegate respondsToSelector:@selector(doPS2PDF)]) {
    return [self.delegate doPS2PDF];
  }
  
  return @NO;  
}

-(NSNumber*)openConsole
{
  if (self.delegate && [self.delegate respondsToSelector:@selector(openConsole)]) {
    return [self.delegate openConsole];
  }
  
  return @YES;  
}

-(NSNumber*)nCompile
{
  if (self.delegate && [self.delegate respondsToSelector:@selector(nCompile)]) {
    return [self.delegate nCompile];
  }
  
  return @1;  
}


- (BOOL)supportsDoBibtex
{
  if (self.delegate && [self.delegate respondsToSelector:@selector(supportsDoBibtex)]) {
    return [self.delegate supportsDoBibtex];
  }
  return NO;
}

- (BOOL)supportsDoPS2PDF
{
  if (self.delegate && [self.delegate respondsToSelector:@selector(supportsDoPS2PDF)]) {
    return [self.delegate supportsDoPS2PDF];
  }
  return NO;
}

- (BOOL)supportsNCompile
{
  if (self.delegate && [self.delegate respondsToSelector:@selector(supportsNCompile)]) {
    return [self.delegate supportsNCompile];
  }
  return NO;
}

@end
