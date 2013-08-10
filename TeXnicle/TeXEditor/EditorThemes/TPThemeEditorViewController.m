//
//  TPThemeEditorViewController.m
//  TeXnicle
//
//  Created by Martin Hewitson on 21/7/13.
//  Copyright (c) 2013 bobsoft. All rights reserved.
//

#import "TPThemeEditorViewController.h"
#import "TPThemeManager.h"
#import "TPTheme.h"
#import "NSColor+ContrastingLabelExtensions.h"
#import "NSDictionary+Theme.h"
#import "externs.h"
#import "NSColor+ContrastingLabelExtensions.h"

@interface TPThemeEditorViewController ()

@property (assign) IBOutlet NSTableView *themesTable;
@property (assign) IBOutlet NSTableView *documentItemsTable;
@property (assign) IBOutlet NSTableView *outlineItemsTable;
@property (assign) IBOutlet NSTableView *syntaxItemsTable;
@property (assign) IBOutlet NSColorWell *documentColorWell;
@property (assign) IBOutlet NSColorWell *syntaxColorWell;
@property (assign) IBOutlet NSColorWell *outlineColorWell;
@property (assign) IBOutlet NSColorWell *currentLineColorWell;
@property (assign) IBOutlet NSColorWell *matchingWordsColorWell;
@property (assign) IBOutlet NSButton *currentLineButton;
@property (assign) IBOutlet NSButton *matchingWordsButton;

@property (assign) IBOutlet NSButton *selectEditorFontButton;
@property (assign) IBOutlet NSButton *selectConsoleFontButton;
@property (assign) IBOutlet NSButton *selectNavigatorFontButton;
@property (assign) IBOutlet NSButton *multilineArgButton;
@property (assign) IBOutlet NSTextField *themeDescriptionTextField;
@property (assign) IBOutlet HHValidatedButton *removeThemeButton;
@property (assign) IBOutlet HHValidatedButton *actionButton;
@property (assign) IBOutlet MMTabBarView *tabBar;

@property (strong) NSButton *activeFontButton;

@property (strong) NSMenu *actionMenu;

@property (strong) TPTheme *selectedTheme;
@property (copy) NSString *selectedKey;

@end

@implementation TPThemeEditorViewController

- (id)init
{
  self = [super initWithNibName:@"TPThemeEditorViewController" bundle:nil];
  if (self) {
    // Initialization code here.
  }
  
  return self;
}

- (void) awakeFromNib
{
	[self.tabBar setStyleNamed:@"Card"];
	[self.tabBar setOrientation:MMTabBarHorizontalOrientation];
	[self.tabBar setAutomaticallyAnimates:YES];
	[self.tabBar setHideForSingleTab:NO];
  [self.tabBar setShowAddTabButton:NO];
  [self.tabBar setCanCloseOnlyTab:NO];
  [self.tabBar setOnlyShowCloseOnHover:YES];
  [self.tabBar setDisableTabClose:YES];
  [self.tabBar setAllowsBackgroundTabClosing:NO];
  [self.tabBar setSizeButtonsToFit:YES];
  [self.tabBar setUseOverflowMenu:NO];
  
  
  [self updateUI];
  [self createActionMenu];
  
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  NSString *selectedThemeName = [defaults valueForKey:TPSelectedTheme];
  
  if (selectedThemeName == nil) {
    self.selectedTheme = [[TPThemeManager sharedManager] themeNamed:@"texnicle"];
  } else {
    self.selectedTheme = [[TPThemeManager sharedManager] themeNamed:selectedThemeName];
  }
  
  // if we didn't get the theme (perhaps the selected one has been deleted), choose default
  if (self.selectedTheme == nil) {
    self.selectedTheme = [[TPThemeManager sharedManager] themeNamed:@"texnicle"];
  }
  
  [self registerThemeChange];
  [self performSelector:@selector(restoreSelectedTheme) withObject:nil afterDelay:0];
}

- (void) restoreSelectedTheme
{
  [self.themesTable selectRowIndexes:[NSIndexSet indexSetWithIndex:[[TPThemeManager sharedManager] indexOfThemeNamed:self.selectedTheme.name]]
                byExtendingSelection:NO];
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
  
}


- (BOOL) validateUserInterfaceItem:(id<NSValidatedUserInterfaceItem>)anItem
{
  if (anItem == self.removeThemeButton) {
    if (self.selectedTheme == nil || self.selectedTheme.isBuiltIn == YES) {
      return NO;
    }
    
    return YES;
  }
  
  if (anItem == self.actionButton) {
    if (self.selectedTheme != nil) {
      return YES;
    }
  }
  
  return NO;
}

