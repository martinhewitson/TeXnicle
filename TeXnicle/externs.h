/*
 *  externs.h
 *  Strongbox
 *
 *  Created by Martin Hewitson on 10/11/09.
 *  Copyright 2009 bobsoft. All rights reserved.
 *
 */

// preferences

#define LargeTextWidth  1e7
#define LargeTextHeight 1e7

typedef enum {
	TPConsoleDisplayAll,
	TPConsoleDisplayTeXnicle,
	TPConsoleDisplayErrors
} TPConsoleDisplay;

typedef enum {
	TPHardWrap,
	TPSoftWrap,
	TPNoWrap
} TPWrapStyle;

extern NSString * const TEDocumentTemplates;

// command completion
extern NSString * const TEUserCommands;
extern NSString * const TERefCommands;
extern NSString * const TECiteCommands;
extern NSString * const TEBeginCommands;
extern NSString * const TEFileCommands;

extern NSString * const TECursorPositionDidChangeNotification;
extern NSString * const TELineWrapStyle;
extern NSString * const TELineLength;
extern NSString * const TEInsertSpacesForTabs;
extern NSString * const TENumSpacesForTab;
extern NSString * const TEShowLineNumbers;
extern NSString * const TEShowCodeFolders;
extern NSString * const TEHighlightCurrentLine;
extern NSString * const TEHighlightCurrentLineColor;
extern NSString * const TEHighlightMatchingWords;
extern NSString * const TEHighlightMatchingWordsColor;
extern NSString * const TPSaveOnCompile;

extern NSString * const TEDocumentBackgroundColor;
extern NSString * const TESyntaxTextColor;
extern NSString * const TEDocumentFont;

extern NSString * const TEConsoleFont;

// comment
extern NSString * const TESyntaxCommentsColor;
extern NSString * const TESyntaxCommentsL2Color;
extern NSString * const TESyntaxCommentsL3Color;
extern NSString * const TESyntaxColorComments;
extern NSString * const TESyntaxColorCommentsL2;
extern NSString * const TESyntaxColorCommentsL3;
extern NSString * const TESyntaxColorMultilineArguments;

// special chars
extern NSString * const TESyntaxSpecialCharsColor;
extern NSString * const TESyntaxColorSpecialChars;

// command
extern NSString * const TESyntaxCommandColor;
extern NSString * const TESyntaxColorCommand;

// arguments
extern NSString * const TESyntaxArgumentsColor;
extern NSString * const TESyntaxColorArguments;

extern NSString * const TPGSPath;
extern NSString * const TPPDFLatexPath;
extern NSString * const TPLatexPath;
extern NSString * const TPDvipsPath;
extern NSString * const TPBibTeXPath;
extern NSString * const TPPS2PDFPath;

extern NSString * const TPDefaultEngineName;
extern NSString * const TPNRunsPDFLatex;
extern NSString * const BibTeXDuringTypeset;
extern NSString * const TPShouldRunPS2PDF;
extern NSString * const OpenConsoleOnTypeset;

extern NSString * const TPTrashFiles;
extern NSString * const TPTrashDocumentFileWhenTrashing;
extern NSString * const TPConsoleDisplayLevel;
extern NSString * const TPSpellCheckerLanguage;

extern NSString * const TPDefaultEncoding;

// Notifications
extern NSString * const TPSyntaxColorsChangedNotification;
extern NSString * const TPFileItemTextStorageChangedNotification;


// String constants
extern NSString * const TPDocumentWasRenamed;
extern NSString * const TPTreeSelectionDidChange;
extern NSString * const TableViewNodeType;
extern NSString * const OutlineViewNodeType;

// Settings
extern NSString * const TPPaletteRowHeight;
extern NSString * const TPLibraryRowHeight;

// Supported File Types (array of dictionaries)
extern NSString * const TPSupportedFileTypes;


