//
//  TeXnicleAppController.m
//  TeXnicle
//
//  Created by hewitson on 26/5/11.
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

#import "TeXnicleAppController.h"
#import "externs.h"
#import "PrefsWindowController.h"
#import "NSArray+Color.h"
#import "ConsoleController.h"
#import "StartupScreenController.h"
#import "TeXProjectDocument.h"
#import "ProjectItemEntity.h"
#import "TeXFileEntity.h"
#import "MABSupportFolder.h"
#import "TPEngineManager.h"
#import "TPSupportedFile.h"
#import "TPProjectBuilder.h"
#import "TPProjectTemplateManager.h"
#import "TPProjectTemplateViewer.h"
#import "TPProjectTemplate.h"
#import "TPProjectTemplateListViewer.h"
#import "TPSyntaxChecker.h"

NSString * const TPDefaultEncoding = @"TPDefaultEncoding";

NSString * const TEDocumentTemplates = @"TEDocumentTemplates";

NSString * const TEUserCommands = @"TEUserCommands";
NSString * const TERefCommands = @"TERefCommands";;
NSString * const TECiteCommands = @"TECiteCommands";
NSString * const TEBeginCommands = @"TEBeginCommands";
NSString * const TEFileCommands = @"TEFileCommands";

NSString * const TEAutomaticallyShowCommandCompletionList = @"TEAutomaticallyShowCommandCompletionList";
NSString * const TEAutomaticallyShowCiteCompletionList = @"TEAutomaticallyShowCiteCompletionList";
NSString * const TEAutomaticallyShowRefCompletionList = @"TEAutomaticallyShowRefCompletionList";
NSString * const TEAutomaticallyShowFileCompletionList = @"TEAutomaticallyShowFileCompletionList";
NSString * const TEAutomaticallyShowBeginCompletionList = @"TEAutomaticallyShowBeginCompletionList";

NSString * const TEAutomaticallyAddEndToBeginStatement = @"TEAutomaticallyAddEndToBeginStatement";
NSString * const TEAutomaticallyInsertClosingBrace = @"TEAutomaticallyInsertClosingBrace";
NSString * const TEAutomaticallyReplaceOpeningDoubleQuote = @"TEAutomaticallyReplaceOpeningDoubleQuote";
NSString * const TEAutomaticallySkipClosingBrackets = @"TEAutomaticallySkipClosingBrackets";

NSString * const TPCheckSyntax = @"TPCheckSyntax";
NSString * const TPCheckSyntaxErrors = @"TPCheckSyntaxErrors";
NSString * const TPChkTeXpath = @"TPChkTeXpath";

NSString * const TPGSPath = @"TPGSPath";
NSString * const TPPDFLatexPath = @"TPPDFLatexPath";
NSString * const TPLatexPath = @"TPLatexPath";
NSString * const TPDvipsPath = @"TPDvipsPath";
NSString * const TPBibTeXPath = @"TPBibTeXPath";
NSString * const TPPS2PDFPath = @"TPPS2PDFPath";


NSString * const TPShouldRunPS2PDF = @"TPShouldRunPS2PDF";
NSString * const TPNRunsPDFLatex = @"TPNRunsPDFLatex";
NSString * const BibTeXDuringTypeset = @"BibTeXDuringTypeset";
NSString * const TPDefaultEngineName = @"TPDefaultEngineName";
NSString * const OpenConsoleOnTypeset = @"OpenConsoleOnTypeset";


NSString * const TPTrashFiles = @"TPTrashFiles";
NSString * const TPTrashDocumentFileWhenTrashing = @"TPTrashDocumentFileWhenTrashing";
NSString * const TPSpellCheckerLanguage = @"TPSpellCheckerLanguage";
NSString * const TPRestoreOpenTabs = @"TPRestoreOpenTabs";
NSString * const TPConsoleDisplayLevel = @"TPConsoleDisplayLevel";

NSString * const TPFileItemTextStorageChangedNotification = @"TPFileItemTextStorageChangedNotification";
NSString * const TPBookmarkDidUpdateNotification = @"TPBookmarkDidUpdateNotification";

NSString * const TECursorPositionDidChangeNotification = @"TECursorPositionDidChangeNotification";
NSString * const TELineWrapStyle = @"TELineWrapStyle";
NSString * const TELineLength = @"TELineLength";
NSString * const TEInsertSpacesForTabs = @"TEInsertSpacesForTabs";
NSString * const TENumSpacesForTab = @"TENumSpacesForTab";
NSString * const TEShowLineNumbers = @"TEShowLineNumbers";
NSString * const TEShowCodeFolders = @"TEShowCodeFolders";
NSString * const TEHighlightCurrentLine = @"TEHighlightCurrentLine";
NSString * const TEHighlightCurrentLineColor = @"TEHighlightCurrentLineColor";
NSString * const TEHighlightMatchingWords = @"TEHighlightMatchingWords"; 
NSString * const TEHighlightMatchingWordsColor = @"TEHighlightMatchingWordsColor";
NSString * const TESelectedTextColor = @"TESelectedTextColor";
NSString * const TESelectedTextBackgroundColor = @"TESelectedTextBackgroundColor";

