//
//  TPSpellCheckerListingViewController.m
//  TeXnicle
//
//  Created by Martin Hewitson on 07/07/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
//

#import "TPSpellCheckerListingViewController.h"
#import "ProjectEntity.h"
#import "ProjectItemEntity.h"
#import "FileEntity.h"
#import "externs.h"
#import "ImageAndTextCell.h"

@interface TPSpellCheckerListingViewController ()

@end

@implementation TPSpellCheckerListingViewController

@synthesize delegate;
@synthesize spellCheckTimer;
@synthesize checkedFiles;
@synthesize outlineView;
@synthesize revealButton;
@synthesize correctButton;
@synthesize progressIndicator;

- (id) initWithDelegate:(id<TPSpellCheckerListingDelegate>)aDelegate
{
  self = [super initWithNibName:@"TPSpellCheckerListingViewController" bundle:nil];
  if (self) {
    self.delegate = aDelegate;
    self.checkedFiles = [NSMutableArray array];
    queue = dispatch_queue_create("com.bobsoft.TeXnicle", NULL);
    dispatch_queue_t priority = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);    
    dispatch_set_target_queue(queue,priority);
  }
  return self;
}


- (void) dealloc
{
  self.checkedFiles = nil;
  [self.spellCheckTimer invalidate];
  self.spellCheckTimer = nil;
	dispatch_release(queue);
  [super dealloc];
}

- (void) awakeFromNib
{
  [self.outlineView setDoubleAction:@selector(outlineViewDoubleClicked)];
  [self.outlineView setTarget:self];
  
	NSTableColumn *tableColumn = [self.outlineView tableColumnWithIdentifier:@"NameColumn"];
	ImageAndTextCell *imageAndTextCell = [[[ImageAndTextCell alloc] init] autorelease];
	[imageAndTextCell setEditable:NO];
	[imageAndTextCell setImage:[NSImage imageNamed:@"TeXnicle_Doc"]];
  [imageAndTextCell setLineBreakMode:NSLineBreakByTruncatingTail];
	[tableColumn setDataCell:imageAndTextCell];	
  
  
  [self setupSpellChecker];
  [self checkSpellingTimerFired];
  

  NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
  
  [nc addObserver:self
         selector:@selector(updateAllLists) 
             name:TPSpellingLanguageChangedNotification
           object:nil];
  
}

