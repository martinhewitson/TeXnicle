//
//  PrefsWindowController.m
//  TeXnicle
//
//  Created by Martin Hewitson on 12/11/09.
//  Copyright 2009 bobsoft. All rights reserved.
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

#import "PrefsWindowController.h"
#import "externs.h"
#import "NSArray+Color.h"
#import "TeXTextView.h"
#import "NSString+Comparisons.h"
#import "TPEnginesEditor.h"
#import "MHFileReader.h"
#import "TPProjectTemplateManager.h"
#import "TPSyntaxChecker.h"
#import "TPDocumentSectionManager.h"
#import "OutlineSectionTagsEditorController.h"
#import "TPThemeEditorViewController.h"

@interface PrefsWindowController ()

@property (strong) TPProjectTemplateManager *projectTemplateManager;
@property (unsafe_unretained) IBOutlet NSView *projectTemplateManagerContainer;
@property (strong) TPSupportedFilesEditor *supportedFilesEditor;
@property (strong) TPEnginesEditor *enginesEditor;
@property (unsafe_unretained) IBOutlet NSView *enginesEditorContainer;
@property (strong) TPTemplateEditorView *templateEditorView;
@property (unsafe_unretained) IBOutlet NSView *templateEditorViewContainer;

@property (unsafe_unretained) IBOutlet NSView *outlineSectionEditorContainer;
@property (strong) OutlineSectionTagsEditorController *outlineSectionController;

@property (unsafe_unretained) IBOutlet NSView *themesEditorContainer;
@property (strong) TPThemeEditorViewController *themesEditorController;

@property (assign) IBOutlet NSButton *liveupdateOverrideButton;
@property (assign) IBOutlet NSTextField *liveupdateNumberRunsLabel;
@property (assign) IBOutlet NSTextField *liveupdateNumberRunsTextField;
@property (assign) IBOutlet NSStepper *liveupdateNumberRunsStepper;


@end

@implementation PrefsWindowController


- (void) awakeFromNib
{
	[self wrapStyleChanged:self];
  BOOL showJumpBar = [[NSUserDefaults standardUserDefaults] boolForKey:TEJumpBarEnabled];
  [self setJumpBarUIState:showJumpBar];
  
  // live update runs status
  [self updateLiveupdateRunsState];
  
  // setup engines editor
  self.enginesEditor = [[TPEnginesEditor alloc] init];
  [[self.enginesEditor view] setFrame:[self.enginesEditorContainer bounds]];
  [self.enginesEditorContainer addSubview:[self.enginesEditor view]];
  
  // default engine popup
  [enginePopup removeAllItems];
  [enginePopup addItemWithTitle:[self engineName]];
  
  // default encoding
  [defaultEncodingPopup removeAllItems];
  MHFileReader *fr = [[MHFileReader alloc] init];
  [defaultEncodingPopup addItemsWithTitles:fr.encodingNames];
  NSString *defaultEncoding = [[NSUserDefaults standardUserDefaults] valueForKey:TPDefaultEncoding];
  [defaultEncodingPopup selectItemWithTitle:defaultEncoding];
  
  
  // template editor
  self.templateEditorView = [[TPTemplateEditorView alloc] init];
  [self.templateEditorView.view setFrame:[self.templateEditorViewContainer bounds]];
  [self.templateEditorViewContainer addSubview:self.templateEditorView.view];
  
  // file types editor
  self.supportedFilesEditor = [[TPSupportedFilesEditor alloc] init];
  [self.supportedFilesEditor.view setFrame:[fileTypesPrefsView bounds]];
  [fileTypesPrefsView addSubview:self.supportedFilesEditor.view];  
  
  // project template chooser
  self.projectTemplateManager = [[TPProjectTemplateManager alloc] init];
  [self.projectTemplateManager.view setFrame:[self.projectTemplateManagerContainer bounds]];
  [self.projectTemplateManagerContainer addSubview:self.projectTemplateManager.view];
  
  // outline sections controller
  self.outlineSectionController = [[OutlineSectionTagsEditorController alloc] init];
  [self.outlineSectionController.view setFrame:self.outlineSectionEditorContainer.bounds];
  [self.outlineSectionEditorContainer addSubview:self.outlineSectionController.view];
  
  // themes editor controller
  self.themesEditorController = [[TPThemeEditorViewController alloc] init];
  [self.themesEditorController.view setFrame:self.themesEditorContainer.bounds];
  [self.themesEditorContainer addSubview:self.themesEditorController.view];
  [self.themesEditorController setNextResponder:self.nextResponder];
  [self setNextResponder:self.themesEditorController];
  
}