NSString * const TPSaveOnCompile = @"TPSaveOnCompile";
NSString * const TPClearConsoleOnCompile = @"TPClearConsoleOnCompile";


NSString * const TEDocumentBackgroundColor = @"TEDocumentBackgroundColor";
NSString * const TEDocumentFont = @"TEDocumentFont";
NSString * const TESyntaxTextColor = @"TESyntaxTextColor";

NSString * const TEConsoleFont = @"TEConsoleFont";

// comment
NSString * const TESyntaxCommentsColor = @"TESyntaxCommentsColor";
NSString * const TESyntaxCommentsL2Color = @"TESyntaxCommentsL2Color";
NSString * const TESyntaxCommentsL3Color = @"TESyntaxCommentsL3Color";
NSString * const TESyntaxColorComments = @"TESyntaxColorComments";
NSString * const TESyntaxColorCommentsL2 = @"TESyntaxColorCommentsL2";
NSString * const TESyntaxColorCommentsL3 = @"TESyntaxColorCommentsL3";
NSString * const TESyntaxColorMultilineArguments = @"TESyntaxColorMultilineArguments";

// markup
NSString * const TESyntaxMarkupL1Color = @"TESyntaxMarkupL1Color";
NSString * const TESyntaxMarkupL2Color = @"TESyntaxMarkupL2Color";
NSString * const TESyntaxMarkupL3Color = @"TESyntaxMarkupL3Color";
NSString * const TESyntaxColorMarkupL1 = @"TESyntaxColorMarkupL1";
NSString * const TESyntaxColorMarkupL2 = @"TESyntaxColorMarkupL2";
NSString * const TESyntaxColorMarkupL3 = @"TESyntaxColorMarkupL3";

// special chars
NSString * const TESyntaxSpecialCharsColor = @"TESyntaxSpecialCharsColor";
NSString * const TESyntaxColorSpecialChars = @"TESyntaxColorSpecialChars";

// dollar chars
NSString * const TESyntaxDollarCharsColor = @"TESyntaxDollarCharsColor";
NSString * const TESyntaxColorDollarChars = @"TESyntaxColorDollarChars";

// commands
NSString * const TESyntaxCommandColor = @"TESyntaxCommandColor";
NSString * const TESyntaxColorCommand = @"TESyntaxColorCommand";

// arguments
NSString * const TESyntaxArgumentsColor = @"TESyntaxArgumentsColor";
NSString * const TESyntaxColorArguments = @"TESyntaxColorArguments";

NSString * const TPPaletteRowHeight = @"TPPaletteRowHeight";
NSString * const TPLibraryRowHeight = @"TPLibraryRowHeight";

NSString * const TPSupportedFileTypes = @"TPSupportedFileTypes";

NSString * const TPLiveUpdateFrequency = @"TPLiveUpdateFrequency";

@implementation TeXnicleAppController

@synthesize openStartupScreenAtAppStartup;

