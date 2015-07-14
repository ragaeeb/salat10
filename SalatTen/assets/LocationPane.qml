import bb.cascades 1.3
import bb.cascades.places 1.0
import bb.cascades.maps 1.0

Page
{
    actionBarAutoHideBehavior: ActionBarAutoHideBehavior.HideOnScroll
    
    function cleanUp() {
        navigationPane.peekEnabled = true;
        notification.locationsFound.disconnect(locations.onLocationsFound);
    }
    
    actions: [
        ActionItem {
            title: qsTr("Refresh") + Retranslate.onLanguageChanged
            imageSource: "images/menu/ic_reset.png"
            ActionBar.placement: ActionBarPlacement.OnBar
            
            function onFound(l,p) {
                busy.running = false;
            }
            
            onTriggered: {
                console.log("UserEvent: RefreshLocation");
                
                var geoFinder = app.refreshLocation();
                
                if (geoFinder) {
                    busy.running = true;
                    geoFinder.finished.connect(onFound)
                }
            }
        },
        
        ActionItem
        {
            id: locationAction
            imageSource: "file:///usr/share/icons/ic_map_all.png"
            ActionBar.placement: 'Signature' in ActionBarPlacement ? ActionBarPlacement["Signature"] : ActionBarPlacement.OnBar
            title: qsTr("Choose Location") + Retranslate.onLanguageChanged
            
            function onSettingChanged(key)
            {
                if (key == "longitude" && boundary.calculationFeasible)
                {
                    mapViewDelegate.delegateActive = true;
                    
                    var location = persist.getValueFor("location");
                    location = location ? location : qsTr("Choose Location");
                    locationAction.title = location;
                    var current = boundary.getCurrent( new Date() );
                    
                    offloader.renderMap(mapViewDelegate.control, persist.getValueFor("latitude"), persist.getValueFor("longitude"), location, translator.render(current.key), true);
                }
            }
            
            onCreationCompleted: {
                persist.settingChanged.connect(onSettingChanged);
                onSettingChanged("longitude");
                
                if ( !persist.contains("longitude") ) {
                    tftk.textField.requestFocus();
                }
            }
            
            attachedObjects: [
                ComponentDefinition {
                    id: pickerDefinition
                    PlacePicker {}
                }
            ]
            
            onTriggered: {
                console.log("UserEvent: LocationPickerTriggered");
                
                var picker = pickerDefinition.createObject();
                var place = picker.show();
                
                if (place && place.latitude && place.longitude)
                {
                    persist.saveValueFor("city", place.city, false);
                    persist.saveValueFor("location", place.name, false);
                    persist.saveValueFor("latitude", place.latitude, true);
                    persist.saveValueFor("longitude", place.longitude, true);
                    persist.saveValueFor("country", place.country, false);
                    locationAction.title = place.name;
                    
                    persist.showToast( qsTr("Location successfully set to %1!").arg(place.name), "", "asset:///images/tabs/ic_map.png" );
                }
                
                picker.destroy();
            }
        }
    ]
    
    titleBar: TitleBar
    {
        id: tb
        kind: TitleBarKind.TextField
        
        kindProperties: TextFieldTitleBarKindProperties
        {
            id: tftk
            textField.hintText: qsTr("Enter location to search...") + Retranslate.onLanguageChanged
            textField.input.submitKey: SubmitKey.Search
            textField.input.flags: TextInputFlag.SpellCheck | TextInputFlag.WordSubstitution | TextInputFlag.AutoPeriodOff | TextInputFlag.AutoCorrection
            textField.input.submitKeyFocusBehavior: SubmitKeyFocusBehavior.Lose
            textField.input.onSubmitted: {
                busy.running = true;
                var query = tftk.textField.text.trim();
                notification.geoLookup(query);
            }
            
            textField.onCreationCompleted: {
                input["keyLayout"] = 7;
            }
        }
    }
    
    Container
    {
        horizontalAlignment: HorizontalAlignment.Fill
        verticalAlignment: VerticalAlignment.Fill
        layout: DockLayout {}
        
        Container
        {
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Fill
            
            DropDown
            {
                id: locations
                title: qsTr("No Locations Found") + Retranslate.onLanguageChanged
                bottomMargin: 0
                
                function onLocationsFound(result)
                {
                    if (result.status == "OK")
                    {
                        locations.removeAll();
                        var n = result.results.length;
                        
                        for (var i = 0; i < n; i++) {
                            var option = optionDef.createObject();
                            option.value = result.results[i];
                            
                            locations.add(option);
                        }
                        
                        locations.title = qsTr("%n locations found", "", n);
                        locations.expanded = true;
                        
                        tutorial.execBelowTitleBar("pickGeoLocation", qsTr("These are the locations that were found based on your query. Pick the one that is closest to you to get the most accurate results.") );
                    } else {
                        persist.showToast( qsTr("Could not fetch geolocation results. Please either use the 'Choose Location' from the bottom, tap on the 'Refresh' button use your GPS or please try again later."), "", "asset:///images/ic_location_failed.png" );
                    }
                    
                    busy.running = false;
                }
                
                onSelectedValueChanged: {
                    var parts = selectedValue.address_components;
                    var city = "";
                    var country = "";
                    var latitude = selectedValue.geometry.location.lat;
                    var longitude = selectedValue.geometry.location.lng;
                    
                    for (var i = parts.length-1; i >= 0; i--)
                    {
                        var types = parts[i].types;
                        
                        if ( types.indexOf("country") != -1 ) {
                            country = parts[i].long_name;
                        } else if ( types.indexOf("locality") != -1 ) {
                            city = parts[i].long_name;
                        }
                    }
                    
                    mapViewDelegate.delegateActive = true;
                    mapViewDelegate.control.animateToLocation(latitude, longitude, 50000);
                    
                    persist.saveValueFor("location", selectedValue.formatted_address);
                    persist.saveValueFor("latitude", latitude, true);
                    persist.saveValueFor("longitude", longitude, true);
                    
                    if (city.length > 0) {
                        persist.saveValueFor("city", place.city, false);
                    }
                    
                    if (country.length > 0) {
                        persist.saveValueFor("country", place.country, false);
                    }
                    
                    locationAction.title = selectedValue.formatted_address;
                }
                
                onCreationCompleted: {
                    notification.locationsFound.connect(onLocationsFound);
                }
                
                attachedObjects: [
                    ComponentDefinition
                    {
                        id: optionDef
                        
                        Option
                        {
                            imageSource: "file:///usr/share/icons/ic_map_all.png"
                            
                            onValueChanged: {
                                text = value.formatted_address;
                                description = "(" + value.geometry.location.lat + ", " + value.geometry.location.lng + ")";
                            }
                        }
                    }
                ]
            }
            
            ControlDelegate
            {
                id: mapViewDelegate
                delegateActive: false
                
                sourceComponent: ComponentDefinition
                {
                    MapView
                    {
                        id: mapView
                        altitude: 100000000
                        tilt: 2
                        verticalAlignment: VerticalAlignment.Center
                        horizontalAlignment: HorizontalAlignment.Center
                        
                        function onMapDataLoaded(data)
                        {
                            var allKeys = translator.eventKeys();
                            var max = 1000*60*30;
                            navigationPane.peekEnabled = false;
                            
                            for (var i = data.length-1; i >= 0; i--)
                            {
                                var current = data[i];
                                var name = current.location;
                                var key = current.current;
                                var rendered;
                                
                                if (current.diff < max) // less than 30 mins
                                {
                                    var index = allKeys.indexOf(key);
                                    
                                    if (index < allKeys.length-1) {
                                        ++index;
                                    } else {
                                        index = 0;
                                    }
                                    
                                    key = allKeys[index];
                                    rendered = qsTr("Almost %1").arg( translator.render(key) );
                                } else {
                                    rendered = translator.render(key);
                                }
                                
                                offloader.renderMap(mapView, current.latitude, current.longitude, name, rendered);
                            }
                            
                            tutorial.exec("searchLocation", qsTr("Type in your exact address to this text box. The more accurate of an address you give, the more accurate the timing results will be."), HorizontalAlignment.Center, VerticalAlignment.Top, 0, 0, ui.du(5) );
                            tutorial.execActionBar("nativeLocationPicker", qsTr("Tap here to pick an existing location from your device.") );
                            tutorial.execActionBar("geoRefresh", qsTr("Tap here to use your device's GPS to obtain your location (this may take a while)."), "r" );
                            tutorial.execCentered("ummahPinch", qsTr("This page shows you all the other Salat10 users across the world! You can do a pinch gesture on this map to zoom in on specific cities to see them in more detail."), "images/tutorial/pinch.png");
                        }
                        
                        onCreationCompleted: {
                            notification.mapDataLoaded.connect(onMapDataLoaded);
                            notification.fetchCheckins();
                        }
                    }
                }
            }
        }
        
        ActivityIndicator
        {
            id: busy
            running: false
            visible: running
            preferredHeight: 200
            preferredWidth: 200
            horizontalAlignment: HorizontalAlignment.Center
            verticalAlignment: VerticalAlignment.Center
        }
    }
}