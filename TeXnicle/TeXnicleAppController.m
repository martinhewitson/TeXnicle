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
//  DISCLAIMED. IN NO EVENT SHALL MARTIN HEWITSON OR BOBSOFT SOFTWARE BE LIABLE FOR ANY
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
#import "NSWorkspaceExtended.h"
#import "TPThemeManager.h"

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

NSString * const TPShouldShowStartupScreenOnClosingLastDocument = @"TPShouldShowStartupScreenOnClosingLastDocument";

NSString * const TEAutomaticallyAddEndToBeginStatement = @"TEAutomaticallyAddEndToBeginStatement";
NSString * const TEAutomaticallyInsertClosingBrace = @"TEAutomaticallyInsertClosingBrace";
NSString * const TEAutomaticallyInsertClosingMath = @"TEAutomaticallyInsertClosingMath";
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

NSString * const TEJumpBarShowSections = @"TEJumpBarShowSections";
NSString * const TEJumpBarShowMarks = @"TEJumpBarShowMarks";
NSString * const TEJumpBarShowBookmarks = @"TEJumpBarShowBookmarks";
NSString * const TEJumpBarShowBibItems = @"TEJumpBarShowBibItems";
NSString * const TEJumpBarShowLineNumbers = @"TEJumpBarShowLineNumbers";
NSString * const TEJumpBarEnabled = @"TEJumpBarEnabled";


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

NSString * const TPSaveOnCompile = @"TPSaveOnCompile";
NSString * const TPClearConsoleOnCompile = @"TPClearConsoleOnCompile";
NSString * const TPSyncPDFAfterCompile = @"TPSyncPDFAfterCompile";
NSString * const TPAutoTrashAfterCompile = @"TPAutoTrashAfterCompile";

NSString * const TEDocumentBackgroundColor = @"TEDocumentBackgroundColor";
NSString * const TEDocumentBackgroundMarginColor = @"TEDocumentBackgroundMarginColor";
NSString * const TEDocumentCursorColor = @"TEDocumentCursorColor";
NSString * const TEDocumentCursorType = @"TEDocumentCursorType";
NSString * const TEDocumentFont = @"TEDocumentFont";
NSString * const TEDocumentLineHeightMultiple = @"TEDocumentLineHeightMultiple";
NSString * const TESyntaxTextColor = @"TESyntaxTextColor";
NSString * const TESelectedTextColor = @"TESelectedTextColor";
NSString * const TESelectedTextBackgroundColor = @"TESelectedTextBackgroundColor";

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

// outline
NSString * const TPOutlineSectionTags = @"TPOutlineSectionTags";
NSString * const TPOutlineDocumentColor = @"TPOutlineDocumentColor";
NSString * const TPOutlinePartColor = @"TPOutlinePartColor";
NSString * const TPOutlineChapterColor = @"TPOutlineChapterColor";
NSString * const TPOutlineSectionColor = @"TPOutlineSectionColor";
NSString * const TPOutlineSubsectionColor = @"TPOutlineSubsectionColor";
NSString * const TPOutlineSubsubsectionColor = @"TPOutlineSubsubsectionColor";
NSString * const TPOutlineParagraphColor = @"TPOutlineParagraphColor";
NSString * const TPOutlineSubparagraphColor = @"TPOutlineSubparagraphColor";


NSString * const TPPaletteRowHeight = @"TPPaletteRowHeight";
NSString * const TPLibraryRowHeight = @"TPLibraryRowHeight";

NSString * const TPSupportedFileTypes = @"TPSupportedFileTypes";

NSString * const TPLiveUpdateMode = @"TPLiveUpdateMode";
NSString * const TPLiveUpdateFrequency = @"TPLiveUpdateFrequency";
NSString * const TPLiveUpdateEditDelay = @"TPLiveUpdateEditDelay";

NSString * const TPSelectedTheme = @"TPSelectedTheme";
NSString * const TPThemeDidMigrate = @"TPThemeDidMigrate";


@implementation TeXnicleAppController