- (void) dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
//	[keywordsController release];
	
}

- (void) windowWillClose:(NSNotification *)notification
{
  [super windowWillClose:notification];
  if ([NSColorPanel sharedColorPanelExists]) {
    [[NSColorPanel sharedColorPanel] close];
  }
}

- (IBAction)defaultEncodingSelected:(id)sender
{
  NSString *encodingName = [defaultEncodingPopup titleOfSelectedItem];
  [[NSUserDefaults standardUserDefaults] setValue:encodingName forKey:TPDefaultEncoding];
  [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setupToolbar
{
  [self addView:generalPrefsView
					label:@"General" 
					image:[NSImage imageNamed:NSImageNamePreferencesGeneral]];	
	
  [self addView:engineView 
					label:@"Typesetting" 
					image:[NSImage imageNamed:@"engine"]];		
	
  [self addView:syntaxColorsView 
					label:@"Font & Colors" image:[NSImage imageNamed:@"fontsAndColors"]];	
	
  [self addView:templatesView 
					label:@"Templates" image:[NSImage imageNamed:@"templates"]];	

  [self addView:outlinePrefsView
					label:@"Outline" image:[NSImage imageNamed:@"outlinePrefs"]];
	
  [self addView:userCommandsView
					label:@"Commands" image:[NSImage imageNamed:@"commandsPrefs"]];	
  
  [self addView:libraryPrefsView
          label:@"Palette & Library"
          image:[NSImage imageNamed:@"libraryPrefs"]];
  
  [self addView:fileTypesPrefsView
          label:@"File Types"
          image:[NSImage imageNamed:@"fileTypesPref"]];
    	
}


#pragma mark -
#pragma mark Engine stuff

- (IBAction)liveupdateOverrideSelected:(id)sender
{
  [self updateLiveupdateRunsState];
}

- (void) updateLiveupdateRunsState
{
  BOOL override = [self.liveupdateOverrideButton state] == NSOnState;
  
  [self.liveupdateNumberRunsLabel setEnabled:override];
  [self.liveupdateNumberRunsStepper setEnabled:override];
  [self.liveupdateNumberRunsTextField setEnabled:override];
}


- (IBAction)selectEngineName:(id)sender
{
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];  
  [defaults setValue:[sender title] forKey:TPDefaultEngineName];
  [defaults synchronize];
}

- (NSString*)engineName
{
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  return [defaults valueForKey:TPDefaultEngineName];  
}

- (void)menuNeedsUpdate:(NSMenu *)menu
{
  if (menu == [enginePopup menu]) {
    NSArray *engines = [self.enginesEditor.engineManager registeredEngineNames];
    [menu removeAllItems];
    for (NSString *name in engines) {
      NSMenuItem *item = [menu addItemWithTitle:name action:@selector(selectEngineName:) keyEquivalent:@""];
      [item setTarget:self];
    }
    [enginePopup selectItemWithTitle:[self engineName]];
  }
}


#pragma mark -
#pragma mark General control

- (IBAction)showJumpbarCheckStateChanged:(id)sender
{
  [self setJumpBarUIState:[sender state]];
}

- (void) setJumpBarUIState:(BOOL)state
{
  [jumpBarShowLineNumbersButton setEnabled:state];
  [jumpBarShowMarkingsButton setEnabled:state];
  [jumpBarShowSectionsButton setEnabled:state];
  [jumpBarShowBibItemsButton setEnabled:state];
  [jumpBarShowBookmarksButton setEnabled:state];
}


#pragma mark -
#pragma mark Syntax check control

- (IBAction)syntaxCheckStateChanged:(id)sender
{
  if ([sender state] == NSOnState) {
    [syntaxErrorsTable setEnabled:YES];
    [chktexBinaryPath setEnabled:YES];
    [chktexBinaryPathBrowse setEnabled:YES];
    [activateAllChecksButton setEnabled:YES];
    [deactivateAllChecksButton setEnabled:YES];
    [defaultChecksButton setEnabled:YES];
  } else {
    [syntaxErrorsTable setEnabled:NO];
    [chktexBinaryPath setEnabled:NO];
    [chktexBinaryPathBrowse setEnabled:NO];
    [activateAllChecksButton setEnabled:NO];
    [deactivateAllChecksButton setEnabled:NO];
    [defaultChecksButton setEnabled:NO];
  }
}

- (IBAction)selectChkTeXPath:(id)sender
{
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  NSOpenPanel *panel = [NSOpenPanel openPanel];
  [panel setCanChooseFiles:YES];
  [panel setCanChooseDirectories:NO];
  [panel setCanCreateDirectories:NO];
  [panel setMessage:@"Select binary for chktex"];
  [panel setPrompt:@"chktex binary"];
  [panel setRepresentedFilename:[defaults valueForKey:TPChkTeXpath]];
  [panel setAllowsMultipleSelection:NO];
  [panel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {
    if (result == NSCancelButton) {
      return;
    }
    
    NSURL *url = [panel URL];
    [defaults setValue:[url path] forKey:TPChkTeXpath];
    [defaults synchronize];
  }];
}


- (IBAction)activateAllErrorChecks:(id)sender
{
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  NSArray *errors = [defaults arrayForKey:TPCheckSyntaxErrors];
  NSMutableArray *newErrors = [NSMutableArray array];
  for (NSDictionary *error in errors) {
    
    NSDictionary *newError = @{@"check": @YES, 
                              @"code": [error valueForKey:@"code"], 
                              @"message": [error valueForKey:@"message"]};
    
    [newErrors addObject:newError];
  }
  [defaults setValue:newErrors forKey:TPCheckSyntaxErrors];
  [defaults synchronize];
  [syntaxErrorsTable reloadData];
}

- (IBAction)deactivateAllErrorChecks:(id)sender
{
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  NSArray *errors = [defaults arrayForKey:TPCheckSyntaxErrors];
  NSMutableArray *newErrors = [NSMutableArray array];
  for (NSDictionary *error in errors) {
    
    NSDictionary *newError = @{@"check": @NO, 
                              @"code": [error valueForKey:@"code"], 
                              @"message": [error valueForKey:@"message"]};
    
    [newErrors addObject:newError];
  }
  [defaults setValue:newErrors forKey:TPCheckSyntaxErrors];
  [defaults synchronize];
  [syntaxErrorsTable reloadData];
}

- (IBAction)defaultErrorChecks:(id)sender
{
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  [defaults setObject:[TPSyntaxChecker defaultSyntaxErrors] forKey:TPCheckSyntaxErrors];
  [defaults synchronize];
  [syntaxErrorsTable reloadData];
}

#pragma mark -
#pragma mark Commands Control


- (IBAction) newCommand:(id)sender
{
	NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	
	[dict setValue:[NSString stringWithFormat:@"\\newCommand%lu", [[userCommandsController arrangedObjects] count]]
					forKey:@"Name"];
	
	[userCommandsController insertObject:dict atArrangedObjectIndex:0];
	[userCommandsController setSelectionIndex:0];
  [userCommandsTable selectRowIndexes:[NSIndexSet indexSetWithIndex:0] byExtendingSelection:NO];
  [userCommandsTable editColumn:0 row:[userCommandsTable selectedRow] withEvent:nil select:YES];
}

-(void)tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  
  if (tableView == syntaxErrorsTable) {
    NSMutableArray *errors = [[defaults arrayForKey:TPCheckSyntaxErrors] mutableCopy];
    if (row >= 0 && row < [errors count]) {
      if ([[tableColumn identifier] isEqualToString:@"SyntaxErrorsCheckColumn"]) {
        NSDictionary *error = errors[row];
        NSDictionary *newError = @{@"check": object, 
                                  @"code": [error valueForKey:@"code"], 
                                  @"message": [error valueForKey:@"message"]};
        errors[row] = newError;
        [defaults setValue:errors forKey:TPCheckSyntaxErrors];
        [defaults synchronize];
        return;
      }
    }
  }
  
  NSString *newCommand = [self formatNewCommand:object];
  if (tableView == userCommandsTable) {
    if (row >= 0 && row < [[userCommandsController arrangedObjects] count]) {
      [[userCommandsController arrangedObjects][row] setValue:newCommand forKey:@"Name"];
    }
  } else if (tableView == citeCommandsTable) {
    NSMutableArray *commands = [[defaults arrayForKey:TECiteCommands] mutableCopy];
    if (row >= 0 && row < [commands count]) {
      commands[row] = newCommand;
      [defaults setObject:commands forKey:TECiteCommands];
    }
  } else if (tableView == refCommandsTable) {
    NSMutableArray *commands = [[defaults arrayForKey:TERefCommands] mutableCopy];
    if (row >= 0 && row < [commands count]) {
      commands[row] = newCommand;
      [defaults setObject:commands forKey:TERefCommands];
    }
  } else if (tableView == fileCommandsTable) {
    NSMutableArray *commands = [[defaults arrayForKey:TEFileCommands] mutableCopy];
    if (row >= 0 && row < [commands count]) {
      commands[row] = newCommand;
      [defaults setObject:commands forKey:TEFileCommands];
    }
  } else if (tableView == beginCommandsTable) {
    NSMutableArray *commands = [[defaults arrayForKey:TEBeginCommands] mutableCopy];
    if (row >= 0 && row < [commands count]) {
      newCommand = [newCommand stringByReplacingOccurrencesOfString:@"\\" withString:@""];
      commands[row] = newCommand;
      [defaults setObject:commands forKey:TEBeginCommands];
    }
  }
  
  [defaults synchronize];
}

