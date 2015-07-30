import bb.cascades 1.3

ListView
{
    id: listView
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
    
    onCreationCompleted: {
        if ( !persist.containsFlag("athanPrompted") ) {
            showAthanPrompt();
        } else {
            tutorial.execCentered("randomBenefit", qsTr("You can tap on the author's name to find out more information about them (you need to have the Quran10 app installed).") );
            tutorial.exec("todaysHijriDate", qsTr("This is today's Hijri date."), HorizontalAlignment.Center, VerticalAlignment.Bottom, 0, 0, 0, ui.du(17) );
            tutorial.exec("exportToCalendar", qsTr("You can tap on the calendar icon to export the timings right to your calendar so that you can get prayer time reminders to show up directly on your device's calendar. This will also allow reminders to be shown even while the app is closed!"), HorizontalAlignment.Left, VerticalAlignment.Bottom, ui.du(2), 0, 0, ui.du(17) );
            tutorial.exec("hijriConverter", qsTr("You can tap on this calendar icon to convert between Hijri and Gregorian calendar dates!"), HorizontalAlignment.Right, VerticalAlignment.Bottom, 0, ui.du(2), 0, ui.du(17) );
            tutorial.exec("editDate", qsTr("If the date is incorrect, press-and-hold on it and choose 'Edit Date' from the menu."), HorizontalAlignment.Center, VerticalAlignment.Bottom, 0, 0, 0, ui.du(17) );
            tutorial.exec("currentEvent", qsTr("This displays the current event that is already in progress."), HorizontalAlignment.Left, VerticalAlignment.Bottom, ui.du(10), 0, 0, ui.du(8) );
            tutorial.exec("toggleCurrentEvent", qsTr("Tapping on the icon will toggle the athan and notification settings for that specific event. So if you want to turn on or turn off the athan and notifications tap on the icon."), HorizontalAlignment.Left, VerticalAlignment.Bottom, ui.du(2), 0, 0, ui.du(8) );
            tutorial.exec("nextEvent", qsTr("This displays the next event that is coming up."), HorizontalAlignment.Left, VerticalAlignment.Bottom, ui.du(10), 0, 0, ui.du(1) );
            tutorial.exec("toggleNextEvent", qsTr("Tapping on the icon will toggle the athan and notification settings for that next event. So if you want to turn on or turn off the athan and notifications tap on the icon."), HorizontalAlignment.Left, VerticalAlignment.Bottom, ui.du(2), 0, 0, ui.du(1) );
            tutorial.exec("footerTap", qsTr("Tap anywhere on this strip to expand it and see the details for today."), HorizontalAlignment.Right, VerticalAlignment.Bottom, 0, ui.du(8), 0, ui.du(1) );
            tutorial.exec("expandFooter", qsTr("You can also expand this strip by swiping-up on it and see the details."), HorizontalAlignment.Center, VerticalAlignment.Bottom, 0, 0, 0, ui.du(2), "images/menu/ic_top.png");
            tutorial.exec("openAppMenu", qsTr("Swipe down from the top-bezel to display the Settings and Help and file bugs!"), HorizontalAlignment.Center, VerticalAlignment.Top, 0, 0, 0, ui.du(2), "images/menu/ic_bottom.png", "d");
        }
    }
    
    function showAthanPrompt()
    {
        listUtil.active = true;
        listUtil.object.athanDialog.show();
    }
    
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