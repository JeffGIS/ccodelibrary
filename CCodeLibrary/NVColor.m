//  NVColor.m
//  CCodeLibrary

#import "NVColor.h"

@implementation NVColor

NVColor *colorFromRGB(int r, int g, int b)
{
    return (NVColor *)[UIColor colorWithRed:(r / 255.0)
                                      green:(g / 255.0)
                                       blue:(b / 255.0)
                                      alpha:1.0];
}

+ (NSArray *)allColors
{
    return @[NVColor.maroonColor, NVColor.darkRedColor, NVColor.brownColor, NVColor.firebrickColor, NVColor.crimsonColor, NVColor.redColor, NVColor.tomatoColor, NVColor.coralColor, NVColor.indianRedColor, NVColor.lightCoralColor, NVColor.darkSalmonColor, NVColor.salmonColor, NVColor.lightSalmonColor, NVColor.orangeRedColor, NVColor.darkOrangeColor, NVColor.orangeColor, NVColor.goldColor, NVColor.darkGoldenrodColor, NVColor.goldenrodColor, NVColor.paleGoldenrodColor, NVColor.darkKhakiColor, NVColor.khakiColor, NVColor.oliveColor, NVColor.yellowColor, NVColor.yellowGreenColor, NVColor.darkOliveGreenColor, NVColor.oliveDrabColor, NVColor.lawnGreenColor, NVColor.greenYellowColor, NVColor.darkGreenColor, NVColor.greenColor, NVColor.forestGreenColor, NVColor.limeColor, NVColor.limeGreenColor, NVColor.lightGreenColor, NVColor.paleGreenColor, NVColor.darkSeaGreenColor, NVColor.mediumSpringGreenColor, NVColor.springGreenColor, NVColor.seaGreenColor, NVColor.mediumAquamarineColor, NVColor.mediumSeaGreenColor, NVColor.lightSeaGreenColor, NVColor.darkSlateGrayColor, NVColor.tealColor, NVColor.darkCyanColor, NVColor.cyanColor, NVColor.lightCyanColor, NVColor.darkTurquoiseColor, NVColor.turquoiseColor, NVColor.mediumTurquoiseColor, NVColor.paleTurquoiseColor, NVColor.aquamarineColor, NVColor.powderBlueColor, NVColor.cadetBlueColor, NVColor.steelBlueColor, NVColor.cornflowerBlueColor, NVColor.deepSkyBlueColor, NVColor.dodgerBlueColor, NVColor.lightBlueColor, NVColor.skyBlueColor, NVColor.lightSkyBlueColor, NVColor.midnightBlueColor, NVColor.navyColor, NVColor.darkBlueColor, NVColor.mediumBlueColor, NVColor.blueColor, NVColor.royalBlueColor, NVColor.blueVioletColor, NVColor.indigoColor, NVColor.darkSlateBlueColor, NVColor.slateBlueColor, NVColor.mediumSlateBlueColor, NVColor.mediumPurpleColor, NVColor.darkMagentaColor, NVColor.darkVioletColor, NVColor.darkOrchidColor, NVColor.mediumOrchidColor, NVColor.purpleColor, NVColor.thistleColor, NVColor.plumColor, NVColor.violetColor, NVColor.magentaColor, NVColor.orchidColor, NVColor.mediumVioletRedColor, NVColor.paleVioletRedColor, NVColor.deepPinkColor, NVColor.hotPinkColor, NVColor.lightPinkColor, NVColor.pinkColor, NVColor.antiqueWhiteColor, NVColor.beigeColor, NVColor.bisqueColor, NVColor.blanchedAlmondColor, NVColor.wheatColor, NVColor.cornSilkColor, NVColor.lemonChiffonColor, NVColor.lightGoldenrodYellowColor, NVColor.lightYellowColor, NVColor.saddleBrownColor, NVColor.siennaColor, NVColor.chocolateColor, NVColor.peruColor, NVColor.sandyBrownColor, NVColor.burlywoodColor, NVColor.tanColor, NVColor.rosyBrownColor, NVColor.moccasinColor, NVColor.navajoWhiteColor, NVColor.peachPuffColor, NVColor.mistyRoseColor, NVColor.lavenderBlushColor, NVColor.linenColor, NVColor.oldLaceColor, NVColor.papayaWhipColor, NVColor.seashellColor, NVColor.mintCreamColor, NVColor.slateGrayColor, NVColor.lightSlateGrayColor, NVColor.lightSteelBlueColor, NVColor.lavenderColor, NVColor.floralWhiteColor, NVColor.aliceBlueColor, NVColor.ghostWhiteColor, NVColor.honeydewColor, NVColor.ivoryColor, NVColor.azureColor, NVColor.dimGrayColor, NVColor.grayColor, NVColor.darkGrayColor, NVColor.silverColor, NVColor.lightGrayColor, NVColor.gainsboroColor];
}

