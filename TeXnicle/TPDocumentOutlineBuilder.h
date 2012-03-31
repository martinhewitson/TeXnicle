//
//  TPDocumentOutlineBuilder.h
//  TeXnicle
//
//  Created by Martin Hewitson on 04/01/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
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
//  DISCLAIMED. IN NO EVENT SHALL DAN WOOD, MIKE ABDULLAH OR KARELIA SOFTWARE BE LIABLE FOR ANY
//  DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//   LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
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
