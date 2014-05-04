import bb.cascades 1.0
import bb.cascades.pickers 1.0
import bb.multimedia 1.0

Sheet
{
    id: root
    
    Page
    {
        titleBar: TitleBar
        {
            title: qsTr("Select Athan") + Retranslate.onLanguageChanged
            
            acceptAction: ActionItem
            {
                id: accept
                property string selected
                enabled: selected.length > 0
                title: qsTr("Accept") + Retranslate.onLanguageChanged
                imageSource: "images/graphics/title_arrow.png"
                
                onSelectedChanged: {
                    if (selected.length > 0)
                    {
                        player.sourceUrl = selected;
                        
                        if (npc.acquired) {
                            player.play();
                        } else {
                            npc.acquire();
                        }
                    }
                }
                
                onTriggered: {
                    var customAthans = {};
                    var all = translator.salatKeys();
                    
                    for (var i = all.length-1; i > 0; i--) { // skip fajr
                        customAthans[ all[i] ] = selected;
                    }
                    
                    persist.saveValueFor("customAthaans", customAthans, false);
                    persist.saveValueFor("athanPicked", 1, false);
                    persist.showToast( qsTr("Athan Successfully Set"), "", "asset:///images/ic_athaan_custom.png" );
                    
                    root.close();
                }
            }
        }
        
        Container
        {
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Center
            background: bg.imagePaint
            topPadding: 10;
            
            Label
            {
                text: qsTr("Please choose your preferred athan for Dhuhr to Isha (you will have to set the Fajr one on your own):") + Retranslate.onLanguageChanged
                multiline: true
                horizontalAlignment: HorizontalAlignment.Fill
                textStyle.textAlign: TextAlign.Center
            }
            
            Divider {
                bottomMargin: 0
            }
            
            ListView
            {
                id: listView
                
                dataModel: ArrayDataModel {
                    id: adm
                }
                
                onTriggered: {
                    clearSelection();
                    toggleSelection(indexPath);
                    
                    player.stop();
                    player.reset();
                    
                    var uri = dataModel.data(indexPath).uri;
                    
                    if (uri) {
                        accept.selected = uri;
                    } else {
                        picker.open();
                    }
                }
                
                listItemComponents: [
                    ListItemComponent
                    {
                        StandardListItem
                        {
                            id: sli
                            translationX: 1000
                            imageSource: ListItemData.imageSource
                            title: ListItemData.artist
                            
                            ListItem.onInitializedChanged: {
                                if (initialized) {
                                    tt.play();
                                }
                            }
                            
                            animations: [
                                TranslateTransition
                                {
                                    id: tt
                                    fromX: 1000
                                    toX: 0
                                    delay: Math.max(250, sli.ListItem.indexInSection*350)
                                    easingCurve: StockCurve.SineIn
                                    duration: sli.ListItem.indexInSection*500
                                }
                            ]
                        }
                    }
                ]
                
                onCreationCompleted: {
                    adm.append({'artist': qsTr("Shaykh Al-Albaani (rahimahullah)"), 'imageSource': "images/ic_athaan_enable.png", 'uri': "asset:///audio/athan_albaani.mp3"});
                    adm.append({'artist': qsTr("Wright Street, Birmingham Masjid"), 'imageSource': "images/ic_notification_enable.png", 'uri': "asset:///audio/athan_birmingham.mp3"});
                    adm.append({'artist': "Custom", 'imageSource': "images/ic_athaan_custom.png", 'uri': null});
                }
                
                attachedObjects: [
                    MediaPlayer {
                        id: player
                    },
                    
                    NowPlayingConnection {
                        id: npc
                        
                        onAcquired: {
                            player.play();
                        }
                        
                        onPause: {
                            player.pause();
                        }
                        
                        onPlay: {
                            player.play();
                        }
                        
                        onRevoked: {
                            player.pause();
                        }
                    },
                    
                    FilePicker
                    {
                        id: picker
                        defaultType: FileType.Music
                        mode: FilePickerMode.Picker
                        title: qsTr("Select Athan") + Retranslate.onLanguageChanged
                        
                        directories :  {
                            return ["/accounts/1000/removable/sdcard/music", "/accounts/1000/shared/music"]
                        }
                        
                        onFileSelected : {
                            accept.selected = "file://"+selectedFiles[0];
                        }
                        
                        onCanceled: {
                            accept.selected = "";
                            listView.clearSelection();
                        }
                    }
                ]
            }
            
            attachedObjects: [
                ImagePaintDefinition {
                    id: bg
                    imageSource: "asset:///images/graphics/banner_expanded.amd"
                }
            ]
        }
    }
    
    onClosed: {
        player.stop();
        destroy();
    }
}