+ (NSArray *)lightColors
{
    return @[NVColor.tomatoColor, NVColor.coralColor, NVColor.lightCoralColor, NVColor.lightSalmonColor, NVColor.paleGoldenrodColor, NVColor.khakiColor, NVColor.yellowColor, NVColor.greenYellowColor, NVColor.lightGreenColor, NVColor.paleGreenColor, NVColor.springGreenColor, NVColor.lightSeaGreenColor, NVColor.cyanColor, NVColor.lightCyanColor, NVColor.paleTurquoiseColor, NVColor.aquamarineColor, NVColor.powderBlueColor, NVColor.lightBlueColor, NVColor.skyBlueColor, NVColor.lightSkyBlueColor, NVColor.thistleColor, NVColor.plumColor, NVColor.violetColor, NVColor.orchidColor, NVColor.paleVioletRedColor, NVColor.hotPinkColor, NVColor.lightPinkColor, NVColor.pinkColor, NVColor.antiqueWhiteColor, NVColor.beigeColor, NVColor.bisqueColor, NVColor.blanchedAlmondColor, NVColor.wheatColor, NVColor.cornSilkColor, NVColor.lemonChiffonColor, NVColor.lightGoldenrodYellowColor, NVColor.lightYellowColor, NVColor.burlywoodColor, NVColor.tanColor, NVColor.moccasinColor, NVColor.navajoWhiteColor, NVColor.peachPuffColor, NVColor.mistyRoseColor, NVColor.lavenderBlushColor, NVColor.linenColor, NVColor.oldLaceColor, NVColor.papayaWhipColor, NVColor.seashellColor, NVColor.mintCreamColor, NVColor.lightSteelBlueColor, NVColor.lavenderColor, NVColor.floralWhiteColor, NVColor.aliceBlueColor, NVColor.honeydewColor, NVColor.ivoryColor, NVColor.azureColor, NVColor.silverColor, NVColor.lightGrayColor, NVColor.gainsboroColor];
}

+ (NSArray *)mediumColors
{
    return @[NVColor.brownColor, NVColor.firebrickColor, NVColor.crimsonColor, NVColor.redColor, NVColor.indianRedColor, NVColor.salmonColor, NVColor.orangeRedColor, NVColor.orangeColor, NVColor.goldColor, NVColor.goldenrodColor, NVColor.yellowGreenColor, NVColor.lawnGreenColor, NVColor.limeColor, NVColor.limeGreenColor, NVColor.mediumSpringGreenColor, NVColor.mediumAquamarineColor, NVColor.mediumSeaGreenColor, NVColor.turquoiseColor, NVColor.mediumTurquoiseColor, NVColor.cadetBlueColor, NVColor.steelBlueColor, NVColor.cornflowerBlueColor, NVColor.deepSkyBlueColor, NVColor.dodgerBlueColor, NVColor.mediumBlueColor, NVColor.blueColor, NVColor.royalBlueColor, NVColor.blueVioletColor, NVColor.slateBlueColor, NVColor.mediumSlateBlueColor, NVColor.mediumPurpleColor, NVColor.mediumOrchidColor, NVColor.magentaColor, NVColor.mediumVioletRedColor, NVColor.deepPinkColor, NVColor.chocolateColor, NVColor.peruColor, NVColor.sandyBrownColor, NVColor.rosyBrownColor, NVColor.lightSlateGrayColor, NVColor.dimGrayColor, NVColor.grayColor, NVColor.darkGrayColor, NVColor.silverColor];
}