- (NSString*)formatNewCommand:(NSString*)userInput
{
  userInput = [userInput stringByReplacingOccurrencesOfString:@" " withString:@"_"];
  if (![userInput beginsWith:@"\\"]) {
    userInput = [@"\\" stringByAppendingString:userInput];
  }
  return userInput;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  if (tableView == citeCommandsTable) {
    NSArray *commands = [defaults valueForKey:TECiteCommands];
    if (row >= 0 && row < [commands count]) {
      return commands[row];
    }
  } else if (tableView == refCommandsTable) {
    NSArray *commands = [defaults valueForKey:TERefCommands];
    if (row >= 0 && row < [commands count]) {
      return commands[row];
    }
  } else if (tableView == fileCommandsTable) {
    NSArray *commands = [defaults valueForKey:TEFileCommands];
    if (row >= 0 && row < [commands count]) {
      return commands[row];
    }
  } else if (tableView == beginCommandsTable) {
    NSArray *commands = [defaults valueForKey:TEBeginCommands];
    if (row >= 0 && row < [commands count]) {
      return commands[row];
    }
  } else if (tableView == syntaxErrorsTable) {
    NSArray *errors = [defaults valueForKey:TPCheckSyntaxErrors];
    if (row >= 0 && row < [errors count]) {
      if ([[tableColumn identifier] isEqualToString:@"SyntaxErrorsCheckColumn"]) {
        return [errors[row] valueForKey:@"check"];
      } else if ([[tableColumn identifier] isEqualToString:@"SyntaxErrorsMessageColumn"]) {
        return [errors[row] valueForKey:@"message"];
      } else if ([[tableColumn identifier] isEqualToString:@"SyntaxErrorsCodeColumn"]) {
        return [errors[row] valueForKey:@"code"];
      }
    }
  }

  
  return nil;
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  if (tableView == citeCommandsTable) {
    NSArray *commands = [defaults valueForKey:TECiteCommands];
    return [commands count];
  } else if (tableView == refCommandsTable) {
    NSArray *commands = [defaults valueForKey:TERefCommands];
    return [commands count];
  } else if (tableView == fileCommandsTable) {
    NSArray *commands = [defaults valueForKey:TEFileCommands];
    return [commands count];
  } else if (tableView == beginCommandsTable) {
    NSArray *commands = [defaults valueForKey:TEBeginCommands];
    return [commands count];
  } else if (tableView == syntaxErrorsTable) {
    return [[defaults valueForKey:TPCheckSyntaxErrors] count]; 
  }

  
  return 0;
}