+ (void) initialize
{
  // create a dictionary for the ‘factory’ defaults
	NSMutableDictionary *defaultValues = [NSMutableDictionary dictionary];
  
  // load library
  NSString *libpath = [[NSBundle mainBundle] pathForResource:@"Library" ofType:@"plist"];
	NSDictionary *library = [NSMutableDictionary dictionaryWithContentsOfFile:libpath];
	[defaultValues setObject:library forKey:@"Library"];
  
  // get the templates from the app bundle plist
	NSString *path = [[NSBundle mainBundle] pathForResource:@"Templates" ofType:@"plist"];
	NSDictionary *templateDictionary = [NSMutableDictionary dictionaryWithContentsOfFile:path];
	NSMutableArray *templates = [NSMutableArray array];
	for (NSDictionary *dict in [templateDictionary valueForKey:@"Templates"]) {
		[templates addObject:[NSMutableDictionary dictionaryWithDictionary:dict]];
	}
	[defaultValues setObject:templates forKey:TEDocumentTemplates];

  // user commands
  [defaultValues setObject:[NSMutableArray array] forKey:TEUserCommands];
  
  // ref commands
  NSMutableArray *refCommands = [NSMutableArray array];
  [refCommands addObject:@"\\ref"];
  [refCommands addObject:@"\\eqref"];
  [defaultValues setObject:refCommands forKey:TERefCommands];
  
  // cite commands
  NSMutableArray *citeCommands = [NSMutableArray array];
  [citeCommands addObject:@"\\cite"];
  [defaultValues setObject:citeCommands forKey:TECiteCommands];
  
  // begin commands
  NSMutableArray *beginCommands = [NSMutableArray array];
	[beginCommands addObject:@"enumerate"];
	[beginCommands addObject:@"array"];
	[beginCommands addObject:@"matrix"];
	[beginCommands addObject:@"itemize"];
	[beginCommands addObject:@"eqnarray"];
	[beginCommands addObject:@"description"];
	[beginCommands addObject:@"quotation"];
	[beginCommands addObject:@"quote"];
	[beginCommands addObject:@"verbatim"];
	[beginCommands addObject:@"verse"];
	[beginCommands addObject:@"table"];
	[beginCommands addObject:@"tabular"];
	[beginCommands addObject:@"center"];
	[beginCommands addObject:@"figure"];
	[beginCommands addObject:@"table"];
  [defaultValues setObject:beginCommands forKey:TEBeginCommands];
  
  // completion stuff
  [defaultValues setObject:[NSNumber numberWithBool:YES] forKey:TEAutomaticallyAddEndToBeginStatement];
  [defaultValues setObject:[NSNumber numberWithBool:YES] forKey:TEAutomaticallyInsertClosingBrace];
  [defaultValues setObject:[NSNumber numberWithBool:YES] forKey:TEAutomaticallyShowCommandCompletionList];
  [defaultValues setObject:[NSNumber numberWithBool:YES] forKey:TEAutomaticallyShowCiteCompletionList];
  [defaultValues setObject:[NSNumber numberWithBool:YES] forKey:TEAutomaticallyShowRefCompletionList];
  [defaultValues setObject:[NSNumber numberWithBool:YES] forKey:TEAutomaticallyShowFileCompletionList];
  [defaultValues setObject:[NSNumber numberWithBool:YES] forKey:TEAutomaticallyShowBeginCompletionList];
  [defaultValues setObject:[NSNumber numberWithBool:YES] forKey:TEAutomaticallyReplaceOpeningDoubleQuote];
  [defaultValues setObject:[NSNumber numberWithBool:YES] forKey:TEAutomaticallySkipClosingBrackets];
  
  // check syntax
  [defaultValues setObject:[NSNumber numberWithBool:YES] forKey:TPCheckSyntax];
  [defaultValues setObject:[TPSyntaxChecker defaultSyntaxErrors] forKey:TPCheckSyntaxErrors];
  [defaultValues setObject:@"/usr/texbin/chktex" forKey:TPChkTeXpath];
  
  // file commands
  NSMutableArray *fileCommands = [NSMutableArray array];
	[fileCommands addObject:@"\\input"];
  [fileCommands addObject:@"\\include"];
  [defaultValues setObject:fileCommands forKey:TEFileCommands];
  
	// Document settings	
	[defaultValues setValue:[NSNumber numberWithInt:TPHardWrap] forKey:TELineWrapStyle];
	[defaultValues setValue:[NSNumber numberWithInt:80] forKey:TELineLength];
	
	[defaultValues setValue:[NSNumber numberWithBool:YES] forKey:TEInsertSpacesForTabs];
	[defaultValues setValue:[NSNumber numberWithInt:2] forKey:TENumSpacesForTab];
	
	[defaultValues setValue:[NSNumber numberWithBool:YES] forKey:TEShowLineNumbers];
	[defaultValues setValue:[NSNumber numberWithBool:NO] forKey:TEShowCodeFolders];
  
  [defaultValues setValue:[NSNumber numberWithBool:YES] forKey:TPRestoreOpenTabs];
  
	[defaultValues setValue:[NSNumber numberWithBool:YES] forKey:TEHighlightCurrentLine];
  [defaultValues setValue:[NSArray arrayWithColor:[NSColor colorWithDeviceWhite:0.95 alpha:1.0]] forKey:TEHighlightCurrentLineColor];

	[defaultValues setValue:[NSNumber numberWithBool:YES] forKey:TEHighlightMatchingWords];
  [defaultValues setValue:[NSArray arrayWithColor:[[NSColor selectedTextBackgroundColor] highlightWithLevel:0.6]] forKey:TEHighlightMatchingWordsColor];
  
  [defaultValues setValue:[NSArray arrayWithColor:[NSColor selectedTextBackgroundColor]] forKey:TESelectedTextBackgroundColor];
  [defaultValues setValue:[NSArray arrayWithColor:[NSColor selectedTextColor]] forKey:TESelectedTextColor];
  
  [defaultValues setValue:[NSNumber numberWithBool:YES] forKey:TPSaveOnCompile];
  [defaultValues setValue:[NSNumber numberWithBool:YES] forKey:TPClearConsoleOnCompile];
	[defaultValues setObject:[NSNumber numberWithBool:YES] forKey:OpenConsoleOnTypeset];

  // console
  [defaultValues setObject:[NSArchiver archivedDataWithRootObject:[NSFont userFixedPitchFontOfSize:12.0]] forKey:TEConsoleFont];  
	
	//--- colors for syntax highlighting
	
  // default text
  [defaultValues setObject:[NSArchiver archivedDataWithRootObject:[NSFont systemFontOfSize:14.0]] forKey:TEDocumentFont];  
	[defaultValues setValue:[NSArray arrayWithColor:[NSColor blackColor]] forKey:TESyntaxTextColor];
  [defaultValues setValue:[NSArray arrayWithColor:[NSColor whiteColor]] forKey:TEDocumentBackgroundColor];
  
  // comments
	[defaultValues setValue:[NSArray arrayWithColor:[NSColor colorWithDeviceWhite:0.4 alpha:1.0]] forKey:TESyntaxCommentsColor];
	[defaultValues setValue:[NSArray arrayWithColor:[NSColor colorWithDeviceWhite:0.6 alpha:1.0]] forKey:TESyntaxCommentsL2Color];
	[defaultValues setValue:[NSArray arrayWithColor:[NSColor colorWithDeviceWhite:0.8 alpha:1.0]] forKey:TESyntaxCommentsL3Color];
	[defaultValues setValue:[NSNumber numberWithBool:YES] forKey:TESyntaxColorComments];
	[defaultValues setValue:[NSNumber numberWithBool:NO] forKey:TESyntaxColorCommentsL2];
	[defaultValues setValue:[NSNumber numberWithBool:NO] forKey:TESyntaxColorCommentsL3];
	[defaultValues setValue:[NSNumber numberWithBool:NO] forKey:TESyntaxColorMultilineArguments];
  
  // markup
	[defaultValues setValue:[NSArray arrayWithColor:[NSColor colorWithDeviceRed:1.0 green:0.1 blue:0.1 alpha:1.0]] forKey:TESyntaxMarkupL1Color];
	[defaultValues setValue:[NSArray arrayWithColor:[NSColor colorWithDeviceRed:0.8 green:0.1 blue:0.1 alpha:1.0]] forKey:TESyntaxMarkupL2Color];
	[defaultValues setValue:[NSArray arrayWithColor:[NSColor colorWithDeviceRed:0.5 green:0.1 blue:0.1 alpha:1.0]] forKey:TESyntaxMarkupL3Color];
	[defaultValues setValue:[NSNumber numberWithBool:NO] forKey:TESyntaxColorMarkupL1];
	[defaultValues setValue:[NSNumber numberWithBool:NO] forKey:TESyntaxColorMarkupL2];
	[defaultValues setValue:[NSNumber numberWithBool:NO] forKey:TESyntaxColorMarkupL3];
  
  // special chars
	[defaultValues setValue:[NSArray arrayWithColor:[NSColor colorWithDeviceRed:50.0/255.0 green:35.0/255.0 blue:1.0 alpha:1.0]] forKey:TESyntaxSpecialCharsColor];
	[defaultValues setValue:[NSNumber numberWithBool:YES] forKey:TESyntaxColorSpecialChars];
  
  // dollar chars
	[defaultValues setValue:[NSArray arrayWithColor:[NSColor redColor]] forKey:TESyntaxDollarCharsColor];
	[defaultValues setValue:[NSNumber numberWithBool:YES] forKey:TESyntaxColorDollarChars];
  
  // commands
	[defaultValues setValue:[NSArray arrayWithColor:[NSColor colorWithDeviceRed:25.0/255.0 green:20.0/255.0 blue:150.0/255.0 alpha:1.0]] forKey:TESyntaxCommandColor];
	[defaultValues setValue:[NSNumber numberWithBool:YES] forKey:TESyntaxColorCommand];
  
  // arguments
	[defaultValues setValue:[NSArray arrayWithColor:[NSColor colorWithDeviceRed:0.0/255.0 green:100.0/255.0 blue:185.0/255.0 alpha:1.0]] forKey:TESyntaxArgumentsColor];
	[defaultValues setValue:[NSNumber numberWithBool:YES] forKey:TESyntaxColorArguments];
	
  //---------- Paths
	// GS
	[defaultValues setObject:@"/usr/local/bin/gs" forKey:TPGSPath];
	
	// PDFLatex
	[defaultValues setObject:@"/usr/texbin/pdflatex" forKey:TPPDFLatexPath];
	
	// Latex
	[defaultValues setObject:@"/usr/texbin/latex" forKey:TPLatexPath];
	
	// dvips
	[defaultValues setObject:@"/usr/texbin/dvips" forKey:TPDvipsPath];
	
	// BibTeX path
	[defaultValues setObject:@"/usr/texbin/bibtex" forKey:TPBibTeXPath];
	
	// ps2pdf path
	[defaultValues setObject:@"" forKey:TPPS2PDFPath];
  
	// Number of times to run pdflatex
	[defaultValues setValue:[NSNumber numberWithUnsignedInt:3] forKey:TPNRunsPDFLatex];
	
	// BibTeX during typeset
	[defaultValues setObject:[NSNumber numberWithBool:YES] forKey:BibTeXDuringTypeset];
	
	// Run ps2pdf after typeset
	[defaultValues setObject:[NSNumber numberWithBool:YES] forKey:TPShouldRunPS2PDF];
  
  // Default engine name
  [defaultValues setObject:@"pdflatex" forKey:TPDefaultEngineName];
  
	// --------- Trash
	NSArray *files = [NSArray arrayWithObjects:@"aux", @"log", @"bbl", @"out", nil];
	[defaultValues setObject:files forKey:TPTrashFiles];
	[defaultValues setObject:[NSNumber numberWithBool:YES] forKey:TPTrashDocumentFileWhenTrashing];
  
	//---------- Console settings
	[defaultValues setValue:[NSNumber numberWithInt:0] forKey:TPConsoleDisplayLevel];	
	
	
	//---------- Hidden settings
	[defaultValues setValue:@"" forKey:TPSpellCheckerLanguage];
  [defaultValues setValue:[NSNumber numberWithFloat:15.0] forKey:TPPaletteRowHeight];
  [defaultValues setValue:[NSNumber numberWithFloat:25.0] forKey:TPLibraryRowHeight];
  
  //---------- Supported File Types
  NSMutableArray *supportedTypes = [NSMutableArray array];
  // tex
  TPSupportedFile *file;
  file = [TPSupportedFile supportedFileWithName:@"TeX Files" extension:@"tex" isBuiltIn:YES syntaxHighlight:YES];
  [supportedTypes addObject: file];

  // bib
  file = [TPSupportedFile supportedFileWithName:@"BiBTeX Files" extension:@"bib" isBuiltIn:YES syntaxHighlight:YES];
  [supportedTypes addObject:file];

  // sty
  file = [TPSupportedFile supportedFileWithName:@"LaTeX Style Files" extension:@"sty" isBuiltIn:YES syntaxHighlight:YES];
  [supportedTypes addObject:file];

  // cls
  file = [TPSupportedFile supportedFileWithName:@"LaTeX Class Files" extension:@"cls" isBuiltIn:YES syntaxHighlight:YES];
  [supportedTypes addObject:file];
  
  // bst
  file = [TPSupportedFile supportedFileWithName:@"BiBTeX Style Files" extension:@"bst" isBuiltIn:YES syntaxHighlight:YES];
  [supportedTypes addObject:file];
  [defaultValues setValue:[NSKeyedArchiver archivedDataWithRootObject:supportedTypes] forKey:TPSupportedFileTypes];
  
  // default encoding
  [defaultValues setValue:@"Unicode (UTF-8)" forKey:TPDefaultEncoding];
  
  // live update frequency
  [defaultValues setValue:[NSNumber numberWithFloat:1.0] forKey:TPLiveUpdateFrequency];
  
  // register the defaults
	[[NSUserDefaults standardUserDefaults] registerDefaults:defaultValues];	
	[[NSUserDefaults standardUserDefaults] synchronize];
  

}