+ (NSArray *)darkColors
{
    return @[NVColor.maroonColor, NVColor.darkRedColor, NVColor.darkSalmonColor, NVColor.darkOrangeColor, NVColor.darkGoldenrodColor, NVColor.darkKhakiColor, NVColor.oliveColor, NVColor.darkOliveGreenColor, NVColor.oliveDrabColor, NVColor.darkGreenColor, NVColor.greenColor, NVColor.forestGreenColor, NVColor.darkSeaGreenColor, NVColor.seaGreenColor, NVColor.darkSlateGrayColor, NVColor.tealColor, NVColor.darkCyanColor, NVColor.darkTurquoiseColor, NVColor.midnightBlueColor, NVColor.navyColor, NVColor.darkBlueColor, NVColor.indigoColor, NVColor.darkSlateBlueColor, NVColor.darkMagentaColor, NVColor.darkVioletColor, NVColor.darkOrchidColor, NVColor.purpleColor, NVColor.saddleBrownColor, NVColor.siennaColor, NVColor.slateGrayColor, NVColor.silverColor];
}

+ (NSArray *)pastelColors
{
    return @[NVColor.coralColor, NVColor.lightCoralColor, NVColor.darkSalmonColor, NVColor.salmonColor, NVColor.lightSalmonColor, NVColor.paleGoldenrodColor, NVColor.khakiColor, NVColor.yellowGreenColor, NVColor.greenYellowColor, NVColor.lightGreenColor, NVColor.paleGreenColor, NVColor.springGreenColor, NVColor.mediumAquamarineColor, NVColor.lightCyanColor, NVColor.paleTurquoiseColor, NVColor.aquamarineColor, NVColor.powderBlueColor, NVColor.lightBlueColor, NVColor.skyBlueColor, NVColor.lightSkyBlueColor, NVColor.thistleColor, NVColor.plumColor, NVColor.violetColor, NVColor.orchidColor, NVColor.paleVioletRedColor, NVColor.lightPinkColor, NVColor.pinkColor, NVColor.antiqueWhiteColor, NVColor.beigeColor, NVColor.bisqueColor, NVColor.blanchedAlmondColor, NVColor.wheatColor, NVColor.cornSilkColor, NVColor.lemonChiffonColor, NVColor.lightGoldenrodYellowColor, NVColor.lightYellowColor, NVColor.moccasinColor, NVColor.navajoWhiteColor, NVColor.peachPuffColor, NVColor.mistyRoseColor, NVColor.lavenderBlushColor, NVColor.linenColor, NVColor.oldLaceColor, NVColor.papayaWhipColor, NVColor.seashellColor, NVColor.mintCreamColor, NVColor.lavenderColor, NVColor.floralWhiteColor, NVColor.aliceBlueColor, NVColor.honeydewColor, NVColor.ivoryColor, NVColor.azureColor];
}

+ (NSArray *)boldColors
{
    return @[NVColor.maroonColor, NVColor.darkRedColor, NVColor.brownColor, NVColor.firebrickColor, NVColor.crimsonColor, NVColor.redColor, NVColor.orangeColor, NVColor.goldColor, NVColor.yellowColor, NVColor.darkGreenColor, NVColor.greenColor, NVColor.forestGreenColor, NVColor.seaGreenColor, NVColor.tealColor, NVColor.darkCyanColor, NVColor.dodgerBlueColor, NVColor.midnightBlueColor, NVColor.navyColor, NVColor.darkBlueColor, NVColor.mediumBlueColor, NVColor.blueColor, NVColor.indigoColor, NVColor.darkSlateBlueColor, NVColor.darkMagentaColor, NVColor.purpleColor, NVColor.mediumVioletRedColor, NVColor.slateGrayColor];
}

+ (NSArray *)neutralColors
{
    return @[NVColor.brownColor, NVColor.firebrickColor, NVColor.darkGoldenrodColor, NVColor.goldenrodColor, NVColor.paleGoldenrodColor, NVColor.darkKhakiColor, NVColor.khakiColor, NVColor.oliveColor, NVColor.saddleBrownColor, NVColor.siennaColor, NVColor.chocolateColor, NVColor.peruColor, NVColor.sandyBrownColor, NVColor.burlywoodColor, NVColor.tanColor, NVColor.rosyBrownColor, NVColor.moccasinColor, NVColor.navajoWhiteColor, NVColor.peachPuffColor, NVColor.linenColor, NVColor.oldLaceColor, NVColor.papayaWhipColor, NVColor.seashellColor, NVColor.floralWhiteColor, NVColor.ivoryColor];
}

