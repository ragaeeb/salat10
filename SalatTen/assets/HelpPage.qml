import QtQuick 1.0
import bb.cascades 1.0
import com.canadainc.data 1.0

Page
{
    id: root
    actionBarAutoHideBehavior: ActionBarAutoHideBehavior.HideOnScroll
    
    titleBar: AboutTitleBar
    {
        id: atb
        videoTutorialUri: "http://youtu.be/Y4QjODg6SR4"
    }
    
    function cleanUp()
    {
    }
    
    function onDataLoaded(id, data)
    {
        if (id == QueryId.GetArticles || id == QueryId.SearchArticles)
        {
            webView.urlValue = undefined;
            
            if (id == QueryId.GetArticles)
            {
                data.unshift({'type': 'internal', 'author': qsTr("Dr. Saleh as-Saleh"), 'title': qsTr("How To Pray"), 'uri': "local:///assets/html/tutorial.html", 'imageSource': "images/dropdown/ic_article_filter.png"});
                data.unshift({'type': 'internal', 'author': qsTr("Dr. Saleh as-Saleh"), 'title': qsTr("Sujud as Sahw"), 'uri': "local:///assets/html/sujud_as_sahw.html", 'imageSource': "images/dropdown/ic_fard.png"});
                data.unshift({'type': 'internal', 'author': qsTr("Shaykh Muhammad Bazmool"), 'title': qsTr("Description of the Prophet's Prayer (With Illustrations)"), 'uri': "https://phaven-prod.s3.amazonaws.com/files/document_part/asset/922451/OwE0QrMeXdq3nKopmSM03VzEgiM/Salat_One.pdf", 'imageSource': "images/dropdown/ic_fiqh.png"});
                
                tutorial.execCentered("openArticle", qsTr("Tap on any of the articles to open it. Note that you need to have the Quran10 app installed for this to function properly.") );
                tutorial.execBelowTitleBar("searchArticle", qsTr("You can search for any keywords in the article title to quickly find it by typing it here and pressing the Enter key.") );
            } else {
                for (var i = data.length-1; i >= 0; i--)
                {
                    var x = data[i];
                    x["imageSource"] = "images/tabs/ic_articles.png";
                    data[i] = x;
                }
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
            hintText: qsTr("Enter article title or author to search...") + Retranslate.onLanguageChanged
            input.submitKey: SubmitKey.Search
            input.flags: TextInputFlag.AutoCapitalizationOff | TextInputFlag.SpellCheck | TextInputFlag.WordSubstitution | TextInputFlag.AutoPeriodOff | TextInputFlag.AutoCorrection
            input.submitKeyFocusBehavior: SubmitKeyFocusBehavior.Lose
            bottomMargin: 0
            input.onSubmitted: {
                var query = searchField.text.trim();
                reporter.record( "ArticleSearch", query);
                
                if (query.length == 0) {
                    reload();
                } else {
                    sql.searchArticles(root, query);
                }
            }
        }
        
        ControlDelegate
        {
            id: articles
            delegateActive: !webView.delegateActive
            visible: delegateActive
            property variant articleData
            
            onControlChanged: {
                if (control && articleData)
                {
                    control.dataModel.clear();
                    control.dataModel.append(articleData);
                    control.refreshState();
                }
            }
            
            onArticleDataChanged: {
                if (control) {
                    controlChanged(control);
                }
            }
            
            sourceComponent: ComponentDefinition
            {
                Container
                {
                    layout: DockLayout {}
                    horizontalAlignment: HorizontalAlignment.Fill
                    verticalAlignment: VerticalAlignment.Fill
                    property alias dataModel: listView.dataModel
                    
                    function refreshState() {
                        noElements.delegateActive = adm.isEmpty();
                    }
                    
                    ListView
                    {
                        id: listView
                        scrollRole: ScrollRole.Main
                        
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
                            console.log("UserEvent: ArticleTapped");
                            var d = dataModel.data(indexPath);
                            
                            if (d.type == "internal")
                            {
                                if ( d.uri.indexOf("http") == 0 ) {
                                    persist.openUri(d.uri);
                                } else {
                                    webView.urlValue = d.uri;
                                }

                                reporter.record( "ArticleTapped", d.uri);
                            } else {
                                persist.invoke( "com.canadainc.Quran10.tafsir.previewer", "", "", "quran://tafsir/"+d.id.toString(), "", global );
                                reporter.record( "ArticleOpen", d.id.toString() );

                                tutorial.execCentered("englishTranslation", qsTr("Note that for you to be able to open the articles properly, your Quran10 translation must be set to 'English'!") );
                            }
                        }
                    }
                    
                    EmptyDelegate
                    {
                        id: noElements
                        graphic: "images/empty/ic_no_articles.png"
                        labelText: qsTr("No articles matched your search criteria. Please try a different search term.") + Retranslate.onLanguageChanged
                        
                        onImageTapped: {
                            console.log("UserEvent: NoArticlesTapped");
                            searchField.requestFocus();
                        }
                    }
                }
            }
        }

        ControlDelegate
        {
            id: webView
            property variant urlValue
            delegateActive: urlValue != undefined
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
                            url: webView.urlValue
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
                                    
                                    tutorial.execBelowTitleBar("returnToHelpList", qsTr("To switch back to the articles list, simply leave this search field empty and press Enter on it.") );
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
    
    attachedObjects: [
        Timer {
            interval: 100
            repeat: false
            running: true
            
            onTriggered: {
                if (deviceUtils.isPhysicalKeyboardDevice) {
                    searchField.requestFocus();
                }
            }
        }
    ]
}