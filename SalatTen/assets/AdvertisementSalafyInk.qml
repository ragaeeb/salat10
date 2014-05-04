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
                imageSource: "images/ic_clock.png"
                
                onTriggered: {
                    console.log("UserEvent: SalafyInkBack");
                    root.close();
                }
            }
        }
        
        actions: [
            InvokeActionItem
            {
                id: browserAction
                ActionBar.placement: ActionBarPlacement.OnBar
                
                query {
                    mimeType: "text/html"
                    uri: "https://twitter.com/SalafyInk/status/410135299084550144"
                    invokeActionId: "bb.action.OPEN"
                }
                
                title: qsTr("Open in Browser") + Retranslate.onLanguageChanged
            }
        ]
        
        ScrollView
        {
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Fill
            scrollViewProperties.pinchToZoomEnabled: true
            
            ImageView
            {
                imageSource: "images/graphics/advertisement_salafyink.jpg"
                horizontalAlignment: HorizontalAlignment.Center
                
                gestureHandlers: [
                    TapHandler {
                        onTapped: {
                            app.launchUrl("https://twitter.com/SalafyInk/status/410135299084550144");
                        }
                    }
                ]
            }
        }
    }
    
    onClosed: {
        persist.saveValueFor("advertisedSalafyInk", 1, false);
        destroy();
    }
}