- (IBAction) selectCurrentLineColor:(id)sender
{
  if (sender == self.currentLineColorWell) {
    [self.selectedTheme setCurrentLineColor:[sender color]];
    [self.selectedTheme save];
  }
}

- (IBAction) selectMatchingWordsColor:(id)sender
{
  if (sender == self.matchingWordsColorWell) {
    [self.selectedTheme setMatchingWordsColor:[sender color]];
    [self.selectedTheme save];
  }
}

- (IBAction)chooseColor:(id)sender
{
  [sender activate:YES];
  [sender setAction:@selector(changeColor:)];
  [sender setTarget:self];
}

- (void) changeColor:(id)sender
{
  if (sender == self.outlineColorWell || sender == self.syntaxColorWell || sender == self.documentColorWell) {
    
    NSColor *color = [(NSColorWell*)sender color];
    if (self.selectedTheme == nil) {
      return;
    }
    
    // set color
    NSColor *currentColor = [self.selectedTheme colorForKey:self.selectedKey];
    if ([color isEqualToColor:currentColor] == NO) {
      [self.selectedTheme setColor:color forKey:self.selectedKey];
      [self.selectedTheme save];
    } else {
      NSLog(@"Equal color, not setting");
    }
  }
}


- (IBAction)changeHighlightCurrentLine:(id)sender
{
  [self.selectedTheme save];
}

- (IBAction)changeHighlightMatchingWords:(id)sender
{
  [self.selectedTheme save];
}

- (IBAction)changeMultilineArguments:(id)sender
{
  [self.selectedTheme save];
}

- (IBAction)selectDocFont:(id)sender
{
  if (self.selectedTheme == nil) {
    return;
  }
  
  self.activeFontButton = sender;
	
	NSFontPanel *fp = [NSFontPanel sharedFontPanel];
	[fp setPanelFont:self.selectedTheme.editorFont isMultiple:YES];
	[fp makeKeyAndOrderFront:self];
	
	NSFontManager *fm = [NSFontManager sharedFontManager];
	[fm setTarget:self];
}

- (IBAction)selectConsoleFont:(id)sender
{
  if (self.selectedTheme == nil) {
    return;
  }
  
  self.activeFontButton = sender;
  
	NSFontPanel *fp = [NSFontPanel sharedFontPanel];
	[fp setPanelFont:self.selectedTheme.consoleFont isMultiple:YES];
	[fp makeKeyAndOrderFront:self];
	
	NSFontManager *fm = [NSFontManager sharedFontManager];
	[fm setTarget:self];
  [fm setDelegate:self];
}

- (void) setFont
{
  //NSLog(@"Set font");
  
  if (self.activeFontButton == self.selectConsoleFontButton) {
    NSFontManager *fontManager = [NSFontManager sharedFontManager];
    NSFont *selectedFont = [fontManager convertFont:self.selectedTheme.consoleFont];
//    NSLog(@"Set font %@", selectedFont);
    [self.selectedTheme setConsoleFont:selectedFont];
  } else if (self.activeFontButton == self.selectEditorFontButton) {
    NSFontManager *fontManager = [NSFontManager sharedFontManager];
    NSFont *selectedFont = [fontManager convertFont:self.selectedTheme.editorFont];
//    NSLog(@"Set font %@", selectedFont);
    [self.selectedTheme setEditorFont:selectedFont];
    [self.outlineItemsTable reloadData];
    [self.syntaxItemsTable reloadData];
    [self.documentItemsTable reloadData];
  } else if (self.activeFontButton == self.selectNavigatorFontButton) {
    NSFontManager *fontManager = [NSFontManager sharedFontManager];
    NSFont *selectedFont = [fontManager convertFont:self.selectedTheme.navigatorFont];
//    NSLog(@"Set font %@", selectedFont);
    [self.selectedTheme setNavigatorFont:selectedFont];
    
    // post notification
    [[NSNotificationCenter defaultCenter] postNotificationName:TPThemeNavigatorFontChangedNotification object:self];
    
  } else {
    return;
  }
  
  [self.selectedTheme save];

}

- (void) changeFont:(id)sender
{
  [self setFont];
}

- (void) changeAttributes:(id)sender
{
  [self setFont];
}

