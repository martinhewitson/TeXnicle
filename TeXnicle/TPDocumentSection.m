//
//  TPDocumentSection.m
//  TeXnicle
//
//  Created by Martin Hewitson on 25/7/11.
//  Copyright 2011 bobsoft. All rights reserved.
//

#import "TPDocumentSection.h"
#import "FileEntity.h"
#import "ProjectEntity.h"
#import "NSString+LaTeX.h"
#import "NSString+Comparisons.h"
#import "NSMutableAttributedString+CodeFolding.h"
#import "RegexKitLite.h"

@implementation TPDocumentSection

@synthesize result;
@synthesize range;
@synthesize document;
@synthesize subsections;

+ (TPDocumentSection*)sectionWithRange:(NSRange)aRange result:(NSString*)aName document:(id)aDocument
{
  return [[[TPDocumentSection alloc] initWithRange:aRange result:aName document:aDocument] autorelease];
}

- (id)initWithRange:(NSRange)aRange result:(NSString*)aName document:(id)aDocument
{
  self = [super init];
  if (self) {
    self.result = aName;
    self.range = NSStringFromRange(aRange);
    self.document = aDocument;
    self.subsections = [NSMutableArray array];
    
    NSLog(@"Made section %@", self);
    
    sections = [[NSMutableArray alloc] init];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:@"\\section" forKey:@"tag"];
    [sections addObject:dict];
    
    dict = [NSMutableDictionary dictionary];
    [dict setObject:@"\\subsection" forKey:@"tag"];
    [sections addObject:dict];
    
    dict = [NSMutableDictionary dictionary];
    [dict setObject:@"\\subsubsection" forKey:@"tag"];
    [sections addObject:dict];
    
    dict = [NSMutableDictionary dictionary];
    [dict setObject:@"\\paragraph" forKey:@"tag"];
    [sections addObject:dict];
    
    dict = [NSMutableDictionary dictionary];
    [dict setObject:@"\\subparagraph" forKey:@"tag"];
    [sections addObject:dict];
    
    dict = [NSMutableDictionary dictionary];
    [dict setObject:@"\\part" forKey:@"tag"];
    [sections addObject:dict];
    
  }
  
  return self;
}


- (void) addSectionsFromFile:(FileEntity*)file inProject:(ProjectEntity*)project
{
	NSCharacterSet *ws = [NSCharacterSet whitespaceCharacterSet];
	NSCharacterSet *ns = [NSCharacterSet newlineCharacterSet];
	
	NSMutableAttributedString *astring = [[[file document] textStorage] mutableCopy];
  //	[astring unfoldAll];
	
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
      
      //			NSLog(@"Checking word '%@'", word);
			// Get section, etc
			for (NSDictionary *secDict in sections) {
				NSString *sec = [secDict valueForKey:@"tag"];
				if ([word hasPrefix:sec]) {
          //					NSLog(@"Found word %@", word);
					NSString *tag = [NSString stringWithFormat:@"%@", word];
          
          
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
            TPDocumentSection *section = [TPDocumentSection sectionWithRange:lineRange 
                                                                      result:[string substringWithRange:tagRange] 
                                                                    document:file];
						
            [self.subsections addObject:section];
						
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
            [self addSectionsFromFile:nextFile inProject:project];
					}
				}				
			} // end recursive call to input/include			
		}
		loc++;
	}
  
}

- (NSString*)description
{
  return [NSString stringWithFormat:@"%@: %@, %@", self.result, self.range, self.subsections];
}

@end
