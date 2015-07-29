import bb.cascades 1.3

ListView
{
    id: listView
    property alias hijriCalc: hijri
    property alias fontStyle: tsd.style
    property variant localization: offloader
    property variant translation: translator
    property alias lssh: scrollStateHandler
    property alias anim: showAnim
    signal footerShown()
    signal footerGone()
    flickMode: FlickMode.SingleItem
    scrollIndicatorMode: ScrollIndicatorMode.None
    snapMode: SnapMode.LeadingEdge
    stickToEdgePolicy: ListViewStickToEdgePolicy.Beginning
    scrollRole: ScrollRole.Main
    
    function showAthanPrompt()
    {
        listUtil.active = true;
        listUtil.object.athanDialog.show();
    }
    
    function onExportReady(daysToExport, result, accountId)
    {
        progressDelegate.delegateActive = true;
        offloader.exportToCalendar(daysToExport, result, accountId);
        
        navigationPane.pop();
    }
    
    function hasCalendar()
    {
        if ( offloader.hasCalendarAccess() ) {
            return true;
        } else {
            var allMessages = [];
            var allIcons = [];
            allMessages.push("Warning: It seems like the app does not have access to your Calendar. This permission is needed for the app to respond to 'calendar' commands if you want to ever check your device's local calendar remotely. If you leave this permission off, some features may not work properly. Tap OK to enable the permissions in the Application Permissions page.");
            allIcons.push("images/toast/ic_calendar_empty.png");
            permissions.messages = allMessages;
            permissions.icons = allIcons;
            permissions.delegateActive = true;
        }
        
        return false;
    }
    
    function exportToCalendar()
    {
        if ( hasCalendar() )
        {
            definition.source = "CalendarExport.qml";
            
            var exporter = definition.createObject();
            exporter.exportingReady.connect(onExportReady);
            
            navigationPane.push(exporter);
        }
    }
    
    function onFinished(confirmed)
    {
        if (confirmed) {
            console.log("UserEvent: ClearCalendarPromptYes");
            progressDelegate.delegateActive = true;
            offloader.cleanupCalendarEvents();
        } else {
            console.log("UserEvent: ClearCalendarPromptNo");
        }
        
        reporter.record("ClearCalendarResult", confirmed.toString());
    }
    
    function clearCalendar()
    {
        if ( hasCalendar() ) {
            persist.showDialog( timings, qsTr("Confirmation"), qsTr("Are you sure you want to clear all favourites?") );
        }
    }
    
    function refresh()
    {
        var current = boundary.getCurrent( new Date() );
        listView.scrollToItem(current.index, ScrollAnimation.Default);
    }
    
    function showHijriConverter()
    {
        var dialog = definition.init("HijriConverterDialog.qml");
        dialog.open();
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
        if (indexPath.length == 1) {
            return "header";
         } else {
             return "item";
         }
    }
    
    dataModel: boundary.getModel()
    
    multiSelectHandler
    {
        onActiveChanged: {
            if (active) {
                tutorial.execActionBar("enableAlarms", qsTr("Use the '%1' action to enable the athan and notifications for the selected events.").arg(enableAthaan.title), "l" );
                tutorial.execActionBar("muteAlarms", qsTr("Use the '%1' action to disable the athan from sounding for all of the selected events in the future. Note that once you mute it, the app will prompt you if you want to still receive notifications in the BlackBerry Hub (instead of hearing the audio athan).").arg(muteAthaans.title) );
                tutorial.execActionBar("copyEvents", qsTr("Use the '%1' action to copy the timings to your device clipboard.").arg(copyAction.title), "r");
                tutorial.exec("openMultiEventMenu", qsTr("Tap here to expand the menu to show more options."), HorizontalAlignment.Right, VerticalAlignment.Bottom, 0, ui.du(1), 0, ui.du(1));
            }
        }
        
        actions: [
            ActionItem {
                id: enableAthaan
                title: qsTr("Enable Alarms/Athans") + Retranslate.onLanguageChanged
                imageSource: "images/list/ic_athaan_enable.png"
                
                onTriggered: {
                    console.log("UserEvent: EnableAthans");
                    listUtil.active = true;
                    listUtil.object.toggleAthaans(true);
                    reporter.record("EnableAthans");
                }
            },
            
            ActionItem {
                id: muteAthaans
                title: qsTr("Mute Alarms/Athans") + Retranslate.onLanguageChanged
                imageSource: "images/list/ic_athaan_mute.png"
                
                onTriggered: {
                    console.log("UserEvent: MuteAthans");
                    listUtil.active = true;
                    listUtil.object.toggleAthaans(false);
                    reporter.record("MuteAthans");
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
                    reporter.record("CopyMultiToClipboard");
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
                    reporter.record("ShareMultiResults");
                }
            },
            
            ActionItem
            {
                id: customSoundAction
                title: qsTr("Change Sound") + Retranslate.onLanguageChanged
                imageSource: "images/menu/ic_athaan_custom.png"
                
                onTriggered: {
                    console.log("UserEvent: ChangeSound");
                    var picker = definition.init("AthanPreviewSheet.qml");
                    listUtil.active = true;
                    
                    picker.all = listUtil.object.getSelectedKeys();
                    picker.open();
                    
                    reporter.record("ChangeSound");
                }
            },
            
            DeleteActionItem
            {
                id: resetSoundAction
                title: qsTr("Reset Sound") + Retranslate.onLanguageChanged
                imageSource: "images/menu/ic_reset_athaan.png"
                
                onTriggered: {
                    console.log("UserEvent: ResetCustomAthan");
                    listUtil.active = true;
                    listUtil.object.resetSound( listUtil.object.getSelectedKeys() );
                    reporter.record("ResetCustomAthan");
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
        if (indexPath.length > 1) {
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
                } else if (firstVisibleItem[0] == 1 && firstVisibleItem[1] == 2) {
                    footerGone();
                    
                    tutorial.execBelowTitleBar( "selectiveAthan", qsTr("Do you want to enable some athans but disable other ones?\n\nYou can do this by tapping on the prayers that you want to play the athan for (ie: Fajr, Maghrib) so they become highlighted. Then from the menu choose 'Enable Alarams/Athans'.") );
                    tutorial.execBelowTitleBar( "editTimings", qsTr("Are your timings off by a few minutes from your local masjid?\n\nThat's easy to fix, simply press-and-hold on the time that is off (ie: Maghrib), and from the menu on the right side choose 'Edit'. You will then be able to adjust the results by up to 10 minutes."), 10 );
                    tutorial.execBelowTitleBar( "setIqamah", qsTr("You can also set iqamah times for when they pray at your local masjid/musalla by pressing-and-holding on the event and choosing 'Set Iqamah'."), 20 );
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