//
//  FinderProjectController.m
//  TeXnicle
//
//  Created by Martin Hewitson on 4/8/11.
//  Copyright 2011 bobsoft. All rights reserved.
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

#import "FinderController.h"
#import "TPResultDocument.h"
#import "TPDocumentMatch.h"
#import "ProjectItemEntity.h"
#import "FileEntity.h"
#import "RegexKitLite.h"
#import "NSString+LaTeX.h"
#import "NSMutableAttributedString+CodeFolding.h"
#import "ImageAndTextCell.h"
#import "NSAttributedString+LineNumbers.h"
#import "MHLineNumber.h"
#import "externs.h"

#define kFindBarSmall 77
#define kFindBarLarge 119


NSString * const TPDocumentMatchAttributeName = @"TPDocumentMatchAttribute";

@implementation FinderController

@synthesize delegate;
@synthesize jumpToButton;
@synthesize searchField;
@synthesize outlineView;
@synthesize progressIndicator;
@synthesize statusLabel;
@synthesize results;
@synthesize topbarView;
@synthesize modeSelector;
@synthesize scrollview;
@synthesize replaceButton;
@synthesize replaceAllButton;
@synthesize replaceView;
@synthesize replaceText;
@synthesize bottomBarView;
@synthesize caseSensitiveCheckbox;
@synthesize searchWholeWordsCheckbox;

- (id) initWithDelegate:(id<FinderControllerDelegate>)aDelegate
{
	self = [super initWithNibName:@"FinderController" bundle:nil];
  
  if (self) {
    
    self.delegate = aDelegate;
    
    self.results = [NSMutableArray array];
    ws = [[NSCharacterSet whitespaceCharacterSet] retain];
    ns = [[NSCharacterSet newlineCharacterSet] retain];
    
    queue = dispatch_queue_create("com.bobsoft.TeXnicle", NULL);
    dispatch_queue_t priority = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);    
    dispatch_set_target_queue(queue,priority);
    
  }
	
	return self;
}

- (void) dealloc
{
  self.outlineView.delegate = nil;
  self.outlineView.dataSource = nil;
  self.delegate = nil;
  [ws release];
  [ns release];
	dispatch_release(queue);
  self.results = nil;
  [super dealloc];
}


- (void) awakeFromNib
{  
  [self.outlineView setDoubleAction:@selector(handleOutlineViewDoubleClick:)];
  [self.outlineView setTarget:self];
  
  // outline view
	NSTableColumn *tableColumn = [self.outlineView tableColumnWithIdentifier:@"NameColumn"];
	ImageAndTextCell *imageAndTextCell = [[[ImageAndTextCell alloc] init] autorelease];
	[imageAndTextCell setEditable:NO];
	[imageAndTextCell setImage:[NSImage imageNamed:@"TeXnicle_Doc"]];
	[tableColumn setDataCell:imageAndTextCell];	
  
  [self.modeSelector selectItemAtIndex:0];
  [self selectMode:self];
}

- (BOOL)validateUserInterfaceItem:(id<NSValidatedUserInterfaceItem>)anItem
{
  if (anItem == jumpToButton) {
    if ([self.outlineView selectedRow] == -1) {
      return NO;
    }
  }
  
  if (anItem == self.replaceButton) {
    if ([[self.outlineView selectedRowIndexes] count] == 0 || [[self.replaceText stringValue] length] == 0) {
      return NO;
    }
  }
  
  if (anItem == self.replaceAllButton) {
    if ([self.results count] == 0 || [[self.replaceText stringValue] length] == 0) {
      return NO;
    }
  }
  
  return YES;
}

#pragma mark -
#pragma mark Control 

- (IBAction)replaceAll:(id)sender
{
  NSString *replacementText = [self.replaceText stringValue];
  for (TPResultDocument *doc in self.results) {
    for (TPDocumentMatch *match in doc.matches) {
      
      [self replaceSearchResult:match withText:replacementText];
      
    }
  }
  
  [self.results removeAllObjects];
  [self.outlineView reloadData];
}

