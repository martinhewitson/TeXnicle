//
//  SyntaxHighlightControlController.h
//  TeXnicle
//
//  Created by Martin Hewitson on 18/12/10.
//  Copyright 2010 AEI Hannover . All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface SyntaxHighlightControlController : NSViewController {

	IBOutlet NSButton *activeButton;
	IBOutlet NSColorWell *colorWell;
	IBOutlet NSTextField *label;
	
	id delegate;
	
	NSString *bindingTag;
  NSString *name;
}

@property (nonatomic, readwrite, assign) id delegate;
@property (nonatomic, readwrite, copy) NSString *bindingTag;
@property (nonatomic, readwrite, copy) NSString *name;

- (id) initWithTag:(NSString*)aTag name:(NSString*)aName;
- (void) setupBindings;

- (IBAction) syntaxColorActiveChanged:(id)sender;

@end
