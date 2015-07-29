import bb.cascades 1.2

Container
{
    id: root
    horizontalAlignment: HorizontalAlignment.Fill
    
    function onSettingChanged(newValue, key)
    {
        var now = new Date();
        var adjust = persist.getValueFor("hijri");
        var hijriDate = root.ListItem.view.hijriCalc.writeIslamicDate(adjust);
        
        hijriActionSet.title = hijriDate;
        hijriActionSet.subtitle = adjust == 0 ? qsTr("No adjustments") : adjust > 0 ? "+"+adjust.toString() : adjust.toString();
        dateDetails.text = hijriDate;
        
        currentEvent.current = boundary.getCurrent(now);
        nextEvent.current = boundary.getNext(now);
    }
    
    function editTiming(key)
    {
        var dialog = definition.init("AdjustEventDialog.qml");
        dialog.key = key;
        dialog.open();
    }
    
    ListItem.onInitializedChanged: {
        if (initialized)
        {
            persist.registerForSetting(root, "hijri", false, false);
            persist.registerForSetting(root, "athaans", false, false);
            persist.registerForSetting(root, "notifications", false, false);
            onSettingChanged();
        }
    }
    
    onCreationCompleted: {
        topPadding = ListItem.view.maxHeight - contentContainer.preferredHeight
    }
    
    layout: StackLayout {
        orientation: LayoutOrientation.LeftToRight
    }
    
    Container
    {
        id: contentContainer
        background: Color.create("#66000000")
        leftPadding: 30
        rightPadding: 30
        bottomPadding: 30
        topPadding: 30
        horizontalAlignment: HorizontalAlignment.Fill
        preferredHeight: 376
        layout: DockLayout {}
        
        layoutProperties: StackLayoutProperties {
            spaceQuota: 1
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
                    defaultImageSource: "images/menu/ic_calendar_add.png"
                    pressedImageSource: defaultImageSource
                    verticalAlignment: VerticalAlignment.Center
                    
                    onClicked: {
                        root.ListItem.view.exportToCalendar();
                    }
                }
                
                Label
                {
                    id: dateDetails
                    textStyle.fontSize: FontSize.XLarge
                    verticalAlignment: VerticalAlignment.Center
                    multiline: true
                    
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
                    defaultImageSource: "images/list/ic_calendar_hijri.png"
                    pressedImageSource: defaultImageSource
                    verticalAlignment: VerticalAlignment.Center
                    horizontalAlignment: HorizontalAlignment.Right
                    
                    onClicked: {
                        root.ListItem.view.showHijriConverter();
                    }
                }
                
                contextActions: [
                    ActionSet
                    {
                        id: hijriActionSet
                        
                        ActionItem {
                            title: qsTr("Edit Date") + Retranslate.onLanguageChanged
                            imageSource: "images/menu/ic_edit.png"
                            
                            onTriggered: {
                                console.log("UserEvent: EditHijriDate");

                                var dialog = definition.init("AdjustHijriDialog.qml");
                                dialog.open();
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
                                
                                iai.data = result.trim();
                            }
                        }
                        
                        DeleteActionItem
                        {
                            id: clearAction
                            title: qsTr("Clear Exported Events") + Retranslate.onLanguageChanged
                            imageSource: "images/menu/ic_calendar_delete.png"
                            
                            onTriggered: {
                                console.log("UserEvent: ClearExportedEvents");
                                root.ListItem.view.clearCalendar();
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
    }
}