- (IBAction)selectNavigatorFont:(id)sender
{
  if (self.selectedTheme == nil) {
    return;
  }
  
  self.activeFontButton = sender;
  
	NSFontPanel *fp = [NSFontPanel sharedFontPanel];
	[fp setPanelFont:self.selectedTheme.navigatorFont isMultiple:YES];
	[fp makeKeyAndOrderFront:self];
	
	NSFontManager *fm = [NSFontManager sharedFontManager];
	[fm setTarget:self];
}

- (IBAction)showContextMenu:(id)sender
{
	NSRect frame = [(NSButton *)sender frame];
	NSPoint menuOrigin = [[(NSButton *)sender superview]
												convertPoint:NSMakePoint(frame.origin.x+frame.size.width+5.0, frame.origin.y+frame.size.height)
												toView:nil];
	
	NSEvent *event =  [NSEvent mouseEventWithType:NSLeftMouseDown
																			 location:menuOrigin
																	modifierFlags:NSLeftMouseDownMask // 0x100
																			timestamp:0
																	 windowNumber:[[(NSButton *)sender window] windowNumber]
																				context:[[(NSButton *)sender window] graphicsContext]
																		eventNumber:0
																		 clickCount:1
																			 pressure:1];
	
	
	[NSMenu popUpContextMenu:self.actionMenu withEvent:event forView:(NSButton *)sender];
  
}

- (void)revealInFinder
{
  NSURL *url = self.selectedTheme.url;
  if (url) {
    NSWorkspace *ws = [NSWorkspace sharedWorkspace];
    [ws selectFile:[url path] inFileViewerRootedAtPath:[[url path] stringByDeletingLastPathComponent]];
  }
}

- (void) createActionMenu
{
	
	// Make popup menu with bound actions
	self.actionMenu = [[NSMenu alloc] initWithTitle:@"Theme Action Menu"];
	[self.actionMenu setAutoenablesItems:NO];
	
	// Duplicate
	NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:@"Duplicate Theme"
																								action:@selector(duplicateTheme)
																				 keyEquivalent:@""];
  [item setTarget:self];
	[self.actionMenu addItem:item];
	
	// Reveal
	item = [[NSMenuItem alloc] initWithTitle:@"Reveal in Finder"
																		action:@selector(revealInFinder)
														 keyEquivalent:@""];
  [item setTarget:self];
	[self.actionMenu addItem:item];
		
}

- (void)duplicateTheme
{
  // get theme
  TPTheme *theme = self.selectedTheme;
  if (!theme) {
    return;
  }
  
  // get path
  NSString *path = [theme.url path];
  
  // make new path
  NSString *newName = [[[path lastPathComponent] stringByDeletingPathExtension] stringByAppendingString:@"_copy"];
  NSString *newPath = [[[path stringByDeletingLastPathComponent] stringByAppendingPathComponent:newName] stringByAppendingPathExtension:[TPThemeManager themeExtension]];
  
  // copy the file
  NSFileManager *fm = [NSFileManager defaultManager];
  NSError *error = nil;
  BOOL success = [fm copyItemAtPath:path toPath:newPath error:&error];
  if (success == NO) {
    [NSApp presentError:error];
  }
  
  // reload engines
  [[TPThemeManager sharedManager] loadThemes];
  
  // reload table
  [self.themesTable reloadData];
  
  // select the new engine
  [self.themesTable selectRowIndexes:[NSIndexSet indexSetWithIndex:[[TPThemeManager sharedManager] indexOfThemeNamed:newName]]
              byExtendingSelection:NO];
}

- (IBAction)addNewTheme:(id)sender
{
  // copy the texnicle default theme
  NSString *themesDir = [TPThemeManager themesDir];
  
  // make name (checking existing names)
  NSString *name = @"new_theme";
  NSString *testName = [NSString stringWithString:name];
  NSInteger counter = 1;
  NSFileManager *fm = [NSFileManager defaultManager];
  while ([fm fileExistsAtPath:[[themesDir stringByAppendingPathComponent:testName] stringByAppendingPathExtension:[TPThemeManager themeExtension]]]) {
    testName = [name stringByAppendingFormat:@"_%ld", counter];
    counter++;
  }
  
  // make new path
  NSString *newEnginePath = [[themesDir stringByAppendingPathComponent:testName] stringByAppendingPathExtension:[TPThemeManager themeExtension]];
  
  // copy template to new path
  NSString *template = [[NSBundle mainBundle] pathForResource:@"texnicle" ofType:[TPThemeManager themeExtension]];
  NSError *error = nil;
  BOOL success = [fm copyItemAtPath:template toPath:newEnginePath error:&error];
  if (success == NO) {
    [NSApp presentError:error];
  }
  
  // reload themes
  [[TPThemeManager sharedManager] loadThemes];
  
  // reload table
  [self.themesTable reloadData];
  
  // select the new theme
  [self.themesTable selectRowIndexes:[NSIndexSet indexSetWithIndex:[[TPThemeManager sharedManager] indexOfThemeNamed:testName]]
              byExtendingSelection:NO];
  
}