- (id)init
{
//  NSLog(@"App delegate init");
  self = [super init];
  if (self) {
    // Initialization code here.
    self.openStartupScreenAtAppStartup = YES;
  }
  
  return self;
}

- (void)dealloc
{
  [super dealloc];
}

- (void)applicationWillTerminate:(NSNotification *)notification
{
	// store the language
	NSString *language = [[NSSpellChecker sharedSpellChecker] language];	
	[[NSUserDefaults standardUserDefaults] setValue:language forKey:TPSpellCheckerLanguage];
	[[NSUserDefaults standardUserDefaults] synchronize];
  //	NSLog(@"Stored language to defaults: %@", language);
	
}

- (void)applicationWillFinishLaunching:(NSNotification *)aNotification
{
  
  // set default
  lineToOpen = NSNotFound;
  
	// set spell checker language
	NSString *language = [[NSUserDefaults standardUserDefaults] valueForKey:TPSpellCheckerLanguage];
	if (![language isEqualToString:@""]) {
		[[NSSpellChecker sharedSpellChecker] setLanguage:language];
	}
  
  // install templates
  [TPProjectTemplateManager installBundleTemplates];
}

- (BOOL)application:(NSApplication *)theApplication openFile:(NSString *)filename
{
//  NSLog(@"Application open file %@", filename);
	NSError *error = nil;
  
  
  TeXProjectDocument *doc = [[NSDocumentController sharedDocumentController] openDocumentWithContentsOfURL:[NSURL fileURLWithPath:filename]
                                                                                  display:YES
                                                                                    error:&error];
	if (doc) {

    NSArray *args = [[NSProcessInfo processInfo] arguments];
    
    if ([args count] == 4) {
      NSString *tag = [args objectAtIndex:2];
      if ([tag isEqualToString:@"-line"]) {
        lineToOpen = [[args objectAtIndex:3] integerValue];
      }    
    }
        
    if (lineToOpen != NSNotFound) {
      [doc.texEditorViewController.textView performSelector:@selector(goToLineWithNumber:) 
                                                 withObject:[NSNumber numberWithInteger:lineToOpen] 
                                                 afterDelay:1];
    }
		return YES;
	}
	
	return NO;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
  [self checkVersion];
  [TPEngineManager installEngines];
  
	id controller = [self startupScreen];
	NSArray *recentURLs = [[NSDocumentController sharedDocumentController] recentDocumentURLs];
	for (NSURL *url in recentURLs) {
    if (![[url pathExtension] isEqualToString:@"engine"]) {
      NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObject:[[url path] lastPathComponent]
                                                                     forKey:@"path"];
      [dict setObject:url forKey:@"url"];
      [[controller recentFiles] addObject:dict];
    }
	}
  
  if (self.openStartupScreenAtAppStartup) {
    if ([[[NSDocumentController sharedDocumentController] documents] count]==0) {
      [self showStartupScreen:self];
    }
  }
  
