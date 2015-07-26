import bb.cascades 1.0
import bb.multimedia 1.0

Sheet
{
    id: root
    
    Page
    {
        actionBarAutoHideBehavior: ActionBarAutoHideBehavior.HideOnScroll
        
        titleBar: TitleBar {
            title: qsTr("Muting the Athan") + Retranslate.onLanguageChanged
        }
        
        ScrollView
        {
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Fill
            
            Container
            {
                horizontalAlignment: HorizontalAlignment.Fill
                verticalAlignment: VerticalAlignment.Fill
                topPadding: 10; bottomPadding: 10; rightPadding: 10; leftPadding: 10
                
                Container
                {
                    layout: DockLayout {}
                    horizontalAlignment: HorizontalAlignment.Center
                    
                    ImageView
                    {
                        imageSource: "images/graphics/tutorial_volume_off.png"
                        horizontalAlignment: HorizontalAlignment.Center
                        verticalAlignment: VerticalAlignment.Center
                    }
                    
                    ImageView
                    {
                        imageSource: "images/graphics/tutorial_volume_on.png"
                        horizontalAlignment: HorizontalAlignment.Center
                        verticalAlignment: VerticalAlignment.Center
                        opacity: 0
                        
                        animations: [
                            SequentialAnimation
                            {
                                id: overlay
                                repeatCount: AnimationRepeatCount.Forever
                                
                                FadeTransition
                                {
                                    fromOpacity: 0
                                    toOpacity: 1
                                    duration: 800
                                    easingCurve: StockCurve.QuarticOut
                                }
                                
                                FadeTransition
                                {
                                    fromOpacity: 1
                                    toOpacity: 0
                                    duration: 800
                                    easingCurve: StockCurve.QuarticIn
                                }
                            }
                        ]
                    }
                }
                
                Label
                {
                    horizontalAlignment: HorizontalAlignment.Fill
                    verticalAlignment: VerticalAlignment.Fill
                    textStyle.textAlign: TextAlign.Center
                    content.flags: TextContentFlag.ActiveText | TextContentFlag.EmoticonsOff
                    multiline: true
                    text: qsTr("\n\nTo mute the athan while it is playing, simply press the volume down button to cancel it.\n\nTry it now to close this screen.") + Retranslate.onLanguageChanged
                    opacity: 0
                    bottomMargin: 40
                    
                    animations: [
                        FadeTransition {
                            id: fader
                            fromOpacity: 0
                            toOpacity: 1
                            easingCurve: StockCurve.CubicOut
                            duration: 1000
                        }
                    ]
                }
            }
        }
    }
    
    onOpened: {
        fader.play();
        overlay.play();
    }
    
    onClosed: {
        persist.setFlag("tutorialMuteAthan", 1);
        destroy();
    }
    
    attachedObjects: [
        MediaKeyWatcher
        {
            key: MediaKey.VolumeDown
            
            onShortPress: {
                reporter.record("MuteAthanBack");
                root.close();
            }
        }
    ]
}