+ (void) initialize
{
  // create a dictionary for the ‘factory’ defaults
	NSMutableDictionary *defaultValues = [NSMutableDictionary dictionary];
  
  
  // get the templates from the app bundle plist
	NSString *path = [[NSBundle mainBundle] pathForResource:@"Templates" ofType:@"plist"];
	NSDictionary *templateDictionary = [NSMutableDictionary dictionaryWithContentsOfFile:path];
	NSMutableArray *templates = [NSMutableArray array];
	for (NSDictionary *dict in [templateDictionary valueForKey:@"Templates"]) {
		[templates addObject:[NSMutableDictionary dictionaryWithDictionary:dict]];
	}
	defaultValues[TEDocumentTemplates] = templates;

  // user commands
  defaultValues[TEUserCommands] = [NSMutableArray array];
  
  // ref commands
  NSMutableArray *refCommands = [NSMutableArray array];
  [refCommands addObject:@"\\ref"];
  [refCommands addObject:@"\\eqref"];
  defaultValues[TERefCommands] = refCommands;
  
  // cite commands
  NSMutableArray *citeCommands = [NSMutableArray array];
  [citeCommands addObject:@"\\cite"];
  defaultValues[TECiteCommands] = citeCommands;
  
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
  defaultValues[TEBeginCommands] = beginCommands;
  
  // completion stuff
  defaultValues[TEAutomaticallyAddEndToBeginStatement] = @YES;
  defaultValues[TEAutomaticallyInsertClosingBrace] = @YES;
  defaultValues[TEAutomaticallyInsertClosingMath] = @YES;
  defaultValues[TEAutomaticallyShowCommandCompletionList] = @YES;
  defaultValues[TEAutomaticallyShowCiteCompletionList] = @YES;
  defaultValues[TEAutomaticallyShowRefCompletionList] = @YES;
  defaultValues[TEAutomaticallyShowFileCompletionList] = @YES;
  defaultValues[TEAutomaticallyShowBeginCompletionList] = @YES;
  defaultValues[TEAutomaticallyReplaceOpeningDoubleQuote] = @YES;
  defaultValues[TEAutomaticallySkipClosingBrackets] = @YES;
  
  // app
  defaultValues[TPShouldShowStartupScreenOnClosingLastDocument] = @YES;
  
  // check syntax
  defaultValues[TPCheckSyntax] = @YES;
  defaultValues[TPCheckSyntaxErrors] = [TPSyntaxChecker defaultSyntaxErrors];
  defaultValues[TPChkTeXpath] = @"/usr/texbin/chktex";
  
  // file commands
  NSMutableArray *fileCommands = [NSMutableArray array];
	[fileCommands addObject:@"\\input"];
  [fileCommands addObject:@"\\include"];
  defaultValues[TEFileCommands] = fileCommands;
  
	// Document settings	
	[defaultValues setValue:@(TPHardWrap) forKey:TELineWrapStyle];
	[defaultValues setValue:@80 forKey:TELineLength];
	
	[defaultValues setValue:@YES forKey:TEInsertSpacesForTabs];
	[defaultValues setValue:@2 forKey:TENumSpacesForTab];
	
	[defaultValues setValue:@YES forKey:TEShowLineNumbers];
	[defaultValues setValue:@NO forKey:TEShowCodeFolders];
  
  [defaultValues setValue:@YES forKey:TPRestoreOpenTabs];
  
	[defaultValues setValue:@YES forKey:TEHighlightCurrentLine];
  [defaultValues setValue:[NSArray arrayWithColor:[NSColor colorWithDeviceWhite:0.95 alpha:1.0]] forKey:TEHighlightCurrentLineColor];

	[defaultValues setValue:@YES forKey:TEHighlightMatchingWords];
  [defaultValues setValue:[NSArray arrayWithColor:[[NSColor selectedTextBackgroundColor] highlightWithLevel:0.6]] forKey:TEHighlightMatchingWordsColor];
  
  [defaultValues setValue:[NSArray arrayWithColor:[NSColor selectedTextBackgroundColor]] forKey:TESelectedTextBackgroundColor];
  [defaultValues setValue:[NSArray arrayWithColor:[NSColor selectedTextColor]] forKey:TESelectedTextColor];
  
  [defaultValues setValue:@YES forKey:TPSaveOnCompile];
  [defaultValues setValue:@YES forKey:TPClearConsoleOnCompile];
  [defaultValues setValue:@NO forKey:TPSyncPDFAfterCompile];
  [defaultValues setValue:@NO forKey:OpenConsoleOnTypeset];
  [defaultValues setValue:@NO forKey:TPAutoTrashAfterCompile];

  // console
  defaultValues[TEConsoleFont] = [NSArchiver archivedDataWithRootObject:[NSFont userFixedPitchFontOfSize:12.0]];  
	
  // themes
  defaultValues[TPSelectedTheme] = @"texnicle";
  defaultValues[TPThemeDidMigrate] = @NO;
  
	//--- colors for syntax highlighting
	
  // default text
  defaultValues[TEDocumentFont] = [NSArchiver archivedDataWithRootObject:[NSFont systemFontOfSize:14.0]];
  defaultValues[TEDocumentLineHeightMultiple] = @1.0;
	[defaultValues setValue:[NSArray arrayWithColor:[NSColor blackColor]] forKey:TESyntaxTextColor];
  [defaultValues setValue:[NSArray arrayWithColor:[NSColor whiteColor]] forKey:TEDocumentBackgroundColor];
  [defaultValues setValue:[NSArray arrayWithColor:[NSColor lightGrayColor]] forKey:TEDocumentBackgroundMarginColor];
  [defaultValues setValue:[NSArray arrayWithColor:[NSColor blackColor]] forKey:TEDocumentCursorColor];
  [defaultValues setValue:@"Line" forKey:TEDocumentCursorType];  
  
  // comments
	[defaultValues setValue:[NSArray arrayWithColor:[NSColor colorWithDeviceWhite:0.4 alpha:1.0]] forKey:TESyntaxCommentsColor];
	[defaultValues setValue:[NSArray arrayWithColor:[NSColor colorWithDeviceWhite:0.6 alpha:1.0]] forKey:TESyntaxCommentsL2Color];
	[defaultValues setValue:[NSArray arrayWithColor:[NSColor colorWithDeviceWhite:0.8 alpha:1.0]] forKey:TESyntaxCommentsL3Color];
	[defaultValues setValue:@YES forKey:TESyntaxColorComments];
	[defaultValues setValue:@NO forKey:TESyntaxColorCommentsL2];
	[defaultValues setValue:@NO forKey:TESyntaxColorCommentsL3];
	[defaultValues setValue:@NO forKey:TESyntaxColorMultilineArguments];
  
  // markup
	[defaultValues setValue:[NSArray arrayWithColor:[NSColor colorWithDeviceRed:1.0 green:0.1 blue:0.1 alpha:1.0]] forKey:TESyntaxMarkupL1Color];
	[defaultValues setValue:[NSArray arrayWithColor:[NSColor colorWithDeviceRed:0.8 green:0.1 blue:0.1 alpha:1.0]] forKey:TESyntaxMarkupL2Color];
	[defaultValues setValue:[NSArray arrayWithColor:[NSColor colorWithDeviceRed:0.5 green:0.1 blue:0.1 alpha:1.0]] forKey:TESyntaxMarkupL3Color];
	[defaultValues setValue:@NO forKey:TESyntaxColorMarkupL1];
	[defaultValues setValue:@NO forKey:TESyntaxColorMarkupL2];
	[defaultValues setValue:@NO forKey:TESyntaxColorMarkupL3];
  
  // special chars
	[defaultValues setValue:[NSArray arrayWithColor:[NSColor colorWithDeviceRed:50.0/255.0 green:35.0/255.0 blue:1.0 alpha:1.0]] forKey:TESyntaxSpecialCharsColor];
	[defaultValues setValue:@YES forKey:TESyntaxColorSpecialChars];
  
  // dollar chars
	[defaultValues setValue:[NSArray arrayWithColor:[NSColor redColor]] forKey:TESyntaxDollarCharsColor];
	[defaultValues setValue:@YES forKey:TESyntaxColorDollarChars];
  
  // commands
	[defaultValues setValue:[NSArray arrayWithColor:[NSColor colorWithDeviceRed:25.0/255.0 green:20.0/255.0 blue:150.0/255.0 alpha:1.0]] forKey:TESyntaxCommandColor];
	[defaultValues setValue:@YES forKey:TESyntaxColorCommand];
  
  // arguments
	[defaultValues setValue:[NSArray arrayWithColor:[NSColor colorWithDeviceRed:0.0/255.0 green:100.0/255.0 blue:185.0/255.0 alpha:1.0]] forKey:TESyntaxArgumentsColor];
	[defaultValues setValue:@YES forKey:TESyntaxColorArguments];
	
  
  // outline
  NSDictionary *sectionTags = @{
                                @"begin"         : @[@"\\begin{document}", @"\\starttext"],
                                @"part"          : @[@"\\part", @"\\part*"],
                                @"chapter"       : @[@"\\chapter", @"\\chapter*"],
                                @"section"       : @[@"\\section", @"\\section*", @"\\subject"],
                                @"subsection"    : @[@"\\subsection", @"\\subsection*", @"\\subsubject"],
                                @"subsubsection" : @[@"\\subsubsection", @"\\subsubsection*", @"\\subsubsubject"],
                                @"paragraph"     : @[@"\\paragraph", @"\\paragraph*"],
                                @"subparagraph"  : @[@"\\subparagraph", @"\\subparagraph*"]
                                };
  
  [defaultValues setValue:sectionTags forKey:TPOutlineSectionTags];
	[defaultValues setValue:[NSArray arrayWithColor:[NSColor  blackColor]] forKey:TPOutlineDocumentColor];
	[defaultValues setValue:[NSArray arrayWithColor:[NSColor  darkGrayColor]] forKey:TPOutlinePartColor];
	[defaultValues setValue:[NSArray arrayWithColor:[NSColor  darkGrayColor]] forKey:TPOutlineChapterColor];
	[defaultValues setValue:[NSArray arrayWithColor:[NSColor  colorWithDeviceRed:0.8 green:0.2 blue:0.2 alpha:1.0]] forKey:TPOutlineSectionColor];
	[defaultValues setValue:[NSArray arrayWithColor:[NSColor  colorWithDeviceRed:0.6 green:0.5 blue:0.5 alpha:1.0]] forKey:TPOutlineSubsectionColor];
	[defaultValues setValue:[NSArray arrayWithColor:[NSColor  colorWithDeviceRed:0.6 green:0.5 blue:0.5 alpha:1.0]] forKey:TPOutlineSubsubsectionColor];
	[defaultValues setValue:[NSArray arrayWithColor:[NSColor  colorWithDeviceWhite:0.6 alpha:1.0]] forKey:TPOutlineParagraphColor];
	[defaultValues setValue:[NSArray arrayWithColor:[NSColor  colorWithDeviceWhite:0.7 alpha:1.0]] forKey:TPOutlineSubparagraphColor];

  // jump bar
  [defaultValues setValue:@YES forKey:TEJumpBarShowBookmarks];
  [defaultValues setValue:@YES forKey:TEJumpBarShowMarks];
  [defaultValues setValue:@YES forKey:TEJumpBarShowSections];
  [defaultValues setValue:@YES forKey:TEJumpBarShowBibItems];
  [defaultValues setValue:@YES forKey:TEJumpBarShowLineNumbers];
  [defaultValues setValue:@YES forKey:TEJumpBarEnabled];
    
  //---------- Paths
	// GS
	defaultValues[TPGSPath] = @"/usr/local/bin/gs";
	
	// PDFLatex
	defaultValues[TPPDFLatexPath] = @"/usr/texbin/pdflatex";
	
	// Latex
	defaultValues[TPLatexPath] = @"/usr/texbin/latex";
	
	// dvips
	defaultValues[TPDvipsPath] = @"/usr/texbin/dvips";
	
	// BibTeX path
	defaultValues[TPBibTeXPath] = @"/usr/texbin/bibtex";
	
	// ps2pdf path
	defaultValues[TPPS2PDFPath] = @"";
  
	// Number of times to run pdflatex
	[defaultValues setValue:@3U forKey:TPNRunsPDFLatex];
	
	// BibTeX during typeset
	defaultValues[BibTeXDuringTypeset] = @YES;
	
	// Run ps2pdf after typeset
	defaultValues[TPShouldRunPS2PDF] = @YES;
  
  // Default engine name
  defaultValues[TPDefaultEngineName] = @"pdflatex";
  
	// --------- Trash
	NSArray *files = @[@"aux", @"log", @"bbl", @"out"];
	defaultValues[TPTrashFiles] = files;
	defaultValues[TPTrashDocumentFileWhenTrashing] = @YES;
  
	//---------- Console settings
	[defaultValues setValue:@0 forKey:TPConsoleDisplayLevel];	
	
	
	//---------- Hidden settings
  [defaultValues setValue:@15.0f forKey:TPPaletteRowHeight];
  [defaultValues setValue:@25.0f forKey:TPLibraryRowHeight];
  
  //---------- Supported File Types
  NSMutableArray *supportedTypes = [NSMutableArray array];
  // tex
  TPSupportedFile *file;
  file = [TPSupportedFile supportedFileWithName:@"TeX Files" extension:@"tex" isBuiltIn:YES syntaxHighlight:YES spellcheck:YES];
  [supportedTypes addObject: file];

  // bib
  file = [TPSupportedFile supportedFileWithName:@"BiBTeX Files" extension:@"bib" isBuiltIn:YES syntaxHighlight:YES spellcheck:YES];
  [supportedTypes addObject:file];

  // sty
  file = [TPSupportedFile supportedFileWithName:@"LaTeX Style Files" extension:@"sty" isBuiltIn:YES syntaxHighlight:YES];
  [supportedTypes addObject:file];

  // ly
  file = [TPSupportedFile supportedFileWithName:@"Lilypond Files" extension:@"ly" isBuiltIn:YES syntaxHighlight:YES];
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
  
  // live update
  [defaultValues setValue:@0 forKey:TPLiveUpdateMode];
  [defaultValues setValue:@1.0f forKey:TPLiveUpdateFrequency];
  [defaultValues setValue:@5.0f forKey:TPLiveUpdateEditDelay];
  
  // register the defaults
	[[NSUserDefaults standardUserDefaults] registerDefaults:defaultValues];	
	[[NSUserDefaults standardUserDefaults] synchronize];
  

}


