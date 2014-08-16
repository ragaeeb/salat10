import bb.cascades 1.0

Page
{
    actionBarAutoHideBehavior: ActionBarAutoHideBehavior.HideOnScroll
    
    titleBar: TitleBar {
        title: qsTr("Clarification") + Retranslate.onLanguageChanged
    }
    
    Container
    {
        horizontalAlignment: HorizontalAlignment.Fill
        verticalAlignment: VerticalAlignment.Fill
        
        TextArea
        {
            editable: false
            textFormat: TextFormat.Html
            text: qsTr("Bismillah,\nAlhamdulillah,\nWa salaatu wa salaamu ala rasoolillah.\nAs'salaamu alaykum wa rahmatullahi wabarakathu.\n\nIn the past version of the app we have erroneously included in our articles and tutorials some individuals who have issues in their manhaj. We would like to publicly clarify and free ourselves from such individuals and make it clear that we do not support them.\n\nThe individuals we are listed below and you can find more information about their issues if you click on them in shaa Allah.\n\nJazakAllahu khayran. May Allah forgive us for our shortcomings and keep us upright. BaarakAllahu feekum.")
            maxHeight: 300
        }
        
        ListView
        {
            dataModel: ArrayDataModel {
                id: adm
            }
            
            listItemComponents: [
                ListItemComponent
                {
                    StandardListItem
                    {
                        id: sli
                        title: ListItemData.name
                        imageSource: "images/ic_folder_warning.png"
                        translationY: -100
                        
                        animations: [
                            TranslateTransition {
                                id: tt
                                fromY: -100
                                toY: 0
                                duration: 1000
                                delay: Math.min(sli.ListItem.indexInSection * 100, 1000)
                                easingCurve: StockCurve.QuadraticOut
                            }
                        ]
                        
                        ListItem.onInitializedChanged: {
                            if (initialized) {
                                tt.play();
                            }
                        }
                    }
                }
            ]
            
            onTriggered: {
                console.log("UserEvent: ClarificationTriggered", indexPath);
                var uri = dataModel.data(indexPath).uri;
                
                if (uri) {
                    app.launchBrowser(uri);
                }
            }
            
            onCreationCompleted: {
                var misguided = [
                    {'name': qsTr("Abdulllah as-Sabt"), 'uri': "http://salafitalk.net/st/viewmessages.cfm?Forum=6&Topic=10170"},
                    {'name': qsTr("Abu Khaliyl")},
                    {'name': qsTr("Fawzee al-Bahraini"), 'uri': "http://www.salafitalk.net/st/viewmessages.cfm?Forum=25&Topic=11688"},
                    {'name': qsTr("Mohammad bin Rizq at-Tarhuni")},
                    {'name': qsTr("Suhaib Hasan"), 'uri': "http://www.troid.ca/index.php/manhaj/abandoning-innovation/groups-and-partisanship/363-deviant-sects-of-the-20th-century"}
                ];
                
                adm.append(misguided);
            }
        }
    }
}