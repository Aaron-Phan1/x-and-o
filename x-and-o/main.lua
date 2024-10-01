local composer = require( "composer" )
 
-- Code to initialize your app
d = display
w1_25 = d.contentWidth * .0125
w2_5 = d.contentWidth * .025
w5 = d.contentWidth * .05
w10 = d.contentWidth * .1
w20 = d.contentWidth * .2
w30 = d.contentWidth * .3
w40 = d.contentWidth * .4
w50 = d.contentWidth * .5
w60 = d.contentWidth * .6
w70 = d.contentWidth * .7
w80 = d.contentWidth * .8
w90 = d.contentWidth * .9

h1_25 = d.contentHeight * .0125
h2_5 = d.contentHeight * .025
h5 = d.contentHeight * .05
h10 = d.contentHeight * .1
h20 = d.contentHeight * .2 
h30 = d.contentHeight * .3
h40 = d.contentHeight * .4
h50 = d.contentHeight * .5
h60 = d.contentHeight * .6
h70 = d.contentHeight * .7
h80 = d.contentHeight * .8
h90 = d.contentHeight * .9


hardColour = {1, 0.45, 0.55}
easyColour = {0.45, 0.9, 1}
composer.gotoScene( "profile_selection" )