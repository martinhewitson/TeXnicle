//
//  Settings.m
//  TeXnicle
//
//  Created by Martin Hewitson on 27/08/11.
//  Copyright (c) 2011 bobsoft. All rights reserved.
//

#import "Settings.h"
#import "ProjectEntity.h"
#import "externs.h"

@implementation Settings
@dynamic engineName;
@dynamic doBibtex;
@dynamic doPS2PDF;
@dynamic nCompile;
@dynamic openConsole;
@dynamic project;

- (void) awakeFromInsert
{
  // setup defaults
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  
  self.engineName = [defaults valueForKey:TPDefaultEngineName];
  self.doBibtex = [defaults valueForKey:BibTeXDuringTypeset];
  self.doPS2PDF = [defaults valueForKey:TPShouldRunPS2PDF];
  self.nCompile = [defaults valueForKey:TPNRunsPDFLatex];
  self.openConsole = [defaults valueForKey:OpenConsoleOnTypeset];
  
}

@end
