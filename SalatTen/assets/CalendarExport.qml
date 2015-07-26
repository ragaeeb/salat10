import bb.cascades 1.3
import com.canadainc.data 1.0

Page
{
    signal exportingReady(int daysToExport, variant result, variant accountId)
    actionBarAutoHideBehavior: ActionBarAutoHideBehavior.HideOnScroll
    
    titleBar: TitleBar
    {
        id: titleControl
        kind: TitleBarKind.FreeForm
        scrollBehavior: TitleBarScrollBehavior.NonSticky
        kindProperties: FreeFormTitleBarKindProperties
        {
            Container
            {
                horizontalAlignment: HorizontalAlignment.Fill
                verticalAlignment: VerticalAlignment.Fill
                topPadding: 10; bottomPadding: 20; leftPadding: 10
                
                Label {
                    text: qsTr("Export Events") + Retranslate.onLanguageChanged
                    verticalAlignment: VerticalAlignment.Center
                    textStyle.color: Color.White
                    textStyle.base: SystemDefaults.TextStyles.BigText
                }
            }
            
            expandableArea
            {
                expanded: true
                
                onExpandedChanged: {
                    console.log("UserEvent: CalendarTitleExpanded", expanded);
                }
                
                content: AccountsDropDown
                {
                    id: accountChoice
                    controller: offloader
                    selectedAccountId: persist.getValueFor("accountId")
                    
                    onAccountsLoaded: {
                        if (numAccounts == 0) {
                            persist.showToast( qsTr("Did not find any accounts. Maybe the app does not have the permissions it needs..."), "", "asset:///images/toast/ic_calendar_empty.png" );
                        } else {
                            tutorial.execCentered( "calcIntro", qsTr("You can export the salat times to your device calendar so that a reminder can scheduled when it is time for salat even when this app is not running.") );
                            
                            if (selectedOption == null)
                            {
                                selectedOption = options[0];
                                expanded = true;
                                
                                tutorial.execBelowTitleBar( "chosenAccount", qsTr("Choose the account you want to sync the calendar events with.") );
                            }
                        }
                    }
                    
                    onExpandedChanged: {
                        if (!expanded)
                        {
                            tutorial.exec( "calDaysCount", qsTr("Use the circular slider to select how many days to export to the calendar."), HorizontalAlignment.Center, VerticalAlignment.Top, 0, 0, ui.du(30) );
                            tutorial.exec( "calEventSelection", qsTr("Select the events that you want to export and the ones you don't want to to sync with the calendar by using the checkbox."), HorizontalAlignment.Right, VerticalAlignment.Center, 0, ui.du(25) );
                            tutorial.exec("calEventAdjust", qsTr("Use the slider to adjust how long before or after the event to remind you about it."), HorizontalAlignment.Right, VerticalAlignment.Center, 0, ui.du(20), 0, 0, undefined, "r" );
                            tutorial.execActionBar( "calcExport", qsTr("Once you are ready to export the events to the calendar, tap here to finalize it.").arg(exportAction.title) );
                            tutorial.execActionBar("calcBack", qsTr("Tap here to close this page."), "b" );
                        }
                    }
                    
                    onSelectedValueChanged: {
                        var changed = persist.saveValueFor("accountId", selectedValue, false);
                        
                        if (changed) {
                            console.log("UserEvent: CalendarAccountChosen", selectedValue);
                        }
                    }
                }
            }
        }
    }
    
    actions: [
        ActionItem
        {
            id: exportAction
            imageSource: "images/menu/ic_calendar_add.png"
            title: qsTr("Export") + Retranslate.onLanguageChanged
            ActionBar.placement: 'Signature' in ActionBarPlacement ? ActionBarPlacement["Signature"] : ActionBarPlacement.OnBar
            enabled: false
            
            onTriggered:
            {
                console.log("UserEvent: ExportCalendar");
                
                var selectedIndices = listView.selectionList();
                var result = [];
                
                for (var i = selectedIndices.length-1; i >= 0; i--) {
                    result.push( adm.data( selectedIndices[i] ) );
                }
                
                if (hourResponse.toggle.checked) {
                    result.push( {'key': "hourResponse", 'value': Math.floor(hourResponse.slideControl.value)} );
                }
                
                var daysToExport = Math.floor(slider.value);
                exportingReady(daysToExport, result, accountChoice.selectedValue);
            }
        }
    ]
    
    Container
    {
        horizontalAlignment: HorizontalAlignment.Fill
        verticalAlignment: VerticalAlignment.Fill
        topPadding: 10
        leftPadding: 10
        rightPadding: 10
        
        Container
        {
            horizontalAlignment: HorizontalAlignment.Center
            layout: DockLayout {}
            
            CircularSlider
            {
                id: slider
                horizontalAlignment: HorizontalAlignment.Center
                verticalAlignment: VerticalAlignment.Center
                preferredHeight: 300; preferredWidth: 300
                value: 6
                
                onTouch: {
                    if ( event.isDown() ) {
                        root.peekEnabled = false;
                    } else if ( event.isUp() || event.isCancel() ) {
                        root.peekEnabled = true;
                    }
                }
                
                onValueChanged: {
                    circularLabel.text = qsTr( "Export %n days", "", Math.floor(value) );
                    console.log("UserEvent: ExportDaysValue", value);
                }
            }
            
            Label {
                id: circularLabel
                horizontalAlignment: HorizontalAlignment.Center
                verticalAlignment: VerticalAlignment.Center
                textStyle.fontSize: FontSize.XXSmall
                multiline: true
                
                onCreationCompleted: {
                    slider.valueChanged(slider.value);
                }
            }
        }
        
        Label
        {
            id: infoText
            multiline: true
            horizontalAlignment: HorizontalAlignment.Fill
            textStyle.fontSize: FontSize.XXSmall
            textStyle.textAlign: TextAlign.Center
            bottomMargin: 10
        }
        
        ListView
        {
            id: listView
            property variant translation: translator
            
            leadingVisual: CalendarListItem
            {
                id: hourResponse
                toggle.checked: false
                toggle.text: qsTr("Friday Du'aa Reminder") + Retranslate.onLanguageChanged
                slideControl.fromValue: -30
                slideControl.toValue: -5
                slideControl.value: -15
                slideControl.enabled: toggle.checked
                
                toggle.onCheckedChanged: {
                    if (checked) {
                        infoText.text = qsTr("On Fridays between Asr and Maghrib a reminder will be scheduled for when the du'aa is accepted.");
                        exportAction.enabled = true;
                    } else {
                        infoText.text = qsTr("No reminder will be scheduled between Asr and Maghrib for the Hour of Response.");
                    }
                    
                    console.log("UserEvent: CalendarFridayTriggered", checked);
                }
                
                slideControl.onValueChanged: {
                    var floored = Math.abs( Math.floor(value) );
                    infoText.text = qsTr("On Fridays a reminder will be scheduled %n minutes before Maghrib for you to make du'aa.", "", floored);
                }
            }
            
            dataModel: ArrayDataModel
            {
                id: adm
                
                onItemUpdated: {
                    var element = data(indexPath);
                    var actualValue = element.value;
                    var event = translator.render(element.key);
                    
                    if (actualValue < 0) {
                        infoText.text = qsTr("You will be notified for %1 %2 minutes before its time.").arg(event).arg( Math.abs(actualValue) );
                    } else if (actualValue == 0) {
                        infoText.text = qsTr("You will be notified for %1 exactly on time.").arg(event);
                    } else {
                        infoText.text = qsTr("You will be notified for %1 %2 minutes after its time.").arg(event).arg(actualValue);
                    }
                }
            }
            
            listItemComponents: [
                ListItemComponent
                {
                    CalendarListItem
                    {
                        id: rootContainer
                        enabled: ListItem.selected
                        toggle.text: rootContainer.ListItem.view.translation.render(ListItemData.key)
                        
                        toggle.onCheckedChanged: {
                            rootContainer.ListItem.view.select(rootContainer.ListItem.indexPath, checked);
                        }
                        
                        slideControl.onValueChanged: {
                            var newValue = ListItemData;
                            newValue.value = Math.floor(value);
                            rootContainer.ListItem.view.dataModel.replace(rootContainer.ListItem.indexPath[0], newValue);
                        }
                    }
                }
            ]
            
            onTriggered: {
                console.log("UserEvent: CalendarItemTriggered", indexPath);
                toggleSelection(indexPath);
            }
            
            onSelectionChanged: {
                var n = selectionList().length;
                
                if (hourResponse.toggle.checked) {
                    ++n;
                }
                
                exportAction.enabled = n > 0;
                infoText.text = qsTr("%n events will be exported.", "", n);
            }
        }
        
        onCreationCompleted: {
            var keys = translator.salatKeys();
            var elements = [];
            
            for (var i = 0; i < keys.length; i++) {
                elements.push({'key': keys[i], 'value': 0});
            }
            
            adm.append(elements);
            listView.selectAll();
            
            listView.scroll(0);
            listView.scroll(-250);
        }
    }
}