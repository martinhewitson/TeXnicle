//
//  FindInProjectController.m
//  TeXnicle
//
//  Created by Martin Hewitson on 20/3/10.
//  Copyright 2010 AEI Hannover . All rights reserved.
//

#import "FindInProjectController.h"
#import "TeXProjectDocument.h"
#import "ProjectEntity.h"
#import "ProjectItemEntity.h"
#import "FileEntity.h"
#import "FileDocument.h"
#import "NSString+LaTeX.h"
#import "NSMutableAttributedString+CodeFolding.h"
#import "RegexKitLite.h"

@implementation FindInProjectController

@synthesize delegate;

- (id) init
{
	
	if (![super initWithWindowNibName:@"FindInProject"])
		return nil;
	
	
	return self;
}

- (void) awakeFromNib
{
	[resultsView setDoubleAction:@selector(handleTableDoubleClick:)];
  [resultsView setTarget:self];
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
  if ([searchTerm length] == 0) {
    return;
  }
	
	NSArray *searchTerms = [searchTerm componentsSeparatedByString:@" "];
  if ([searchTerms count] == 0) {
    return;
  }

	NSMutableString *regexp = [NSMutableString stringWithString:@"(\\n)?.*"];
	for (NSString *term in searchTerms) {
		[regexp appendFormat:@"%@(\\s)*(\\n)?", term];
	}
	[regexp appendFormat:@".*(\\n)?"];
	
//	NSString *regexp = [NSString stringWithFormat:@".*%@.*", searchTerm];
//	NSString *regexp = [NSString stringWithFormat:@"(\\n)?.*%@.*(\\n)?", searchTerm];
	
  ProjectEntity *project = [self.delegate project];
	
//	NSLog(@"Searching for '%@' in project %@", searchTerm, [project valueForKey:@"name"]);
//	NSLog(@"Searching with regexp: %@", regexp);
	
	[searchResults removeObjects:[searchResults arrangedObjects]];

	// go through each doc in the project
	for (ProjectItemEntity *item in [project valueForKey:@"items"]) {
		if ([item isKindOfClass:[FileEntity class]]) {
			
			FileEntity *file = (FileEntity*)item;
			if ([[file valueForKey:@"isText"] boolValue]) {
				
//				NSLog(@"Searching %@...", [file valueForKey:@"name"]);
				
				// get the text for this file
				FileDocument *doc = [file document];
								
				NSMutableAttributedString *aStr = [[doc textStorage] mutableCopy];
				NSString *string = [aStr unfoldedString];
				[aStr release];
//				NSString *string = [[doc textStorage] string];
				if (!string)
					return;
				
//				NSLog(@"Searching string %@", string);
				
				
				
				NSArray *results = [string componentsMatchedByRegex:regexp];
				
				NSScanner *aScanner = [NSScanner scannerWithString:string];
//				NSLog(@"Results: %@", results);
				if ([results count] > 0) {
					
					for (NSString *result in results) {
												
						NSString *returnResult = [NSString stringWithControlsFilteredForString:result];
						
//						returnResult = [result stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
						returnResult = [result stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
						
						if ([aScanner scanUpToString:returnResult intoString:NULL]) {
							
							NSRange resultRange = NSMakeRange([aScanner scanLocation], [returnResult length]);
							
							NSRange subrange    = [returnResult rangeOfRegex:[searchTerms objectAtIndex:0]];
							resultRange.location += subrange.location;
							resultRange.length = [searchTerm length];
//							NSLog(@"Got results range:%@", NSStringFromRange(resultRange));
							
							NSMutableDictionary *dict = [NSMutableDictionary dictionary];
							[dict setObject:file forKey:@"document"];
							[dict setObject:NSStringFromRange(resultRange) forKey:@"range"];
							[dict setObject:[NSString stringWithControlsFilteredForString:returnResult] forKey:@"result"];
							[searchResults addObject:dict];
//							NSLog(@"Found %@", returnResult);
							
							[resultsView reloadData];
						}
					} // end loop over results
				} // end if [results count] > 0
			} // end if isText			
		} // end if is file
	} // end loop over project items
}

- (IBAction)handleTableDoubleClick:(id)sender
{
	NSInteger row = [resultsView clickedRow];
	if (row < 0) {
		// get selection
		row = [resultsView selectedRow];
	}
	
	if (row >= 0) {
		
		// get file
		FileEntity *file = [[searchResults arrangedObjects] objectAtIndex:row];
		[self.delegate highlightSearchResult:[file valueForKey:@"result"] 
                               withRange:NSRangeFromString([file valueForKey:@"range"])
                                  inFile:[file valueForKey:@"document"]];
		
	}
}

@end