- (IBAction)replaceSelected:(id)sender
{
  NSString *replacementText = [self.replaceText stringValue];
  NSIndexSet *selectedIndexes = [self.outlineView selectedRowIndexes];
  NSUInteger currentIndex = [selectedIndexes firstIndex];
  while (currentIndex != NSNotFound)
  {
    id item = [self.outlineView itemAtRow:currentIndex];
		if ([item isKindOfClass:[TPDocumentMatch class]]) {
      TPDocumentMatch *match = (TPDocumentMatch*)item;      
      [self replaceSearchResult:match withText:replacementText];      
      TPResultDocument *doc = match.parent;
      [doc.matches removeObject:item];
      if ([doc.matches count] == 0) {
        [self.results removeObject:doc];
      }
    }
    currentIndex = [selectedIndexes indexGreaterThanIndex:currentIndex];
  }

  [self.outlineView reloadData];
}

- (IBAction)selectMode:(id)sender
{
  NSRect contentBounds = [self.view bounds];
  NSRect bottomBarBounds = [self.bottomBarView bounds];
  if ([modeSelector indexOfSelectedItem] == 0) {
    // find
    NSRect fr = [self.topbarView frame];
    [self.topbarView setFrame:NSMakeRect(fr.origin.x, contentBounds.size.height-kFindBarSmall+1, fr.size.width, kFindBarSmall)];
    [self.scrollview setFrame:NSMakeRect(0, bottomBarBounds.size.height, fr.size.width, contentBounds.size.height-kFindBarSmall-bottomBarBounds.size.height)];
    [self.replaceView setHidden:YES];
  } else {
    // replace
    NSRect fr = [self.topbarView frame];
    [self.topbarView setFrame:NSMakeRect(fr.origin.x, contentBounds.size.height-kFindBarLarge+1, fr.size.width, kFindBarLarge)];
    [self.scrollview setFrame:NSMakeRect(0, bottomBarBounds.size.height, fr.size.width, contentBounds.size.height-kFindBarLarge-bottomBarBounds.size.height)];
    [self.replaceView setHidden:NO];
  }
}

// Expand all results
- (IBAction)expandAll:(id)sender
{
  for (TPDocumentMatch *f in [self results]) {
    [self.outlineView expandItem:f];
  }
}

// Collapse all results
- (IBAction)collapseAll:(id)sender
{
  for (TPDocumentMatch *f in [self results]) {
    [self.outlineView collapseItem:f];
  }
}

- (IBAction) performSearch:(id)sender
{
  if (self.delegate == nil) {
    return;
  }
  
  //  NSLog(@"Perform search %@", sender);
  NSString *searchTerm = [self.searchField stringValue];
  
  [self searchForTerm:searchTerm];
}

- (void)searchForTerm:(NSString*)searchTerm
{
  shouldSearchOnEnd = NO;
  if (isSearching) {
    shouldContinueSearching = NO;
    shouldSearchOnEnd = YES;
    return;
  }
    
  // clear existing search
  [self.results removeAllObjects];  
  [self clearAllSearchResults];
  
  [self.outlineView reloadData];
  
  if ([searchTerm length] == 0) {
    [self didEndSearch:self];
    return;
  }
  
  shouldContinueSearching = YES;
  isSearching = YES;
  
  
  [self performSelector:@selector(beginSearchForTerm:) withObject:searchTerm afterDelay:0.1];
}

