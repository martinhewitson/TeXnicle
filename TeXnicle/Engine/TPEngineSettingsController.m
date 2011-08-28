//
//  TPEngineSettingsController.m
//  TeXnicle
//
//  Created by Martin Hewitson on 27/08/11.
//  Copyright 2011 bobsoft. All rights reserved.
//

#import "TPEngineSettingsController.h"
#import "MHStrokedFiledView.h"

@implementation TPEngineSettingsController

@synthesize delegate;

- (id)initWithDelegate:(id<TPEngineSettingsDelegate>)aDelegate
{
  self = [super initWithNibName:@"TPEngineSettingsController" bundle:nil];
  if (self) {
    self.delegate = aDelegate;
  }
  
  return self;
}

- (void) awakeFromNib
{
  [self setupEngineSettings];
  
  NSColor *color1 = [NSColor colorWithDeviceRed:231.0/255.0 green:231.0/255.0 blue:231.0/255.0 alpha:1.0];
  NSColor *color2 = [NSColor colorWithDeviceRed:221.0/255.0 green:221.0/255.0 blue:221.0/255.0 alpha:1.0];
  
  pane1.fillColor = color1;
  pane2.fillColor = color2;
  pane3.fillColor = color1;
  
}

- (void)setupEngineSettings
{
  [engineSelector removeAllItems];
  [engineSelector addItemWithTitle:[self engineName]];
  
  [doBibtexButton setState:[[self doBibtex] intValue]];
  [doPS2PDFButton setState:[[self doPS2PDF] intValue]];
  [openConsoleButton setState:[[self openConsole] intValue]];
  
  [nCompileTextField setIntegerValue:[[self nCompile] intValue]];
  [nCompileStepper setIntegerValue:[[self nCompile] intValue]];
}


- (void)menuNeedsUpdate:(NSMenu *)menu
{
  NSArray *engines = [self registeredEngineNames];
  [menu removeAllItems];
  for (NSString *name in engines) {    
    NSMenuItem *item = [menu addItemWithTitle:name action:@selector(engineSelected:) keyEquivalent:@""];
    [item setTarget:self];
  }
  [engineSelector selectItemWithTitle:[self engineName]];
}

- (IBAction)engineSelected:(id)sender
{
  [self didSelectEngineName:[sender title]];
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

-(NSArray*)registeredEngineNames
{
  if (self.delegate && [self.delegate respondsToSelector:@selector(registeredEngineNames)]) {
    return [self.delegate registeredEngineNames];
  }
  return [NSArray array];
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
  
  return [NSNumber numberWithBool:NO];  
}

-(NSNumber*)doPS2PDF
{
  if (self.delegate && [self.delegate respondsToSelector:@selector(doPS2PDF)]) {
    return [self.delegate doPS2PDF];
  }
  
  return [NSNumber numberWithBool:NO];  
}

-(NSNumber*)openConsole
{
  if (self.delegate && [self.delegate respondsToSelector:@selector(openConsole)]) {
    return [self.delegate openConsole];
  }
  
  return [NSNumber numberWithBool:YES];  
}

-(NSNumber*)nCompile
{
  if (self.delegate && [self.delegate respondsToSelector:@selector(nCompile)]) {
    return [self.delegate nCompile];
  }
  
  return [NSNumber numberWithInteger:1];  
}




@end
