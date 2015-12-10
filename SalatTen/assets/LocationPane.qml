import bb.cascades 1.3
import bb.cascades.places 1.0
import bb.cascades.maps 1.3
import com.canadainc.data 1.0

Page
{
    id: locationPage
    actionBarAutoHideBehavior: ActionBarAutoHideBehavior.HideOnScroll
    
    function cleanUp()
    {
        navigationPane.peekEnabled = true;
        notification.locationsFound.disconnect(locations.onLocationsFound);
        Application.aboutToQuit.disconnect(onAboutToQuit);
        app.gpsReadyChanged.disconnect(onGpsReadyChanged);
        
        if (mapViewDelegate.delegateActive) {
            mapViewDelegate.control.cleanUp();
        }
    }
    
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
            persist.showToast( qsTr("Could not fetch geolocation results. Please either use the '%1' from the bottom, tap on the 'Refresh' button use your GPS or please try again later.").arg(locationAction.title), "images/toast/ic_location_failed.png" );
        }
        
        busy.delegateActive = false;
    }
    
    function onAboutToQuit() {
        mapViewDelegate.delegateActive = false;
    }
    
    function onSettingChanged(value, key)
    {
        if (key == "longitude" && boundary.calculationFeasible)
        {
            var location = persist.getValueFor("location");
            location = location ? location : qsTr("Choose Location");
            locationAction.title = location;

            if (!mapViewDelegate.delegateActive) {
                mapViewDelegate.delegateActive = true;
                var current = boundary.getCurrent( new Date() );
                offloader.renderMap(mapViewDelegate.control, persist.getValueFor("latitude"), persist.getValueFor("longitude"), location, translator.render(current.key), true);
            }
        } else if (!boundary.calculationFeasible) {
            persist.showToast( qsTr("Your location was not yet detected, please set your location for accurate timings."), "images/dropdown/ic_masjid.png" );
            notification.ipLookup();
        }
    }
    
    function onGpsReadyChanged()
    {
        if (app.gpsReady) {
            busy.delegateActive = false;
        }
    }
    
    onCreationCompleted: {
        notification.locationsFound.connect(onLocationsFound);
        Application.aboutToQuit.connect(onAboutToQuit);
        app.gpsReadyChanged.connect(onGpsReadyChanged);
        
        locationAnim.play();
    }
    
    actions: [
        ActionItem
        {
            id: refresh
            title: qsTr("GPS Refresh") + Retranslate.onLanguageChanged
            imageSource: "images/menu/ic_reset.png"
            ActionBar.placement: ActionBarPlacement.OnBar
            enabled: app.gpsReady
            
            onTriggered: {
                console.log("UserEvent: RefreshLocation");
                reporter.record("RefreshLocation");
                
                var ok = app.refreshLocation();
                
                if (ok) {
                    busy.delegateActive = true;
                } else {
                    global.showLocationServices();
                }
            }
        },
        
        ActionItem
        {
            id: locationAction
            imageSource: "images/menu/ic_map.png"
            ActionBar.placement: 'Signature' in ActionBarPlacement ? ActionBarPlacement["Signature"] : ActionBarPlacement.OnBar
            title: qsTr("Choose Location") + Retranslate.onLanguageChanged
            
            attachedObjects: [
                ComponentDefinition {
                    id: pickerDefinition
                    PlacePicker {}
                }
            ]
            
            onTriggered: {
                console.log("UserEvent: PickLocation");
                
                var picker = pickerDefinition.createObject();
                var place = picker.show();
                
                if (place && place.latitude && place.longitude)
                {
                    persist.saveValueFor("city", place.city, false);
                    persist.saveValueFor("location", place.name, false);
                    persist.saveValueFor("country", place.country, false);
                    persist.saveValueFor("latitude", place.latitude);
                    persist.saveValueFor("longitude", place.longitude);
                    persist.showToast( qsTr("Location successfully set to %1!").arg(place.name), "images/tabs/ic_map.png" );

                    reporter.record( "latitude", place.latitude.toString() );
                    reporter.record( "longitude", place.longitude.toString() );
                    reporter.record("location", place.name);
                    reporter.record("city", place.city);
                    reporter.record("country", place.country);
                } else {
                    console.log("LocationFailedPick");
                    reporter.record("LocationFailedPick");
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
                busy.delegateActive = true;
                var query = tftk.textField.text.trim();
                reporter.record("LocationQuery", query);
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
                translationY: -100
                
                animations: [
                    TranslateTransition
                    {
                        id: locationAnim
                        fromY: -100
                        toY: 0
                        easingCurve: StockCurve.ExponentialOut
                        duration: 1000
                        delay: 250
                        
                        onEnded: {
                            tftk.textField.requestFocus();
                            persist.registerForSetting(locationPage, "longitude");
                            tutorial.exec("searchLocation", qsTr("Type in your exact address to this text box. The more accurate of an address you give, the more accurate the timing results will be."), HorizontalAlignment.Center, VerticalAlignment.Top, 0, 0, tutorial.du(5) );
                            tutorial.execActionBar("nativeLocationPicker", qsTr("Tap here to pick an existing location from your device.") );
                            tutorial.execActionBar("geoRefresh", qsTr("Tap here to use your device's GPS to obtain your location (this may take a while)."), "r" );
                            tutorial.execActionBar("returnToSettings", qsTr("Tap here to go back to the Settings page."), "b" );
                        }
                    }
                ]
                
                onSelectedValueChanged: {
                    if (selectedValue)
                    {
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
                            persist.saveValueFor("city", city, false);
                            reporter.record("city", city);
                        }
                        
                        if (country.length > 0) {
                            persist.saveValueFor("country", country, false);
                            reporter.record( "country", country );
                        }
                        
                        locationAction.title = selectedValue.formatted_address;
                        
                        reporter.record( "latitude", latitude.toString() );
                        reporter.record( "longitude", longitude.toString() );
                        reporter.record( "location", selectedValue.formatted_address );
                    }
                }
                
                attachedObjects: [
                    ComponentDefinition
                    {
                        id: optionDef
                        
                        Option
                        {
                            imageSource: "images/dropdown/ic_map_result.png"
                            
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
                        
                        onCaptionButtonClicked: {
                            console.log("UserEvent: CaptionClicked", focusedId);
                            
                            if ( focusedId.indexOf("http") == 0 )
                            {
                                persist.openUri(focusedId);
                                reporter.record("OpenUrl", focusedId);
                            } else {
                                reporter.record("LocationPinTapped");
                            }
                        }
                        
                        function cleanUp() {
                            notification.mapDataLoaded.connect(onMapDataLoaded);
                        }
                        
                        function onDataLoaded(id, data)
                        {
                            console.log("*** DSFLSDKFJ", id);
                            console.log("*** xxx", QueryId.FetchCenters);
                            if (id == QueryId.FetchCenters)
                            {
                                console.log("*** DSFLSDKF333J", id);
                                for (var i = data.length-1; i >= 0; i--) {
                                    console.log("*** DSFLSDKF333Jxxxx", id);
                                    offloader.renderCenter(mapView, data[i]);
                                }
                            }
                        }
                        
                        function onMapDataLoaded(data)
                        {
                            notification.mapDataLoaded.disconnect(onMapDataLoaded);
                            
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
                            
                            tutorial.execCentered("ummahPinch", qsTr("This page shows you all the other Salat10 users across the world! You can do a pinch gesture on this map to zoom in on specific cities to see them in more detail."), "images/tutorial/pinch.png");
                        }
                        
                        onCreationCompleted: {
                            notification.mapDataLoaded.connect(onMapDataLoaded);
                            notification.fetchCheckins();
                            
                            sql.fetchCenters(mapView);
                        }
                    }
                }
            }
        }
        
        ProgressControl
        {
            id: busy
            asset: "images/loading/loading_location.png"
        }
        
        OfflineDelegate {
            id: offliner
        }
    }
}