//  NSLog(@"App finished launching");
}

- (void) checkVersion
{
  NSError *error = nil;
  NSString *html = @"http://www.bobsoft-mac.de/resources/TeXnicle/latestversion.txt";
  NSURL *url = [NSURL URLWithString:html];
  NSString *latest = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];
  
  NSArray *parts = [latest componentsSeparatedByString:@" "];
  CGFloat latestVersion = [[parts objectAtIndex:0] floatValue];
  CGFloat latestBuild = [[parts objectAtIndex:1] floatValue];
  
//  NSLog(@"Latest ver %f, build %f", latestVersion, latestBuild);
  
  // get values from main bundle
  
	NSDictionary *dict = [[NSBundle mainBundle] infoDictionary];
  CGFloat currentBuild = [[dict valueForKey:@"CFBundleVersion"] floatValue];
  CGFloat currentVersion = [[dict valueForKey:@"CFBundleShortVersionString"] floatValue];
  
//  NSLog(@"Current %f, %f", currentVersion, currentBuild);
  
  if (latestVersion > currentVersion || (latestVersion == currentVersion && latestBuild > currentBuild)) {
    NSAlert *alert = [NSAlert alertWithMessageText:@"New version available"
                                     defaultButton:@"Download Now"
                                   alternateButton:@"Download Later"
                                       otherButton:nil
                         informativeTextWithFormat:@"Version %0.1f build %0.1f of TeXnicle is available for download", latestVersion, latestBuild];
    NSInteger result = [alert runModal];
    if (result == NSAlertDefaultReturn) {
      [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://www.bobsoft-mac.de"]];
    } else if (result == NSAlertAlternateReturn) {
      // do nothing
    }
  }
}

                      
- (id)startupScreen
{
	if (!startupScreenController) {
		startupScreenController = [[StartupScreenController alloc] init];
	}
	return startupScreenController;
}

