//
//  FinderProjectController.m
//  TeXnicle
//
//  Created by Martin Hewitson on 4/8/11.
//  Copyright 2011 bobsoft. All rights reserved.
//

#import "FinderController.h"
#import "TPResultDocument.h"
#import "TPDocumentMatch.h"
#import "ProjectItemEntity.h"
#import "FileEntity.h"
#import "RegexKitLite.h"
#import "NSString+LaTeX.h"
#import "NSMutableAttributedString+CodeFolding.h"

@implementation FinderController

@synthesize delegate;
@synthesize jumpToButton;
@synthesize searchField;
@synthesize outlineView;
@synthesize progressIndicator;
@synthesize statusLabel;
@synthesize results;

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
    
    arrayLock = dispatch_semaphore_create(1);
    
  }
	
	return self;
}

- (void) dealloc
{
  [ws release];
  [ns release];
	dispatch_release(queue);
  dispatch_release(arrayLock);
  self.results = nil;
  [super dealloc];
}

- (void) awakeFromNib
{  
  [self.outlineView setDoubleAction:@selector(handleOutlineViewDoubleClick:)];
  [self.outlineView setTarget:self];
}


#pragma mark -
#pragma mark Control 

- (IBAction) performSearch:(id)sender
{
  if (self.delegate == nil) {
    return;
  }
  
  //  NSLog(@"Perform search %@", sender);
  
	NSString *searchTerm = [[sender stringValue] stringByReplacingOccurrencesOfString:@"\\"
                                                                         withString:@"\\\\"];
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
  
  if ([searchTerm length] == 0) {
    [self didEndSearch:self];
    return;
  }
  
  [self didBeginSearch:self];
	
  //	NSString *regexp = [NSString stringWithFormat:@".*%@.*", searchTerm];
  //	NSString *regexp = [NSString stringWithFormat:@"(\\n)?.*%@.*(\\n)?", searchTerm];
	
  ProjectEntity *project = [self project];
	
  //  NSLog(@"Searching for '%@' in project %@", searchTerm, [project valueForKey:@"name"]);
  //  NSLog(@"Searching with regexp: %@", regexp);
	
  dispatch_semaphore_wait(arrayLock, DISPATCH_TIME_FOREVER);
  [self.results removeAllObjects];  
  shouldContinueSearching = YES;
  isSearching = YES;
  dispatch_semaphore_signal(arrayLock);
  
  
	// go through each doc in the project
  NSArray *items = [project valueForKey:@"items"];
  filesProcessed = 0;
	for (ProjectItemEntity *item in items) {
		if ([item isKindOfClass:[FileEntity class]]) {
			
			FileEntity *file = (FileEntity*)item;
			if ([[file valueForKey:@"isText"] boolValue]) {
        dispatch_async(queue, ^{						
          NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];          
          [self searchForTerm:searchTerm inFile:file];
          [pool drain];      
        });
        filesProcessed++;
			} // end if isText			
		} // end if is file
	} // end loop over project items
  
}