- (void) beginSearchForTerm:(NSString*)searchTerm
{
  
  [self didBeginSearch:self];
	
  //	NSString *regexp = [NSString stringWithFormat:@".*%@.*", searchTerm];
  //	NSString *regexp = [NSString stringWithFormat:@"(\\n)?.*%@.*(\\n)?", searchTerm];
	
  ProjectEntity *project = [self project];
	
  //  NSLog(@"Searching for '%@' in project %@", searchTerm, [project valueForKey:@"name"]);
  //  NSLog(@"Searching with regexp: %@", regexp);  
  
	// go through each doc in the project
  filesProcessed = 0;
  NSArray *items = [project valueForKey:@"items"];
	for (ProjectItemEntity *item in items) {
		if ([item isKindOfClass:[FileEntity class]]) {
			
			FileEntity *file = (FileEntity*)item;
			if ([[file valueForKey:@"isText"] boolValue]) {
        [self clearSearchResultsFromFile:file];
        filesProcessed++;
      }
    }
  }
  
	for (ProjectItemEntity *item in items) {
		if ([item isKindOfClass:[FileEntity class]]) {
			
			FileEntity *file = (FileEntity*)item;
			if ([[file valueForKey:@"isText"] boolValue]) {
        dispatch_async(queue, ^{						
                    
//          NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];               
          [self stringSearchForTerm:searchTerm inFile:file];
//          [pool drain];      
          
        });
			} // end if isText			
		} // end if is file
	} // end loop over project items
  
}

- (void) clearAllSearchResults
{
  NSArray *items = [[self project] valueForKey:@"items"];
	for (ProjectItemEntity *item in items) {
		if ([item isKindOfClass:[FileEntity class]]) {			
			FileEntity *file = (FileEntity*)item;
			if ([[file valueForKey:@"isText"] boolValue]) {
        [self clearSearchResultsFromFile:file];
      }
    }
  }
}

- (void) clearSearchResultsFromFile:(FileEntity*)file
{
  [[file.document textStorage] beginEditing];
  [[file.document textStorage] removeAttribute:TPDocumentMatchAttributeName range:NSMakeRange(0, [[file.document textStorage] length])];
  [[file.document textStorage] endEditing];
}

- (void) stringSearchForTerm:(NSString *)searchTerm inFile:(FileEntity*)file
{
  // get the text for this file
  FileDocument *doc = [file document];
  NSMutableAttributedString *attributedString = [doc textStorage];
  NSMutableAttributedString *aStr = [attributedString mutableCopy];
  NSArray *lineNumbers = [aStr lineNumbersForTextRange:NSMakeRange(0, [aStr length])];
  NSString *string = [aStr unfoldedString];
  [aStr release];
  if (!string)
    return;
  
  // check for case sensitive searches
  NSScanner *aScanner = [NSScanner scannerWithString:string];
  if ([self.caseSensitiveCheckbox state] == NSOnState) {
    [aScanner setCaseSensitive:YES];
  }
  
  // check for matching full words
  BOOL matchFullWords = [self.searchWholeWordsCheckbox state] == NSOnState;
  NSCharacterSet *newLineCharacterSet = [NSCharacterSet newlineCharacterSet];
	NSCharacterSet *whitespaceCharacterSet = [NSCharacterSet whitespaceCharacterSet];	

  TPResultDocument *resultDoc = [self resultDocumentForDocument:file];
  
  NSInteger scanLocation = 0;
  while(scanLocation < [string length]) {
    if (!shouldContinueSearching) {
      break;
    } // If should continue 
    
    // scan for the search term
    if ([aScanner scanUpToString:searchTerm intoString:NULL]) {
      scanLocation = [aScanner scanLocation];
      if (scanLocation >= [string length]) {
        break;
      } else {
        // move on
        [aScanner setScanLocation:scanLocation+[searchTerm length]];
        // we found a match
        NSRange resultRange = NSMakeRange(scanLocation, [searchTerm length]);
        if (resultRange.location != NSNotFound) {
          
          BOOL acceptMatch = YES;
          // check if we are matching full words
          if (matchFullWords == YES) {
           // this means there should be a whitespace of newline before and after the matched range
            if (scanLocation > 0) {
              char prefix = [string characterAtIndex:scanLocation-1];
              if (![whitespaceCharacterSet characterIsMember:prefix] &&
                  ![newLineCharacterSet characterIsMember:prefix]) {
                acceptMatch = NO;
              }
            }
            
            if (scanLocation+[searchTerm length] < [string length]) {
              char postfix = [string characterAtIndex:scanLocation+[searchTerm length]];
              if (![whitespaceCharacterSet characterIsMember:postfix] &&
                  ![newLineCharacterSet characterIsMember:postfix]) {
                acceptMatch = NO;
              }
            }
          }
          
          if (acceptMatch == YES) {
            NSInteger len = [searchTerm length] + 30;
            NSRange matchingRange = NSMakeRange(scanLocation, len);
            while (NSMaxRange(matchingRange) >= [string length]) {
              matchingRange = NSMakeRange(scanLocation, --len);
            }
            NSString *matchingString = [string substringWithRange:matchingRange];
            
            MHLineNumber *ln = [MHLineNumber lineNumberContainingIndex:resultRange.location inArray:lineNumbers];
            NSInteger lineNumber = ln.number;
            
            TPDocumentMatch *match = [[TPDocumentMatch alloc] initWithLine:lineNumber withRange:resultRange subrange:NSMakeRange(0, [searchTerm length]) matchingString:matchingString inDocument:resultDoc];
            [resultDoc addMatch:match];
            [match release];
            
            dispatch_async(dispatch_get_main_queue(),
                           // block
                           ^{
                             [self didMakeMatch:self];
                             [self.outlineView reloadData];
                           });
          }
        } // end subrange found      
      } // end if scanLocation less than string length
    } else {
      break;
    } // end if scanner returns true
  } // end while scanLocation less than string length
  
  // decrement the number of files processed
  filesProcessed--;
  
  
  if ([resultDoc.matches count] > 0) {
    dispatch_async(dispatch_get_main_queue(),
                  // block
                  ^{
                    if (![self.results containsObject:resultDoc]) {
                      [self.results addObject:resultDoc];              
                    }
                  });
  }
    
  // check if this is the last one?
  if (filesProcessed == 0) {
    if (!shouldContinueSearching) {
      // send cancelled message
      [self didCancelSearch:self];
    }
    isSearching = NO;
    shouldContinueSearching = NO;
    
    dispatch_sync(dispatch_get_main_queue(),
                  // block
                  ^{
                    [self didEndSearch:self];
                    [self.outlineView performSelector:@selector(reloadData) withObject:nil afterDelay:0];
                  });
  }
  
}

