# LaTeX2HTML 2002-2-1 (1.70)
# Associate images original text with physical files.


$key = q/>;MSF=1.6;AAT/;
$cached_env_img{$key} = q|<IMG
 WIDTH="17" HEIGHT="30" ALIGN="MIDDLE" BORDER="0"
 SRC="|."$dir".q|img3.png"
 ALT="$&gt;$">|; 

$key = q/<;MSF=1.6;AAT/;
$cached_env_img{$key} = q|<IMG
 WIDTH="17" HEIGHT="30" ALIGN="MIDDLE" BORDER="0"
 SRC="|."$dir".q|img2.png"
 ALT="$&lt;$">|; 

$key = q/.;MSF=1.6;AAT/;
$cached_env_img{$key} = q|<IMG
 WIDTH="9" HEIGHT="13" ALIGN="BOTTOM" BORDER="0"
 SRC="|."$dir".q|img1.png"
 ALT="$.$">|; 

1;

