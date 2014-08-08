import bb.cascades 1.0

Page
{
    id: root
    actionBarAutoHideBehavior: ActionBarAutoHideBehavior.HideOnScroll
    
    titleBar: AboutTitleBar {
        id: atb
    }
    
    actions: [
        ActionItem
        {
            imageSource: "file:///usr/share/icons/bb_action_openbbmchannel.png"
            title: atb.channelTitle
            ActionBar.placement: 'Signature' in ActionBarPlacement ? ActionBarPlacement["Signature"] : ActionBarPlacement.OnBar
            
            onTriggered: {
                console.log("UserEvent: OpenChannelTriggered");
                persist.openChannel();
            }
        },
        
        ActionItem
        {
            imageSource: "images/menu/ic_video_tutorial.png"
            title: qsTr("Video Tutorial") + Retranslate.onLanguageChanged
            ActionBar.placement: ActionBarPlacement.OnBar
            
            onTriggered: {
                console.log("UserEvent: VideoTutorialTriggered");
                persist.tutorialVideo("http://www.youtube.com/watch?v=AbHZLmWSKts", false);
            }
        }
    ]
    
    Container
    {
        leftPadding: 10; rightPadding: 10;
        horizontalAlignment: HorizontalAlignment.Fill
        verticalAlignment: VerticalAlignment.Fill
        
	    ScrollView
	    {
	        horizontalAlignment: HorizontalAlignment.Fill
	        verticalAlignment: VerticalAlignment.Fill
	        scrollViewProperties.pinchToZoomEnabled: true
	        
	        Label
	        {
	            multiline: true
		        horizontalAlignment: HorizontalAlignment.Fill
		        verticalAlignment: VerticalAlignment.Center
	            textStyle.textAlign: TextAlign.Center
	            textStyle.fontSize: FontSize.XSmall
	            textStyle.lineHeight: 1.25
	            content.flags: TextContentFlag.ActiveText | TextContentFlag.EmoticonsOff
	            text: "\n\nSalat10 is a prayer time calculator for Muslims and offers a lot of additional features that other apps do not have. It also calculates Hijri dates based on the current Julian calendar date.

The usage of the app is very simple and the app tries to take care of most of the manual work for you. It will automatically determine your location and pick the calculation angles that are most relevant to your area to give you accurate timings. However you still have control over these settings if you want to adjust them yourself.

The app must remain open for the athan to function properly (until headless apps are officially supported on BlackBerry 10). 30 minutes before an event happens you will notice it display a message on the event itself, and 5 minutes before the event the countdown will get even more verbose. Once the new event comes in you will hear and see the notification if you have enabled the settings.


The codebase for this class is based on the code of:
Fayez Alhargan, 2001
King Abdulaziz City for Science and Technology
Computer and Electronics Research Institute
Riyadh, Saudi Arabia
alhargan@kacst.edu.sa
Tel:4813770
Fax:4813764
version: opn1.2

The Qibla compass formula was taken from the Azimuth/Distance calculator by Don Cross <http://cosinekitty.com/compass.html>

Special thanks to:
Muhammad Riaz <webif@islamicfinder.org>

Hijri Calendar development credits: Habib bin Hilal <http://www.al-habib.info/islamic-calendar/hijricalendartext.htm>"
	        }
	    }
    }
}