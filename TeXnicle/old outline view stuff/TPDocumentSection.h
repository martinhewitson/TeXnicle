//
//  TPDocumentSection.h
//  TeXnicle
//
//  Created by Martin Hewitson on 25/7/11.
//  Copyright 2011 bobsoft. All rights reserved.
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
