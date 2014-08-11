import bb.cascades 1.0
import bb.system 1.0

NavigationPane
{
    id: navigationPane
    signal locateClicked();
    
    function onSettingChanged(key)
    {
        mainPage.actionsEnabled = persist.contains("latitude") && persist.contains("longitude");
        
        if (key == "hijri") {
            mainPage.titleBar.bannerText = hijri.writeIslamicDate( persist.getValueFor("hijri") );
        }
    }
    
    function initialized()
    {
        persist.settingChanged.connect(onSettingChanged);
        onSettingChanged("hijri");
        
        if ( !persist.contains("athanPrompted") ) {
            athaanDialog.show();
        } else if ( !persist.contains("athanPicked") && app.atLeastOneAthanScheduled ) {
            definition.source = "AthanPreviewSheet.qml";
            var picker = definition.createObject();
            picker.open();
        } else if ( !persist.contains("tutorialMuteAthan") ) {
            definition.source = "MuteAthanTutorial.qml";
            var picker = definition.createObject();
            picker.open();
        } else if ( persist.tutorialVideo("http://www.youtube.com/watch?v=AbHZLmWSKts") ) {}
        else if ( persist.tutorial( "tutorialSettings", qsTr("If your Fajr and Isha prayer timings seem to be incorrect, you may need to choose another Calculation Angles that is specific to the area you are living in.\n\nTo do this swipe-down from the top-bezel and go to Settings. You will then find the Calculation Angles dropdown."), "asset:///images/dropdown/ic_angles.png" ) ) {}
        else if ( persist.tutorial( "tutorialSelectiveAthan", qsTr("Do you want to enable some athans but disable other ones?\n\nYou can do this by tapping on the prayers that you want to play the athan for (ie: Fajr, Maghrib) so they become highlighted. Then from the menu on the right choose 'Enable Alarams/Athans'."), "asset:///images/ic_athaan_enable.png" ) ) {}
        else if ( persist.tutorial( "tutorialCustomAthan", qsTr("Do you know how to choose your own custom athan?\n\nIf you wanted your own custom athan to be played for all Maghrib prayers for example, tap on the Maghrib item in the list, and from the menu choose 'Set Custom Sound'. Then choose the audio file to play.\n\nTo reset back to default, use the Reset Sound action from the menu."), "asset:///images/ic_athaan_custom.png" ) ) {}
        else if ( persist.tutorial( "tutorialExportCalendar", qsTr("Do you want to sync the timings with your device calendar?\n\nYou can do this by tapping on the '...' icon on the bottom-right menu, and choosing 'Export to Calendar'\n\nTo remove them, use the Clear Exported Events action."), "asset:///images/ic_calendar_empty.png" ) ) {}
        else if ( persist.tutorial( "tutorialHijriDate", qsTr("Did you know you can see the current Hijri date by tapping on the SALAT10 title-bar at the top? Try it!\n\nIf your Hijri date is off by a day or two, simply press-and-hold on it and choose 'Edit' from the menu on the right!"), "asset:///images/ic_calendar_empty.png" ) ) {}
        else if ( persist.tutorial( "tutorialEdit", qsTr("Are your timings off by a few minutes from your local masjid?\n\nThat's easy to fix, simply press-and-hold on the time that is off (ie: Maghrib), and from the menu on the right side choose 'Edit'. You will then be able to adjust the results by up to 10 minutes."), "asset:///images/menu/ic_edit.png" ) ) {}
        else if ( persist.tutorial( "tutorialNewMuslim", qsTr("Are you a new Muslim?\n\nIf you need step-by-step tutorials on the prayer, please have a look at the 'Tutorial' tab on the menu on the left-side. It should be of help to you in shaa Allah!"), "asset:///images/tabs/ic_tutorial.png" ) ) {}
        else if ( !persist.contains("alFurqanAdvertised") ) {
            definition.source = "AlFurqanAdvertisement.qml";
            var picker = definition.createObject();
            picker.open();
        } else if ( reporter.performCII() ) {}
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
                imageSource: "images/menu/ic_refresh.png"
                enabled: mainPage.actionsEnabled
                ActionBar.placement: ActionBarPlacement.OnBar
                
                onTriggered: {
                    console.log("UserEvent: RefreshTimes");
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
                imageSource: "images/menu/ic_share.png"
                enabled: mainPage.actionsEnabled
                
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
                    
                    result = result.substring(0, result.length-1); // remove last new line
                    iai.data = result
                }
                
                ActionBar.placement: ActionBarPlacement.OnBar
            },
	        
	        ActionItem
	        {
	            id: exportAction
	            title: qsTr("Export to Calendar")
	            imageSource: "images/menu/ic_calendar_add.png"
	            enabled: mainPage.actionsEnabled
	            
                function onExportReady(daysToExport, result, accountId)
                {
                    progressDelegate.delegateActive = true;
                    app.exportToCalendar(daysToExport, result, accountId);
                    
                    navigationPane.pop();
                }

	            onTriggered: {
                    console.log("UserEvent: ExportToCalendar");
	                
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
                imageSource: "images/menu/ic_calendar_delete.png"
	            
	            onTriggered: {
                    console.log("UserEvent: ClearExportedEvents");
	                
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
                            console.log("UserEvent: ClearExportedConfirmation", value);
			                
			                if (value == SystemUiResult.ConfirmButtonSelection) {
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
                    console.log("UserEvent: TimeTriggered", indexPath);
                    
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
            
            BenefitOverlay {
                id: benefit
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
	
    attachedObjects: [
        ComponentDefinition {
            id: definition
        },
        
        SystemDialog {
            id: athaanDialog
            title: qsTr("Enable Athan?") + Retranslate.onLanguageChanged
            body: qsTr("Do you want to enable athans to automatically play when it is time for salah?") + Retranslate.onLanguageChanged
            rememberMeText: qsTr("Display notifications in the BlackBerry Hub") + Retranslate.onLanguageChanged
            cancelButton.label: qsTr("No") + Retranslate.onLanguageChanged
            confirmButton.label: qsTr("Yes") + Retranslate.onLanguageChanged
            rememberMeChecked: true
            includeRememberMe: true
            
            onFinished: {
                var enableAthaan = result == SystemUiResult.ConfirmButtonSelection;
                var enableNotifications = rememberMeSelection();
                
                var notifications = persist.getValueFor("notifications");
                var athaans = persist.getValueFor("athaans");
                var keys = translator.eventKeys();
                
                for (var i = keys.length-1; i >= 0; i--)
                {
                    notifications[ keys[i] ] = enableNotifications;
                    athaans[ keys[i] ] = enableAthaan;
                }
                
                persist.saveValueFor("notifications", notifications);
                persist.saveValueFor("athaans", athaans);
                persist.saveValueFor("athanPrompted", 1, false);
            }
        }
    ]
}