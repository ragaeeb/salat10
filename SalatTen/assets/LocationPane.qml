import bb.cascades 1.0
import bb.cascades.places 1.0
import bb.cascades.maps 1.0

NavigationPane
{
    onPopTransitionEnded: {
        page.destroy();
    }
    
    Page
    {
        actions: [
            ActionItem {
                title: qsTr("Refresh") + Retranslate.onLanguageChanged
                imageSource: "images/ic_reset.png"
                ActionBar.placement: ActionBarPlacement.OnBar

                function onFound(l,p) {
                    busy.running = false;
                }

                onTriggered: {
                    var geoFinder = app.refreshLocation();
                    
                    if (geoFinder) {
                        busy.running = true;
                        geoFinder.finished.connect(onFound)
                    }
                }
            },
            
            ActionItem {
                id: locationAction
                imageSource: "file:///usr/share/icons/ic_map_all.png"
                
                function onSettingChanged(key)
                {
                    if (key == "longitude" && notification.calculationFeasible)
                    {
                        mapViewDelegate.delegateActive = true;
                        
                        var location = persist.getValueFor("location");
                        location = location ? location : qsTr("Choose Location");
                        locationAction.title = location;
                        var current = boundary.getCurrent( new Date() );
                        
                        app.renderMap(mapViewDelegate.control, persist.getValueFor("latitude"), persist.getValueFor("longitude"), location, translator.render(current.key), true);
                    }
                }
                
                onCreationCompleted: {
                    persist.settingChanged.connect(onSettingChanged);
                    onSettingChanged("longitude");
                }
                
                attachedObjects: [
                    ComponentDefinition {
                        id: pickerDefinition
                        PlacePicker {}
                    }
                ]
                
                onTriggered: {
                    var picker = pickerDefinition.createObject();
                    var place = picker.show();
                    
                    if (place && place.latitude && place.longitude)
                    {
                        persist.saveValueFor("city", place.city);
                        persist.saveValueFor("location", place.name);
                        persist.saveValueFor("altitude", place.altitude);
                        persist.saveValueFor("latitude", place.latitude);
                        persist.saveValueFor("longitude", place.longitude);
                        persist.saveValueFor("country", place.country);
                        locationAction.title = place.name;

                        persist.showToast( qsTr("Location successfully set to %1!").arg(place.name), "", "asset:///images/ic_map.png" );
                    }
                    
                    picker.destroy();
                }
                
                ActionBar.placement: ActionBarPlacement.OnBar
            }
        ]
        
        Container
        {
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Fill
            layout: DockLayout {}
            
            ControlDelegate
            {
                id: mapViewDelegate
                delegateActive: false
                
                sourceComponent: ComponentDefinition
                {
                    MapView {
                        id: mapView
                        altitude: 100000000
                        tilt: 2
                        verticalAlignment: VerticalAlignment.Center
                        horizontalAlignment: HorizontalAlignment.Center
                        
                        function onMapDataLoaded(data)
                        {
                            var allKeys = translator.eventKeys();
                            var max = 1000*60*30;
                            
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
                                
                                app.renderMap(mapView, current.latitude, current.longitude, name, rendered);
                            }
                        }
                        
                        onCreationCompleted: {
                            app.mapDataLoaded.connect(onMapDataLoaded);
                            app.fetchCheckins();
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
}