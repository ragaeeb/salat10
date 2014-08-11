import bb.cascades 1.0

Sheet
{
    id: root
    
    Page
    {
        titleBar: TitleBar
        {
            title: qsTr("Learn Arabic!") + Retranslate.onLanguageChanged
            
            dismissAction: ActionItem
            {
                title: qsTr("Back") + Retranslate.onLanguageChanged
                imageSource: "images/tabs/ic_clock.png"
                
                onTriggered: {
                    console.log("UserEvent: AlFurqanBack");
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
                background: Color.White
                horizontalAlignment: HorizontalAlignment.Fill
                verticalAlignment: VerticalAlignment.Fill
                topPadding: 10; bottomPadding: 10; rightPadding: 10; leftPadding: 10
                
                ImageView
                {
                    imageSource: "images/graphics/al_furqan_logo.png"
                    horizontalAlignment: HorizontalAlignment.Center
                    translationX: 1000
                    
                    animations: [
                        TranslateTransition {
                            id: tt
                            fromX: 500
                            toX: 0
                            duration: 500
                            easingCurve: StockCurve.ElasticOut
                        }
                    ]
                }
                
                Label
                {
                    horizontalAlignment: HorizontalAlignment.Fill
                    verticalAlignment: VerticalAlignment.Fill
                    textStyle.textAlign: TextAlign.Center
                    content.flags: TextContentFlag.ActiveText | TextContentFlag.EmoticonsOff
                    textStyle.color: Color.Black
                    multiline: true
                    text: qsTr("Al Furqan Arabic E-learning Institute\n\nAl Furqan Arabic E-learning Institute invites you to an opportunity to learn Arabic from a qualified group of Instructors from Umul Qura University in Makkah, Saudi Arabia. All Instructors specialize in teaching Arabic to non-native speakers. Classes are conducted live on WizIQ 3 times a week (Wednesdays, Thursdays, and Sundays). Classes are conducted from 9:30 PM - 11:30 PM Saudi Time and costs $65 USD / month.\n\nContact us at alfurqanarabic1@gmail.com if you have any questions or concerns.\n\nBBM: C002A2E22\n\nwww.alfurqanarabic.org") + Retranslate.onLanguageChanged
                    opacity: 0
                    
                    animations: [
                        FadeTransition {
                            id: fader
                            fromOpacity: 0
                            toOpacity: 1
                            easingCurve: StockCurve.ExponentialInOut
                            duration: 1000
                        }
                    ]
                }
            }
        }
    }
    
    onOpened: {
        fader.play();
        tt.play();
    }
    
    onClosed: {
        persist.saveValueFor("advertisedAlFurqan", 1, false);
        destroy();
    }
}