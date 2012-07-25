%% General purpose commands
today = #(strftime "%B %d, %Y" (localtime (current-time)))

%% Layout related commands
acceptCues = {
		\new Voice = "cue" {
		\set fontSize = #-3
		\override Stem #'length-fraction = #0.8
		\override Beam #'thickness = #0.384
		\override Beam #'length-fraction = #0.8
	}
}	

cueClefAlto = { \once \override Staff.Clef #'font-size = #-3 \clef alto }
cueClefBass  = { \once \override Staff.Clef #'font-size = #-3 \clef bass }
cueClefTenor = { \once \override Staff.Clef #'font-size = #-3 \clef tenor }
cueClefTreble = { \once \override Staff.Clef #'font-size = #-3 \clef treble }

stemExtend = {
	\once \override Stem #'length = #22
	\once \override Stem #'cross-staff = ##t
}	
noFlag = \once \override Stem #'flag-style = #'no-flag