- (IBAction) correct:(id)sender
{
	
	NSRect frame = [(NSButton *)sender frame];
	NSPoint menuOrigin = [[(NSButton *)sender superview] 
												convertPoint:NSMakePoint(frame.origin.x+frame.size.width, frame.origin.y+frame.size.height)																		 
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
	
  
  // get selected word
  TPMisspelledWord *word = [self selectedWord];
  if (word == nil) {
    return;
  }
  
  NSMenu *menu = [self correctionMenuForWord:word withTarget:self];
  
	[NSMenu popUpContextMenu:menu withEvent:event forView:(NSButton *)sender];
	
	
}

- (void) selectedCorrection:(id)sender
{  
  NSString *correction = [sender title];
  
  TPMisspelledWord *word = [self selectedWord];
  
  if ([correction hasPrefix:@"Learn"]) {
    
    [[NSSpellChecker sharedSpellChecker] learnWord:word.word];
    word.parent.needsUpdate = YES;
    [self checkSpellingTimerFired];
    
  } else {
  
    [self replaceMisspelledWord:word.word atRange:word.range withCorrection:correction inFile:word.parent.file];
    
  }
}

- (NSMenu*)correctionMenuForWord:(TPMisspelledWord*)word withTarget:(id)target
{
  NSMenu *theMenu = [[[NSMenu alloc] 
											initWithTitle:@"Spelling Item Context Menu"] 
										 autorelease];
	
	[theMenu setAutoenablesItems:NO];
	
  
  
	NSMenuItem *menuItem;
  
  menuItem = [[NSMenuItem alloc] initWithTitle:@"Possible Corrections"
                                        action:nil
                                 keyEquivalent:@""];
  [menuItem setEnabled:NO];
  [theMenu addItem:menuItem];
  [menuItem release];
  
  [theMenu addItem:[NSMenuItem separatorItem]];
  
  menuItem = [[NSMenuItem alloc] initWithTitle:[NSString stringWithFormat:@"Learn \u201c%@\u201d", word.word]
                                        action:@selector(selectedCorrection:)
                                 keyEquivalent:@""];
  [menuItem setTarget:target];
  [theMenu addItem:menuItem];
  [menuItem release];
  
  [theMenu addItem:[NSMenuItem separatorItem]];
  
  NSArray *corrections = word.corrections;
  
  for (NSString *correction in corrections) {
    menuItem = [[NSMenuItem alloc] initWithTitle:correction
                                          action:@selector(selectedCorrection:)
                                   keyEquivalent:@""];
    [menuItem setTarget:target];
    [theMenu addItem:menuItem];
    [menuItem release];
    
  }  
  
  return theMenu;
}


- (void) outlineViewDoubleClicked
{
  NSInteger row = [self.outlineView clickedRow];
  id item = [self.outlineView itemAtRow:row];
  if ([item isKindOfClass:[TPSpellCheckedFile class]]) {
    if ([self.outlineView isItemExpanded:item]) {
      [self.outlineView collapseItem:item];
    } else {
      [self.outlineView expandItem:item];
    }
  } else if ([item isKindOfClass:[TPMisspelledWord class]]) {
    TPMisspelledWord *word = (TPMisspelledWord*)item;
    [self highlightMisspelledWord:word.word atRange:word.range inFile:word.parent.file];
  }
}

// Jump to the selected bookmark
- (IBAction)jumpToSelectedWord:(id)sender
{
  TPMisspelledWord *w = [self selectedWord];
  if (w) {    
    [self highlightMisspelledWord:w.word atRange:w.range inFile:w.parent.file];
  }
}

// Returns the currently selected bookmark, or nil
- (TPMisspelledWord*)selectedWord
{
  NSInteger row = [self.outlineView selectedRow];
  id item = [self.outlineView itemAtRow:row];
  if ([item isKindOfClass:[TPMisspelledWord class]]) {
    return item;
  }
  
  return nil;
}


- (void) updateAllLists
{
  for (TPSpellCheckedFile *checkedFile in self.checkedFiles) {
    checkedFile.needsUpdate = YES;
  }
  
  [self checkSpellingTimerFired];
}

- (IBAction)forceUpdate:(id)sender
{
  [self updateAllLists];
}


- (void) setupSpellChecker
{
  if (self.spellCheckTimer) {
    [self.spellCheckTimer invalidate];
    self.spellCheckTimer = nil;
  }
  
  self.spellCheckTimer = [NSTimer scheduledTimerWithTimeInterval:5
                                                          target:self
                                                        selector:@selector(checkSpellingTimerFired) 
                                                        userInfo:nil
                                                         repeats:YES];
  
}

- (void) checkSpellingTimerFired
{
  if (checkingFiles > 0) {
    return;
  }
  
  NSArray *filesToCheck = [self filesToSpellCheck];
  
  checkingFiles = 0;
  if (filesToCheck) {
    
    NSArray *sortedItems = [filesToCheck sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
      NSString *first  = [(ProjectItemEntity*)a valueForKey:@"name"];
      NSString *second = [(ProjectItemEntity*)b valueForKey:@"name"];
      return [first compare:second]==NSOrderedDescending;
    }];

    // need to remove any checked-files which should be no longer checked
    NSMutableArray *filesToRemove = [NSMutableArray array];
    for (TPSpellCheckedFile *checkedFile in self.checkedFiles) {
      if (![sortedItems containsObject:checkedFile.file]) {
        [filesToRemove addObject:checkedFile];
      }
    }
    [self.checkedFiles removeObjectsInArray:filesToRemove];
    
    
    for (FileEntity *file in sortedItems) {
      if ([[file valueForKey:@"isText"] boolValue]) {
        
        BOOL shouldCheck = NO;
        
        // File's object
        TPSpellCheckedFile *checkedFile = [self checkedFileForFile:file];
        
        if (checkedFile == nil) {
          shouldCheck = YES;
        }
        
        if (shouldCheck == NO) {
          // check the last edit time against the last checked time
          NSDate *lastEdit = [file valueForKey:@"lastEditDate"];
          NSDate *lastCheck = checkedFile.lastCheck;
          if ([lastEdit timeIntervalSinceDate:lastCheck] > 0) {
            shouldCheck = YES;
          }            
        }  
        
        if (checkedFile.needsUpdate) {
          shouldCheck = YES;
        }
        
        if (shouldCheck) {
          //            NSLog(@"+ Checking file %@", [file name]);
          checkingFiles++;
          [self.progressIndicator startAnimation:self];
          dispatch_async(queue, ^{						
            
            NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];               
            [self addMisspelledWordsFromFile:file];
            [pool drain];      
            
          });
        } else {
          //            NSLog(@"- Not checking file %@", [file name]);
        }
      }          
    }
  }
  
