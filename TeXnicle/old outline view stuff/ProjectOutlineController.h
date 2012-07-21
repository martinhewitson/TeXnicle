//
//  ProjectOutlineController.h
//  TeXnicle
//
//  Created by Martin Hewitson on 24/3/10.
//  Copyright 2010 bobsoft. All rights reserved.
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

#import <Cocoa/Cocoa.h>

@class ProjectEntity;
@class FileEntity;
@class TPDocumentSection;

@protocol ProjectOutlineControllerDelegate <NSObject>
@optional
- (ProjectEntity*)project;
- (NSNumber*)maxOutlineDepth;
- (NSURL*)fileURL;
- (NSAttributedString*)documentString;
- (void) highlightSearchResult:(NSString*)result withRange:(NSRange)aRange inFile:(id)aFile;
- (BOOL) shouldGenerateOutline;
@end

@interface ProjectOutlineController : NSWindowController <NSOutlineViewDelegate, NSOutlineViewDataSource> {

	NSTimer *timer;
	NSMutableArray *sections;
	NSMutableParagraphStyle *paragraphStyle;
	
//	TeXProjectDocument *projectDocument;
	IBOutlet NSTextView *textView;
	id<ProjectOutlineControllerDelegate> delegate;
	BOOL generating;
  
  IBOutlet NSOutlineView *outlineView;
  TPDocumentSection *section;
}

@property (nonatomic, retain) NSTimer *timer;
@property (assign) IBOutlet id<ProjectOutlineControllerDelegate> delegate;
@property (retain) TPDocumentSection *section;

- (void) generateTOC;
- (void) generateTOCForProject:(ProjectEntity*)project;
- (void) generateTOCForFileAtURL:(NSURL*)aURL;

//- (void) handleDocChanges:(NSNotification*)aNote;
- (NSMutableAttributedString*) addLinksTo:(NSMutableAttributedString*)aStr InFile:(id)aFile inProject:(ProjectEntity*)project;
- (NSMutableAttributedString*) addLinksTo:(NSMutableAttributedString*)aStr forString:(NSMutableAttributedString*)astring atURL:(NSURL*)aURL;
-(void) turnOffWrapping;
- (void) deactivate;

//- (void) reloadData;

@end