+ (NSArray *)warmColors
{
    return @[NVColor.maroonColor, NVColor.darkRedColor, NVColor.brownColor, NVColor.firebrickColor, NVColor.crimsonColor, NVColor.redColor, NVColor.tomatoColor, NVColor.coralColor, NVColor.indianRedColor, NVColor.lightCoralColor, NVColor.darkSalmonColor, NVColor.salmonColor, NVColor.lightSalmonColor, NVColor.orangeRedColor, NVColor.darkOrangeColor, NVColor.orangeColor, NVColor.goldColor, NVColor.darkGoldenrodColor, NVColor.goldenrodColor, NVColor.khakiColor, NVColor.oliveColor, NVColor.yellowColor, NVColor.yellowGreenColor, NVColor.antiqueWhiteColor, NVColor.bisqueColor, NVColor.blanchedAlmondColor, NVColor.wheatColor, NVColor.cornSilkColor, NVColor.lemonChiffonColor, NVColor.lightGoldenrodYellowColor, NVColor.lightYellowColor, NVColor.sandyBrownColor, NVColor.moccasinColor, NVColor.navajoWhiteColor, NVColor.peachPuffColor, NVColor.linenColor, NVColor.oldLaceColor, NVColor.papayaWhipColor, NVColor.seashellColor, NVColor.floralWhiteColor, NVColor.ivoryColor];
}

+ (NSArray *)coolColors
{
    return @[NVColor.oliveColor, NVColor.yellowGreenColor, NVColor.darkOliveGreenColor, NVColor.oliveDrabColor, NVColor.lawnGreenColor, NVColor.greenYellowColor, NVColor.darkGreenColor, NVColor.greenColor, NVColor.forestGreenColor, NVColor.limeColor, NVColor.limeGreenColor, NVColor.lightGreenColor, NVColor.paleGreenColor, NVColor.darkSeaGreenColor, NVColor.mediumSpringGreenColor, NVColor.springGreenColor, NVColor.seaGreenColor, NVColor.mediumAquamarineColor, NVColor.mediumSeaGreenColor, NVColor.lightSeaGreenColor, NVColor.darkSlateGrayColor, NVColor.tealColor, NVColor.darkCyanColor, NVColor.cyanColor, NVColor.lightCyanColor, NVColor.darkTurquoiseColor, NVColor.turquoiseColor, NVColor.mediumTurquoiseColor, NVColor.paleTurquoiseColor, NVColor.aquamarineColor, NVColor.powderBlueColor, NVColor.cadetBlueColor, NVColor.steelBlueColor, NVColor.cornflowerBlueColor, NVColor.deepSkyBlueColor, NVColor.dodgerBlueColor, NVColor.lightBlueColor, NVColor.skyBlueColor, NVColor.lightSkyBlueColor, NVColor.midnightBlueColor, NVColor.navyColor, NVColor.darkBlueColor, NVColor.mediumBlueColor, NVColor.blueColor, NVColor.royalBlueColor, NVColor.blueVioletColor, NVColor.indigoColor, NVColor.darkSlateBlueColor, NVColor.slateBlueColor, NVColor.mediumSlateBlueColor, NVColor.mediumPurpleColor, NVColor.darkMagentaColor, NVColor.darkVioletColor, NVColor.darkOrchidColor, NVColor.mediumOrchidColor, NVColor.purpleColor, NVColor.mediumVioletRedColor, NVColor.rosyBrownColor, NVColor.slateGrayColor, NVColor.lightSlateGrayColor];
}

+ (instancetype)maroonColor
{
    return colorFromRGB(128,0,0);
}

+ (instancetype)darkRedColor
{
    return colorFromRGB(139,0,0);
}

+ (instancetype)brownColor
{
    return colorFromRGB(165,42,42);
}