- (id)init
{
  //NSLog(@"App delegate init");
  self = [super init];
  if (self) {
    // Initialization code here.
    self.openStartupScreenAtAppStartup = YES;
    self.didSetup = NO;
  }
  
  return self;
}


- (void)applicationWillTerminate:(NSNotification *)notification
{
}

- (void)applicationWillFinishLaunching:(NSNotification *)aNotification
{
  //NSLog(@"App will finish launching");
  
  // set default
  lineToOpen = NSNotFound;
  
  [self doSetup];
}

- (BOOL)application:(NSApplication *)theApplication openFile:(NSString *)filename
{
  //NSLog(@"Application open file %@", filename);
	NSError *error = nil;
  
  [self doSetup];
  
  TeXProjectDocument *doc = [[NSDocumentController sharedDocumentController] openDocumentWithContentsOfURL:[NSURL fileURLWithPath:filename]
                                                                                  display:YES
                                                                                    error:&error];
	if (doc) {

    NSArray *args = [[NSProcessInfo processInfo] arguments];
    
    if ([args count] == 4) {
      NSString *tag = args[2];
      if ([tag isEqualToString:@"-line"]) {
        lineToOpen = [args[3] integerValue];
      }    
    }
        
    if (lineToOpen != NSNotFound) {
      [doc.texEditorViewController.textView performSelector:@selector(goToLineWithNumber:) 
                                                 withObject:@(lineToOpen) 
                                                 afterDelay:1];
    }
		return YES;
	}
	
	return NO;
}

