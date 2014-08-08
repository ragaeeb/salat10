import bb.cascades 1.0
import com.canadainc.data 1.0

NavigationPane
{
    onPopTransitionEnded: {
        page.destroy();
    }
    
    function escapeRegExp(str) {
        return str.replace(/[\-\[\]\/\{\}\(\)\*\+\?\.\\\^\$\|]/g, "\\$&");
    }
    
    function replaceAll(find, replace, str) {
        return str.replace(new RegExp(escapeRegExp(find), 'g'), replace);
    }
    
    Page
    {
        id: rootPage
        actionBarAutoHideBehavior: ActionBarAutoHideBehavior.HideOnScroll
        
        titleBar: TitleBar {
            id: titleControl
            title: qsTr("Sujud As Sahw") + Retranslate.onLanguageChanged
        }
        
        actions: [
            ActionItem {
                id: chartAction
                title: qsTr("Useful Chart") + Retranslate.onLanguageChanged
                imageSource: "images/menu/ic_table.png"
                ActionBar.placement: ActionBarPlacement.OnBar
                
                onTriggered: {
                    webView.url = "local:///assets/html/sujud_as_sahw.html";
                }
                
                onCreationCompleted: {
                    triggered();
                }
            }
        ]
        
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
        
        onCreationCompleted: {
            sql.dataLoaded.connect( function(id, data)
            {
                if (id == QueryId.GetSujudArticles)
                {
                    for (var i = data.length-1; i >= 0; i--)
                    {
                        var action = actionDefinition.createObject();
                        action.data = data[i];
                        
                        rootPage.addAction(action);
                    }
                }
            });
        
        	sql.query = "SELECT author,title,body,reference from articles WHERE event_key='sahw'";
            sql.load(QueryId.GetSujudArticles);
        }
    }
    
    attachedObjects: [
        ComponentDefinition
        {
            id: actionDefinition

            ActionItem {
                property variant data
                imageSource: "images/tabs/ic_article.png"
                
                onDataChanged: {
                    title = data.title;
                }
                
                onTriggered: {
                    titleControl.title = data.author;
                    webView.html = replaceAll("\n", "<br>", data.body)+"<br><br>"+data.reference;
                }
            }
        }
    ]
}