#pragma mark -
#pragma mark Cite Command Control

- (void)editSelectedInTableView:(NSTableView*)aTableView
{
  NSInteger row = [aTableView selectedRow];
  if (row >= 0 && row != NSNotFound) {
    [aTableView scrollRowToVisible:row];
    [aTableView editColumn:0 row:row withEvent:nil select:YES];
  }
}

- (IBAction)newCiteCommand:(id)sender
{
  NSString *newCommand = @"\\newCite";
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  NSMutableArray *commands = [[defaults arrayForKey:TECiteCommands] mutableCopy];
  [commands addObject:newCommand];
  [defaults setObject:commands forKey:TECiteCommands];
  [defaults synchronize];
  [citeCommandsTable reloadData];
  [citeCommandsTable selectRowIndexes:[NSIndexSet indexSetWithIndex:[commands count]-1] byExtendingSelection:NO];
  [self performSelector:@selector(editSelectedInTableView:) withObject:citeCommandsTable afterDelay:0];
}

   
- (IBAction)deleteSelectedCiteCommand:(id)sender
{
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  NSMutableArray *commands = [[defaults arrayForKey:TECiteCommands] mutableCopy];
  NSInteger row = [citeCommandsTable selectedRow];
  if (row >=0 && row < [commands count]) {
    [commands removeObjectAtIndex:row];
    [defaults setObject:commands forKey:TECiteCommands];
    [defaults synchronize];
    [citeCommandsTable reloadData];
  }
}

