// Created by iWeb 3.0.3 local-build-20110604

setTransparentGifURL('Media/transparent.gif');function applyEffects()
{var registry=IWCreateEffectRegistry();registry.registerEffects({shadow_0:new IWShadow({blurRadius:4,offset:new IWPoint(1.4142,1.4142),color:'#000000',opacity:0.500000}),stroke_0:new IWStrokeParts([{rect:new IWRect(-1,1,2,164),url:'Home_files/stroke.png'},{rect:new IWRect(-1,-1,2,2),url:'Home_files/stroke_1.png'},{rect:new IWRect(1,-1,164,2),url:'Home_files/stroke_2.png'},{rect:new IWRect(165,-1,2,2),url:'Home_files/stroke_3.png'},{rect:new IWRect(165,1,2,164),url:'Home_files/stroke_4.png'},{rect:new IWRect(165,165,2,2),url:'Home_files/stroke_5.png'},{rect:new IWRect(1,165,164,2),url:'Home_files/stroke_6.png'},{rect:new IWRect(-1,165,2,2),url:'Home_files/stroke_7.png'}],new IWSize(166,166))});registry.applyEffects();}
function hostedOnDM()
{return false;}
function onPageLoad()
{loadMozillaCSS('Home_files/HomeMoz.css')
adjustLineHeightIfTooBig('id1');adjustFontSizeIfTooBig('id1');Widget.onload();fixupAllIEPNGBGs();fixAllIEPNGs('Media/transparent.gif');IMpreload('Home_files','shapeimage_2','0');applyEffects()}
function onPageUnload()
{Widget.onunload();}