//
//- (void) searchForTerm:(NSString *)searchTerm inFile:(FileEntity*)file
//{
//  // get the text for this file
//  FileDocument *doc = [file document];
//  
//	NSArray *searchTerms = [searchTerm componentsSeparatedByString:@" "];
//  if ([searchTerms count] == 0) {
//    return;
//  }
//  
//	NSMutableString *regexp = [NSMutableString stringWithString:@"(\\n)?.*"];
//	for (NSString *term in searchTerms) {
//		[regexp appendFormat:@"%@(\\s)*(\\n)?", term];
//	}
//	[regexp appendFormat:@".*(\\n)?"];
//  
//  NSMutableAttributedString *aStr = [[doc textStorage] mutableCopy];
//  NSArray *lineNumbers = [aStr lineNumbersForTextRange:NSMakeRange(0, [aStr length])];
//  NSString *string = [aStr unfoldedString];
//  [aStr release];
//  if (!string)
//    return;
//  
////  NSLog(@"Searching for %@", regexp);
//  
//  NSArray *regexpresults = [string componentsMatchedByRegex:regexp];
//  
//  NSScanner *aScanner = [NSScanner scannerWithString:string];
//  if ([regexpresults count] > 0) {
//    
//    for (NSString *result in regexpresults) {
//      if (!shouldContinueSearching) {
//        break;
//      } // If should continue 
//      
//      NSString *returnResult = [result stringByTrimmingCharactersInSet:ws];
//      returnResult = [returnResult stringByTrimmingCharactersInSet:ns];
//      
//      if ([aScanner scanUpToString:returnResult intoString:NULL]) {
//        
//        NSRange resultRange = NSMakeRange([aScanner scanLocation], [returnResult length]);
//        if (resultRange.location != NSNotFound) {
//          
//          NSRange subrange    = [returnResult rangeOfRegex:[searchTerms objectAtIndex:0]];
//          if (subrange.location != NSNotFound) {
//            resultRange.location += subrange.location;
//            resultRange.length = [searchTerm length];
//                        
//            // scan back to start of word
//            NSInteger idx = subrange.location;
//            while (idx > 0) {
//              if ([ws characterIsMember:[returnResult characterAtIndex:idx]]) {
//                idx++;
//                break;
//              }
//              idx--;
//            }
//            NSInteger len = (NSInteger)MIN(subrange.location-idx+30, [returnResult length]);
//            len = MAX(len, [searchTerm length]);
//            if (len+idx > [returnResult length]) {
//              len = [returnResult length]-idx;
//            }
//            NSString *matchingString = [returnResult substringWithRange:NSMakeRange(idx, len)];
//            if (idx>0) {
//              matchingString = [@"..." stringByAppendingString:matchingString];
//              idx-=3;
//            }
//            
//            TPResultDocument *resultDoc = [self resultDocumentForDocument:file];
//            MHLineNumber *ln = [MHLineNumber lineNumberContainingIndex:resultRange.location inArray:lineNumbers];
//            NSInteger lineNumber = ln.number;
//            TPDocumentMatch *match = [TPDocumentMatch documentMatchInLine:lineNumber withRange:resultRange subrange:NSMakeRange(subrange.location-idx, [searchTerm length]) matchingString:matchingString inDocument:resultDoc];
//            dispatch_semaphore_wait(arrayLock, DISPATCH_TIME_FOREVER);
//            [resultDoc addMatch:match];
//            if (![self.results containsObject:resultDoc]) {
//              [self.results addObject:resultDoc];
//            }
//            
//            dispatch_sync(dispatch_get_main_queue(),
//                          // block
//                          ^{
//                            [self didMakeMatch:self];
//                            [self.outlineView reloadData];
//                          });
//            dispatch_semaphore_signal(arrayLock);
//          } // end subrange found
//        } // end result range founds
//      } // end scanner
//    } // end loop over results
//  } // end if [results count] > 0
//  
//  filesProcessed--;
//  
//  // check if this is the last one?
//  if (filesProcessed == 0) {
//    [self didEndSearch:self];
//    if (!shouldContinueSearching) {
//      // send cancelled message
//      [self didCancelSearch:self];
//    }
//    isSearching = NO;
//    shouldContinueSearching = NO;
//    [self.outlineView reloadData];
//  }
//  
//}