//  NSLog(@"%@", self.lists);
}

- (TPSpellCheckedFile*)checkedFileForFile:(FileEntity*)file
{
  for (TPSpellCheckedFile *checkedFile in self.checkedFiles) {
    if (checkedFile.file == file) {
      return checkedFile;
    }
  }
  
  return nil;
}

- (void) addMisspelledWordsFromFile:(FileEntity*)file
{
  NSString *string = [file workingContentString];     
  
  
  TPSpellCheckedFile *checkedFile = [self checkedFileForFile:file];
  BOOL addFile = NO;
  if (checkedFile == nil) {
    checkedFile = [[[TPSpellCheckedFile alloc] initWithFile:file] autorelease];
    addFile = YES;
  }
  
  NSArray *words = [self listOfMisspelledWordsFromString:string forFile:checkedFile];
  
  dispatch_async(dispatch_get_main_queue(),
                 // block
                 ^{
                   checkedFile.lastCheck = [NSDate date];
                   checkedFile.words = words;
                   checkedFile.needsUpdate = NO;
                   if (addFile) {
                     [self.checkedFiles addObject:checkedFile];
                   }
                   [self.outlineView reloadData];
                   checkingFiles--;
                   
                   if (checkingFiles == 0) {
                     [self.progressIndicator stopAnimation:self];
                   }
                   
                 });
  
}

- (NSArray*)listOfMisspelledWordsFromString:(NSString*)aString forFile:(TPSpellCheckedFile*)aFile
{
  NSSpellChecker *checker = [NSSpellChecker sharedSpellChecker];
  NSMutableArray *words = [NSMutableArray array];
  NSRange range = NSMakeRange(0, 0);
  NSRange lastRange = NSMakeRange(0, 0);
  NSInteger wordCount = 0;
  while (range.location < [aString length] && wordCount < 1000) {
    
    range = [checker checkSpellingOfString:aString startingAt:range.location];
    
    
    if (range.location == NSNotFound) {
      break;
    }
    
    // check if we wrapped
    if (range.location < lastRange.location) {
      break;
    }
    
    // did we get a word?
    if (NSMaxRange(range) < [aString length]) {
      NSString *misspelledWord = [aString substringWithRange:range];
      NSArray *corrections = [checker guessesForWordRange:range inString:aString language:nil inSpellDocumentWithTag:0];
      TPMisspelledWord *word = [TPMisspelledWord wordWithWord:misspelledWord corrections:corrections range:range parent:aFile];
      [words addObject:word];
      wordCount++;
    }
    
    // store last range
    lastRange = range;
    
    // move on
    range = NSMakeRange(NSMaxRange(range), 0);
  } // end while loop
  
  return words;
}

#pragma mark -
#pragma mark Delegate

- (NSArray*)filesToSpellCheck
{
  if (self.delegate && [self.delegate respondsToSelector:@selector(filesToSpellCheck)]) {
    return [self.delegate filesToSpellCheck];
  }
  return [NSArray array];
}

