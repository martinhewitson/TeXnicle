//
//  ProjectOutlineController.m
//  TeXnicle
//
//  Created by Martin Hewitson on 24/3/10.
//  Copyright 2010 bobsoft. All rights reserved.
//

#import "ProjectOutlineController.h"
#import "ProjectEntity.h"
#import "FileEntity.h"
#import "NSString+LaTeX.h"
#import "NSString+Comparisons.h"
#import "NSMutableAttributedString+CodeFolding.h"
#import "RegexKitLite.h"
#import "TPDocumentSection.h"
#import "MHFileReader.h"
#import "NSString+RelativePath.h"


@implementation ProjectOutlineController

@synthesize timer;
@synthesize delegate;
@synthesize section;

//- (id)initWithDocument:(TeXProjectDocument*)aDocument
- (id)init 
{	
  
//  NSLog(@"Init ProjectOutlineController");
	self = [super init];
  if (self) {
    generating = NO;
    
    //	[self setProjectDocument:aDocument];
    CGFloat topSize = 14.0;
    sections = [[NSMutableArray alloc] init];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:@"\\section" forKey:@"tag"];
    [dict setObject:[NSNumber numberWithInt:1] forKey:@"indent"];
    [dict setObject:[NSNumber numberWithFloat:topSize] forKey:@"size"];
    [dict setObject:[NSColor blackColor] forKey:@"color"];
    [sections addObject:dict];
    
    dict = [NSMutableDictionary dictionary];
    [dict setObject:@"\\subsection" forKey:@"tag"];
    [dict setObject:[NSNumber numberWithInt:2] forKey:@"indent"];
    [dict setObject:[NSNumber numberWithFloat:topSize-2] forKey:@"size"];
    [dict setObject:[NSColor darkGrayColor] forKey:@"color"];
    [sections addObject:dict];
    
    dict = [NSMutableDictionary dictionary];
    [dict setObject:@"\\subsubsection" forKey:@"tag"];
    [dict setObject:[NSNumber numberWithInt:3] forKey:@"indent"];
    [dict setObject:[NSNumber numberWithFloat:topSize-4] forKey:@"size"];
    [dict setObject:[NSColor lightGrayColor] forKey:@"color"];
    [sections addObject:dict];
    
    dict = [NSMutableDictionary dictionary];
    [dict setObject:@"\\paragraph" forKey:@"tag"];
    [dict setObject:[NSNumber numberWithInt:1] forKey:@"indent"];
    [dict setObject:[NSNumber numberWithFloat:topSize] forKey:@"size"];
    [dict setObject:[NSColor blackColor] forKey:@"color"];
    [sections addObject:dict];
    
    dict = [NSMutableDictionary dictionary];
    [dict setObject:@"\\subparagraph" forKey:@"tag"];
    [dict setObject:[NSNumber numberWithInt:2] forKey:@"indent"];
    [dict setObject:[NSNumber numberWithFloat:topSize-2] forKey:@"size"];
    [dict setObject:[NSColor darkGrayColor] forKey:@"color"];
    [sections addObject:dict];
    
    dict = [NSMutableDictionary dictionary];
    [dict setObject:@"\\part" forKey:@"tag"];
    [dict setObject:[NSNumber numberWithInt:1] forKey:@"indent"];
    [dict setObject:[NSNumber numberWithFloat:topSize] forKey:@"size"];
    [dict setObject:[NSColor blackColor] forKey:@"color"];
    [sections addObject:dict];
    
    
    paragraphStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    [paragraphStyle setLineSpacing:3.0];
        
    //	NSLog(@"Starting timer");
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                  target:self
                                                selector:@selector(generateTOC)
                                                userInfo:nil
                                                 repeats:YES];
  }
	

	return self;
}

- (void) awakeFromNib
{
  [self turnOffWrapping];
}

