import bb.cascades 1.0

Page
{
    id: root
    actionBarAutoHideBehavior: ActionBarAutoHideBehavior.HideOnScroll
    
    actions: [
        ActionItem
        {
            property bool sujudSahw: false
            ActionBar.placement: ActionBarPlacement.OnBar
            imageSource: "images/menu/ic_help.png"
            title: sujudSahw ? qsTr("Sujud as-Sahw") + Retranslate.onLanguageChanged : qsTr("How To Pray") + Retranslate.onLanguageChanged
            
            onTriggered: {
                var dest = sujudSahw ? "sujud_as_sahw.html" : "tutorial.html";
                webView.url = "local:///assets/html/"+dest;
                sujudSahw = !sujudSahw;
            }
            
            onCreationCompleted: {
                triggered();
            }
        }
    ]
    
    titleBar: AboutTitleBar
    {
        id: atb
        videoTutorialUri: "http://www.youtube.com/watch?v=AbHZLmWSKts"
    }
    
    function cleanUp()
    {
    }
    
    Container
    {
        horizontalAlignment: HorizontalAlignment.Fill
        verticalAlignment: VerticalAlignment.Fill
        background: Color.White
        layout: DockLayout {}
        
        ScrollView
        {
            id: scrollView
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Fill
            scrollViewProperties.scrollMode: ScrollMode.Both
            scrollViewProperties.pinchToZoomEnabled: true
            scrollViewProperties.initialScalingMethod: ScalingMethod.AspectFill
            
            WebView
            {
                id: webView
                settings.zoomToFitEnabled: true
                settings.activeTextEnabled: true
                horizontalAlignment: HorizontalAlignment.Fill
                verticalAlignment: VerticalAlignment.Fill
                
                onLoadProgressChanged: {
                    progressIndicator.value = loadProgress;
                }
                
                onLoadingChanged: {
                    if (loadRequest.status == WebLoadStatus.Started) {
                        progressIndicator.visible = true;
                        progressIndicator.state = ProgressIndicatorState.Progress;
                    } else if (loadRequest.status == WebLoadStatus.Succeeded) {
                        progressIndicator.visible = false;
                        progressIndicator.state = ProgressIndicatorState.Complete;
                    } else if (loadRequest.status == WebLoadStatus.Failed) {
                        html = "<html><head><title>Load Fail</title><style>* { margin: 0px; padding 0px; }body { font-size: 48px; font-family: monospace; border: 1px solid #444; padding: 4px; }</style> </head> <body>Loading failed! Please check your internet connection.</body></html>"
                        progressIndicator.visible = false;
                        progressIndicator.state = ProgressIndicatorState.Error;
                    }
                }
            }
        }
        
        ProgressIndicator {
            id: progressIndicator
            horizontalAlignment: HorizontalAlignment.Center
            verticalAlignment: VerticalAlignment.Top
            visible: true
            value: 0
            fromValue: 0
            toValue: 100
            state: ProgressIndicatorState.Pause
            topMargin: 0; bottomMargin: 0; leftMargin: 0; rightMargin: 0;
        }
    }
}