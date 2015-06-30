import bb.cascades 1.0
import com.canadainc.data 1.0

Container
{
    horizontalAlignment: HorizontalAlignment.Fill
    verticalAlignment: VerticalAlignment.Fill
    background: Color.White
    layout: DockLayout {}
    property bool sujudSahw: true
    
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
            url: "local:///assets/html/sujud_as_sahw.html"
            
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
    
    ImageButton
    {
        id: locationAction
        defaultImageSource: "images/menu/ic_help.png"
        horizontalAlignment: HorizontalAlignment.Right
        
        onClicked: {
            var dest = sujudSahw ? "tutorial.html" : "sujud_as_sahw.html";
            webView.url = "local:///assets/html/"+dest;
            sujudSahw = !sujudSahw;
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