+ (instancetype)firebrickColor
{
    return colorFromRGB(178,34,34);
}

+ (instancetype)crimsonColor
{
    return colorFromRGB(220,20,60);
}

+ (instancetype)redColor
{
    return colorFromRGB(255,0,0);
}

+ (instancetype)tomatoColor
{
    return colorFromRGB(255,99,71);
}

+ (instancetype)coralColor
{
    return colorFromRGB(255,127,80);
}

+ (instancetype)indianRedColor
{
    return colorFromRGB(205,92,92);
}

+ (instancetype)lightCoralColor
{
    return colorFromRGB(240,128,128);
}

+ (instancetype)darkSalmonColor
{
    return colorFromRGB(233,150,122);
}

+ (instancetype)salmonColor
{
    return colorFromRGB(250,128,114);
}

+ (instancetype)lightSalmonColor
{
    return colorFromRGB(255,160,122);
}

+ (instancetype)orangeRedColor
{
    return colorFromRGB(255,69,0);
}

+ (instancetype)darkOrangeColor
{
    return colorFromRGB(255,140,0);
}

+ (instancetype)orangeColor
{
    return colorFromRGB(255,165,0);
}

+ (instancetype)goldColor
{
    return colorFromRGB(255,215,0);
}

+ (instancetype)darkGoldenrodColor
{
    return colorFromRGB(184,134,11);
}

+ (instancetype)goldenrodColor
{
    return colorFromRGB(218,165,32);
}

+ (instancetype)paleGoldenrodColor
{
    return colorFromRGB(238,232,170);
}

+ (instancetype)darkKhakiColor
{
    return colorFromRGB(189,183,107);
}

+ (instancetype)khakiColor
{
    return colorFromRGB(240,230,140);
}

+ (instancetype)oliveColor
{
    return colorFromRGB(128,128,0);
}

+ (instancetype)yellowColor
{
    return colorFromRGB(255,255,0);
}

+ (instancetype)yellowGreenColor
{
    return colorFromRGB(154,205,50);
}

+ (instancetype)darkOliveGreenColor
{
    return colorFromRGB(85,107,47);
}

+ (instancetype)oliveDrabColor
{
    return colorFromRGB(107,142,35);
}

+ (instancetype)lawnGreenColor
{
    return colorFromRGB(124,252,0);
}

+ (instancetype)greenYellowColor
{
    return colorFromRGB(173,255,47);
}

+ (instancetype)darkGreenColor
{
    return colorFromRGB(0,100,0);
}

+ (instancetype)greenColor
{
    return colorFromRGB(0,128,0);
}

+ (instancetype)forestGreenColor
{
    return colorFromRGB(34,139,34);
}

+ (instancetype)limeColor
{
    return colorFromRGB(0,255,0);
}

+ (instancetype)limeGreenColor
{
    return colorFromRGB(50,205,50);
}

+ (instancetype)lightGreenColor
{
    return colorFromRGB(144,238,144);
}

+ (instancetype)paleGreenColor
{
    return colorFromRGB(152,251,152);
}

+ (instancetype)darkSeaGreenColor
{
    return colorFromRGB(143,188,143);
}

+ (instancetype)mediumSpringGreenColor
{
    return colorFromRGB(0,250,154);
}

+ (instancetype)springGreenColor
{
    return colorFromRGB(0,255,127);
}

+ (instancetype)seaGreenColor
{
    return colorFromRGB(46,139,87);
}

+ (instancetype)mediumAquamarineColor
{
    return colorFromRGB(102,205,170);
}

+ (instancetype)mediumSeaGreenColor
{
    return colorFromRGB(60,179,113);
}

+ (instancetype)lightSeaGreenColor
{
    return colorFromRGB(32,178,170);
}

+ (instancetype)darkSlateGrayColor
{
    return colorFromRGB(47,79,79);
}

+ (instancetype)tealColor
{
    return colorFromRGB(0,128,128);
}

+ (instancetype)darkCyanColor
{
    return colorFromRGB(0,139,139);
}

+ (instancetype)cyanColor
{
    return colorFromRGB(0,255,255);
}

+ (instancetype)lightCyanColor
{
    return colorFromRGB(224,255,255);
}

