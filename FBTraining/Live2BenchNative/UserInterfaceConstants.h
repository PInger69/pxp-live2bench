//
//  UserInterfaceConstants.h
//  JumpPad
//
//  Created by Si Te Feng on 12/5/2013.
//  Copyright (c) 2013 Si Te Feng. All rights reserved.
//

#ifndef JumpPad_UserInterfaceConstants_h
#define JumpPad_UserInterfaceConstants_h


//////////////////////////////////
#pragma mark - Borders and Lines

#define kiPadDashletMargin               12



////////////////////////////////////
#pragma mark - System Default Values

#define kiPadStatusBarHeight			20.0
#define kiPadNavigationBarHeight        44.0
#define kiPadSearchBarHeight            44.0
#define kiPadFilterBarHeight            44.0
#define kiPadTabBarHeight               56.0
#define kiPadTopBarHeight               64.0

#define kiPadWidthLandscape             1024
#define kiPadWidthPortrait              768
#define kiPadHeightLandscape            768
#define kiPadHeightPortrait             1024

//-----------------
#define kiPadHeightFormSheetLandscape    620
#define kiPadWidthFormSheetLandscape     540

#define kiPadKeyboardHeightLandscape 		  352
#define kiPadKeyboardHeightPortrait 		  264

#define kiPadScreenSizePortrait         CGSizeMake(768,1024)
#define kiPadScreenSizeLandscape        CGSizeMake(1024,768)
#define kiPhone35InchScreenSizePortrait CGSizeMake(320,480)
#define kiPhone4InchScreenSizePortrait  CGSizeMake(320,568)






/////////////////////////////////////
#pragma mark - Graphical UI Elements

//#define kiPadSizeMainBannerPortrait       CGSizeMake(768,200)
//#define kiPadSizeMainBannerLandscape      CGSizeMake(1024,200)

#define kiPadDashletSizePortrait           CGSizeMake(240,240)
#define kiPadDashletSizeLandscape          CGSizeMake(241,241)

#define kiPadDashletImageSizePortrait      CGSizeMake(234,177)
#define kiPadDashletImageSizeLandscape     CGSizeMake(235,178)

#define kiPadDashletImagePadding            3

//#define kiPadSizeDashletLogoPortrait      CGSizeMake(180,180)
//#define kiPadSizeDashletLogoLandscape     CGSizeMake(155,155)

//#define kiPadSizeDashletCollegeTitleIcon  CGSizeMake(kiPadDashletTitleHeight * 1.5, kiPadDashletTitleHeight * 0.9)


//////////////////////////////////////
//Program Academic View Controller

static const CGFloat kGapWidth = 15;
static const CGFloat kHexWidth = (kiPadWidthPortrait-3*kGapWidth)/2.0;
static const CGFloat kHexHeight = kHexWidth* 1.154700538;

static const CGFloat kHexLineWidth = 4;







///////////////////////////////////
#pragma mark - Resource Image Sizes

//in dashlets and banners
#define kiPadSizeCollegeLogo   CGSizeMake(180,180)


//in dashletBackgroundView and the photo slide show in the program extended chart
//shinked to (372 x 303) when in dashlets
#define kiPadSizeProgramImage  CGSizeMake(400,300)
#define kiPadSizeFacultyImage  CGSizeMake(400,300)
#define kiPadSizeCollegeImage  CGSizeMake(400,300)


#define kiPadSizeCountryFlag   CGSizeMake(50,25)














#endif