- (BOOL)shouldPerformSpellCheck
{
  if (self.delegate && [self.delegate respondsToSelector:@selector(shouldPerformSpellCheck)]) {
    return [self.delegate shouldPerformSpellCheck];
  }
  return NO;
}

- (void)highlightMisspelledWord:(NSString*)word atRange:(NSRange)aRange inFile:(FileEntity*)aFile
{
  if (self.delegate && [self.delegate respondsToSelector:@selector(highlightMisspelledWord:atRange:inFile:)]) {
    [self.delegate highlightMisspelledWord:word atRange:aRange inFile:aFile];
  }
}

- (void)replaceMisspelledWord:(NSString*)word atRange:(NSRange)aRange withCorrection:(NSString*)correction inFile:(FileEntity*)aFile
{
  if (self.delegate && [self.delegate respondsToSelector:@selector(replaceMisspelledWord:atRange:withCorrection:inFile:)]) {
    [self.delegate replaceMisspelledWord:word atRange:aRange withCorrection:correction inFile:aFile];
  }
}

- (void)dictionaryDidLearnNewWord
{
  if (self.delegate && [self.delegate respondsToSelector:@selector(dictionaryDidLearnNewWord)]) {
    [self.delegate dictionaryDidLearnNewWord];
  }
}


#pragma mark -
#pragma mark OutlineView Data Source

- (NSArray*)nonEmptyCheckedFiles
{
  NSMutableArray *files = [NSMutableArray array];
  for (TPSpellCheckedFile *file in self.checkedFiles) {
    if ([file.words count] > 0) {
      [files addObject:file];
    }
  }

  return files;
}

- (BOOL) outlineView:(NSOutlineView *)outlineView isGroupItem:(id)item
{
  if (item == nil) {
    return NO;
  }
    
  if ([item isKindOfClass:[TPSpellCheckedFile class]]) {
    return YES;
  }
  
  return NO;
}

- (id) outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{  
  if ([self.outlineView isRowSelected:[self.outlineView rowForItem:item]]) {    
    return [item valueForKey:@"selectedDisplayString"];
  } else {
    return [item valueForKey:@"displayString"];
  }
}

- (BOOL) outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
  if (item == nil) {
    return NO;
  }
  
  if ([item isKindOfClass:[TPSpellCheckedFile class]]) {
    return [[item valueForKey:@"words"] count] > 0;
  }
  
  return NO;
}

- (id) outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item
{
  if (item == nil) {
    return [[self nonEmptyCheckedFiles] objectAtIndex:index];
  }
  
  return [[item valueForKey:@"words"] objectAtIndex:index];  
}

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
{
  if (item == nil) {
    return [[self nonEmptyCheckedFiles] count];
  }
  
  if ([item isKindOfClass:[TPSpellCheckedFile class]]) {
    return [[item valueForKey:@"words"] count];
  }
  
  return 0;
}

#pragma mark -
#pragma mark OutlineView Delegate

- (void) outlineView:(NSOutlineView *)anOutlineView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn item:(id)item
{
  if (anOutlineView == self.outlineView) {
    if ([cell isMemberOfClass:[ImageAndTextCell class]]) {
      if ([item isKindOfClass:[TPSpellCheckedFile class]]) {
        [cell setImage:[NSImage imageNamed:@"TeXnicle_Doc"]];
      } else if ([item isKindOfClass:[TPMisspelledWord class]]) {
        [cell setImage:[NSImage imageNamed:@"spellingMistake"]];
      }
    }
  }
}

- (void) selectedCorrection:(NSString*)correction forMisspelledWord:(TPMisspelledWord*)word
{
  [self replaceMisspelledWord:word.word atRange:word.range withCorrection:correction inFile:word.parent.file];
}

#pragma mark -
#pragma mark Validate Buttons

- (BOOL)validateUserInterfaceItem:(id<NSValidatedUserInterfaceItem>)anItem
{
  if (anItem == self.revealButton){
    if ([self selectedWord]) {
      return YES;
    }
  }
  
  if (anItem == self.correctButton){
    if ([self selectedWord]) {
      return YES;
    }
  }
  
  return NO;
}


@end