+ (instancetype)darkTurquoiseColor
{
    return colorFromRGB(0,206,209);
}

+ (instancetype)turquoiseColor
{
    return colorFromRGB(64,224,208);
}

+ (instancetype)mediumTurquoiseColor
{
    return colorFromRGB(72,209,204);
}

+ (instancetype)paleTurquoiseColor
{
    return colorFromRGB(175,238,238);
}

+ (instancetype)aquamarineColor
{
    return colorFromRGB(127,255,212);
}

+ (instancetype)powderBlueColor
{
    return colorFromRGB(176,224,230);
}

+ (instancetype)cadetBlueColor
{
    return colorFromRGB(95,158,160);
}

+ (instancetype)steelBlueColor
{
    return colorFromRGB(70,130,180);
}

+ (instancetype)cornflowerBlueColor
{
    return colorFromRGB(100,149,237);
}

+ (instancetype)deepSkyBlueColor
{
    return colorFromRGB(0,191,255);
}

+ (instancetype)dodgerBlueColor
{
    return colorFromRGB(30,144,255);
}

+ (instancetype)lightBlueColor
{
    return colorFromRGB(173,216,230);
}

+ (instancetype)skyBlueColor
{
    return colorFromRGB(135,206,235);
}

+ (instancetype)lightSkyBlueColor
{
    return colorFromRGB(135,206,250);
}

+ (instancetype)midnightBlueColor
{
    return colorFromRGB(25,25,112);
}

+ (instancetype)navyColor
{
    return colorFromRGB(0,0,128);
}

+ (instancetype)darkBlueColor
{
    return colorFromRGB(0,0,139);
}

+ (instancetype)mediumBlueColor
{
    return colorFromRGB(0,0,205);
}

+ (instancetype)blueColor
{
    return colorFromRGB(0,0,255);
}

+ (instancetype)royalBlueColor
{
    return colorFromRGB(65,105,225);
}

+ (instancetype)blueVioletColor
{
    return colorFromRGB(138,43,226);
}

+ (instancetype)indigoColor
{
    return colorFromRGB(75,0,130);
}

+ (instancetype)darkSlateBlueColor
{
    return colorFromRGB(72,61,139);
}

+ (instancetype)slateBlueColor
{
    return colorFromRGB(106,90,205);
}

+ (instancetype)mediumSlateBlueColor
{
    return colorFromRGB(123,104,238);
}

+ (instancetype)mediumPurpleColor
{
    return colorFromRGB(147,112,219);
}

+ (instancetype)darkMagentaColor
{
    return colorFromRGB(139,0,139);
}

+ (instancetype)darkVioletColor
{
    return colorFromRGB(148,0,211);
}

+ (instancetype)darkOrchidColor
{
    return colorFromRGB(153,50,204);
}

+ (instancetype)mediumOrchidColor
{
    return colorFromRGB(186,85,211);
}

+ (instancetype)purpleColor
{
    return colorFromRGB(128,0,128);
}

+ (instancetype)thistleColor
{
    return colorFromRGB(216,191,216);
}

+ (instancetype)plumColor
{
    return colorFromRGB(221,160,221);
}

+ (instancetype)violetColor
{
    return colorFromRGB(238,130,238);
}

+ (instancetype)magentaColor
{
    return colorFromRGB(255,0,255);
}

+ (instancetype)orchidColor
{
    return colorFromRGB(218,112,214);
}

+ (instancetype)mediumVioletRedColor
{
    return colorFromRGB(199,21,133);
}

+ (instancetype)paleVioletRedColor
{
    return colorFromRGB(219,112,147);
}

+ (instancetype)deepPinkColor
{
    return colorFromRGB(255,20,147);
}

+ (instancetype)hotPinkColor
{
    return colorFromRGB(255,105,180);
}

+ (instancetype)lightPinkColor
{
    return colorFromRGB(255,182,193);
}

+ (instancetype)pinkColor
{
    return colorFromRGB(255,192,203);
}

+ (instancetype)antiqueWhiteColor
{
    return colorFromRGB(250,235,215);
}

+ (instancetype)beigeColor
{
    return colorFromRGB(245,245,220);
}