- (IBAction)removeSelectedTheme:(id)sender
{
  if (self.selectedTheme != nil) {
    // prompt user
    NSAlert *alert = [NSAlert alertWithMessageText:@"Delete Theme?"
                                     defaultButton:@"Delete"
                                   alternateButton:@"Cancel"
                                       otherButton:nil
                         informativeTextWithFormat:@"Are you sure you want to delete theme %@?", self.selectedTheme.name];
    
    NSInteger result = [alert runModal];
    
    if (result == NSAlertAlternateReturn) {
      return;
    }
    
    // move path on disk to trash
    NSString *path = [self.selectedTheme.url path];
    NSString *source = [path stringByDeletingLastPathComponent];
    NSString *file = [path lastPathComponent];
    
    
    [[NSWorkspace sharedWorkspace] performFileOperation:NSWorkspaceRecycleOperation
                                                 source:source
                                            destination:@""
                                                  files:@[file]
                                                    tag:nil];
    
    // reload engines
    [[TPThemeManager sharedManager] loadThemes];
    
    // reload table
    [self.themesTable reloadData];
  }
}

#pragma mark -
#pragma mark TabView Data Source

- (void) tabView:(NSTabView *)tabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem
{
  NSTableView *tableView = nil;
  if ([tabView indexOfTabViewItem:tabViewItem] == 0) {
    // documents
    tableView = self.documentItemsTable;
  } else if ([tabView indexOfTabViewItem:tabViewItem] == 1) {
    // syntax
    tableView = self.syntaxItemsTable;
  } else if ([tabView indexOfTabViewItem:tabViewItem] == 2) {
    // outline
    tableView = self.outlineItemsTable;
  }
  
  // set color well
  NSInteger row = [tableView selectedRow];
  NSDictionary *dict = [self dictionaryForTableView:tableView];
  if (dict == nil) {
    return;
  }
  
  NSArray *keys = [dict sortedKeys];
  TPTheme *th = self.selectedTheme;
  if (row >=0 && row < [keys count]) {
    self.selectedKey = keys[row];
    
    NSColor *c = [th colorForKey:keys[row]];
    [[self colorWellForTableView:tableView] setColor:c];
  }
}

#pragma mark -
#pragma mark TableView Data Source

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
  if (tableView == self.themesTable) {
    TPThemeManager *tm = [TPThemeManager sharedManager];
    return [[tm registeredThemeNames] count];
  }
  
  if (tableView == self.documentItemsTable ||
      tableView == self.syntaxItemsTable ||
      tableView == self.outlineItemsTable) {
    TPTheme *th = self.selectedTheme;
    if (th) {
      NSDictionary *dict = [self dictionaryForTableView:tableView];
      if (dict == nil) {
        return 0;
      }
      return [[dict sortedKeys] count];
    }
  }
  
  return 0;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
  if (tableView == self.themesTable) {
    TPThemeManager *tm = [TPThemeManager sharedManager];
    NSArray *themes = [tm registeredThemes];
    if (row >= 0 && row < [themes count]) {
      TPTheme *theme = themes[row];
      return theme.name;
    }
  }
  
  if (tableView == self.documentItemsTable ||
      tableView == self.syntaxItemsTable ||
      tableView == self.outlineItemsTable) {
    TPThemeManager *tm = [TPThemeManager sharedManager];
    TPTheme *th = self.selectedTheme;
    if (th == nil) {
      return nil;
    }
    
    NSDictionary *dict = [self dictionaryForTableView:tableView];
    if (dict == nil) {
      return nil;
    }
    
    NSArray *keys = [dict sortedKeys];
    if (row >=0 && row < [keys count]) {
      if (tableView == self.syntaxItemsTable && [[tableColumn identifier] isEqualToString:@"ActiveColumn"]) {
        
        NSString *key = keys[row];
        NSNumber *state = [th activeStateForKey:key];
        return state;
        
      } else {
        NSString *itemDesc = [tm descriptionForKey:keys[row]];
        return itemDesc;
      }
    }
  }
  
  return nil;
}