- (TPResultDocument*)resultDocumentForDocument:(FileEntity*)aFile
{
  for (TPResultDocument *doc in self.results) {
    if (doc.document == aFile) {
      return doc;
    }
  }
  
  return [TPResultDocument resultWithDocument:aFile];
}




- (IBAction)handleOutlineViewDoubleClick:(id)sender
{
//  NSLog(@"Handle double click");
	NSInteger row = [self.outlineView clickedRow];
	if (row < 0) {
		// get selection
		row = [self.outlineView selectedRow];
	}
//	NSLog(@"Jumping to row %d", row);
	if (row >= 0) {
    id item = [self.outlineView itemAtRow:row];
		if ([item isKindOfClass:[TPDocumentMatch class]]) {
      [self jumpToResultAtRow:row];
    } else if ([item isKindOfClass:[TPResultDocument class]]) {
      if ([self.outlineView isItemExpanded:item]) {
        [[self.outlineView animator] collapseItem:item];
      } else {
        [[self.outlineView animator] expandItem:item];
      }
    }
	}
}


- (NSInteger)count
{
  NSInteger count = 0;
  for (TPResultDocument *doc in self.results) {
    for (TPDocumentMatch *match in doc.matches) {
      count++;
    }
  }
  return count;  
}

- (void) jumpToResultAtRow:(NSInteger)aRow
{
  id item = [self.outlineView itemAtRow:aRow];
  //  NSLog(@"Found item %@ at index %ld: %@", [item class], aRow, item);
  if ([item isKindOfClass:[TPDocumentMatch class]]) {
    
    TPDocumentMatch *match = (TPDocumentMatch*)item;    
    [self highlightFinderSearchResult:match];
    
  }
}