-(void) turnOffWrapping
{
//  NSLog(@"Turn off wrapping for %@", textView);
	const float			LargeNumberForText = 1.0e7;
	NSTextContainer*	textContainer = [textView textContainer];
	NSRect				frame;
	NSScrollView*		scrollView = [textView enclosingScrollView];
	
	// Make sure we can see right edge of line:
	[scrollView setHasHorizontalScroller:YES];
	
	// Make text container so wide it won't wrap:
	[textContainer setContainerSize: NSMakeSize(LargeNumberForText, LargeNumberForText)];
	[textContainer setWidthTracksTextView:NO];
	[textContainer setHeightTracksTextView:NO];
	
	// Make sure text view is wide enough:
	frame.origin = NSMakePoint(0.0, 0.0);
	frame.size = [scrollView contentSize];
	
	[textView setMaxSize:NSMakeSize(LargeNumberForText, LargeNumberForText)];
	[textView setHorizontallyResizable:YES];
	[textView setVerticallyResizable:YES];
	//	[textView setAutoresizingMask:NSViewNotSizable];
	
	
}

- (void) deactivate
{
  [timer invalidate];
}


- (void) dealloc
{
  self.delegate = nil;
  [self.timer invalidate];
  self.timer = nil;
	self.section = nil;
	[sections release];
	[super dealloc];
}




//- (void) handleDocChanges:(NSNotification*)aNote
//{
//	if (!delegate) 
//		return;
//  
//	[[self window] setTitle:[NSString stringWithFormat:@"Overview of %@", [[delegate project] valueForKey:@"name"]]];
//	// regenerate TOC
//	[self generateTOC];
//	
//}

- (void) generateTOC
{
  if (generating)
    return;
  if (![self.delegate respondsToSelector:@selector(shouldGenerateOutline)]) {
    return;
  }
  
  BOOL shouldGenerate = [self.delegate shouldGenerateOutline];
  
  if (self.delegate == nil || !shouldGenerate) {
    return;
  }
  
	generating = YES;
	
//	NSLog(@"Generating TOC");
//	[textStorage deleteCharactersInRange:NSMakeRange(0, [[textStorage string] length])];
		
	// start from the main doc
//	NSLog(@"Project doc: %@", self.delegate);
	if (!self.delegate) 
		return;
	
	ProjectEntity *project = [self.delegate project];
//  NSLog(@"Project %@", project);
	if (project) {
    [self generateTOCForProject:project];
  } else {
    if ([self.delegate respondsToSelector:@selector(fileURL)]) {
      NSURL *fileURL = [self.delegate fileURL];
      [self generateTOCForFileAtURL:fileURL];
    }
  }
		
	
//	[self setDocumentEdited:NO];
	[textView didChangeText];				
	
	generating = NO;
}

- (void) generateTOCForFileAtURL:(NSURL*)aURL
{
	NSTextStorage *textStorage = [textView textStorage];
  
  if (![self.delegate respondsToSelector:@selector(documentString)]) {
    return;
  }
  
	NSAttributedString *attString = [self.delegate performSelector:@selector(documentString)];
  NSString *string = [attString string]; 
	// take \begin{document} as the start
	if (!string)
		return;
	
	NSScanner *aScanner = [NSScanner scannerWithString:string];
	
	NSString *tag = @"\\begin{document}";
  NSInteger loc = 0;
  NSInteger taglength = 0;
	if ([aScanner scanUpToString:tag intoString:NULL]) {
		
		NSInteger scanloc = [aScanner scanLocation];
		if (scanloc < 0 || scanloc >= [string length]) {
      // do nothing
    } else {
      loc = scanloc;
      taglength = [tag length];
    }    
	}  
  
  // add link to the textView
  NSMutableDictionary *dict = [NSMutableDictionary dictionary];
  if (aURL) {
    [dict setObject:aURL forKey:@"document"];
    [dict setObject:NSStringFromRange(NSMakeRange(loc, taglength)) forKey:@"range"];
    [dict setObject:[aURL lastPathComponent] forKey:@"result"];
  }
  
  NSMutableDictionary* attributes = [NSMutableDictionary dictionaryWithObject:dict forKey:NSLinkAttributeName];
  
  [attributes setObject:paragraphStyle forKey:NSParagraphStyleAttributeName];
  [attributes setObject:[NSCursor pointingHandCursor] forKey:NSCursorAttributeName];
  [attributes setObject:[NSFont messageFontOfSize:16.0] forKey:NSFontAttributeName];
  NSString *rootNode = @"Untitled";
  if (aURL) {
    rootNode = [[NSString stringWithFormat:@"%@", [aURL lastPathComponent]] stringByDeletingPathExtension];
  }
  NSMutableAttributedString* attrPath = [[NSMutableAttributedString alloc] initWithString:[rootNode stringByAppendingString:@"\n"]
                                                                               attributes:attributes];
  
  // now start the recursive process of adding links for all sections etc
  
  NSMutableAttributedString *newStr = [self addLinksTo:attrPath forString:[[attString mutableCopy] autorelease] atURL:aURL];
  
  //		NSLog(@"Got TOC: %@", [newStr string]);
  
  if ([[textStorage string] isEqualToString:[newStr string]]) {
    //      NSLog(@"Outline didn't change");
  } else {
    [textStorage setAttributedString:newStr];
    [textView setLinkTextAttributes:attributes];
  }
  
  [attrPath release];
  
}


