//
//  Settings.m
//  TeXnicle
//
//  Created by Martin Hewitson on 27/08/11.
//  Copyright (c) 2011 bobsoft. All rights reserved.
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

#import "Settings.h"
#import "ProjectEntity.h"
#import "externs.h"

@implementation Settings

@dynamic doLiveUpdate;
@dynamic language;
@dynamic engineName;
@dynamic doBibtex;
@dynamic doPS2PDF;
@dynamic nCompile;
@dynamic openConsole;
@dynamic project;
@dynamic showStatusBar;

- (void) awakeFromInsert
{
  [self setDefaultSettings];
}

- (void) awakeFromFetch
{
  [self performSelector:@selector(updateSettings) withObject:nil afterDelay:0];
}


- (void) updateSettings
{
  if (self.language == nil && self.managedObjectContext != nil) {
    self.language = [[NSSpellChecker sharedSpellChecker] language];
  }
  
  if (self.doLiveUpdate == nil && self.managedObjectContext != nil) {
    self.doLiveUpdate = @NO;
  }
  
}

- (void)setDefaultSettings
{
  // setup defaults
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  
  self.engineName = [defaults valueForKey:TPDefaultEngineName];
  self.doBibtex = [defaults valueForKey:BibTeXDuringTypeset];
  self.doPS2PDF = [defaults valueForKey:TPShouldRunPS2PDF];
  self.nCompile = [defaults valueForKey:TPNRunsPDFLatex];
  self.openConsole = [defaults valueForKey:OpenConsoleOnTypeset];
  self.language = [[NSSpellChecker sharedSpellChecker] language];
}

@end