- (void) jumpToSearchResult:(NSInteger)index
{
  id item = [self resultAtIndex:index];
//  NSLog(@"Found item %@ at index %ld: %@", [item class], index, item);
  if ([item isKindOfClass:[TPDocumentMatch class]]) {
    TPDocumentMatch *match = (TPDocumentMatch*)item;
    TPResultDocument *doc = match.parent;
        
    [self.outlineView performSelectorOnMainThread:@selector(expandItem:) withObject:doc waitUntilDone:YES];
    [self.outlineView selectRowIndexes:[NSIndexSet indexSetWithIndex:[self.outlineView rowForItem:match]]
                  byExtendingSelection:NO];
    
    [self performSelectorOnMainThread:@selector(handleOutlineViewDoubleClick:) withObject:self waitUntilDone:YES];
  }
}

- (id)resultAtIndex:(NSInteger)anIndex
{
  NSInteger count = 0;
  for (TPResultDocument *doc in self.results) {
    for (TPDocumentMatch *match in doc.matches) {
      if (count == anIndex) {
        return match;
      }
      count++;
    }
  }
  return nil;
}

- (void)setSearchTerm:(NSString*)aString
{
  [self.searchField setStringValue:aString];
}


#pragma mark -
#pragma mark SearchResults OutlineView delegate

- (BOOL) outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item
{
  if ([item isKindOfClass:[TPDocumentMatch class]]) {
    return YES;
  }
  return NO;
}

- (void) outlineView:(NSOutlineView *)anOutlineView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn item:(id)item
{
  if (anOutlineView == self.outlineView) {
    if ([cell isMemberOfClass:[ImageAndTextCell class]]) {
      if ([item isKindOfClass:[TPResultDocument class]]) {
        [cell setImage:[NSImage imageNamed:@"TeXnicle_Doc"]];
      } else if ([item isKindOfClass:[TPDocumentMatch class]]) {
        [cell setImage:[NSImage imageNamed:@"textResult"]];
      }
    }
  }
}


#pragma mark -
#pragma mark SearchResults OutlineView datasource

- (NSArray*) orderedResults
{
  NSArray *sortedArray;
  sortedArray = [self.results sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
    NSString *first  = [[(TPResultDocument*)a valueForKey:@"displayString"] string];
    NSString *second = [[(TPResultDocument*)b valueForKey:@"displayString"] string];
    return [first compare:second]==NSOrderedDescending;
  }];
  
  return sortedArray;
}


