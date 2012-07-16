//
//  TPEngineSettingsController.h
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

@class MHStrokedFiledView;

@protocol TPEngineSettingsDelegate <NSObject>

-(void)didSelectDoBibtex:(BOOL)state;
-(void)didSelectDoPS2PDF:(BOOL)state;
-(void)didSelectOpenConsole:(BOOL)state;
-(void)didChangeNCompile:(NSInteger)number;
-(void)didSelectEngineName:(NSString*)aName;
-(void)didSelectLanguage:(NSString*)aName;

-(NSString*)engineName;
-(NSNumber*)doBibtex;
-(NSNumber*)doPS2PDF;
-(NSNumber*)openConsole;
-(NSNumber*)nCompile;

- (BOOL)supportsDoBibtex;
- (BOOL)supportsDoPS2PDF;
- (BOOL)supportsNCompile;

- (NSString*)language;

-(NSArray*)registeredEngineNames;

@end

@interface TPEngineSettingsController : NSViewController <TPEngineSettingsDelegate, NSTextFieldDelegate> {
@private
  IBOutlet NSPopUpButton *engineSelector;
  IBOutlet NSButton *doBibtexButton;
  IBOutlet NSButton *doPS2PDFButton;
  IBOutlet NSButton *openConsoleButton;
  IBOutlet NSTextField *nCompileTextField;
  IBOutlet NSStepper *nCompileStepper;
  IBOutlet NSTextField *nCompileLabel;
  IBOutlet NSPopUpButton *languageSelector;
  
  IBOutlet MHStrokedFiledView *pane1;
  IBOutlet MHStrokedFiledView *pane2;
  IBOutlet MHStrokedFiledView *pane3;
  IBOutlet MHStrokedFiledView *pane4;
  
  id<TPEngineSettingsDelegate> delegate;
}

@property (assign) id<TPEngineSettingsDelegate> delegate;

- (id) initWithDelegate:(id<TPEngineSettingsDelegate>)aDelegate;

- (void)setupEngineSettings;
- (IBAction)engineSelected:(id)sender;
- (IBAction)selectedDoBibtex:(id)sender;
- (IBAction)selectedDoPS2PDF:(id)sender;
- (IBAction)selectedOpenConsole:(id)sender;
- (IBAction)changeNCompile:(id)sender;

@end
