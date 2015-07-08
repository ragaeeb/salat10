import bb.cascades 1.0
import com.canadainc.data 1.0

Page
{
    id: root
    actionBarAutoHideBehavior: ActionBarAutoHideBehavior.HideOnScroll
    
    actions: [
        ActionItem
        {
            ActionBar.placement: ActionBarPlacement.OnBar
            imageSource: "images/menu/ic_help.png"
            title: qsTr("Sujud as-Sahw") + Retranslate.onLanguageChanged
            
            onTriggered: {
                webView.url = "local:///assets/html/sujud_as_sahw.html";
            }
        },
        
        ActionItem
        {
            property bool sujudSahw: false
            ActionBar.placement: ActionBarPlacement.OnBar
            imageSource: "images/menu/ic_help.png"
            title: qsTr("How To Pray") + Retranslate.onLanguageChanged
            
            onTriggered: {
                webView.url = "local:///assets/html/tutorial.html";
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
        background: webView.delegateActive ? Color.White : SystemDefaults.Paints.ContainerBackground
        layout: DockLayout {}
        
        ControlDelegate
        {
            id: articles
            delegateActive: !webView.delegateActive
            visible: delegateActive
            
            sourceComponent: ComponentDefinition
            {
                ListView
                {
                    id: listView
                    
                    dataModel: ArrayDataModel {
                        id: adm
                    }
                    
                    listItemComponents:
                    [
                        ListItemComponent {
                            StandardListItem
                            {
                                imageSource: "images/tabs/ic_article.png"
                                title: ListItemData.author
                                description: ListItemData.title
                            }
                        }
                    ]
                    
                    function onDataLoaded(id, data)
                    {
                        if (id == QueryId.GetArticles)
                        {
                            adm.clear();
                            adm.append(data);
                        }
                    }
                    
                    onTriggered: {
                        var d = dataModel.data(indexPath);
                        persist.invoke( "com.canadainc.Quran10.tafsir.previewer", "", "", "quran://tafsir/"+d.id.toString(), global );
                    }
                    
                    onCreationCompleted: {
                        sql.fetchArticles(listView);
                    }
                }
            }
        }

        ControlDelegate
        {
            id: webView
            property variant url
            delegateActive: url != undefined
            visible: delegateActive
            
            sourceComponent: ComponentDefinition
            {
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
                        url: webView.url
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