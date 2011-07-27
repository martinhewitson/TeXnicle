//
//  TPDocumentSection.h
//  TeXnicle
//
//  Created by Martin Hewitson on 25/7/11.
//  Copyright 2011 AEI Hannover . All rights reserved.
//

#import <Foundation/Foundation.h>

@class FileEntity;
@class ProjectEntity;

@interface TPDocumentSection : NSObject {
  
	NSMutableArray *sections;
  
}

@property (copy) NSString *range;
@property (copy) NSString *result;
@property (assign) id document;
@property (retain) NSMutableArray *subsections;

+ (TPDocumentSection*)sectionWithRange:(NSRange)aRange result:(NSString*)aName document:(id)aDocument;
- (id)initWithRange:(NSRange)aRange result:(NSString*)aName document:(id)aDocument;
- (void) addSectionsFromFile:(FileEntity*)file inProject:(ProjectEntity*)project;

@end
