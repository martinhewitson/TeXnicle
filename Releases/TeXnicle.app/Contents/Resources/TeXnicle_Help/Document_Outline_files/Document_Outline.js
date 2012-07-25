// Created by iWeb 3.0.4 local-build-20111225

setTransparentGifURL('Media/transparent.gif');function applyEffects()
{var registry=IWCreateEffectRegistry();registry.registerEffects({shadow_0:new IWShadow({blurRadius:4,offset:new IWPoint(1.4142,1.4142),color:'#000000',opacity:0.500000}),shadow_1:new IWShadow({blurRadius:4,offset:new IWPoint(1.4142,1.4142),color:'#000000',opacity:0.500000}),shadow_2:new IWShadow({blurRadius:4,offset:new IWPoint(1.4142,1.4142),color:'#000000',opacity:0.500000}),stroke_0:new IWStrokeParts([{rect:new IWRect(-1,1,2,208),url:'Document_Outline_files/stroke.png'},{rect:new IWRect(-1,-1,2,2),url:'Document_Outline_files/stroke_1.png'},{rect:new IWRect(1,-1,231,2),url:'Document_Outline_files/stroke_2.png'},{rect:new IWRect(232,-1,2,2),url:'Document_Outline_files/stroke_3.png'},{rect:new IWRect(232,1,2,208),url:'Document_Outline_files/stroke_4.png'},{rect:new IWRect(232,209,2,2),url:'Document_Outline_files/stroke_5.png'},{rect:new IWRect(1,209,231,2),url:'Document_Outline_files/stroke_6.png'},{rect:new IWRect(-1,209,2,2),url:'Document_Outline_files/stroke_7.png'}],new IWSize(233,210)),shadow_3:new IWShadow({blurRadius:4,offset:new IWPoint(1.4142,1.4142),color:'#000000',opacity:0.500000})});registry.applyEffects();}
function hostedOnDM()
{return false;}
function onPageLoad()
{loadMozillaCSS('Document_Outline_files/Document_OutlineMoz.css')
adjustLineHeightIfTooBig('id1');adjustFontSizeIfTooBig('id1');adjustLineHeightIfTooBig('id2');adjustFontSizeIfTooBig('id2');Widget.onload();fixAllIEPNGs('Media/transparent.gif');applyEffects()}
function onPageUnload()
{Widget.onunload();}
