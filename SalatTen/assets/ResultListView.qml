import bb.cascades 1.2

ListView
{
    id: listView
    objectName: "listView"
    property variant translation: translator
    property variant localization: localizer
    property bool manualSelected: false
    flickMode: FlickMode.SingleItem
        
    dataModel: boundary.getModel()
    
    attachedObjects: [
        ListScrollStateHandler {
            id: scrollStateHandler
            
            onFirstVisibleItemChanged:
            {
                if (firstVisibleItem[0] == 0 && firstVisibleItem[1] == 0) {
                    boundary.loadBeginning();
                }
            }
            
            onAtEndChanged: {
                if (atEnd) {
                    boundary.loadMore();
                }
            }
        }
    ]
}