- (void) generateTOCForProject:(ProjectEntity*)project
{
	NSTextStorage *textStorage = [textView textStorage];
  
	FileEntity *mainFile = [project valueForKey:@"mainFile"];
  //  NSLog(@"Main file %@", mainFile);
	if (!mainFile)
		return;
  
	NSString *string = [mainFile workingContentString];
	
	// take \begin{document} as the start
	if (!string)
		return;
	
	NSScanner *aScanner = [NSScanner scannerWithString:string];
	
	NSString *tag = @"\\begin{document}";
	if ([aScanner scanUpToString:tag intoString:NULL]) {
		
		NSInteger loc = [aScanner scanLocation];
		if (loc < 0 || loc >= [string length])
			return;
		
		// add link to the textView
		NSMutableDictionary *dict = [NSMutableDictionary dictionary];
		[dict setObject:mainFile forKey:@"document"];
		[dict setObject:NSStringFromRange(NSMakeRange(loc, [tag length])) forKey:@"range"];
		[dict setObject:[mainFile valueForKey:@"name"] forKey:@"result"];
		
		NSMutableDictionary* attributes = [NSMutableDictionary dictionaryWithObject:dict forKey:NSLinkAttributeName];
		
		[attributes setObject:paragraphStyle forKey:NSParagraphStyleAttributeName];
		[attributes setObject:[NSCursor pointingHandCursor] forKey:NSCursorAttributeName];
		[attributes setObject:[NSFont messageFontOfSize:16.0] forKey:NSFontAttributeName];
		NSString *rootNode = [[NSString stringWithFormat:@"%@", [mainFile name]] stringByDeletingPathExtension];
		NSMutableAttributedString* attrPath = [[NSMutableAttributedString alloc] initWithString:[rootNode stringByAppendingString:@"\n"]
																																								 attributes:attributes];
		
		
		// now start the recursive process of adding links for all sections etc
    NSMutableAttributedString *newStr;
    newStr = [self addLinksTo:attrPath InFile:mainFile inProject:project];
		
    if ([[textStorage string] isEqualToString:[newStr string]]) {
      //      NSLog(@"Outline didn't change");
    } else {
      [textStorage setAttributedString:newStr];
      [textView setLinkTextAttributes:attributes];
    }
    
		[attrPath release];
    
	}  
}

- (NSDictionary*) sectionNamed:(NSString*)aString
{
	for (NSDictionary *dict in sections) {
		if ([[dict valueForKey:@"tag"] isEqual:aString]) {
			return dict;
		}
	}
	return nil;
}

