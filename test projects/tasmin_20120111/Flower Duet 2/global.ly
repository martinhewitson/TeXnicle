\version "2.13.59"

global = {
	\time 6/8
	\key b \major
	s2.
	
	\time 3/8
	s4. \bar "||"
	
	\time 6/8
	\tempo "Andantino con moto" 8 = 144
	s2.*20 \bar "||"
	
	\tempo "a Tempo"
	s2.*6
	
	\key g \major
	\tempo "Un peu plus animé" 8 = 160
	s2.*20 \bar "||"
	
	\key b \major
	\tempo "Tempo primo"
	s2.*20
	
	\tempo "a Tempo"
	s2.*5 
	
	s2 \tempo "a Tempo" s4
	s2.*11
	
	\tempo "a Tempo"
	s2.*6 \bar "|."
}