- (BOOL) outlineView:(NSOutlineView *)outlineView isGroupItem:(id)item
{
  if (item == nil) {
    return NO;
  }
  
  if ([item isKindOfClass:[TPResultDocument class]]) {
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
  
  if ([item isKindOfClass:[TPResultDocument class]]) {
    return [[item valueForKey:@"matches"] count] > 0;
  }
  
  return NO;
}

- (id) outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item
{
  if (item == nil) {
    return [[self orderedResults] objectAtIndex:index];
  }
  
  return [[item valueForKey:@"matches"] objectAtIndex:index];  
}

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
{
  if (item == nil) {
    return [self.results count];
  }
  
  if ([item isKindOfClass:[TPResultDocument class]]) {
    return [[item valueForKey:@"matches"] count];
  }
  
  return 0;
}

#pragma mark -
#pragma mark FinderController Delegate

- (ProjectEntity*)project
{
  if (self.delegate && [self.delegate respondsToSelector:@selector(project)]) {
    return [self.delegate project];
  }
  return nil;
}

- (void) replaceSearchResult:(TPDocumentMatch*)result withText:(NSString*)replacement
{
  // do nothing just call delegate
  if (self.delegate && [self.delegate respondsToSelector:@selector(replaceSearchResult:withText:)]) {
    [self.delegate replaceSearchResult:result withText:replacement];
  }
}

- (void) replaceSearchResult:(NSString*)result withRange:(NSRange)aRange inFile:(FileEntity*)aFile withText:(NSString*)replacement
{
  // do nothing just call delegate
  if (self.delegate && [self.delegate respondsToSelector:@selector(replaceSearchResult:withRange:inFile:withText:)]) {
    [self.delegate replaceSearchResult:result withRange:aRange inFile:aFile withText:replacement];
  }
}


- (void) highlightFinderSearchResult:(TPDocumentMatch *)result
{
  if (self.delegate && [self.delegate respondsToSelector:@selector(highlightFinderSearchResult:)]) {
    [self.delegate highlightFinderSearchResult:result];
  }
}

- (void) highlightSearchResult:(NSString*)result withRange:(NSRange)aRange inFile:(FileEntity*)aFile
{
  // do nothing just call delegate
  if (self.delegate && [self.delegate respondsToSelector:@selector(highlightSearchResult:withRange:inFile:)]) {
    [self.delegate highlightSearchResult:result withRange:aRange inFile:aFile];
  }
}


- (void) didBeginSearch:(FinderController *)aFinder
{
  [self.progressIndicator startAnimation:self];
  [self.statusLabel setStringValue:@"Searching..."];
  
  if (self.delegate && [self.delegate respondsToSelector:@selector(didBeginSearch:)]) {
    [self.delegate didBeginSearch:self];
  }
}

- (void) didEndSearch:(FinderController *)aFinder
{
  
  ProjectEntity *project = [self project];
  	
  //  NSLog(@"Searching for '%@' in project %@", searchTerm, [project valueForKey:@"name"]);
  //  NSLog(@"Searching with regexp: %@", regexp);  
  
	// go through each doc in the project and add attachments
  NSArray *items = [project valueForKey:@"items"];
	for (ProjectItemEntity *item in items) {
		if ([item isKindOfClass:[FileEntity class]]) {
			
			FileEntity *file = (FileEntity*)item;
			if ([[file valueForKey:@"isText"] boolValue]) {
        TPResultDocument *resultDoc = [self resultDocumentForDocument:file];
        NSTextStorage *storage = [[file document] textStorage];
        [storage beginEditing];
        for (TPDocumentMatch *match in resultDoc.matches) {
          // attach the resultDoc to the text
          //    NSLog(@"Attaching [%@] to doc '%@' at range %@", match, [file name], NSStringFromRange(match.range));
          [storage addAttribute:TPDocumentMatchAttributeName value:match range:match.range];    
          //    NSLog(@"%@", [doc textStorage]);
        }  
        [storage endEditing];
        //  NSLog(@"%@", [doc textStorage]);
        //  NSLog(@"Lazy? %d", [[doc textStorage] fixesAttributesLazily]);
      }
    }
  }
  
  [self.progressIndicator stopAnimation:self];
  if ([aFinder count] > 0) {
    NSString *string = [NSString stringWithFormat:@"Found %d results in %d files.", [aFinder count], [self.results count]];
    [self.statusLabel setStringValue:string];
  } else {
    [self.statusLabel setStringValue:@"No results."];
  }

  if (self.delegate && [self.delegate respondsToSelector:@selector(didEndSearch:)]) {
    [self.delegate didEndSearch:self];
  }
}

- (void) didCancelSearch:(FinderController *)aFinder
{
  [self.progressIndicator stopAnimation:self];
  NSString *string = @"Cancelled.";
  [self.statusLabel setStringValue:string];
  
  if (self.delegate && [self.delegate respondsToSelector:@selector(didCancelSearch:)]) {
    [self.delegate didCancelSearch:self];
  }
}

- (void)didMakeMatch:(FinderController *)aFinder
{
  //  NSLog(@"Did match");
  NSString *string = [NSString stringWithFormat:@"Found %d results...", [aFinder count]];
  [self.statusLabel setStringValue:string];
  
  if (self.delegate && [self.delegate respondsToSelector:@selector(didMakeMatch:)]) {
    [self.delegate didMakeMatch:self];
  }
}

- (NSInteger)lineNumberForRange:(NSRange)aRange
{
  if (self.delegate && [self.delegate respondsToSelector:@selector(lineNumberForRange:)]) {
    return [self.delegate lineNumberForRange:aRange];
  }
  return NSNotFound;
}


@end
