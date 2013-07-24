//
//  externs.h
//  TeXnicle
//
//  Created by Martin Hewitson on 10/11/09.
//  Copyright 2009 bobsoft. All rights reserved.
//
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

#define TEAR_DOWN 1

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
	TPNoWrap,
  TPWindowWrap
} TPWrapStyle;

extern NSString * const TEDocumentTemplates;

// command completion
extern NSString * const TEUserCommands;
extern NSString * const TERefCommands;
extern NSString * const TECiteCommands;
extern NSString * const TEBeginCommands;
extern NSString * const TEFileCommands;

extern NSString * const TEAutomaticallyShowCommandCompletionList;
extern NSString * const TEAutomaticallyShowCiteCompletionList;
extern NSString * const TEAutomaticallyShowRefCompletionList;
extern NSString * const TEAutomaticallyShowFileCompletionList;
extern NSString * const TEAutomaticallyShowBeginCompletionList;

extern NSString * const TEAutomaticallyAddEndToBeginStatement;
extern NSString * const TEAutomaticallyInsertClosingBrace;
extern NSString * const TEAutomaticallyInsertClosingMath;
extern NSString * const TEAutomaticallyReplaceOpeningDoubleQuote;
extern NSString * const TEAutomaticallySkipClosingBrackets;

extern NSString * const TPShouldShowStartupScreenOnClosingLastDocument;

extern NSString * const TPCheckSyntax;
extern NSString * const TPCheckSyntaxErrors;
extern NSString * const TPChkTeXpath;

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
extern NSString * const TESelectedTextColor;
extern NSString * const TESelectedTextBackgroundColor;
extern NSString * const TPSaveOnCompile;
extern NSString * const TPClearConsoleOnCompile;
extern NSString * const TPSyncPDFAfterCompile;
extern NSString * const TPAutoTrashAfterCompile;

extern NSString * const TEDocumentBackgroundMarginColor;
extern NSString * const TEDocumentBackgroundColor;
extern NSString * const TEDocumentCursorColor;
extern NSString * const TEDocumentCursorType;
extern NSString * const TESyntaxTextColor;
extern NSString * const TEDocumentFont;
extern NSString * const TEDocumentLineHeightMultiple;

extern NSString * const TEConsoleFont;

// jump bar
extern NSString * const TEJumpBarShowSections;
extern NSString * const TEJumpBarShowMarks;
extern NSString * const TEJumpBarShowBookmarks;
extern NSString * const TEJumpBarShowBibItems;
extern NSString * const TEJumpBarShowLineNumbers;
extern NSString * const TEJumpBarEnabled;

// themes
extern NSString * const TPSelectedTheme;
extern NSString * const TPThemeDidMigrate;

// outline colors
extern NSString * const TPOutlineSectionTags;
extern NSString * const TPOutlineDocumentColor;
extern NSString * const TPOutlinePartColor;
extern NSString * const TPOutlineChapterColor;
extern NSString * const TPOutlineSectionColor;
extern NSString * const TPOutlineSubsectionColor;
extern NSString * const TPOutlineSubsubsectionColor;
extern NSString * const TPOutlineParagraphColor;
extern NSString * const TPOutlineSubparagraphColor;


// comment
extern NSString * const TESyntaxCommentsColor;
extern NSString * const TESyntaxCommentsL2Color;
extern NSString * const TESyntaxCommentsL3Color;
extern NSString * const TESyntaxColorComments;
extern NSString * const TESyntaxColorCommentsL2;
extern NSString * const TESyntaxColorCommentsL3;
extern NSString * const TESyntaxColorMultilineArguments;

// markup
extern NSString * const TESyntaxMarkupL1Color;
extern NSString * const TESyntaxMarkupL2Color;
extern NSString * const TESyntaxMarkupL3Color;
extern NSString * const TESyntaxColorMarkupL1;
extern NSString * const TESyntaxColorMarkupL2;
extern NSString * const TESyntaxColorMarkupL3;


// special chars
extern NSString * const TESyntaxSpecialCharsColor;
extern NSString * const TESyntaxColorSpecialChars;

// dollar chars
extern NSString * const TESyntaxDollarCharsColor;
extern NSString * const TESyntaxColorDollarChars;

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
extern NSString * const TPRestoreOpenTabs;
extern NSString * const TPDefaultEncoding;

// Notifications
extern NSString * const TPThemeSelectionChangedNotification;
extern NSString * const TPSyntaxColorsChangedNotification;
extern NSString * const TPFileItemTextStorageChangedNotification;
extern NSString * const TPBookmarkDidUpdateNotification;
extern NSString * const TPSpellingLanguageChangedNotification;
extern NSString * const TPFileMetadataSectionsUpdatedNotification;
extern NSString * const TPFileMetadataUpdatedNotification;
extern NSString * const TPMetadataManagerDidBeginUpdateNotification;
extern NSString * const TPMetadataManagerDidEndUpdateNotification;
//extern NSString * const TPFileMetadataWarningsUpdatedNotification;
extern NSString * const TPLibraryDidUpdateNotification;
extern NSString * const TPLogfileAvailableNotification;


// String constants
extern NSString * const TPDocumentWasRenamed;
extern NSString * const TPTreeSelectionDidChange;
extern NSString * const TableViewNodeType;
extern NSString * const OutlineViewNodeType;
extern NSString * const TPDocumentMatchAttributeName;

extern NSString * const TPLiveUpdateMode;
extern NSString * const TPLiveUpdateFrequency;
extern NSString * const TPLiveUpdateEditDelay;

extern NSString * const TPSpellingAutomaticByLanguage;

// Settings
extern NSString * const TPPaletteRowHeight;
extern NSString * const TPLibraryRowHeight;

// Supported File Types (array of dictionaries)
extern NSString * const TPSupportedFileTypes;