- (void) doSetup
{
  if (self.didSetup == NO) {
    //NSLog(@"Do setup");
    // install templates
    [TPProjectTemplateManager installBundleTemplates];
    
    // install engines
    [TPEngineManager installEngines];
    
    // setup app-wide library
    self.library = [[TPLibrary alloc] init];
    
    // setup app-wide palette
    self.palette = [[TPPalette alloc] init];
    
    // load themes
    [TPThemeManager migrateDefaultsToTheme];
    [TPThemeManager installThemes];
    TPThemeManager *themeManager = [TPThemeManager sharedManager];
    self.didSetup = YES;
  }
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
  //NSLog(@"App did finish launching");
  
	id controller = [self startupScreen];
	NSArray *recentURLs = [[NSDocumentController sharedDocumentController] recentDocumentURLs];
	for (NSURL *url in recentURLs) {
    if (![[url pathExtension] isEqualToString:@"engine"]) {
      NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObject:[[url path] lastPathComponent]
                                                                     forKey:@"path"];
      dict[@"url"] = url;
      [[controller recentFiles] addObject:dict];
    }
	}
  
  if (self.openStartupScreenAtAppStartup) {
    if ([[[NSDocumentController sharedDocumentController] documents] count]==0) {
      [self showStartupScreen:self];
    }
  }
  
  //NSLog(@"App finished launching");
}