+ (instancetype)bisqueColor
{
    return colorFromRGB(255,228,196);
}

+ (instancetype)blanchedAlmondColor
{
    return colorFromRGB(255,235,205);
}

+ (instancetype)wheatColor
{
    return colorFromRGB(245,222,179);
}

+ (instancetype)cornSilkColor
{
    return colorFromRGB(255,248,220);
}

+ (instancetype)lemonChiffonColor
{
    return colorFromRGB(255,250,205);
}

+ (instancetype)lightGoldenrodYellowColor
{
    return colorFromRGB(250,250,210);
}

+ (instancetype)lightYellowColor
{
    return colorFromRGB(255,255,224);
}

+ (instancetype)saddleBrownColor
{
    return colorFromRGB(139,69,19);
}

+ (instancetype)siennaColor
{
    return colorFromRGB(160,82,45);
}

+ (instancetype)chocolateColor
{
    return colorFromRGB(210,105,30);
}

+ (instancetype)peruColor
{
    return colorFromRGB(205,133,63);
}

+ (instancetype)sandyBrownColor
{
    return colorFromRGB(244,164,96);
}

+ (instancetype)burlywoodColor
{
    return colorFromRGB(222,184,135);
}

+ (instancetype)tanColor
{
    return colorFromRGB(210,180,140);
}

+ (instancetype)rosyBrownColor
{
    return colorFromRGB(188,143,143);
}

+ (instancetype)moccasinColor
{
    return colorFromRGB(255,228,181);
}

+ (instancetype)navajoWhiteColor
{
    return colorFromRGB(255,222,173);
}

+ (instancetype)peachPuffColor
{
    return colorFromRGB(255,218,185);
}

+ (instancetype)mistyRoseColor
{
    return colorFromRGB(255,228,225);
}

+ (instancetype)lavenderBlushColor
{
    return colorFromRGB(255,240,245);
}

+ (instancetype)linenColor
{
    return colorFromRGB(250,240,230);
}

+ (instancetype)oldLaceColor
{
    return colorFromRGB(253,245,230);
}

+ (instancetype)papayaWhipColor
{
    return colorFromRGB(255,239,213);
}

+ (instancetype)seashellColor
{
    return colorFromRGB(255,245,238);
}

+ (instancetype)mintCreamColor
{
    return colorFromRGB(245,255,250);
}

+ (instancetype)slateGrayColor
{
    return colorFromRGB(112,128,144);
}

+ (instancetype)lightSlateGrayColor
{
    return colorFromRGB(119,136,153);
}

+ (instancetype)lightSteelBlueColor
{
    return colorFromRGB(176,196,222);
}

+ (instancetype)lavenderColor
{
    return colorFromRGB(230,230,250);
}

+ (instancetype)floralWhiteColor
{
    return colorFromRGB(255,250,240);
}

+ (instancetype)aliceBlueColor
{
    return colorFromRGB(240,248,255);
}

+ (instancetype)ghostWhiteColor
{
    return colorFromRGB(248,248,255);
}

+ (instancetype)honeydewColor
{
    return colorFromRGB(240,255,240);
}

+ (instancetype)ivoryColor
{
    return colorFromRGB(255,255,240);
}

+ (instancetype)azureColor
{
    return colorFromRGB(240,255,255);
}

+ (instancetype)snowColor
{
    return colorFromRGB(255,250,250);
}

+ (instancetype)blackColor
{
    return colorFromRGB(0,0,0);
}

+ (instancetype)dimGrayColor
{
    return colorFromRGB(105,105,105);
}

+ (instancetype)grayColor
{
    return colorFromRGB(128,128,128);
}

+ (instancetype)darkGrayColor
{
    return colorFromRGB(169,169,169);
}

+ (instancetype)silverColor
{
    return colorFromRGB(192,192,192);
}

+ (instancetype)lightGrayColor
{
    return colorFromRGB(211,211,211);
}

+ (instancetype)gainsboroColor
{
    return colorFromRGB(220,220,220);
}

+ (instancetype)whiteSmokeColor
{
    return colorFromRGB(245,245,245);
}

+ (instancetype)whiteColor
{
    return colorFromRGB(255,255,255);
}

@end