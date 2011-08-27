//
//  TPEngineSettingsController.h
//  TeXnicle
//
//  Created by Martin Hewitson on 27/08/11.
//  Copyright 2011 bobsoft. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol TPEngineSettingsDelegate <NSObject>

-(void)didSelectDoBibtex:(BOOL)state;
-(void)didSelectDoPS2PDF:(BOOL)state;
-(void)didSelectOpenConsole:(BOOL)state;
-(void)didChangeNCompile:(NSInteger)number;
-(void)didSelectEngineName:(NSString*)aName;

-(NSString*)engineName;
-(NSNumber*)doBibtex;
-(NSNumber*)doPS2PDF;
-(NSNumber*)openConsole;
-(NSNumber*)nCompile;

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