- (void) searchForTerm:(NSString *)searchTerm inFile:(FileEntity*)file
{
  // get the text for this file
  FileDocument *doc = [file document];
  
	NSArray *searchTerms = [searchTerm componentsSeparatedByString:@" "];
  if ([searchTerms count] == 0) {
    return;
  }
  
	NSMutableString *regexp = [NSMutableString stringWithString:@"(\\n)?.*"];
	for (NSString *term in searchTerms) {
		[regexp appendFormat:@"%@(\\s)*(\\n)?", term];
	}
	[regexp appendFormat:@".*(\\n)?"];
  
  NSMutableAttributedString *aStr = [[doc textStorage] mutableCopy];
  NSString *string = [aStr unfoldedString];
  [aStr release];
  if (!string)
    return;
  
  NSArray *regexpresults = [string componentsMatchedByRegex:regexp];
  
  NSScanner *aScanner = [NSScanner scannerWithString:string];
  BOOL didMatch = NO;
  if ([regexpresults count] > 0) {
    
    for (NSString *result in regexpresults) {
      if (!shouldContinueSearching) {
        break;
      } // If should continue 
      
      NSString *returnResult = [NSString stringWithControlsFilteredForString:result];
      
      returnResult = [result stringByTrimmingCharactersInSet:ws];
      returnResult = [returnResult stringByTrimmingCharactersInSet:ns];
      
      if ([aScanner scanUpToString:returnResult intoString:NULL]) {
        
        NSRange resultRange = NSMakeRange([aScanner scanLocation], [returnResult length]);
        if (resultRange.location != NSNotFound) {
          
          NSRange subrange    = [returnResult rangeOfRegex:[searchTerms objectAtIndex:0]];
          if (subrange.location != NSNotFound) {
            resultRange.location += subrange.location;
            resultRange.length = [searchTerm length];
            
            TPResultDocument *resultDoc = [self resultDocumentForDocument:file];
            
            // scan back to start of word
            NSInteger idx = subrange.location;
            while (idx > 0) {
              if ([ws characterIsMember:[returnResult characterAtIndex:idx]]) {
                break;
              }
              idx--;
            }
            NSInteger len = (NSInteger)MIN(subrange.location-idx+30, [returnResult length]-idx);
            len = MAX(len, [searchTerm length]);
            NSString *matchingString = [returnResult substringWithRange:NSMakeRange(idx, len)];
            if (idx>0) {
              matchingString = [@"..." stringByAppendingString:matchingString];
              idx-=3;
            }
            
            TPDocumentMatch *match = [TPDocumentMatch documentMatchWithRange:resultRange subrange:NSMakeRange(subrange.location-idx, [searchTerm length]) matchingString:matchingString];
            dispatch_semaphore_wait(arrayLock, DISPATCH_TIME_FOREVER);
            [resultDoc addMatch:match];
            if (![self.results containsObject:resultDoc]) {
              [self.results addObject:resultDoc];
            }
            didMatch = YES;
            dispatch_semaphore_signal(arrayLock);
            
            dispatch_sync(dispatch_get_main_queue(),
                          // block
                          ^{
                            [self didMakeMatch:self];
                            [self.outlineView reloadData];
                          });
          } // end subrange found
        } // end result range founds
      } // end scanner
    } // end loop over results
  } // end if [results count] > 0
  
  filesProcessed--;
  
  // check if this is the last one?
  if (filesProcessed == 0) {
    [self didEndSearch:self];
    if (!shouldContinueSearching) {
      // send cancelled message
      [self didCancelSearch:self];
    }
    isSearching = NO;
    shouldContinueSearching = NO;
    [self.outlineView reloadData];
  }
  
}

- (TPResultDocument*)resultDocumentForDocument:(FileEntity*)aFile
{
  for (TPResultDocument *doc in self.results) {
    if (doc.document == aFile) {
      return doc;
    }
  }
  
  return [TPResultDocument resultWithDocuemnt:aFile];
}




- (IBAction)handleOutlineViewDoubleClick:(id)sender
{
	NSInteger row = [self.outlineView clickedRow];
	if (row < 0) {
		// get selection
		row = [self.outlineView selectedRow];
	}
	
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
    TPResultDocument *doc = [self.outlineView parentForItem:item];
    
    [self highlightSearchResult:match.match 
                      withRange:match.range
                         inFile:[doc valueForKey:@"document"]];
    
  }
}


- (void) jumpToSearchResult:(NSInteger)index
{
  id item = [self resultAtIndex:index];
  //  NSLog(@"Found item %@ at index %ld: %@", [item class], index, item);
  if ([item isKindOfClass:[TPDocumentMatch class]]) {
    TPDocumentMatch *match = (TPDocumentMatch*)item;
    TPResultDocument *doc = [self.outlineView parentForItem:item];
    
    [self highlightSearchResult:match.match 
                      withRange:match.range
                         inFile:[doc valueForKey:@"document"]];
    
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

#pragma mark -
#pragma mark SearchResults OutlineView datasource

- (BOOL) outlineView:(NSOutlineView *)outlineView isGroupItem:(id)item
{
  if ([item isKindOfClass:[TPResultDocument class]]) {
    return YES;
  }
  
  return NO;
}

- (id) outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{
  return [item valueForKey:@"displayString"];
}

- (BOOL) outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
  if ([item isKindOfClass:[TPResultDocument class]]) {
    return [[item valueForKey:@"matches"] count] > 0;
  }
  
  return NO;
}

- (id) outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item
{
  if (item == nil) {
    return [self.results objectAtIndex:index];
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
  [self.progressIndicator stopAnimation:self];
  NSString *string = [NSString stringWithFormat:@"Found %d results.", [aFinder count]];
  [self.statusLabel setStringValue:string];

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



@end
