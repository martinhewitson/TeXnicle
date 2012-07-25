\version "2.13.59"

\include "lilypond.h.ly"
\include "title.h.ly"

\include "global.ly"
\include "mezzo.ly"
\include "violin.ly"
\include "cello.ly"

#(set-global-staff-size 16)

\paper {
	annotate-spacing = ##f
	paper-width = 9.25\in
	paper-height = 12.25\in
	page-top-space = 5\mm
	line-width = 190\mm
%	top-margin = #4
	bottom-margin = 10\mm
	ragged-bottom = ##f
%	ragged-last-bottom = ##f
	between-system-padding = 1\mm
%	systemSeparatorMarkup = \slashSeparator
}

\book {
	\header {
		title           = "Sous le dôme épais le jasmin"
		subtitle        = "(pour Kristine et Stijn)"
		opus            = "Lakmé"
		composer        = "Léo Delibes"
		year            = "(1836-1891)"
		instrumentName  = "Score"
		user            = ""
		lastupdated     = \today
	}

	\score { 
		<<
%			\new StaffGroup <<
				#(set-accidental-style 'modern 'StaffGroup) 
				\new Staff {
					\set Staff.midiInstrument = "voice"
					\set Staff.instrumentName = "Mezzo Soprano"
					\set Staff.shortInstrumentName = "Mez."
					\new Voice = melody 
						\keepWithTag #'score { << \global \mezMelody >> }
				}
				\new Lyrics \lyricsto melody \mezLyrics
				\new Staff {
					\set Staff.midiInstrument = "violin"
					\set Staff.instrumentName = "Violin"
					\set Staff.shortInstrumentName = "Vln"
					\keepWithTag #'score { << \global \vln >> }
				}
				\new Staff {
					\set Staff.midiInstrument = "cello"
					\set Staff.instrumentName = "Violoncello"
					\set Staff.shortInstrumentName = "Vlc"
					\keepWithTag #'score { << \global \vlc >> }
				}
%			>>
		>>

		\header {
			breakbefore = ##t
			title = "Sous le dôme épais le jasmin"
			composer = "L. Delibes"
			opus = ""
			year = "Lakmé"
		}

%		\midi {
%			\context {
%				\Score
%				tempoWholesPerMinute = #(ly:make-moment 200 8)%
%			}
%		}

		\layout {
			\context {
				\Score
					\override SpacingSpanner
						#'base-shortest-duration = #(ly:make-moment 1 4)
			}
		}
	
	}
}						