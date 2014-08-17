import bb.cascades 1.0
import com.canadainc.data 1.0

NavigationPane
{
    id: navigationPane
    
    onPopTransitionEnded: {
        page.destroy();
    }
    
    Page
    {
        actionBarAutoHideBehavior: ActionBarAutoHideBehavior.HideOnScroll
        
        actions: [
            ActionItem
            {
                ActionBar.placement: 'Signature' in ActionBarPlacement ? ActionBarPlacement["Signature"] : ActionBarPlacement.OnBar
                imageSource: "images/tabs/ic_articles.png"
                title: qsTr("Times of Salah") + Retranslate.onLanguageChanged
                
                onTriggered: {
                    console.log("UserEvent: TimesOfSalahTriggered");
                    app.launchBrowser("http://abdurrahman.org/sunnah/bulughalmaramNotes/BM_129-143-TimesOfSalah-35p.pdf");
                }
            },
            
            ActionItem
            {
                ActionBar.placement: ActionBarPlacement.OnBar
                imageSource: "images/menu/ic_table.png"
                title: qsTr("Times of the Prayers") + Retranslate.onLanguageChanged
                
                onTriggered: {
                    console.log("UserEvent: TimesOfPrayers");
                    app.launchBrowser("http://abdurrahman.org/sunnah/sahihBukhari/010.sbt.html");
                }
            },
            
            ActionItem
            {
                ActionBar.placement: ActionBarPlacement.OnBar
                imageSource: "file:///usr/share/icons/ic_accept.png"
                title: qsTr("Bukhari: Salat") + Retranslate.onLanguageChanged
                
                onTriggered: {
                    console.log("UserEvent: TimesOfPrayers");
                    app.launchBrowser("http://abdurrahman.org/sunnah/sahihBukhari/008.sbt.html");
                }
            },
            
            ActionItem
            {
                imageSource: "images/dropdown/ic_article_filter.png"
                title: qsTr("Kitab Al-Salat") + Retranslate.onLanguageChanged
                
                onTriggered: {
                    console.log("UserEvent: KitabAlSalat");
                    app.launchBrowser("http://abdurrahman.org/sunnah/sahihMuslim/004.smt.html");
                }
            }
        ]
        
        titleBar: TitleBar
        {
            id: titleControl
            kind: TitleBarKind.FreeForm
            scrollBehavior: TitleBarScrollBehavior.NonSticky
            kindProperties: FreeFormTitleBarKindProperties
            {
                Container
                {
                    horizontalAlignment: HorizontalAlignment.Fill
                    verticalAlignment: VerticalAlignment.Fill
                    topPadding: 10; bottomPadding: 20; leftPadding: 10
                    
                    Label {
                        text: qsTr("Articles") + Retranslate.onLanguageChanged
                        verticalAlignment: VerticalAlignment.Center
                        textStyle.color: Color.White
                        textStyle.base: SystemDefaults.TextStyles.BigText
                    }
                }
                
                expandableArea
                {
                    expanded: true
                    
                    content: DropDown
                    {
                        id: filter
                        horizontalAlignment: HorizontalAlignment.Fill
                        title: qsTr("Filter") + Retranslate.onLanguageChanged

                        Option {
                            text: qsTr("Common Mistakes") + Retranslate.onLanguageChanged
                            description: qsTr("Articles and fatwa related to errors") + Retranslate.onLanguageChanged
                            imageSource: "images/dropdown/ic_mistakes.png"
                            value: "event_key='mistakes'"
                        }
                        
                        Option {
                            text: qsTr("Duha") + Retranslate.onLanguageChanged
                            description: qsTr("Articles and fatwa related to Salat-ul Duha") + Retranslate.onLanguageChanged
                            imageSource: "images/dropdown/ic_asr_hanafi.png"
                            value: "event_key='duha'"
                        }
                        
                        Option {
                            text: qsTr("Eid") + Retranslate.onLanguageChanged
                            description: qsTr("Articles and fatwa related to Salat-Eid") + Retranslate.onLanguageChanged
                            imageSource: "images/dropdown/ic_eid.png"
                            value: "event_key='eid'"
                        }
                        
                        Option {
                            text: qsTr("Fard") + Retranslate.onLanguageChanged
                            description: qsTr("Articles related to the 5 wajib prayers") + Retranslate.onLanguageChanged
                            imageSource: "images/dropdown/ic_fard.png"
                            value: "event_key='fajr' OR event_key='dhuhr' OR event_key='asr' OR event_key='maghrib' OR event_key='isha'"
                        }
                        
                        Option {
                            text: qsTr("Fiqh") + Retranslate.onLanguageChanged
                            description: qsTr("Articles related to the the fiqh of Salah") + Retranslate.onLanguageChanged
                            imageSource: "images/dropdown/ic_fiqh.png"
                            value: "event_key='fiqh'"
                        }
                        
                        Option {
                            text: qsTr("Istikhaarah") + Retranslate.onLanguageChanged
                            description: qsTr("Articles related to the Salat-ul Istikhaarah") + Retranslate.onLanguageChanged
                            imageSource: "images/dropdown/ic_gold.png"
                            value: "event_key='istikhaarah'"
                        }
                        
                        Option {
                            text: qsTr("Janaza") + Retranslate.onLanguageChanged
                            description: qsTr("Articles related to the Funeral Prayer") + Retranslate.onLanguageChanged
                            imageSource: "images/dropdown/ic_janaza.png"
                            value: "event_key='janaza'"
                        }
                        
                        Option {
                            text: qsTr("Jumu'ah") + Retranslate.onLanguageChanged
                            description: qsTr("Articles and fatwa related to Salatul-Jumu'ah") + Retranslate.onLanguageChanged
                            imageSource: "images/dropdown/ic_asr_shafii.png"
                            value: "event_key='jumuah'"
                        }
                        
                        Option {
                            text: qsTr("Sutrah") + Retranslate.onLanguageChanged
                            description: qsTr("Articles related to the the sutrah") + Retranslate.onLanguageChanged
                            imageSource: "images/dropdown/ic_sutrah.png"
                            value: "event_key='sutrah'"
                        }
                        
                        Option {
                            text: qsTr("Tahiyyatul-Masjid") + Retranslate.onLanguageChanged
                            description: qsTr("Articles related to Tahiyyatul-Masjid") + Retranslate.onLanguageChanged
                            imageSource: "images/dropdown/ic_masjid.png"
                            value: "event_key='masjid'"
                        }
                        
                        Option {
                            id: uncatFilter
                            text: qsTr("Uncategorized") + Retranslate.onLanguageChanged
                            description: qsTr("Unclassified articles") + Retranslate.onLanguageChanged
                            imageSource: "images/dropdown/ic_article_filter.png"
                            value: "event_key ISNULL"
                        }
                        
                        Option {
                            text: qsTr("Witr") + Retranslate.onLanguageChanged
                            description: qsTr("Articles related to Salatul-Witr") + Retranslate.onLanguageChanged
                            imageSource: "images/dropdown/ic_moon.png"
                            value: "event_key='witr'"
                        }
                        
                        onSelectedOptionChanged:
                        {
                            console.log("UserEvent: ArticleCategoryChosen", selectedOption.value);
                            
                            sql.query = "SELECT * from articles WHERE %1".arg(selectedOption.value);
                            sql.load(QueryId.GetArticles);
                        }
                    }
                }
            }
        }
        
        Container
        {
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Fill
            background: back.imagePaint
            layout: DockLayout {}
            
            attachedObjects: [
                ImagePaintDefinition {
                    id: back
                    imageSource: "images/graphics/background.png"
                }
            ]
            
            EmptyDelegate
            {
                id: emptyDelegate
                graphic: "images/empty/ic_no_articles.png"
                labelText: qsTr("There are no articles loaded. Select a category from the dropdown to load them or tap here.")
                delegateActive: true
                
                onImageTapped: {
                    filter.expanded = true;
                }
            }
            
            ListView
            {
                id: listView
                visible: false

                dataModel: GroupDataModel
                {
                    id: gdm
                    grouping: ItemGrouping.ByFullValue
                    sortingKeys: ["title"]
                }
                
                listItemComponents:
                [
                    ListItemComponent {
                        type: "header"
                        
                        Header {
                            title: ListItemData
                        }
                    },
                    
                    ListItemComponent
                    {
                        type: "item"
                        
                        Container
                        {
                            id: sli
                            horizontalAlignment: HorizontalAlignment.Fill
                            verticalAlignment: VerticalAlignment.Fill
                            
                            opacity: 0
                            animations: [
                                FadeTransition
                                {
                                    id: showAnim
                                    fromOpacity: 0
                                    toOpacity: 1
                                    duration: sli.ListItem.indexInSection*300
                                }
                            ]
                            
                            onCreationCompleted: {
                                showAnim.play();
                            }
                            
                            StandardListItem {
                                title: ListItemData ? ListItemData.author : ""
                                description: ListItemData ? ListItemData.title : ""
                                imageSource: "images/tabs/ic_article.png"
                                
                                gestureHandlers: [
                                    TapHandler {
                                        onTapped: {
                                            console.log("UserEvent: ExpandArticle");
                                            bodyDelegate.delegateActive = !bodyDelegate.delegateActive;
                                        }
                                    }
                                ]
                            }
                            
                            ControlDelegate
                            {
                                id: bodyDelegate
                                horizontalAlignment: HorizontalAlignment.Fill
                                verticalAlignment: VerticalAlignment.Fill
                                delegateActive: false

                                sourceComponent: ComponentDefinition
                                {
                                    TextArea
                                    {
                                        backgroundVisible: false
                                        content.flags: TextContentFlag.ActiveText | TextContentFlag.EmoticonsOff
                                        editable: false
                                        horizontalAlignment: HorizontalAlignment.Fill
                                        text: ListItemData.body+"\n\n"+ListItemData.reference
                                    }
                                }
                            }
                        }
                    }
                ]

                onCreationCompleted: {
                    sql.dataLoaded.connect( function(id, data)
                    {
                        if (id == QueryId.GetArticles)
                        {
                            busy.running = false;
                            
                            gdm.clear();
                            gdm.insertList(data);

                            listView.visible = data.length > 0;
                            emptyDelegate.delegateActive = data.length == 0;
                            navigationPane.parent.unreadContentCount = data.length;
                        }
                    });
                }
            }
            
            ActivityIndicator
            {
                id: busy
                preferredHeight: 200
                horizontalAlignment: HorizontalAlignment.Center
                running: false
            }
        }
    }
}