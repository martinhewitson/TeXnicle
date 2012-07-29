//
//  TPProjectTemplateCreator.h
//  TeXnicle
//
//  Created by Martin Hewitson on 14/02/12.
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
//  DISCLAIMED. IN NO EVENT SHALL MARTIN HEWITSON OR BOBSOFT SOFTWARE BE LIABLE FOR ANY
//  DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//   LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import <Cocoa/Cocoa.h>

@class TPOutlineView;
@class ProjectItemTreeController;
@class ProjectEntity;

@protocol TPProjectTemplateCreateDelegate <NSObject>

- (ProjectEntity*)project;
- (NSManagedObjectContext*)managedObjectContext;

@end

@interface TPProjectTemplateCreator : NSWindowController <NSWindowDelegate> {
@private
  id<TPProjectTemplateCreateDelegate> __unsafe_unretained delegate;
  NSManagedObjectContext *__unsafe_unretained managedObjectContext;
  TPOutlineView *__unsafe_unretained outlineView;
  ProjectItemTreeController *__unsafe_unretained treeController;
  NSTextField *__unsafe_unretained templateNameTextField;
  NSString *suggestedTemplateName;
  NSTextField *__unsafe_unretained templateDescriptionField;
  NSString *suggestedTemplateDescription;
}

@property (unsafe_unretained) id<TPProjectTemplateCreateDelegate> delegate;
@property (unsafe_unretained) NSManagedObjectContext *managedObjectContext;
@property (unsafe_unretained) IBOutlet TPOutlineView *outlineView;
@property (unsafe_unretained) IBOutlet ProjectItemTreeController *treeController;
@property (unsafe_unretained) IBOutlet NSTextField *templateNameTextField;
@property (copy) NSString *suggestedTemplateName;
@property (unsafe_unretained) IBOutlet NSTextField *templateDescriptionField;
@property (copy) NSString *suggestedTemplateDescription;

+ (NSString*) projectTemplatesDirectory;

- (id) initWithDelegate:(id<TPProjectTemplateCreateDelegate>)aDelegate;

- (void)setSuggestedTemplateName:(NSString*)aname;

- (IBAction)selectAllFiles:(id)sender;
- (IBAction)deselectAllFiles:(id)sender;

- (IBAction)cancelCreation:(id)sender;
- (IBAction)createTemplate:(id)sender;

- (void) createTemplateWithName:(NSString*)aName project:(ProjectEntity*)aProject;
- (void) overwriteAlertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo;

@end
