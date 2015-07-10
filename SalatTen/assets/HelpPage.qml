import bb.cascades 1.0
import com.canadainc.data 1.0

Page
{
    id: root
    actionBarAutoHideBehavior: ActionBarAutoHideBehavior.HideOnScroll
    
    titleBar: AboutTitleBar
    {
        id: atb
        videoTutorialUri: "http://www.youtube.com/watch?v=AbHZLmWSKts"
    }
    
    actions: [
        ActionItem
        {
            ActionBar.placement: ActionBarPlacement.OnBar
            imageSource: "images/compass/ic_compass.png"
            title: qsTr("Compass") + Retranslate.onLanguageChanged
            
            onTriggered: {
                var c = definition.init("CompassPane.qml");
                navigationPane.push(c);
            }
        }
    ]
    
    function cleanUp()
    {
    }
    
    function onDataLoaded(id, data)
    {
        if (id == QueryId.GetArticles || id == QueryId.SearchArticles)
        {
            webView.delegateActive = false;
            
            if (id == QueryId.GetArticles) {
                data.unshift({'type': 'internal', 'author': qsTr("Dr. Saleh as-Saleh"), 'title': qsTr("How To Pray"), 'uri': "local:///assets/html/tutorial.html", 'imageSource': "images/menu/ic_help.png"});
                data.unshift({'type': 'internal', 'author': qsTr("Dr. Saleh as-Saleh"), 'title': qsTr("Sujud as Sahw"), 'uri': "local:///assets/html/sujud_as_sahw.html"});
            }

            articles.articleData = data;
        }
    }
    
    function reload() {
        sql.fetchArticles(root);
    }
    
    onCreationCompleted: {
        reload();
    }
    
    Container
    {
        horizontalAlignment: HorizontalAlignment.Fill
        verticalAlignment: VerticalAlignment.Fill
        background: webView.delegateActive ? Color.White : SystemDefaults.Paints.ContainerBackground
        
        TextField
        {
            id: searchField
            hintText: qsTr("Enter text to search...") + Retranslate.onLanguageChanged
            input.submitKey: SubmitKey.Search
            input.flags: TextInputFlag.AutoCapitalizationOff | TextInputFlag.SpellCheck | TextInputFlag.WordSubstitution | TextInputFlag.AutoPeriodOff | TextInputFlag.AutoCorrection
            input.submitKeyFocusBehavior: SubmitKeyFocusBehavior.Lose
            bottomMargin: 0
            input.onSubmitted: {
                var query = searchField.text.trim();
                
                if (query.length == 0) {
                    reload();
                } else {
                    sql.searchArticles(root, query);
                }
            }
            
            onCreationCompleted: {
                input["keyLayout"] = 7;
            }
        }
        
        ControlDelegate
        {
            id: articles
            delegateActive: !webView.delegateActive
            visible: delegateActive
            property variant articleData
            
            onControlChanged: {
                if (control && articleData) {
                    control.dataModel.clear();
                    control.dataModel.append(articleData);
                }
            }
            
            onArticleDataChanged: {
                if (control) {
                    controlChanged(control);
                }
            }
            
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
                        ListItemComponent
                        {
                            StandardListItem
                            {
                                imageSource: ListItemData.imageSource ? ListItemData.imageSource : "images/tabs/ic_article.png"
                                title: ListItemData.author
                                description: ListItemData.title
                            }
                        }
                    ]
                    
                    onTriggered: {
                        var d = dataModel.data(indexPath);
                        
                        if (d.type == "internal") {
                            webView.url = d.uri;
                        } else {
                            persist.invoke( "com.canadainc.Quran10.tafsir.previewer", "", "", "quran://tafsir/"+d.id.toString(), global );
                        }
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
                Container
                {
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
                    
                    ProgressIndicator
                    {
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
    }
}