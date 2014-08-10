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
    
    function setJamaah(indexPath)
    {
        definition.source = "JamaahPickerDialog.qml";
        
        var data = dataModel.data(indexPath);
        
        var dialog = definition.createObject();
        dialog.key = data.key;
        dialog.base = data.value;
        dialog.open();
    }
    
    function removeJamaah(indexPath)
    {
        boundary.removeIqamah( dataModel.data(indexPath).key );
        persist.showToast( qsTr("Iqamah time removed"), "", "asset:///images/menu/ic_remove_jamaah.png" );
    }
    
    onCreationCompleted: {
        notification.currentEventChanged.connect(onCurrentEventChanged);
    }
    
    dataModel: boundary.getModel()
    
    multiSelectAction: MultiSelectActionItem {
        imageSource: "images/menu/ic_select_more.png"
    }
    
    multiSelectHandler
    {
        actions: [
            ActionItem {
                id: enableAthaan
                title: qsTr("Enable Alarms/Athans") + Retranslate.onLanguageChanged
                imageSource: "images/ic_athaan_enable.png"
                
                onTriggered: {
                    listUtil.toggleAthaans(true);
                }
            },
            
            ActionItem {
                id: muteAthaans
                objectName: "endMultiChats"
                title: qsTr("Mute Alarms/Athans") + Retranslate.onLanguageChanged
                imageSource: "images/ic_athaan_mute.png"
                
                onTriggered: {
                    listUtil.toggleAthaans(false);
                }
            },
            
            ActionItem
            {
                id: copyAction
                title: qsTr("Copy") + Retranslate.onLanguageChanged
                imageSource: "images/menu/ic_copy.png"
                
                onTriggered: {
                    persist.copyToClipboard( listUtil.textualizeSelected() );
                }
            },
            
            InvokeActionItem
            {
                id: shareAction
                imageSource: "images/menu/ic_share.png"
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
                id: customSoundAction
                title: qsTr("Set Custom Sound") + Retranslate.onLanguageChanged
                imageSource: "images/ic_athaan_custom.png"
                
                onTriggered: {
                    listUtil.setCustomAthaans( listUtil.getSelectedKeys() );
                }
            },
            
            DeleteActionItem {
                id: resetSoundAction
                title: qsTr("Reset Sound") + Retranslate.onLanguageChanged
                imageSource: "images/menu/ic_reset_athaan.png"
                
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
        copyAction.enabled = shareAction.enabled = resetSoundAction.enabled = customSoundAction.enabled = enableAthaan.enabled = muteAthaans.enabled = n > 0;
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