- (TPTheme*)themeAtRow:(NSInteger)row
{
  TPThemeManager *tm = [TPThemeManager sharedManager];
  NSArray *themes = [tm registeredThemes];
  if (row >= 0 && row < [themes count]) {
    TPTheme *theme = themes[row];
    return theme;
  }
  
  return nil;
}


- (void)tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
  if (tableView == self.themesTable) {
    NSString *newName = (NSString*)object;
    
    // get theme
    TPTheme *theme = [self themeAtRow:row];
    
    // get path
    NSString *oldPath = [theme.url path];
    
    // get new path
    NSString *newPath = [[[oldPath stringByDeletingLastPathComponent] stringByAppendingPathComponent:newName] stringByAppendingPathExtension:[TPThemeManager themeExtension]];
    
    // move the file
    NSFileManager *fm = [NSFileManager defaultManager];
    NSError *error = nil;
    BOOL success = [fm moveItemAtPath:oldPath toPath:newPath error:&error];
    if (success == NO) {
      [NSApp presentError:error];
    }
    
    // reload engines
    [[TPThemeManager sharedManager] loadThemes];
    
    // reload table
    [self.themesTable reloadData];
    
    // select the new engine
    [self performSelector:@selector(selectThemeNamed:) withObject:newName afterDelay:0];
  }
  
  if (tableView == self.syntaxItemsTable) {
    if ([[tableColumn identifier] isEqualToString:@"ActiveColumn"]) {
      
      TPTheme *th = self.selectedTheme;
      if (th) {
       
        NSDictionary *dict = [self dictionaryForTableView:tableView];
        if (dict == nil) {
          return;
        }
        
        NSArray *keys = [dict sortedKeys];
        if (row >=0 && row < [keys count]) {
          [th setState:object forKey:keys[row]];
          [th save];
        }
      }
    }
  }
  
}

- (void) selectThemeNamed:(NSString*)aName
{
  NSInteger index = [[TPThemeManager sharedManager] indexOfThemeNamed:aName];
  if (index >= 0 && index != NSNotFound) {
    [self.themesTable selectRowIndexes:[NSIndexSet indexSetWithIndex:index]
                byExtendingSelection:NO];
  }
}

- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row
{
  if (tableView == self.themesTable) {
//    [self registerThemeChange];
  }
  
  return YES;
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
  NSTableView *tableView = [notification object];
  
  if (tableView == self.themesTable) {
    TPThemeManager *tm = [TPThemeManager sharedManager];
    NSArray *themes = [tm registeredThemes];
    NSInteger row = [self.themesTable selectedRow];
    if (row >= 0 && row < [themes count]) {
      self.selectedTheme = themes[row];
    } else {
      self.selectedTheme = nil;
    }
    
    [self registerThemeChange];
    
  } else if (tableView == self.documentItemsTable ||
             tableView == self.syntaxItemsTable ||
             tableView == self.outlineItemsTable) {
    
    self.selectedKey = nil;
    
    [self.currentLineColorWell deactivate];
    [self.matchingWordsColorWell deactivate];
    
    // set color well
    NSInteger row = [tableView selectedRow];
    NSDictionary *dict = [self dictionaryForTableView:tableView];
    if (dict == nil) {
      return;
    }
    
    NSArray *keys = [dict sortedKeys];
    TPTheme *th = self.selectedTheme;
    if (row >=0 && row < [keys count]) {
      self.selectedKey = keys[row];
      
      NSColor *c = [th colorForKey:keys[row]];
      [[self colorWellForTableView:tableView] setColor:c];
      [[self colorWellForTableView:tableView] activate:YES];
    }
    
  }
  
  [self updateUI];
}



- (NSColorWell*)colorWellForTableView:(NSTableView*)tableView
{
  if (tableView == self.documentItemsTable) {
    return self.documentColorWell;
  } else if (tableView == self.outlineItemsTable) {
    return self.outlineColorWell;
  } else {
    return self.syntaxColorWell;
  }
}

