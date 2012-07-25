%% /home/sjoerd/scores/ly/title.h.ly
%% Created on Thu Jan 12 11:26:11 CET 2006
\version "2.12.3"

\paper {
	bookTitleMarkup = \markup {
		\column {
			\fill-line {
				\lower #30 \override #'(font-size . 8)
				\fromproperty #'header:composer
			}
			\fill-line {
				\lower #5 \override #'(font-size . 5)
				\fromproperty #'header:year
			}
			\fill-line {
				\lower #20 \override #'(font-size . 12) \bold
				\fromproperty #'header:title
			}
			\fill-line {
				\lower #10 \override #'(font-size . 6)
				\fromproperty #'header:subtitle
			}
			\fill-line {
				\lower #10 \override #'(font-size . 6)
				\fromproperty #'header:opus
			}
			\fill-line {
				\lower #20 \huge \override #'(box-padding . 0.5)
				\box \fromproperty #'header:instrumentName
			}
			\fill-line {
				\lower #30 \override #'(font-size . 2)
				\fromproperty #'header:theLyrics
			}
		}
	}
	
	oddFooterMarkup = \markup {
		\column {
			\fill-line {
				\tiny
				\on-the-fly #first-page \tiny \fromproperty #'header:user
				\on-the-fly #first-page \tiny \fromproperty #'header:lastupdated
			}
			\fill-line {
				\on-the-fly #last-page \fromproperty #'header:tagline
			}
		}
	}
	
	scoreTitleMarkup = \markup {
		\column {
			\fill-line {
				\huge \bold \fromproperty #'header:title
			}
			\fill-line {
				\italic \fromproperty #'header:subtitle
			}
			\fill-line {
				\small \fromproperty #'header:poet
				\line {
					\small \fromproperty #'header:composer
					\small \fromproperty #'header:opus
				}
			}
			\fill-line {
				\large \fromproperty #'header:piece
				\huge  \fromproperty #'header:piecenr
				\small \fromproperty #'header:year
			}
		}
	}
}
