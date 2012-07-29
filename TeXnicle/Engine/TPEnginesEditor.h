//
//  TPEnginesEditor.h
//  TeXnicle
//
//  Created by Martin Hewitson on 27/08/11.
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
//  DISCLAIMED. IN NO EVENT SHALL MARTIN HEWITSON OR BOBSOFT SOFTWARE BE LIABLE FOR ANY
//  DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//   LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import <Cocoa/Cocoa.h>
#import "TPEngineManager.h"
#import "HHValidatedButton.h"

@interface TPEnginesEditor : NSViewController <NSUserInterfaceValidations, NSTableViewDataSource, NSTableViewDelegate, TPEngineManagerDelegate> {
@private
  TPEngineManager *engineManager;
  NSTableView *__unsafe_unretained tableView;
  HHValidatedButton *__unsafe_unretained editButton;
  HHValidatedButton *__unsafe_unretained duplicateButton;
  HHValidatedButton *__unsafe_unretained addEngineButton;
  HHValidatedButton *__unsafe_unretained deleteButton;
  HHValidatedButton *__unsafe_unretained revealButton;
}

@property (strong) TPEngineManager *engineManager;
@property (unsafe_unretained) IBOutlet NSTableView *tableView;

@property (unsafe_unretained) IBOutlet HHValidatedButton *editButton;
@property (unsafe_unretained) IBOutlet HHValidatedButton *duplicateButton;
@property (unsafe_unretained) IBOutlet HHValidatedButton *addEngineButton;
@property (unsafe_unretained) IBOutlet HHValidatedButton *deleteButton;
@property (unsafe_unretained) IBOutlet HHValidatedButton *revealButton;

- (TPEngine*)selectedEngine;
- (TPEngine*)engineAtRow:(NSInteger)aRow;

- (IBAction)editSelectedEngine:(id)sender;
- (IBAction)duplicateSelectedEngine:(id)sender;
- (IBAction)newEngine:(id)sender;
- (IBAction)deleteSelectedEngine:(id)sender;
- (IBAction)revealSelectedEngine:(id)sender;

- (void) selectEngineNamed:(NSString*)aName;


@end