- (void) registerThemeChange
{
  if (self.selectedTheme) {
    TPThemeManager *tm = [TPThemeManager sharedManager];
    [tm setSelectedTheme:self.selectedTheme];
    
    // reload details tables
    [self.documentItemsTable reloadData];
    [self.syntaxItemsTable reloadData];
    [self.outlineItemsTable reloadData];
    
    // post notification
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    NSDictionary *dict = @{@"ThemeName" : self.selectedTheme.name};
    [nc postNotificationName:TPThemeSelectionChangedNotification object:self userInfo:dict];
    
    // cache selected
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:self.selectedTheme.name forKey:TPSelectedTheme];
    [defaults synchronize];
  }
}

- (void) updateUI
{
  BOOL state = YES;
  TPTheme *th = self.selectedTheme;
  if (th == nil || th.isBuiltIn == YES) {
    state = NO;
  }
  if (self.selectedKey != nil) {
    [self.outlineColorWell setEnabled:state];
    [self.syntaxColorWell setEnabled:state];
    [self.documentColorWell setEnabled:state];
    [self.currentLineColorWell setEnabled:state];
    [self.matchingWordsColorWell setEnabled:state];
    [self.matchingWordsButton setEnabled:state];
    [self.currentLineButton setEnabled:state];
  } else {
    [self.outlineColorWell setEnabled:NO];
    [self.syntaxColorWell setEnabled:NO];
    [self.documentColorWell setEnabled:NO];
    [self.currentLineColorWell setEnabled:NO];
    [self.matchingWordsColorWell setEnabled:NO];
    [self.currentLineButton setEnabled:NO];
    [self.matchingWordsButton setEnabled:NO];
  }
  
  [self.multilineArgButton setEnabled:state];
  [self.selectEditorFontButton setEnabled:state];
  [self.selectConsoleFontButton setEnabled:state];
}

- (NSDictionary*)dictionaryForTableView:(NSTableView*)tableView
{
  TPTheme *th = self.selectedTheme;
  if (th == nil) {
    return nil;
  }
  NSDictionary *dict = nil;
  if (tableView == self.documentItemsTable) {
    dict = th.documentColors;
  } else if (tableView == self.outlineItemsTable) {
    dict = th.outlineColors;
  } else {
    dict = th.syntaxColors;
  }
  return dict;
}

- (void)tableView:(NSTableView *)tableView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
  if (tableView == self.documentItemsTable ||
      tableView == self.outlineItemsTable ||
      tableView == self.syntaxItemsTable) {
    
    TPTheme *th = self.selectedTheme;
    if (th == nil) {
      return;
    }

    if ([[tableColumn identifier] isEqualToString:@"ActiveColumn"]) {
      NSButtonCell *bcell = (NSButtonCell*)cell;
      // set enabled or not?
      if (th.isBuiltIn) {
        [bcell setEnabled:NO];
      } else {
        [bcell setEnabled:YES];
      }
      
    } else {
      [cell setTextColor:[NSColor blackColor]];
      
      NSDictionary *dict = [self dictionaryForTableView:tableView];
      if (dict == nil) {
        return;
      }
      
      
      NSArray *keys = [dict sortedKeys];
      if (row >=0 && row < [keys count]) {
        NSColor *c = [th colorForKey:keys[row]];
        
        NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithString:[cell title]];
        
        if (row != [tableView selectedRow]) {
          [title addAttribute:NSForegroundColorAttributeName value:c range:NSMakeRange(0, [title length])];
          [title addAttribute:NSBackgroundColorAttributeName value:[c contrastingLabelColor] range:NSMakeRange(0, [title length])];
        } else {
          [title addAttribute:NSForegroundColorAttributeName value:[NSColor whiteColor] range:NSMakeRange(0, [title length])];
          
        }
        
        [title addAttribute:NSFontAttributeName value:[th editorFont] range:NSMakeRange(0, [title length])];
        [cell setAttributedStringValue:title];
      }
    }
    
  }
}

- (BOOL)tableView:(NSTableView *)tableView shouldEditTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
  if (tableView == self.themesTable) {
    TPThemeManager *tm = [TPThemeManager sharedManager];
    NSArray *themes = [tm registeredThemes];
    NSInteger row = [self.themesTable selectedRow];
    if (row >= 0 && row < [themes count]) {
      TPTheme *theme = themes[row];
      if (theme.isBuiltIn == NO) {
        return YES;
      }
    }
  }
  
  return NO;
}

#pragma mark -
#pragma mark NSTextField Delegate

- (void) controlTextDidEndEditing:(NSNotification *)obj
{
  [self.selectedTheme save];
}




@end
