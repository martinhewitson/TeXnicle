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
extern NSString * const TEUserCommands;

extern NSString * const TECursorPositionDidChangeNotification;
extern NSString * const TELineWrapStyle;
extern NSString * const TELineLength;
extern NSString * const TEInsertSpacesForTabs;
extern NSString * const TENumSpacesForTab;
extern NSString * const TEShowLineNumbers;
extern NSString * const TEShowCodeFolders;
extern NSString * const TEHighlightCurrentLine;
extern NSString * const TPSaveOnCompile;

extern NSString * const TEDocumentBackgroundColor;
extern NSString * const TESyntaxTextColor;
extern NSString * const TEDocumentFont;

extern NSString * const TEConsoleFont;

// comment
extern NSString * const TESyntaxCommentsColor;
extern NSString * const TESyntaxColorComments;

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

extern NSString * const TPNRunsPDFLatex;
extern NSString * const BibTeXDuringTypeset;
extern NSString * const TPTrashFiles;
extern NSString * const TPTrashDocumentFileWhenTrashing;
extern NSString * const TPConsoleDisplayLevel;
extern NSString * const OpenConsoleOnTypeset;
extern NSString * const TPSpellCheckerLanguage;

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



