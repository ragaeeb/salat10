import bb.cascades 1.0
import bb.system 1.0

NavigationPane
{
    id: navigationPane
    signal locateClicked();

    attachedObjects: [
        ComponentDefinition {
            id: definition
        }
    ]
    
    function onSettingChanged(key)
    {
        mainPage.actionsEnabled = persist.contains("latitude") && persist.contains("longitude");
        
        if (key == "hijri") {
            mainPage.titleBar.bannerText = hijri.writeIslamicDate( persist.getValueFor("hijri") );
        }
        
        if (mainPage.actionsEnabled) {
            persist.tutorialVideo("http://www.youtube.com/watch?v=AbHZLmWSKts");
        }
    }
    
    function initialized()
    {
        persist.settingChanged.connect(onSettingChanged);
        onSettingChanged("hijri");
    }
    
    onCreationCompleted: {
        app.initialize.connect(initialized);
    }
    
    onPopTransitionEnded: {
        page.destroy();
    }
    
	Page
	{
        id: mainPage
        property bool actionsEnabled: false;
        actionBarAutoHideBehavior: ActionBarAutoHideBehavior.HideOnScroll
        
        onPeekedAtChanged: {
            listView.secretPeek = peekedAt;
        }
        
        titleBar: SalatTitleBar
        {
            onEditTitleTriggered: {
                definition.source = "AdjustHijriDialog.qml";
                
                var dialog = definition.createObject();
                dialog.open();
            }
        }
        
	    actions: [
            ActionItem {
                title: qsTr("Refresh") + Retranslate.onLanguageChanged
                imageSource: "images/ic_refresh.png"
                enabled: mainPage.actionsEnabled
                ActionBar.placement: ActionBarPlacement.OnBar
                
                onTriggered: {
                    listView.onCurrentEventChanged();
                }
                
                shortcuts: [
                    SystemShortcut {
                        type: SystemShortcuts.Reply
                    }
                ]
            },
            
            InvokeActionItem {
                id: iai
                title: qsTr("Share") + Retranslate.onLanguageChanged
                enabled: mainPage.actionsEnabled
                
                query {
                    mimeType: "text/plain"
                    invokeActionId: "bb.action.SHARE"
                }
                
                onTriggered: {
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
                    
                    result = result.substring(0, result.length-1); // remove last new line
                    iai.data = result
                }
                
                ActionBar.placement: ActionBarPlacement.OnBar
            },
	        
	        ActionItem
	        {
	            id: exportAction
	            title: qsTr("Export to Calendar")
	            imageSource: "file:///usr/share/icons/ic_add_event.png"
	            enabled: mainPage.actionsEnabled
	            
                function onExportReady(daysToExport, result, accountId)
                {
                    progressDelegate.delegateActive = true;
                    app.exportToCalendar(daysToExport, result, accountId);
                    
                    navigationPane.pop();
                }

	            onTriggered: {
	                if (app.hasCalendarAccess)
	                {
                        definition.source = "CalendarExport.qml";
                        
                        var exporter = definition.createObject();
                        exporter.exportingReady.connect(onExportReady);
                        
                        navigationPane.push(exporter);
	                }
                }
	            
                shortcuts: [
                    Shortcut {
                        key: qsTr("X") + Retranslate.onLanguageChanged
                    }
                ]
	        },
	        
	        DeleteActionItem
	        {
	            id: clearAction
                title: qsTr("Clear Exported Events") + Retranslate.onLanguageChanged
                imageSource: "images/ic_calendar_delete.png"
	            
	            onTriggered: {
                    if (app.hasCalendarAccess) {
                        prompt.show();
                    }
                }
	            
	            attachedObjects: [
	                SystemDialog {
	                    id: prompt
                        title: qsTr("Confirmation") + Retranslate.onLanguageChanged
                        body: qsTr("Are you sure you want to clear all the scheduled calendar reminders?") + Retranslate.onLanguageChanged
                        confirmButton.label: qsTr("Yes") + Retranslate.onLanguageChanged
                        cancelButton.label: qsTr("No") + Retranslate.onLanguageChanged
                        
			            onFinished: {
			                if (result == SystemUiResult.ConfirmButtonSelection) {
                                progressDelegate.delegateActive = true;
			                    app.cleanupCalendarEvents();
			                }
			            }
	                }
	            ]
            }
	    ]
	    
        Container
        {
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Fill
            background: back.imagePaint
            layout: DockLayout {}
            
            EmptyDelegate
            {
                id: emptyDelegate
                graphic: "images/empty/ic_no_coordinates.png"
                labelText: qsTr("No coordinates detected. Either wait for the GPS to detect your location or tap here to pick a location.") + Retranslate.onLanguageChanged
                delegateActive: boundary.empty && !persist.contains("latitude")
                
                onImageTapped: {
                    locateClicked();
                }
            }
            
            ResultListView 
            {
                id: listView
                visible: !boundary.empty
                property bool secretPeek: false
                
                function manualDeselect()
                {
                    clearSelection();
                    manualSelected = false;
                }
                
                onActivationChanged: {
                    if (active && manualSelected) {
                        manualDeselect();
                    }
                }
                
                onTriggered: {
                    if (manualSelected) {
                        manualDeselect();
                    }
                    
                    multiSelectHandler.active = true;
                    toggleSelection(indexPath);
                }
            }
            
            ControlDelegate
            {
                id: progressDelegate
                horizontalAlignment: HorizontalAlignment.Center
                delegateActive: false;
                
                function onProgressChanged(current, total)
                {
                    control.showBusy = false;
                    control.value = current;
                    control.toValue = total;
                }
                
                function onComplete(message, icon)
                {
                    delegateActive = false;
                    persist.showToast(message, "", icon);
                }
                
                onCreationCompleted: {
                    app.operationProgress.connect(onProgressChanged);
                    app.operationComplete.connect(onComplete);
                }
                
                onControlChanged: {
                    exportAction.enabled = clearAction.enabled = control == null;
                }
                
                sourceComponent: ComponentDefinition
                {
                    Container
                    {
                        property alias value: progress.value
                        property alias toValue: progress.toValue
                        property alias showBusy: busy.running
                        horizontalAlignment: HorizontalAlignment.Fill
                        
                        ActivityIndicator
                        {
                            id: busy
                            horizontalAlignment: HorizontalAlignment.Center
                            preferredHeight: 100; preferredWidth: 100
                            running: true
                        }
                        
                        ProgressIndicator
                        {
                            id: progress
                            fromValue: 0;
                            horizontalAlignment: HorizontalAlignment.Center
                            state: ProgressIndicatorState.Progress
                        }
                    }
                }
            }
        }
        
        attachedObjects: [
            HijriCalculator {
                id: hijri
            },
            
            ImagePaintDefinition {
                id: back
                imageSource: "images/graphics/background.png"
            }   
        ]
	}
}