- (BOOL)applicationShouldOpenUntitledFile:(NSApplication *)sender
{
	return NO;
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication
{
	return NO;
}

- (void) applicationWillResignActive:(NSNotification *)notification
{
  for (id doc in [[NSDocumentController sharedDocumentController] documents]) {
    [[[doc windowForSheet] contentView] setNeedsDisplay:YES];
  }
}

- (IBAction)showPreferences:(id)sender
{
	[[PrefsWindowController sharedPrefsWindowController] showWindow:nil];
}

- (IBAction) showConsole:(id)sender
{
	ConsoleController *consoleController = [ConsoleController sharedConsoleController];
	[consoleController showWindow:self];
	[[consoleController window] makeKeyAndOrderFront:self];
}

- (IBAction) showStartupScreen:(id)sender
{
	if (!startupScreenController) {
		startupScreenController = [[StartupScreenController alloc] init];
	}
	
	[startupScreenController displayWindow:self];
	//	[startupScreenController showWindow:self];
	//	[[startupScreenController window] makeKeyAndOrderFront:self];
}

#pragma mark -
#pragma mark Document Control 

- (IBAction)createProjectFromTemplate:(id)sender
{
  // make template list viewer
  TPProjectTemplateListViewer *viewer = [[[TPProjectTemplateListViewer alloc] init] autorelease];
  [NSApp runModalForWindow:viewer.window];  
}

- (IBAction) newEmptyProject:(id)sender
{
  id doc = [TeXProjectDocument createNewTeXnicleProject];
  
	if (doc) {
		[doc saveDocument:self];
	}
}

- (IBAction) newArticleDocument:(id)sender
{
  id doc = [TeXProjectDocument createNewTeXnicleProject];
  
	// Check if a document was opened
	if (doc) {
		// Add a new main TeX file to the doc
		if ([doc respondsToSelector:@selector(addNewArticleMainFile)]) {
			[doc performSelector:@selector(addNewArticleMainFile)];
      [doc performSelector:@selector(saveDocument:) withObject:self];
		}
	}
}

- (IBAction) newLaTeXFile:(id)sender
{
	
	NSError *error = nil;
  
	id doc = [[NSDocumentController sharedDocumentController] makeUntitledDocumentOfType:@"TeX Document" error:&error];
	if (doc == nil) {
		[NSApp presentError:error];
		return;
	}
	
	[[NSDocumentController sharedDocumentController] addDocument:doc];
	[doc makeWindowControllers];
	[doc showWindows];
	
	if ([[self startupScreen] isOpen]) {
		[[self startupScreen] displayOrCloseWindow:self];
	}

}

- (IBAction)buildProject:(id)sender 
{
  // get a project director or file from the user  
  NSOpenPanel *panel = [NSOpenPanel openPanel];
  [panel setTitle:@"Build New Project..."];
  [panel setAllowedFileTypes:[NSArray arrayWithObject:@"trip"]];
  [panel setNameFieldLabel:@"Source:"];
  [panel setCanChooseFiles:YES];
  [panel setCanChooseDirectories:YES];
  [panel setCanCreateDirectories:NO];
  [panel setMessage:@"Choose a main TeX file (one containing \\documentclass) or a directory of TeX files. \nIf a directory is chosen, the first TeX file containing \\documentclass is taken as the main file."];
  [panel setAllowedFileTypes:[NSArray arrayWithObjects:@"tex", NSFileTypeDirectory, nil]];
  
  BOOL result = [panel runModal];
  
  if (result == NSFileHandlingPanelCancelButton) {
    return;
  }
  
  
  NSString *path = [[[panel URLs] objectAtIndex:0] path];
  NSFileManager *fm = [NSFileManager defaultManager];
  NSError *error =nil;
  NSDictionary *atts = [fm attributesOfItemAtPath:path error:&error];
  if (atts == nil) {
    [NSApp presentError:error];
    return;
  }
  TPProjectBuilder *pb = nil;
  if ([atts fileType] == NSFileTypeDirectory) {
    pb = [TPProjectBuilder builderWithDirectory:path];
  } else {
    pb = [TPProjectBuilder builderWithMainfile:path];
  }
  
  // check if the project already exists and ask the user if they want to overwrite it
  // Remove file if it is there
  NSString *docpath = [pb.projectFileURL path];
  if ([fm fileExistsAtPath:docpath]) {
    
    NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
    [formatter setDateFormat:@".yyyy_MM_dd_HH_mm_ss"];
    NSString *movedPath = [docpath stringByAppendingFormat:@"%@", [formatter stringFromDate:[NSDate date]]];
    
    NSAlert *alert = [NSAlert alertWithMessageText:@"A TeXnicle Project Already Exists"
                                     defaultButton:@"Continue"
                                   alternateButton:@"Cancel"
                                       otherButton:nil
                         informativeTextWithFormat:@"A project file called %@ already exists in %@.\nIf you continue, the exiting project file will be moved to:\n%@.", [docpath lastPathComponent], [docpath stringByDeletingLastPathComponent], [movedPath lastPathComponent]];
    
    NSInteger result = [alert runModal];
    
    if (result == NSAlertAlternateReturn) {
      return;
    }
    
    NSError *moveError = nil;
    [fm moveItemAtPath:docpath toPath:movedPath error:&moveError];
    if (moveError) {
      [NSApp presentError:moveError];
      return;
    }
  }
  
  [TeXProjectDocument createTeXnicleProjectAtURL:pb.projectFileURL];
  NSError *openError = nil;
  TeXProjectDocument *doc = [[NSDocumentController sharedDocumentController] openDocumentWithContentsOfURL:pb.projectFileURL display:YES error:&openError];
  if (openError) {
    [NSApp presentError:openError];
    return;
  }  
  
  [pb populateDocument:doc];  
}

#pragma mark -
#pragma mark Menu Control 

- (void)menuNeedsUpdate:(NSMenu *)menu
{
//  NSLog(@"Menu update");
	id doc = nil;
	if ([NSDocumentController sharedDocumentController]) {
		doc = [[NSDocumentController sharedDocumentController] currentDocument];
	}
	
	if ([[menu title] isEqual:@"Project"]) {
		
		
		//	// Close and Close Tab
		//	NSMenuItem *closeMenuItem = [menu itemWithTag:100];
		//	NSMenuItem *closeTabMenuItem = [menu itemWithTag:110];
		//	
		//
		//		NSLog(@"Current window %@", [[NSApplication sharedApplication] keyWindow]);
		//	
		
		// New Folder menu item
		NSMenuItem *newFolderItem = [menu itemWithTag:10];
		if (newFolderItem) {
			[newFolderItem setEnabled:NO];
			if (doc) {
				if ([doc respondsToSelector:@selector(canAddNewFolder)]) {
					if ([doc performSelector:@selector(canAddNewFolder)]) {
						[newFolderItem setEnabled:YES];
					}
				}
			}
		}
		
		// New File menu item
		NSMenuItem *newFileItem = [menu itemWithTag:15];
		if (newFileItem) {
			[newFileItem setEnabled:NO];
			if (doc) {
				if ([doc respondsToSelector:@selector(canAddNewFile)]) {
					if ([doc performSelector:@selector(canAddNewFile)]) {
						[newFileItem setEnabled:YES];
					}
				}
			}
		}
		
		// New TeX File menu item
		NSMenuItem *newTeXFileMenu = [menu itemWithTag:20];
		if (newTeXFileMenu) {
			[newTeXFileMenu setEnabled:NO];
			if (doc) {
				if ([doc respondsToSelector:@selector(canAddNewTeXFile)]) {
					if ([doc performSelector:@selector(canAddNewTeXFile)]) {
						[newTeXFileMenu setEnabled:YES];
					}
				}
			}
		}
		
		// Delete menu item
		NSMenuItem *deleteMenu = [menu itemWithTag:30];
		if (deleteMenu) {
			[deleteMenu setEnabled:NO];
			if (doc) {
				if ([doc respondsToSelector:@selector(canRemove)]) {
					if ([doc canRemove]) {
						[deleteMenu setEnabled:YES];
						[deleteMenu setTitle:[NSString stringWithFormat:@"Remove \u201c%@\u201d", [doc performSelector:@selector(nameOfSelectedProjectItem)]]];
					}
				}
			}
		}
		
		// Open project folder
		NSMenuItem *openProjectFolderItem = [menu itemWithTag:21];
		if (openProjectFolderItem) {
			[openProjectFolderItem setEnabled:NO];
			if (doc) {
				if ([doc respondsToSelector:@selector(project)]) {
					[openProjectFolderItem setEnabled:YES];
				}
			}
		}
		
		// Open project TOC
		NSMenuItem *projectTocItem = [menu itemWithTag:22];
		if (projectTocItem) {
			[projectTocItem setEnabled:NO];
			if (doc) {
				if ([doc isKindOfClass:[TeXProjectDocument class]]) {
					[projectTocItem setEnabled:YES];
				}
			}
		}
		
		// Set Main File item
		NSMenuItem *setMainItem = [menu itemWithTag:25];
		if (setMainItem) {
			[setMainItem setTitle:@"Set Main File"];
			[setMainItem setEnabled:NO];
			if (doc) {
				if ([doc respondsToSelector:@selector(getSelectedItems)]) {
					NSArray *items = [doc performSelector:@selector(getSelectedItems)];
					if ([items count] == 1) {
						ProjectItemEntity *item = [items objectAtIndex:0];
						if ([item isKindOfClass:[FileEntity class]]) {
              
              NSArray *exts = [[TPSupportedFilesManager sharedSupportedFilesManager] supportedExtensions];
              
							if ([exts containsObject:[item valueForKey:@"extension"]]) {
								[setMainItem setEnabled:YES];
								if ([[doc project] valueForKey:@"mainFile"] == item) {
									[setMainItem setTitle:[NSString stringWithFormat:@"Unset \u201c%@\u201d As Main File", [item valueForKey:@"name"]]];
								} else {
									[setMainItem setTitle:[NSString stringWithFormat:@"Set \u201c%@\u201d As Main File", [item valueForKey:@"name"]]];
								}
							}
						}
					}
				}
			}
		}
		
		// Jump to main file
		NSMenuItem *jumpToMainItem = [menu itemWithTag:26];
		if (jumpToMainItem) {
			[jumpToMainItem setEnabled:NO];
			if (doc) {
				if ([doc respondsToSelector:@selector(project)]) {
					if ([[doc project] valueForKey:@"mainFile"]) {
						[jumpToMainItem setEnabled:YES];
					}
				}
			}
		}
		
		// Add existing file...
		NSMenuItem *addExistingFileItem = [menu itemWithTag:27];
		if (addExistingFileItem) {
			[addExistingFileItem setEnabled:NO];
			if (doc) {
				if ([doc respondsToSelector:@selector(canAddNewTeXFile)]) {
					[addExistingFileItem setEnabled:[doc canAddNewTeXFile]];
				}
			}
		}
		
		// Typeset menuitem
		NSMenuItem *item = [menu itemWithTag:40];
		if (item) {
			[item setEnabled:NO];
			[item setTitle:@"Typeset Project"];
			if (doc) {
				if ([doc respondsToSelector:@selector(canTypeset)]) {
          BOOL result = [doc canTypeset];
					[item setEnabled:result];
					NSString *mainFile = [[[doc project] valueForKey:@"mainFile"] valueForKey:@"shortName"];
					if (mainFile) {
						[item setTitle:[NSString stringWithFormat:@"Typeset \u201c%@\u201d", mainFile]];
					}
				}
			}
		}
		
		// Typeset and view menu item
		item = [menu itemWithTag:50];
		if (item) {
			[item setEnabled:NO];
			if (doc) {
				if ([doc respondsToSelector:@selector(canTypeset)]) {
					[item setEnabled:[doc canTypeset]];
				}
			}
		}
		
		// View PDF
		item = [menu itemWithTag:60];
		if (item) {
			[item setEnabled:NO];
			if (doc) {
				if ([doc respondsToSelector:@selector(canViewPDF)]) {
					[item setEnabled:[doc canViewPDF]];
				}
			}
		}
		
		// BibTeX
		item = [menu itemWithTag:70];
		if (item) {
			[item setTitle:@"BibTeX Project"];
			[item setEnabled:NO];
			if (doc) {
				if ([doc respondsToSelector:@selector(canBibTeX)]) {
					[item setEnabled:[doc canBibTeX]];
					NSString *mainFile = [[[doc project] valueForKey:@"mainFile"] valueForKey:@"shortName"];
					if (mainFile) {
						[item setTitle:[NSString stringWithFormat:@"BibTeX \u201c%@\u201d", mainFile]];
					}
				}
			}
		}
	} // End if Project menu
	
	// View menu
	if ([[menu title] isEqual:@"View"]) {
		NSMenuItem *showHidden = [menu itemWithTag:100];
		if (showHidden) {
			id fr = [[NSApp keyWindow] firstResponder];
			if ([fr respondsToSelector:@selector(showsInvisibleCharacters)]) {
				[showHidden setEnabled:[fr showsInvisibleCharacters]]; 
				[showHidden setState:[fr showsInvisibleCharacters]]; 
			} else {
				[showHidden setEnabled:NO]; 
				[showHidden setState:0]; 
			}
		}		
		
	} // end view menu
	
}


@end