#pragma mark -
#pragma mark Ref Command Control

- (IBAction)newRefCommand:(id)sender
{
  NSString *newCommand = @"\\newRef";
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  NSMutableArray *commands = [[defaults arrayForKey:TERefCommands] mutableCopy];
  [commands addObject:newCommand];
  [defaults setObject:commands forKey:TERefCommands];
  [defaults synchronize];
  [refCommandsTable reloadData];
  [refCommandsTable selectRowIndexes:[NSIndexSet indexSetWithIndex:[commands count]-1] byExtendingSelection:NO];
  [self performSelector:@selector(editSelectedInTableView:) withObject:refCommandsTable afterDelay:0];
}

- (IBAction)deleteSelectedRefCommand:(id)sender
{
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  NSMutableArray *commands = [[defaults arrayForKey:TERefCommands] mutableCopy];
  NSInteger row = [refCommandsTable selectedRow];
  if (row >=0 && row < [commands count]) {
    [commands removeObjectAtIndex:row];
    [defaults setObject:commands forKey:TERefCommands];
    [defaults synchronize];
    [refCommandsTable reloadData];
  }
}


#pragma mark -
#pragma mark File Command Control

- (IBAction)newFileCommand:(id)sender
{
  NSString *newCommand = @"\\newFile";
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  NSMutableArray *commands = [[defaults arrayForKey:TEFileCommands] mutableCopy];
  [commands addObject:newCommand];
  [defaults setObject:commands forKey:TEFileCommands];
  [defaults synchronize];
  [fileCommandsTable reloadData];
  [fileCommandsTable selectRowIndexes:[NSIndexSet indexSetWithIndex:[commands count]-1] byExtendingSelection:NO];
  [self performSelector:@selector(editSelectedInTableView:) withObject:fileCommandsTable afterDelay:0];
}

- (IBAction)deleteSelectedFileCommand:(id)sender
{
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  NSMutableArray *commands = [[defaults arrayForKey:TEFileCommands] mutableCopy];
  NSInteger row = [fileCommandsTable selectedRow];
  if (row >=0 && row < [commands count]) {
    [commands removeObjectAtIndex:row];
    [defaults setObject:commands forKey:TEFileCommands];
    [defaults synchronize];
    [fileCommandsTable reloadData];
  }
}

#pragma mark -
#pragma mark Begin Command Control