- (NSMutableAttributedString*) addLinksTo:(NSMutableAttributedString*)aStr forString:(NSMutableAttributedString*)astring atURL:(NSURL*)aURL
{
	NSMutableAttributedString *newStr = [[[NSMutableAttributedString alloc] initWithAttributedString:aStr] autorelease];
  //	NSLog(@"Searching file %@", [aFile valueForKey:@"name"]);
	NSCharacterSet *ws = [NSCharacterSet whitespaceCharacterSet];
	NSCharacterSet *ns = [NSCharacterSet newlineCharacterSet];
	  
	NSString *string = [astring unfoldedString];
	[astring release];
	
	string = [string stringByReplacingOccurrencesOfRegex:@"\n" withString:@" "];
	//string = [string stringByReplacingOccurrencesOfRegex:@"\r" withString:@" "];
	string = [@" " stringByAppendingString:string];
  
  NSLog(@"Searching %@", aURL);	
	
	NSUInteger loc = 0;
	while (loc < [string length]) {
		if ([ws characterIsMember:[string characterAtIndex:loc]] ||
				[ns characterIsMember:[string characterAtIndex:loc]]) {
			
			NSString *word = [string nextWordStartingAtLocation:&loc];
 			word = [word stringByTrimmingCharactersInSet:ws];
      
      //			NSLog(@"Checking word '%@'", word);
			// Get section, etc
			for (NSDictionary *secDict in sections) {
				NSString *sec = [secDict valueForKey:@"tag"];
				if ([word hasPrefix:sec]) {
          //					NSLog(@"Found word %@", word);
					NSString *tag = [NSString stringWithFormat:@"%@", word];
					NSMutableDictionary *dict = [NSMutableDictionary dictionary];
          if (aURL) {
            [dict setObject:aURL forKey:@"document"];
          }
					NSInteger start = loc + 1 - [tag length];
					
					NSInteger partStart = -1;
					NSInteger partEnd = -1;
					while (start < [string length]) {
            //						NSLog(@"Checking '%C'", [string characterAtIndex:start]);
						if (partStart<0 && [string characterAtIndex:start] == '{') {
							partStart = start+1;
						}
						if (partEnd<0 && [string characterAtIndex:start] == '}') {
							partEnd = start;
							break;
						}
						start++;
					}
					
					if (partStart>=0 && partEnd>=0) {
						NSRange tagRange = NSMakeRange(partStart, partEnd-partStart);
            //						NSLog(@"Check range: '%@'", [string substringWithRange:tagRange]);
						NSRange lineRange = tagRange;
						lineRange.location--;
						[dict setObject:NSStringFromRange(lineRange) forKey:@"range"];
            if (aURL) {
              [dict setObject:[aURL lastPathComponent] forKey:@"result"];
            }
						NSDictionary* attributes = [NSDictionary dictionaryWithObject:dict forKey:NSLinkAttributeName];
						
						NSString *disp = @"";					
						for (int kk=0; kk<[[secDict valueForKey:@"indent"] intValue]; kk++) {
							disp = [disp stringByAppendingString:@"    "];
						}
						disp = [disp stringByAppendingFormat:@"%@\n", [string substringWithRange:tagRange]];
						NSMutableAttributedString* attrPath = [[NSMutableAttributedString alloc] initWithString:disp 
																																												 attributes:attributes];
						
						NSRange dispRange = NSMakeRange(0,[attrPath length]);
						[attrPath addAttribute:NSFontAttributeName 
														 value:[NSFont messageFontOfSize:[[secDict valueForKey:@"size"] floatValue]] 
														 range:dispRange];
            [attrPath addAttribute:NSForegroundColorAttributeName
                             value:[secDict valueForKey:@"color"]
                             range:dispRange];
            [attrPath addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:dispRange];
						
						[newStr appendAttributedString:attrPath];
						[attrPath release];
						
						break;
					}
				}
			}
			
			//			NSLog(@"Got word '%@'", word);
			if ([word hasPrefix:@"\\input"] || [word hasPrefix:@"\\include"]) {
        //				NSLog(@"Found %@", word);
				
				// get the file from this input
				int sloc = 0;
				int start = -1;
				int end = -1;
				while (sloc < [word length]) {
					if ([word characterAtIndex:sloc]=='{') {
						start = sloc;
					}
					if ([word characterAtIndex:sloc]=='}') {
						end = sloc;
					}
					sloc++;
				}
				
				NSString *filePath = nil;
				if (start > 0 && end > 0) {
					filePath = [word substringWithRange:NSMakeRange(start+1, end-start-1)];
				}
				
				if (filePath && aURL) {
          
          NSString *rootPath = [[aURL URLByDeletingLastPathComponent] path];
          NSString *targetPath = [rootPath stringByAppendingPathComponent:[rootPath relativePathTo:filePath]];          
          if ([[NSFileManager defaultManager] fileExistsAtPath:targetPath]) {
            NSURL *nextURL = [NSURL fileURLWithPath:targetPath];
            if (nextURL) {
              MHFileReader *fr = [[[MHFileReader alloc] init] autorelease];
              NSString *str = [fr readStringFromFileAtURL:nextURL];
              if (str) {
                NSMutableAttributedString *newString = [[NSMutableAttributedString alloc] initWithString:str];
                newStr = [self addLinksTo:newStr forString:newString atURL:nextURL];
              }
            }
          }
          
				}				
			} // end recursive call to input/include			
		}
		loc++;
	}
  
	return newStr;
}

