//
//  TPDocumentSection.h
//  TeXnicle
//
//  Created by Martin Hewitson on 25/7/11.
//  Copyright 2011 bobsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FileEntity;
@class ProjectEntity;
@class TPDocumentSectionTemplate;

@interface TPDocumentSection : NSObject {
@private
  NSRange range;
  TPDocumentSection *document;
  NSMutableArray *subsections;
  NSString *name;
  TPDocumentSectionTemplate *type;
}

@property (assign) NSRange range;
@property (assign) TPDocumentSectionTemplate *type;
@property (copy) NSString *name;
@property (assign) TPDocumentSection *document;
@property (retain) NSMutableArray *subsections;

+ (TPDocumentSection*)sectionWithRange:(NSRange)aRange type:(TPDocumentSectionTemplate*)aTemplate name:(NSString*)aName document:(id)aDocument;
- (id)initWithRange:(NSRange)aRange type:(TPDocumentSectionTemplate*)aTemplate name:(NSString*)aName document:(id)aDocument;
//- (void) addSectionsFromFile:(FileEntity*)file inProject:(ProjectEntity*)project;

- (void)addSubsection:(TPDocumentSection*)aSubsection;


@end
