import bb.cascades 1.2

ListView
{
    id: listView
    property bool draggingStarted: false
    property alias hijriCalc: hijri
    property alias fontStyle: tsd.style
    property variant localization: offloader
    property variant translation: translator
    property alias lssh: scrollStateHandler
    property alias anim: showAnim
    signal footerShown()
    flickMode: FlickMode.SingleItem
    objectName: "listView"
    scrollIndicatorMode: ScrollIndicatorMode.None
    snapMode: SnapMode.LeadingEdge
    stickToEdgePolicy: ListViewStickToEdgePolicy.Beginning

    function refresh()
    {
        var current = boundary.getCurrent( new Date() );

        listView.scrollToItem(current.index, ScrollAnimation.Default);
    }

    function edit(indexPath)
    {
        var key = dataModel.data(indexPath).key;
        
        var dialog = definition.init("AdjustEventDialog.qml");
        dialog.key = key;
        dialog.open();
    }
    
    function setJamaah(indexPath)
    {
        var data = dataModel.data(indexPath);
        
        var dialog = definition.init("JamaahPickerDialog.qml");
        dialog.key = data.key;
        dialog.base = data.value;
        dialog.open();
    }
    
    function removeJamaah(indexPath)
    {
        app.removeIqamah( dataModel.data(indexPath).key );
        persist.showToast( qsTr("Iqamah time removed"), "", "asset:///images/menu/ic_remove_jamaah.png" );
    }
    
    function itemType(data, indexPath)
    {
        if (!draggingStarted && indexPath == 0) {
            return "preview";
        } else if (indexPath.length == 1) {
            return "header";
        } else {
            return "item";
        }
    }
    
    dataModel: boundary.getModel()
    
    multiSelectHandler
    {
        actions: [
            ActionItem {
                id: enableAthaan
                title: qsTr("Enable Alarms/Athans") + Retranslate.onLanguageChanged
                imageSource: "images/list/ic_athaan_enable.png"
                
                onTriggered: {
                    console.log("UserEvent: EnableAthans");
                    listUtil.active = true;
                    listUtil.object.toggleAthaans(true);
                }
            },
            
            ActionItem {
                id: muteAthaans
                objectName: "endMultiChats"
                title: qsTr("Mute Alarms/Athans") + Retranslate.onLanguageChanged
                imageSource: "images/list/ic_athaan_mute.png"
                
                onTriggered: {
                    console.log("UserEvent: MuteAthans");
                    listUtil.active = true;
                    listUtil.object.toggleAthaans(false);
                }
            },
            
            ActionItem
            {
                id: copyAction
                title: qsTr("Copy") + Retranslate.onLanguageChanged
                imageSource: "images/menu/ic_copy.png"
                
                onTriggered: {
                    console.log("UserEvent: CopyMultiToClipboard");
                    listUtil.active = true;
                    persist.copyToClipboard( listUtil.object.textualizeSelected() );
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
                    console.log("UserEvent: ShareMultiResults");
                    listUtil.active = true;
                    data = persist.convertToUtf8( listUtil.object.textualizeSelected() );
                }
            },
            
            ActionItem {
                id: customSoundAction
                title: qsTr("Change Sound") + Retranslate.onLanguageChanged
                imageSource: "images/menu/ic_athaan_custom.png"
                
                onTriggered: {
                    console.log("UserEvent: ChangeSound");
                    var picker = definition.init("AthanPreviewSheet.qml");
                    listUtil.active = true;
                    
                    picker.all = listUtil.object.getSelectedKeys();
                    picker.open();
                }
            },
            
            DeleteActionItem {
                id: resetSoundAction
                title: qsTr("Reset Sound") + Retranslate.onLanguageChanged
                imageSource: "images/menu/ic_reset_athaan.png"
                
                onTriggered: {
                    console.log("UserEvent: ResetCustomAthan");
                    listUtil.active = true;
                    listUtil.object.resetSound( listUtil.object.getSelectedKeys() );
                }
            }
        ]
        
        status: qsTr("None selected") + Retranslate.onLanguageChanged
    }
    
    onSelectionChanged: {
        if (selected && indexPath.length == 1) {
            select(indexPath, false);
            return;
        }
        
        var n = selectionList().length;
        multiSelectHandler.status = qsTr("+%n Events Selected", "", n) + Retranslate.onLanguageChanged
        copyAction.enabled = shareAction.enabled = resetSoundAction.enabled = customSoundAction.enabled = enableAthaan.enabled = muteAthaans.enabled = n > 0;
    }
    
    listItemComponents: [
        ListItemComponent
        {
            type: "header"
            HeaderItem {}
        },
        
        ListItemComponent
        {
            type: "item"
            
            EventListItem {
                id: eli
            }
        },
        
        ListItemComponent
        {
            type: "preview"
            PreviewListItem {}
        }
    ]
    
    onTriggered: {
        if (!draggingStarted && indexPath == 0) {
            scrollToItem([0,0], ScrollAnimation.Smooth);
        } else if (indexPath.length > 1) {
            multiSelectHandler.active = true;
            toggleSelection(indexPath);
        }
    }
    
    attachedObjects: [
        ListScrollStateHandler
        {
            id: scrollStateHandler
            property variant lastVisible
            
            onFirstVisibleItemChanged:
            {
                if (firstVisibleItem[0] == 0 && firstVisibleItem[1] == 0) {
                    boundary.loadBeginning();
                }
                
                if (lastVisible != firstVisibleItem && firstVisibleItem.length == 1)
                {
                    footerShown();
                    lastVisible = firstVisibleItem;
                }
            }
            
            onScrollingChanged: {
                if (scrolling) {
                    draggingStarted = true;
                } else if (atBeginning) {
                    draggingStarted = false;
                }
            }
            
            onAtEndChanged: {
                if (atEnd) {
                    boundary.loadMore();
                }
            }
        },
        
        Delegate {
            id: listUtil
            active: false
            source: "ResultListUtil.qml"
        },
        
        HijriCalculator {
            id: hijri
        },
        
        TextStyleDefinition {
            id: tsd
            fontFamily: "sans-serif"
            fontSize: FontSize.Large
        }
    ]
    
    animations: [
        ParallelAnimation
        {
            id: showAnim
            
            FadeTransition {
                fromOpacity: 0
                toOpacity: 1
                duration: 500
                easingCurve: StockCurve.CubicOut
            }
            
            TranslateTransition {
                fromY: 300
                toY: 0
                duration: 500
                easingCurve: StockCurve.CubicOut
            }
        }
    ]
}