// Created by iWeb 3.0.3 local-build-20110605

setTransparentGifURL('Media/transparent.gif');function applyEffects()
{var registry=IWCreateEffectRegistry();registry.registerEffects({shadow_2:new IWShadow({blurRadius:4,offset:new IWPoint(1.4142,1.4142),color:'#000000',opacity:0.500000}),shadow_1:new IWShadow({blurRadius:4,offset:new IWPoint(1.4142,1.4142),color:'#000000',opacity:0.500000}),stroke_0:new IWStrokeParts([{rect:new IWRect(-1,1,2,223),url:'Document_Outline_files/stroke.png'},{rect:new IWRect(-1,-1,2,2),url:'Document_Outline_files/stroke_1.png'},{rect:new IWRect(1,-1,211,2),url:'Document_Outline_files/stroke_2.png'},{rect:new IWRect(212,-1,2,2),url:'Document_Outline_files/stroke_3.png'},{rect:new IWRect(212,1,2,223),url:'Document_Outline_files/stroke_4.png'},{rect:new IWRect(212,224,2,2),url:'Document_Outline_files/stroke_5.png'},{rect:new IWRect(1,224,211,2),url:'Document_Outline_files/stroke_6.png'},{rect:new IWRect(-1,224,2,2),url:'Document_Outline_files/stroke_7.png'}],new IWSize(213,225)),shadow_3:new IWShadow({blurRadius:4,offset:new IWPoint(1.4142,1.4142),color:'#000000',opacity:0.500000}),shadow_0:new IWShadow({blurRadius:4,offset:new IWPoint(1.4142,1.4142),color:'#000000',opacity:0.500000})});registry.applyEffects();}
function hostedOnDM()
{return false;}
function onPageLoad()
{loadMozillaCSS('Document_Outline_files/Document_OutlineMoz.css')
adjustLineHeightIfTooBig('id1');adjustFontSizeIfTooBig('id1');adjustLineHeightIfTooBig('id2');adjustFontSizeIfTooBig('id2');Widget.onload();fixAllIEPNGs('Media/transparent.gif');applyEffects()}
function onPageUnload()
{Widget.onunload();}
