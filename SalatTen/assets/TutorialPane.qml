import bb.cascades 1.0

NavigationPane
{
    onPopTransitionEnded: {
        page.destroy();
    }
    
    Page
    {
        id: rootPage
        actionBarAutoHideBehavior: ActionBarAutoHideBehavior.HideOnScroll
        
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
                    url: "local:///assets/html/tutorial.html"
                    
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
}