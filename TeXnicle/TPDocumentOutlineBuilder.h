//
//  TPDocumentOutlineBuilder.h
//  TeXnicle
//
//  Created by Martin Hewitson on 04/01/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TPDocumentSectionTemplate.h"
#import "TPDocumentSection.h"

@protocol DocumentOutlineBuilderDelegate <NSObject>

- (ProjectEntity*)project;
- (NSURL*)fileURL;
- (NSAttributedString*)documentString;


@end
 
@interface TPDocumentOutlineBuilder : NSObject <DocumentOutlineBuilderDelegate> {
@private
  id<DocumentOutlineBuilderDelegate> delegate;
  NSMutableArray *templates;
}

@property (assign) id<DocumentOutlineBuilderDelegate> delegate;
@property (retain) NSMutableArray *templates;

+ (TPDocumentOutlineBuilder*)outlineBuilderWithDelegate:(id<DocumentOutlineBuilderDelegate>)aDelegate;
- (id)initWithDelegate:(id<DocumentOutlineBuilderDelegate>)aDelegate;
- (void) makeTemplates;

- (TPDocumentSection*) buildDocumentOutline;
- (TPDocumentSection*) generateSectionsForProject;
- (TPDocumentSection*) generateSectionsForFile;
- (void) addSectionsToSection:(TPDocumentSection*)section fromString:(NSString*)string forTemplate:(TPDocumentSectionTemplate*)aTemplate inRange:(NSRange)aRange;
- (TPDocumentSection*) parseSection:(TPDocumentSectionTemplate*)aTemplate fromString:(NSString*)string startingFrom:(NSInteger)loc;
- (NSString*)parseArgumentFromString:(NSString*)string startingAt:(NSInteger*)loc;
- (NSString*)consolidatedFileContentsForFile:(FileEntity*)aFile;
- (void) parseString:(NSString*)string forSection:(TPDocumentSection*)section followingSection:(TPDocumentSection*)nextSection startingOrder:(NSInteger)order;

@end
