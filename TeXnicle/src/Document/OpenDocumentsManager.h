//
//  OpenDocumentsManager.h
//  TeXnicle
//
//  Created by Martin Hewitson on 12/3/10.
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
//  DISCLAIMED. IN NO EVENT SHALL MARTIN HEWITSON OR BOBSOFT SOFTWARE BE LIABLE FOR ANY
//  DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//   LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import <Cocoa/Cocoa.h>
#import "TeXEditorViewController.h"
#import "TPImageViewerController.h"
#import "MMTabBarView.h"

extern NSString * const TPOpenDocumentsDidChangeFileNotification;
extern NSString * const TPOpenDocumentsDidAddFileNotification;

@class FileEntity;
@class OpenDocument;
@class ProjectEntity;

@protocol OpenDocumentsManagerDelegate <NSObject>

-(ProjectEntity*)project;
-(void) openDocumentsManager:(id)aDocumentManager didSelectFile:(FileEntity*)aFile;

@end

@interface OpenDocumentsManager : NSResponder <MMTabBarViewDelegate> {

@private
  
  
}

@property (strong) NSMutableArray *openDocuments;
@property (strong) NSMutableArray *standaloneWindows;

@property (nonatomic, assign) BOOL isOpening;
@property (unsafe_unretained) IBOutlet NSView *navigationButtonsView;
@property (nonatomic, unsafe_unretained) FileEntity *currentDoc;

@property (unsafe_unretained) IBOutlet id<OpenDocumentsManagerDelegate> delegate;
@property (unsafe_unretained) IBOutlet NSTabView *tabView;
@property (unsafe_unretained) IBOutlet MMTabBarView *tabBar;
@property (unsafe_unretained) IBOutlet NSBox *tabBackground;

@property (unsafe_unretained) TeXEditorViewController *texEditorViewController;
@property (unsafe_unretained) TPImageViewerController *imageViewerController;
@property (unsafe_unretained) NSView *imageViewContainer;

- (NSInteger) count;
- (void) refreshTabForDocument:(FileEntity*)aDoc;
- (void) handleDocumentRenamed:(NSNotification*)aNote;
- (void)updateDoc;
- (void)setupViewerForDoc:(FileEntity*)aDoc;

- (void) selectTabForFile:(FileEntity*)aFile;

- (void) standaloneWindowForFile:(FileEntity*)aFile;
- (void)closeAllTabs;
- (void) disableEditors;
- (void) closeCurrentTab;
- (NSInteger) indexOfDocumentWithFile:(FileEntity*)aFile;
- (void) removeDocument:(FileEntity*)aDoc;
- (void) addAndSelectDocument:(FileEntity*)aDoc;
- (void) addDocument:(FileEntity*)aDoc select:(BOOL)selectTab;
- (void) disableTextView;
- (void) enableTextView;
- (void)enableImageView:(BOOL)state;
- (void) disableImageView;

- (void) setCursorAndScrollPositionForCurrentDoc;
- (void) saveCursorAndScrollPosition;
- (void) commitStatus;

- (void) setup;
- (void) tearDown;

@end


