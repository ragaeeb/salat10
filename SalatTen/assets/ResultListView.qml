import bb.cascades 1.0

ListView
{
    id: listView
    objectName: "listView"
    property variant translation: translator
    property variant localization: localizer
    property alias util: listUtil
    property bool manualSelected: false
    
    function onCurrentEventChanged()
    {
        var current = boundary.getCurrent( new Date() );
        
        listView.clearSelection();
        manualSelected = true;
        listView.toggleSelection(current.index);
        listView.scrollToItem(current.index, ScrollAnimation.Default);
    }
    
    function edit(indexPath)
    {
        var key = dataModel.data(indexPath).key;
        
        definition.source = "AdjustEventDialog.qml";
        
        var dialog = definition.createObject();
        dialog.key = key;
        dialog.open();
    }
    
    onCreationCompleted: {
        notification.currentEventChanged.connect(onCurrentEventChanged);
    }
    
    dataModel: boundary.getModel()
    
    multiSelectAction: MultiSelectActionItem {}
    
    multiSelectHandler
    {
        actions: [
            ActionItem {
                id: enableAthaan
                title: qsTr("Enable Alarms/Athaans") + Retranslate.onLanguageChanged
                imageSource: "images/ic_athaan_enable.png"
                
                onTriggered: {
                    listUtil.toggleAthaans(true);
                }
            },
            
            ActionItem {
                id: muteAthaans
                objectName: "endMultiChats"
                title: qsTr("Mute Alarms/Athaans") + Retranslate.onLanguageChanged
                imageSource: "images/ic_athaan_mute.png"
                
                onTriggered: {
                    listUtil.toggleAthaans(false);
                }
            },
            
            ActionItem {
                title: qsTr("Copy") + Retranslate.onLanguageChanged
                imageSource: "images/ic_copy.png"
                
                onTriggered: {
                    persist.copyToClipboard( listUtil.textualizeSelected() );
                }
            },
            
            InvokeActionItem {
                title: qsTr("Share") + Retranslate.onLanguageChanged
                
                query {
                    mimeType: "text/plain"
                    invokeActionId: "bb.action.SHARE"
                }
                
                onTriggered: {
                    data = persist.convertToUtf8( listUtil.textualizeSelected() );
                }
            },
            
            ActionItem {
                title: qsTr("Set Custom Sound") + Retranslate.onLanguageChanged
                imageSource: "images/ic_athaan_custom.png"
                
                onTriggered: {
                    listUtil.setCustomAthaans( listUtil.getSelectedKeys() );
                }
            },
            
            DeleteActionItem {
                title: qsTr("Reset Sound") + Retranslate.onLanguageChanged
                imageSource: "images/ic_reset_athaan.png"
                
                onTriggered: {
                    listUtil.resetSound( listUtil.getSelectedKeys() );
                }
            }
        ]
        
        status: qsTr("None selected") + Retranslate.onLanguageChanged
    }
    
    onSelectionChanged: {
        var n = selectionList().length
        multiSelectHandler.status = qsTr("+%n Events Selected", "", n) + Retranslate.onLanguageChanged
        enableAthaan.enabled = muteAthaans.enabled = n > 0;
    }
    
    listItemComponents: [
        ListItemComponent {
            type: "header"
            Header {
                title: Qt.formatDate(ListItemData, Qt.SystemLocaleLongDate);
            }
        },
        
        ListItemComponent
        {
            type: "item"
            
            EventListItem {
                id: eli
            }
        }
    ]
    
    attachedObjects: [
        ListScrollStateHandler {
            id: scrollStateHandler
            
            onFirstVisibleItemChanged:
            {
                if (firstVisibleItem[0] == 0 && firstVisibleItem[1] == 0) {
                    boundary.loadBeginning();
                }
            }
            
            onAtEndChanged: {
                if (atEnd) {
                    boundary.loadMore();
                }
            }
        },
        
        ResultListUtil {
            id: listUtil
        }
    ]
}