- (NSMutableAttributedString*) addLinksTo:(NSMutableAttributedString*)aStr InFile:(id)aFile inProject:(ProjectEntity*)project
{
	NSMutableAttributedString *newStr = [[[NSMutableAttributedString alloc] initWithAttributedString:aStr] autorelease];
	NSCharacterSet *ws = [NSCharacterSet whitespaceCharacterSet];
	NSCharacterSet *ns = [NSCharacterSet newlineCharacterSet];
	
  NSMutableAttributedString *astring;
  astring = [[[aFile document] textStorage] mutableCopy];
    
	NSString *string = [astring unfoldedString];
	[astring release];
	
	string = [string stringByReplacingOccurrencesOfRegex:@"\n" withString:@" "];
	//string = [string stringByReplacingOccurrencesOfRegex:@"\r" withString:@" "];
	string = [@" " stringByAppendingString:string];
//	NSLog(@"Searching %@", [aFile name]);	
	
	NSUInteger loc = 0;
	while (loc < [string length]) {
		if ([ws characterIsMember:[string characterAtIndex:loc]] ||
				[ns characterIsMember:[string characterAtIndex:loc]]) {
			
			NSString *word = [string nextWordStartingAtLocation:&loc];
 			word = [word stringByTrimmingCharactersInSet:ws];
 			word = [word stringByTrimmingCharactersInSet:ns];
		
//			NSLog(@"Checking word '%@'", word);
			// Get section, etc
			for (NSDictionary *secDict in sections) {
				NSString *sec = [secDict valueForKey:@"tag"];
				if ([word hasPrefix:sec]) {
//					NSLog(@"Found word %@", word);
					NSString *tag = [NSString stringWithFormat:@"%@", word];
					NSMutableDictionary *dict = [NSMutableDictionary dictionary];
					[dict setObject:aFile forKey:@"document"];
					NSInteger start = loc + 1 - [tag length];
					
					NSInteger partStart = -1;
					NSInteger partEnd = -1;
					while (start < [string length]) {
//						NSLog(@"Checking '%C'", [string characterAtIndex:start]);
						if (partStart<0 && [string characterAtIndex:start] == '{') {
							partStart = start+1;
						}
						if (partEnd<0 && [string characterAtIndex:start] == '}') {
							partEnd = start;
							break;
						}
						start++;
					}
					
					if (partStart>=0 && partEnd>=0) {
						NSRange tagRange = NSMakeRange(partStart, partEnd-partStart);
//						NSLog(@"Check range: '%@'", [string substringWithRange:tagRange]);
						NSRange lineRange = tagRange;
						lineRange.location--;
						[dict setObject:NSStringFromRange(lineRange) forKey:@"range"];
            [dict setObject:[aFile valueForKey:@"name"] forKey:@"result"];
            
						NSDictionary* attributes = [NSDictionary dictionaryWithObject:dict forKey:NSLinkAttributeName];
						
						NSString *disp = @"";					
						for (int kk=0; kk<[[secDict valueForKey:@"indent"] intValue]; kk++) {
							disp = [disp stringByAppendingString:@"    "];
						}
						disp = [disp stringByAppendingFormat:@"%@\n", [string substringWithRange:tagRange]];
						NSMutableAttributedString* attrPath = [[NSMutableAttributedString alloc] initWithString:disp 
																																												 attributes:attributes];
						
						NSRange dispRange = NSMakeRange(0,[attrPath length]);
						[attrPath addAttribute:NSFontAttributeName 
														 value:[NSFont messageFontOfSize:[[secDict valueForKey:@"size"] floatValue]] 
														 range:dispRange];
            [attrPath addAttribute:NSForegroundColorAttributeName
                             value:[secDict valueForKey:@"color"]
                             range:dispRange];
            [attrPath addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:dispRange];
						
						[newStr appendAttributedString:attrPath];
						[attrPath release];
						
						break;
					}
				}
			}
			
			//			NSLog(@"Got word '%@'", word);
			if ([word hasPrefix:@"\\input"] || [word hasPrefix:@"\\include"]) {
//				NSLog(@"Found %@", word);
				
				// get the file from this input
				int sloc = 0;
				int start = -1;
				int end = -1;
				while (sloc < [word length]) {
					if ([word characterAtIndex:sloc]=='{') {
						start = sloc;
					}
					if ([word characterAtIndex:sloc]=='}') {
						end = sloc;
					}
					sloc++;
				}
				
				NSString *filePath = nil;
				if (start > 0 && end > 0) {
					filePath = [word substringWithRange:NSMakeRange(start+1, end-start-1)];
				}
				
				if (filePath) {
          //					NSLog(@"Got file path %@", filePath);
					// find a file with this filepath
          FileEntity *nextFile = [project fileWithPath:filePath];
          if (nextFile) {
            newStr = [self addLinksTo:newStr InFile:nextFile inProject:project];
          }
				}				
			} // end recursive call to input/include			
		}
		loc++;
	}

	return newStr;
}

