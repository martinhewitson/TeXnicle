//
//  TPOutlineView.h
//  TeXnicle
//
//  Created by Martin Hewitson on 30/1/10.
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
#import "ProjectItemTreeController.h"
#import "ESOutlineView.h"
#import "TeXProjectDocument.h"

@interface TPOutlineView : ESOutlineView {

  TeXProjectDocument *mainDocument;
	IBOutlet ProjectItemTreeController *treeController;
	ProjectItemEntity *selectedItem;
	NSUInteger selectedRow;
  BOOL dragLeftView;
  BOOL showMenu;
}

@property (assign) IBOutlet TeXProjectDocument *mainDocument;
@property (assign) BOOL dragLeftView;
@property (assign) BOOL showMenu;

- (void) setNeedsDisplay;

-(NSMenu*)defaultMenuForRow:(NSInteger)row;
- (NSMenu*)defaultMenu;

- (IBAction) addExistingFile:(id)sender;
- (IBAction) addExistingFileToSelectedFolder:(id)sender;

- (IBAction) revealItem:(id)sender;
- (IBAction) renameItem:(id)sender;
- (IBAction) removeItem:(id)sender;
- (IBAction) locateItem:(id)sender;

@end
