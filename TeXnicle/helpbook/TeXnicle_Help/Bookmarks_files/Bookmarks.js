// Created by iWeb 3.0.4 local-build-20111225

setTransparentGifURL('Media/transparent.gif');function applyEffects()
{var registry=IWCreateEffectRegistry();registry.registerEffects({shadow_2:new IWShadow({blurRadius:4,offset:new IWPoint(1.4142,1.4142),color:'#000000',opacity:0.500000}),shadow_1:new IWShadow({blurRadius:4,offset:new IWPoint(1.4142,1.4142),color:'#000000',opacity:0.500000}),shadow_3:new IWShadow({blurRadius:4,offset:new IWPoint(1.4142,1.4142),color:'#000000',opacity:0.500000}),shadow_0:new IWShadow({blurRadius:4,offset:new IWPoint(1.4142,1.4142),color:'#000000',opacity:0.500000}),shadow_6:new IWShadow({blurRadius:4,offset:new IWPoint(1.4142,1.4142),color:'#000000',opacity:0.500000}),shadow_5:new IWShadow({blurRadius:4,offset:new IWPoint(1.4142,1.4142),color:'#000000',opacity:0.500000}),stroke_0:new IWStrokeParts([{rect:new IWRect(-1,1,2,100),url:'Bookmarks_files/stroke.png'},{rect:new IWRect(-1,-1,2,2),url:'Bookmarks_files/stroke_1.png'},{rect:new IWRect(1,-1,217,2),url:'Bookmarks_files/stroke_2.png'},{rect:new IWRect(218,-1,2,2),url:'Bookmarks_files/stroke_3.png'},{rect:new IWRect(218,1,2,100),url:'Bookmarks_files/stroke_4.png'},{rect:new IWRect(218,101,2,2),url:'Bookmarks_files/stroke_5.png'},{rect:new IWRect(1,101,217,2),url:'Bookmarks_files/stroke_6.png'},{rect:new IWRect(-1,101,2,2),url:'Bookmarks_files/stroke_7.png'}],new IWSize(219,102)),shadow_4:new IWShadow({blurRadius:4,offset:new IWPoint(1.4142,1.4142),color:'#000000',opacity:0.500000})});registry.applyEffects();}
function hostedOnDM()
{return false;}
function onPageLoad()
{loadMozillaCSS('Bookmarks_files/BookmarksMoz.css')
adjustLineHeightIfTooBig('id1');adjustFontSizeIfTooBig('id1');adjustLineHeightIfTooBig('id2');adjustFontSizeIfTooBig('id2');Widget.onload();fixAllIEPNGs('Media/transparent.gif');applyEffects()}
function onPageUnload()
{Widget.onunload();}
