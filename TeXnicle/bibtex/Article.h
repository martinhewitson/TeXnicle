//
//  Article.h
//  TeXnicle
//
//  Created by Martin Hewitson on 22/3/10.
//  Copyright 2010 AEI Hannover . All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BibliographyEntry.h"

@interface Article : BibliographyEntry <NSCoding, NSCopying> {

	NSString *journal;
	NSString *volume;
	NSString *number;
	NSString *pages;
	NSString *abstractText;
	
	
}

@property (readwrite, retain) NSString *journal;
@property (readwrite, retain) NSString *volume;
@property (readwrite, retain) NSString *number;
@property (readwrite, retain) NSString *pages;
@property (readwrite, retain) NSString *abstractText;

- (void)observeKeys;


@end
