import bb.cascades 1.2

Container
{
    id: root
    background: Color.create("#66000000")
    leftPadding: 30
    rightPadding: 30
    bottomPadding: 30
    topPadding: 30
    horizontalAlignment: HorizontalAlignment.Fill
    preferredHeight: 376
    layout: DockLayout {}
    
    function cleanUp()
    {
        boundary.recalculationNeeded.disconnect(refresh);
        notification.currentEventChanged.disconnect(refresh);
        currentEvent.cleanUp();
        nextEvent.cleanUp();
    }
    
    onTouch: {
        if ( event.isDown() ) {
            background = Color.create("#99000000");
        } else if ( event.isUp() || event.isCancel() ) {
            background = Color.create("#66000000");
        }
    }
    
    function hasCalendar()
    {
        if ( offloader.noCalendarAccess() )
        {
            var allMessages = [];
            var allIcons = [];
            allMessages.push("Warning: It seems like the app does not have access to your Calendar. This permission is needed for the app to respond to 'calendar' commands if you want to ever check your device's local calendar remotely. If you leave this permission off, some features may not work properly. Tap OK to enable the permissions in the Application Permissions page.");
            allIcons.push("images/toast/ic_calendar_empty.png");
            permissions.messages = allMessages;
            permissions.icons = allIcons;
            permissions.delegateActive = true;
        } else {
            return true;
        }
    }
    
    function refresh()
    {
        var now = new Date();
        var adjust = persist.getValueFor("hijri");
        var hijriDate = hijriCalc.writeIslamicDate(adjust, now);
        
        hijriActionSet.title = hijriDate;
        hijriActionSet.subtitle = adjust == 0 ? qsTr("No adjustments") : adjust > 0 ? "+"+adjust.toString() : adjust.toString();
        dateDetails.text = hijriDate;
        
        var currentOne = boundary.getCurrent(now);
        currentOne.active = true;
        
        currentEvent.current = currentOne;
        nextEvent.current = boundary.getNext(now);
        timings.onFooterShown();
    }
    
    function onSettingChanged(newValue, key) {
        refresh();
    }
    
    function editTiming(key)
    {
        var dialog = definition.init("AdjustEventDialog.qml");
        dialog.key = key;
        dialog.open();
    }
    
    function editIqaamah(key, value)
    {
        var dialog = definition.init("JamaahPickerDialog.qml");
        dialog.key = key;
        dialog.base = value;
        dialog.open();
    }
    
    onCreationCompleted: {
        boundary.recalculationNeeded.connect(refresh);
        notification.currentEventChanged.connect(refresh);
        persist.registerForSetting(root, "athaans", false, false);
        persist.registerForSetting(root, "notifications");
        persist.registerForSetting(root, "hijri", false, false);
    }
    
    Container
    {
        id: previewContainer
        horizontalAlignment: HorizontalAlignment.Fill
        verticalAlignment: VerticalAlignment.Center
        
        Container
        {
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Center
            bottomPadding: 20
            
            layout: StackLayout {
                orientation: LayoutOrientation.LeftToRight
            }
            
            ImageButton
            {
                id: convertHijri
                defaultImageSource: "images/list/ic_calendar_hijri.png"
                pressedImageSource: defaultImageSource
                verticalAlignment: VerticalAlignment.Center
                translationX: -150
                
                onClicked: {
                    var dialog = definition.init("HijriConverterDialog.qml");
                    dialog.open();
                }
            }
            
            Label
            {
                id: dateDetails
                textStyle.fontSize: FontSize.Large
                verticalAlignment: VerticalAlignment.Center
                multiline: true
                opacity: 0
                
                layoutProperties: StackLayoutProperties {
                    spaceQuota: 1
                }
                
                onCreationCompleted: {
                    if ( "navigation" in dateDetails ) {
                        var nav = dateDetails.navigation;
                        nav.focusPolicy = 0x2;
                    }
                }
            }
            
            ImageButton
            {
                id: compassButton
                horizontalAlignment: HorizontalAlignment.Right
                verticalAlignment: VerticalAlignment.Center
                defaultImageSource: "images/compass/ic_compass.png"
                pressedImageSource: defaultImageSource
                translationX: 300
                
                onClicked: {
                    console.log("UserEvent: OpenCompass");
                    var c = definition.init("CompassPane.qml");
                    c.open();
                    reporter.record("OpenCompass");
                }
            }
            
            ImageButton
            {
                id: editDate
                defaultImageSource: "images/menu/ic_edit.png"
                pressedImageSource: defaultImageSource
                verticalAlignment: VerticalAlignment.Center
                horizontalAlignment: HorizontalAlignment.Right
                translationX: 150
                
                onClicked: {
                    console.log("UserEvent: EditHijriDate");
                    
                    var dialog = definition.init("AdjustHijriDialog.qml");
                    dialog.open();
                }
            }
            
            contextActions: [
                ActionSet
                {
                    id: hijriActionSet
                    
                    ActionItem
                    {
                        title: qsTr("Export") + Retranslate.onLanguageChanged
                        imageSource: "images/menu/ic_calendar_add.png"
                        
                        function onExportReady(daysToExport, result, accountId)
                        {
                            progressDelegate.delegateActive = true;
                            offloader.exportToCalendar(daysToExport, result, accountId);
                            
                            navigationPane.pop();
                        }
                        
                        onTriggered: {
                            if ( hasCalendar() )
                            {
                                var exporter = definition.init("CalendarExport.qml");
                                exporter.exportingReady.connect(onExportReady);
                                
                                navigationPane.push(exporter);
                            }
                        }
                    }
                    
                    InvokeActionItem
                    {
                        id: iai
                        title: qsTr("Share") + Retranslate.onLanguageChanged
                        imageSource: "images/menu/ic_share.png"
                        
                        query {
                            mimeType: "text/plain"
                            invokeActionId: "bb.action.SHARE"
                        }
                        
                        onTriggered: {
                            console.log("UserEvent: ShareTimes");
                            var target = new Date();
                            var today = boundary.calculate(target);
                            var location = persist.getValueFor("location");
                            
                            var result = Qt.formatDate(target, Qt.SystemLocaleLongDate);
                            
                            if (location) {
                                result += ": "+location;
                            }
                            
                            result += "\n\n";
                            
                            for (var i = 0; i < today.length; i++) {
                                result += translator.render(today[i].key)+": "+Qt.formatTime(today[i].value, Qt.SystemLocaleShortDate) + "\n";
                            }
                            
                            iai.data = result.trim()+"\n\n[Shared from Salat10]";
                        }
                    }
                    
                    ActionItem
                    {
                        imageSource: "images/common/ic_copy.png"
                        title: qsTr("Copy Date") + Retranslate.onLanguageChanged
                        
                        onTriggered: {
                            console.log("UserEvent: CopyTodayHijri");
                            persist.copyToClipboard(dateDetails.text);
                        }
                    }
                    
                    DeleteActionItem
                    {
                        id: clearAction
                        title: qsTr("Clear Exported Events") + Retranslate.onLanguageChanged
                        imageSource: "images/menu/ic_calendar_delete.png"
                        
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
                        
                        onTriggered: {
                            console.log("UserEvent: ClearExportedEvents");
                            
                            if ( hasCalendar() ) {
                                persist.showConfirmDialog( clearAction, qsTr("Are you sure you want to clear all the calendar events?") );
                            }
                            
                            reporter.record("ClearExportedEvents");
                        }
                    }
                }
            ]
        }
        
        Divider {}
        
        PreviewEvent
        {
            id: currentEvent
            style.fontWeight: FontWeight.Bold
            bottomPadding: 20
        }
        
        PreviewEvent
        {
            id: nextEvent
            style.fontSize: FontSize.Medium
            topPadding: 10
        }
    }
    
    animations: [
        SequentialAnimation
        {
            id: ttx
            
            onCreationCompleted: {
                play();
            }
            
            FadeTransition {
                target: dateDetails
                fromOpacity: 0
                toOpacity: 1
                delay: 350
                duration: 1000
                easingCurve: StockCurve.QuadraticOut
            }
            
            TranslateTransition
            {
                target: editDate
                
                fromX: 150
                toX: 0
                duration: global.getRandomReal(200, 400)
                delay: global.getRandomReal(100, 250)
                easingCurve: StockCurve.SineOut
            }
            
            TranslateTransition
            {
                target: compassButton
                
                fromX: 300
                toX: 0
                duration: global.getRandomReal(200, 400)
                delay: global.getRandomReal(100, 250)
                easingCurve: StockCurve.QuadraticInOut
            }
            
            TranslateTransition
            {
                target: convertHijri
                
                fromX: -150
                toX: 0
                duration: global.getRandomReal(200, 400)
                delay: global.getRandomReal(100, 250)
                easingCurve: StockCurve.ExponentialOut
            }
        }
    ]
}