#pragma mark -
#pragma mark Text View Delegate

- (BOOL)textView:(NSTextView *)aTextView clickedOnLink:(id)link
{
  //	NSLog(@"Clicked %@", link);
	[delegate highlightSearchResult:[link valueForKey:@"result"]
                        withRange:NSRangeFromString([link valueForKey:@"range"])
                           inFile:[link valueForKey:@"document"]];
	return YES;
}

#pragma mark -
#pragma mark outline view data source

- (void) reloadData
{
  NSLog(@"Reloading data");
//  if (generating)
//    return;
  if (![self.delegate respondsToSelector:@selector(shouldGenerateOutline)]) {
    return;
  }
  
  BOOL shouldGenerate = [self.delegate shouldGenerateOutline];
  
  if (self.delegate == nil || !shouldGenerate) {
    return;
  }
  
//	generating = YES;
	
	// start from the main doc
	if (!self.delegate) 
		return;
	
	ProjectEntity *project = [self.delegate project];
	if (!project)
		return;
	
	FileEntity *mainFile = [project valueForKey:@"mainFile"];
	if (!mainFile)
		return;
  
  self.section = [TPDocumentSection sectionWithRange:NSMakeRange(0, 0) 
                                              result:@"Document" 
                                            document:nil];
  [self.section addSectionsFromFile:mainFile inProject:project];

	
//	NSString *string = [mainFile workingContentString];
//	
//	// take \begin{document} as the start
//	if (!string)
//		return;
//	
//	NSScanner *aScanner = [NSScanner scannerWithString:string];
//	
//	NSString *tag = @"\\begin{document}";
//	if ([aScanner scanUpToString:tag intoString:NULL]) {
//		
//		NSInteger loc = [aScanner scanLocation];
//		if (loc < 0 || loc >= [string length]) {
//      NSLog(@"scanner location out of range");
//			return;
//    }
//		
//    self.section = [TPDocumentSection sectionWithRange:NSMakeRange(loc, [tag length]) 
//                                                result:[mainFile valueForKey:@"name"] 
//                                              document:mainFile];
//    [self.section addSectionsFromFile:mainFile inProject:project];
//	}	
		
  NSLog(@"Section %@", section);
  
  [outlineView reloadData];
  
//	generating = NO;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
  if (item == nil) {
    return YES;
  }
  
  if ([[item valueForKey:@"subsections"] count]>0) {
    return YES;
  }
  
  return NO;
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item
{
  if (item == nil) {
    return self.section;
  }
  
  return [[item valueForKey:@"subsections"] objectAtIndex:index];
}

-(NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
{
  if (item == nil) {
    return 1;
  }
  
  return [[item valueForKey:@"subsections"] count];
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{
  return [item valueForKey:@"result"];
}

@end