- (void) checkVersion
{
  NSError *error = nil;
  NSString *html = @"http://www.bobsoft-mac.de/resources/TeXnicle/latestversion.txt";
  NSURL *url = [NSURL URLWithString:html];
  NSString *latest = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];
  
  if (latest == nil)
    return;
  
  NSArray *parts = [latest componentsSeparatedByString:@" "];
  CGFloat latestVersion = [parts[0] floatValue];
  CGFloat latestBuild = [parts[1] floatValue];
  
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

- (IBAction)showUserManual:(id)sender
{
  if (self.helpViewer == nil) {
    self.helpViewer = [[PDFViewer alloc] initWithDelegate:self];
  }
  [self.helpViewer showWindow:self];
}

- (NSString*)documentPathForViewer:(PDFViewerController *)aPDFViewer
{
  NSString *path = [[NSBundle mainBundle] pathForResource:@"Texnicle-User-Manual" ofType:@"pdf"];
  return path;
}


#pragma mark -
#pragma mark Document Control 

- (IBAction)createProjectFromTemplate:(id)sender
{
  // make template list viewer
  TPProjectTemplateListViewer *viewer = [[TPProjectTemplateListViewer alloc] init];
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

- (IBAction) buildNewProject:(id)sender 
{
  // get a project director or file from the user  
  NSOpenPanel *panel = [NSOpenPanel openPanel];
  [panel setTitle:@"Build New Project..."];
  [panel setAllowedFileTypes:@[@"trip"]];
  [panel setNameFieldLabel:@"Source:"];
  [panel setCanChooseFiles:YES];
  [panel setCanChooseDirectories:YES];
  [panel setCanCreateDirectories:NO];
  [panel setMessage:@"Choose a main TeX file (one containing \\documentclass) or a directory of TeX files. \nIf a directory is chosen, the first TeX file containing \\documentclass is taken as the main file."];
  [panel setAllowedFileTypes:@[@"tex", NSFileTypeDirectory]];
  
  BOOL result = [panel runModal];
  
  if (result == NSFileHandlingPanelCancelButton) {
    return;
  }
  
  
  NSString *path = [[panel URLs][0] path];
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
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
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
						ProjectItemEntity *item = items[0];
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
