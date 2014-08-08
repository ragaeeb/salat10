import bb.cascades 1.0

Sheet
{
    id: root
    
    Page
    {
        titleBar: TitleBar
        {
            title: qsTr("Athan Canceling") + Retranslate.onLanguageChanged
            
            dismissAction: ActionItem
            {
                enabled: checkBox.checked
                title: qsTr("Back") + Retranslate.onLanguageChanged
                imageSource: "images/tabs/ic_clock.png"
                
                onTriggered: {
                    console.log("UserEvent: MuteAthanBack");
                    root.close();
                }
            }
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
                                    duration: 1200
                                    easingCurve: StockCurve.QuarticOut
                                }
                                
                                FadeTransition
                                {
                                    fromOpacity: 1
                                    toOpacity: 0
                                    duration: 1200
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
                    text: qsTr("\n\nTo mute the athan while it is playing, simply press the volume down button to cancel it.") + Retranslate.onLanguageChanged
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
        persist.saveValueFor("tutorialMuteAthan", 1, false);
        destroy();
    }
}