- (IBAction)newBeginCommand:(id)sender
{
  NSString *newCommand = @"newBegin";
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  NSMutableArray *commands = [[defaults arrayForKey:TEBeginCommands] mutableCopy];
  [commands addObject:newCommand];
  [defaults setObject:commands forKey:TEBeginCommands];
  [defaults synchronize];
  [beginCommandsTable reloadData];
  [beginCommandsTable selectRowIndexes:[NSIndexSet indexSetWithIndex:[commands count]-1] byExtendingSelection:NO];
  [self performSelector:@selector(editSelectedInTableView:) withObject:beginCommandsTable afterDelay:0];
}

- (IBAction)deleteSelectedBeginCommand:(id)sender
{
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  NSMutableArray *commands = [[defaults arrayForKey:TEBeginCommands] mutableCopy];
  NSInteger row = [beginCommandsTable selectedRow];
  if (row >=0 && row < [commands count]) {
    [commands removeObjectAtIndex:row];
    [defaults setObject:commands forKey:TEBeginCommands];
    [defaults synchronize];
    [beginCommandsTable reloadData];
  }
}

#pragma mark -
#pragma mark Control 

- (IBAction) insertSpacesForTabsChanged:(id)sender
{
  if ([sender state] == NSOffState) {
    [spacesLabel setTextColor:[NSColor disabledControlTextColor]];
    [numSpacesEdit setEnabled:NO];
    [numSpacesStepper setEnabled:NO];
  } else {
    [spacesLabel setTextColor:[NSColor controlTextColor]];
    [numSpacesEdit setEnabled:YES];
    [numSpacesStepper setEnabled:YES];
  }
}

- (IBAction) wrapStyleChanged:(id)sender
{
	if ([wrapStylePopup indexOfSelectedItem] == TPNoWrap ||
      [wrapStylePopup indexOfSelectedItem] == TPWindowWrap) {
		[wrapWidthEdit setEnabled:NO];
		[wrapWidthStepper setEnabled:NO];
		[wrapAtWidthLabel setTextColor:[NSColor disabledControlTextColor]];
		[wrapCharsLabel setTextColor:[NSColor disabledControlTextColor]];
	} else {
		[wrapWidthEdit setEnabled:YES];
		[wrapWidthStepper setEnabled:YES];
		[wrapAtWidthLabel setTextColor:[NSColor controlTextColor]];
		[wrapCharsLabel setTextColor:[NSColor controlTextColor]];
	}
}

- (IBAction) browseForGSExecutable:(id)sender
{
	// get user to choose file
	NSOpenPanel *openPanel = [NSOpenPanel openPanel]; 
	[openPanel setCanChooseFiles:YES];
	[openPanel setCanChooseDirectories:NO];
	[openPanel setAllowsMultipleSelection:NO];
	[openPanel setCanCreateDirectories:NO];
	[openPanel setMessage:@"Locate Ghostscript (gs) binary"];
	
  [openPanel beginSheetModalForWindow:[self window] completionHandler:^(NSInteger result) {
    if (result == NSCancelButton) 
      return;
    
    NSString *path = [[openPanel URL] path];
    
    // set the path to the item
    [[NSUserDefaults standardUserDefaults] setObject:path forKey:TPGSPath];
    
  }];
  
	
}


- (IBAction) browseForPDFLatexExecutable:(id)sender
{
	// get user to choose file
	NSOpenPanel *openPanel = [NSOpenPanel openPanel]; 
	[openPanel setCanChooseFiles:YES];
	[openPanel setCanChooseDirectories:NO];
	[openPanel setAllowsMultipleSelection:NO];
	[openPanel setCanCreateDirectories:NO];
	[openPanel setMessage:@"Locate pdflatex binary"];
	
  [openPanel beginSheetModalForWindow:[self window] completionHandler:^(NSInteger result) {
    if (result == NSCancelButton) 
      return;
    
    NSString *path = [[openPanel URL] path];
    
    // set the path to the item
    [[NSUserDefaults standardUserDefaults] setObject:path forKey:TPPDFLatexPath];
    
    
  }];
  
}

- (void) colorClick: (id) sender 
{	// sender is the table view
	NSColorPanel* panel;
	panel = [NSColorPanel sharedColorPanel];
  [panel setAction:NULL];
}

@end
