//
//  TechReport.h
//  TeXnicle
//
//  Created by Martin Hewitson on 3/4/10.
//  Copyright 2010 AEI Hannover . All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BibliographyEntry.h"

@interface TechReport : BibliographyEntry <NSCoding, NSCopying> {

	NSString *month;
	NSString *number;
	
}

@property (readwrite, retain) NSString *month;
@property (readwrite, retain) NSString *number;


@end
