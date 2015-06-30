import bb.cascades 1.0

NavigationPane
{
    id: root
    
    Menu.definition: CanadaIncMenu
    {
        id: menuDef
        projectName: "salat10"
        allowDonations: true
        bbWorldID: "21198062"
        help.imageSource: "images/menu/ic_help.png"
        help.title: qsTr("Help") + Retranslate.onLanguageChanged
        settings.imageSource: "images/menu/ic_settings.png"
        settings.title: qsTr("Settings") + Retranslate.onLanguageChanged
    }
    
    Page
    {
        id: tabsPage
        actionBarVisibility: lss.firstVisibleItem == 1 ? ChromeVisibility.Overlay : ChromeVisibility.Hidden;

        actions: [
            ActionItem
            {
                id: locationAction
                imageSource: "file:///usr/share/icons/ic_map_all.png"
                ActionBar.placement: 'Signature' in ActionBarPlacement ? ActionBarPlacement["Signature"] : ActionBarPlacement.OnBar
                title: qsTr("Choose Location") + Retranslate.onLanguageChanged
                
                onTriggered: {
                    console.log("UserEvent: LocationPickerTriggered");
                }
            }
        ]

        ListView
        {
            id: tabsList
            property variant firstItem // keeps track of what current items is shown on screen
            snapMode: SnapMode.LeadingEdge
            flickMode: FlickMode.SingleItem
            scrollIndicatorMode: ScrollIndicatorMode.None
            
            dataModel: ArrayDataModel {
                id: adm
            }

            layout: StackListLayout {
                orientation: LayoutOrientation.LeftToRight
            }
            
            function itemType(data, indexPath)
            {
                return data.toString();
            }
            
            listItemComponents: [
                ListItemComponent
                {
                    type: "timings"
                    
                    TimingsContainer
                    {
                        id: cityItem
                        property variant firstItem: ListItem.view.firstItem
                        
                        onFirstItemChanged: {
                            if ("" + firstItem == "" + cityItem.ListItem.indexPath) {
                                cityItem.showAnim();
                            } else {
                                cityItem.hideAnim();
                            }
                        }
                    }
                },
                
                ListItemComponent {
                    type: "location"
                    
                    LocationPane {
                        
                    }
                }
            ]
            
            attachedObjects: [
                ListScrollStateHandler
                {
                    id: lss
                    
                    onScrollingChanged: {
                        if (!scrolling)
                        {
                            if (firstVisibleItem.length == 0) { // race condition check since scolling and firstVisible item is set simultaniously at startup
                                tabsList.firstItem = 0;
                            } else {
                                tabsList.firstItem = firstVisibleItem;
                            }
                        }
                    }
                }
            ]
        }
    }
    
    function onReady()
    {
        adm.append("timings");
        adm.append("location");
    }
    
    onCreationCompleted: {
        app.lazyInitComplete.connect(onReady);
    }
}