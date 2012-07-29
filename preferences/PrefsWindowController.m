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

@implementation PrefsWindowController

@synthesize enginesEditor;
@synthesize enginesEditorContainer;
@synthesize supportedFilesEditor;
@synthesize templateEditorView;
@synthesize templateEditorViewContainer;
@synthesize projectTemplateManager;
@synthesize projectTemplateManagerContainer;

- (void) awakeFromNib
{
  
	
	// Comments controller
	commentsController = [[SyntaxHighlightControlController alloc] initWithTag:@"Comments" name:@"Comments (%)"];
	[commentsView addSubview:[commentsController view]];
	
	// Comments L2 controller
	commentsL2Controller = [[SyntaxHighlightControlController alloc] initWithTag:@"CommentsL2" name:@"Comments (%%)"];
	[commentsL2View addSubview:[commentsL2Controller view]];
  
  // Comments L3 controller
	commentsL3Controller = [[SyntaxHighlightControlController alloc] initWithTag:@"CommentsL3" name:@"Comments (%%%)"];
	[commentsL3View addSubview:[commentsL3Controller view]];

	// Markup L1 controller
	markupL1Controller = [[SyntaxHighlightControlController alloc] initWithTag:@"MarkupL1" name:@"Markup (< >)"];
	[markupL1View addSubview:[markupL1Controller view]];
	
	// Markup L2 controller
	markupL2Controller = [[SyntaxHighlightControlController alloc] initWithTag:@"MarkupL2" name:@"Markup (<< >>)"];
	[markupL2View addSubview:[markupL2Controller view]];

  // Markup L3 controller
	markupL3Controller = [[SyntaxHighlightControlController alloc] initWithTag:@"MarkupL3" name:@"Markup (<<< >>>)"];
	[markupL3View addSubview:[markupL3Controller view]];

	// math controller
	mathController = [[SyntaxHighlightControlController alloc] initWithTag:@"SpecialChars" name:@"Special Characters"];
	[mathView addSubview:[mathController view]];
	
	// commands controller
	commandsController = [[SyntaxHighlightControlController alloc] initWithTag:@"Command" name:@"Commands"];
	[commandsView addSubview:[commandsController view]];
	
	// arguments controller
	argumentsController = [[SyntaxHighlightControlController alloc] initWithTag:@"Arguments" name:@"Arguments"];
	[argumentsView addSubview:[argumentsController view]];
	
	// dollar controller
	dollarController = [[SyntaxHighlightControlController alloc] initWithTag:@"DollarChars" name:@"Dollar ($)"];
	[dollarView addSubview:[dollarController view]];
  
	// keywords controller
//	keywordsController = [[SyntaxHighlightControlController alloc] initWithTag:@"Keywords"];
//	[keywordsView addSubview:[keywordsController view]];
	
	[self wrapStyleChanged:self];
  
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
  
}

- (void) dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
//	[keywordsController release];
	
}

- (void) windowWillClose:(NSNotification *)notification
{
}

- (IBAction)defaultEncodingSelected:(id)sender
{
  NSString *encodingName = [defaultEncodingPopup titleOfSelectedItem];
  [[NSUserDefaults standardUserDefaults] setValue:encodingName forKey:TPDefaultEncoding];
  [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setupToolbar
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];	
	NSFont *f = [NSUnarchiver unarchiveObjectWithData:[defaults valueForKey:TEDocumentFont]];
	if (!f) {
		f = [NSFont systemFontOfSize:14];
	}
	[docFont setValue:f forKey:@"font"];	
	[docFont setStringValue:[NSString stringWithFormat:@"%@ - %0.0f pt", [f displayName], [f pointSize]]];
  
  
	f = [NSUnarchiver unarchiveObjectWithData:[defaults valueForKey:TEConsoleFont]];
	if (!f) {
		f = [NSFont userFixedPitchFontOfSize:12];
	}
	[consoleFont setValue:f forKey:@"font"];	
	[consoleFont setStringValue:[NSString stringWithFormat:@"%@ - %0.0f pt", [f displayName], [f pointSize]]];
  
	
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
  NSArray *engines = [self.enginesEditor.engineManager registeredEngineNames];
  [menu removeAllItems];
  for (NSString *name in engines) {    
    NSMenuItem *item = [menu addItemWithTitle:name action:@selector(selectEngineName:) keyEquivalent:@""];
    [item setTarget:self];
  }
  [enginePopup selectItemWithTitle:[self engineName]];
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
  NSMutableArray *errors = [defaults mutableArrayValueForKey:TPCheckSyntaxErrors];
  for (NSDictionary *error in errors) {
    
    NSDictionary *newError = @{@"check": @YES, 
                              @"code": [error valueForKey:@"code"], 
                              @"message": [error valueForKey:@"message"]};
    
    errors[[errors indexOfObject:error]] = newError;
  }
  
  [defaults synchronize];
  [syntaxErrorsTable reloadData];
}

