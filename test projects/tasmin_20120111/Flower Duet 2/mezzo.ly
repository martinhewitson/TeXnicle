\version "2.13.59"

mezMelody = \relative c'' {
	R2. | R4. \fermata
	\slurDotted
	r8 dis4 ~ ^\p dis8 cis16\(([ dis]) e8-.\) |
	r8 dis4 ~ dis8 cis16\(([ dis]) e8-.\) |
	
}

mezLyrics = \lyricmode {
	Dôme é -- pais le jas-min
}

mez = <<
	\new Voice  = melody \mezMelody
	\new Lyrics \lyricsto melody \mezLyrics
>>