- (IBAction)deactivateAllErrorChecks:(id)sender
{
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  NSMutableArray *errors = [defaults mutableArrayValueForKey:TPCheckSyntaxErrors];
  for (NSDictionary *error in errors) {
    
    NSDictionary *newError = @{@"check": @NO, 
                              @"code": [error valueForKey:@"code"], 
                              @"message": [error valueForKey:@"message"]};
    
    errors[[errors indexOfObject:error]] = newError;
  }
  
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
	
	[dict setValue:[NSString stringWithFormat:@"\\newCommand%d", [[userCommandsController arrangedObjects] count]]
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
    NSMutableArray *errors = [defaults mutableArrayValueForKey:TPCheckSyntaxErrors];
    if (row >= 0 && row < [errors count]) {
      if ([[tableColumn identifier] isEqualToString:@"SyntaxErrorsCheckColumn"]) {
        NSDictionary *error = errors[row];
        NSDictionary *newError = @{@"check": object, 
                                  @"code": [error valueForKey:@"code"], 
                                  @"message": [error valueForKey:@"message"]};
        errors[row] = newError;
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
    NSMutableArray *commands = [defaults mutableArrayValueForKey:TECiteCommands];
    if (row >= 0 && row < [commands count]) {
      commands[row] = newCommand;
      [defaults setObject:commands forKey:TECiteCommands];
    }
  } else if (tableView == refCommandsTable) {
    NSMutableArray *commands = [defaults mutableArrayValueForKey:TERefCommands];
    if (row >= 0 && row < [commands count]) {
      commands[row] = newCommand;
      [defaults setObject:commands forKey:TERefCommands];
    }
  } else if (tableView == fileCommandsTable) {
    NSMutableArray *commands = [defaults mutableArrayValueForKey:TEFileCommands];
    if (row >= 0 && row < [commands count]) {
      commands[row] = newCommand;
      [defaults setObject:commands forKey:TEFileCommands];
    }
  } else if (tableView == beginCommandsTable) {
    NSMutableArray *commands = [defaults mutableArrayValueForKey:TEBeginCommands];
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
  NSMutableArray *commands = [defaults mutableArrayValueForKey:TECiteCommands];
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
  NSMutableArray *commands = [defaults mutableArrayValueForKey:TECiteCommands];
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
  NSMutableArray *commands = [defaults mutableArrayValueForKey:TERefCommands];
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
  NSMutableArray *commands = [defaults mutableArrayValueForKey:TERefCommands];
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
  NSMutableArray *commands = [defaults mutableArrayValueForKey:TEFileCommands];
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
  NSMutableArray *commands = [defaults mutableArrayValueForKey:TEFileCommands];
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
  NSMutableArray *commands = [defaults mutableArrayValueForKey:TEBeginCommands];
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
  NSMutableArray *commands = [defaults mutableArrayValueForKey:TEBeginCommands];
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
	if ([wrapStylePopup indexOfSelectedItem] == TPNoWrap) {
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


- (IBAction)selectDocFont:(id)sender
{
	
	NSFontPanel *fp = [NSFontPanel sharedFontPanel];
	[fp setPanelFont:[docFont font] isMultiple:YES];
	[fp makeKeyAndOrderFront:self];
	
	NSFontManager *fm = [NSFontManager sharedFontManager];
	[fm setTarget:self];
	[fm setAction:@selector(docFontChanged:)];
}

- (void)docFontChanged:(id)sender
{
	NSFont *f = [sender convertFont:[docFont font]];
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setValue:[NSArchiver archivedDataWithRootObject:f] forKey:TEDocumentFont];
	[defaults synchronize];
	[docFont setValue:f forKey:@"font"];	
	[docFont setStringValue:[NSString stringWithFormat:@"%@ - %0.0f pt", [f displayName], [f pointSize]]];
}

- (IBAction)selectConsoleFont:(id)sender
{
	
	NSFontPanel *fp = [NSFontPanel sharedFontPanel];
	[fp setPanelFont:[consoleFont font] isMultiple:YES];
	[fp makeKeyAndOrderFront:self];
	
	NSFontManager *fm = [NSFontManager sharedFontManager];
	[fm setTarget:self];
	[fm setAction:@selector(consoleFontChanged:)];
}

- (void)consoleFontChanged:(id)sender
{
	NSFont *f = [sender convertFont:[consoleFont font]];
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setValue:[NSArchiver archivedDataWithRootObject:f] forKey:TEConsoleFont];
	[defaults synchronize];
	[consoleFont setValue:f forKey:@"font"];	
	[consoleFont setStringValue:[NSString stringWithFormat:@"%@ - %0.0f pt", [f displayName], [f pointSize]]];
}


- (void) colorClick: (id) sender 
{	// sender is the table view
	NSColorPanel* panel;
	panel = [NSColorPanel sharedColorPanel];
  [panel setAction:NULL];
}

- (IBAction)setDefaultLineHighlightingColor:(id)sender
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  [defaults setValue:[NSArray arrayWithColor:[NSColor colorWithDeviceWhite:0.95 alpha:1.0]] forKey:TEHighlightCurrentLineColor];
  [defaults synchronize];
}

- (IBAction)setDefaultMatchingWordHighlightingColor:(id)sender
{  
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  [defaults setValue:[NSArray arrayWithColor:[[NSColor selectedTextBackgroundColor] highlightWithLevel:0.6]] forKey:TEHighlightMatchingWordsColor];
  [defaults synchronize];
}

- (IBAction)setDefaultSelectedTextColor:(id)sender
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  [defaults setValue:[NSArray arrayWithColor:[NSColor selectedTextColor]] forKey:TESelectedTextColor];
  [defaults synchronize];
}

- (IBAction)setDefaultSelectedTextBackgroundColor:(id)sender
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  [defaults setValue:[NSArray arrayWithColor:[NSColor selectedTextBackgroundColor]] forKey:TESelectedTextBackgroundColor];
  [defaults synchronize];
}


@end
