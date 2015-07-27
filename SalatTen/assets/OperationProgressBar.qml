import bb.cascades 1.0

ControlDelegate
{
    id: progressDelegate
    horizontalAlignment: HorizontalAlignment.Center
    verticalAlignment: VerticalAlignment.Center
    delegateActive: false;
    visible: delegateActive
    
    function onProgressChanged(current, total)
    {
        control.showBusy = false;
        control.value = current;
        control.toValue = total;
    }
    
    function onComplete(message, icon)
    {
        delegateActive = false;
        persist.showToast(message, icon);
    }
    
    onCreationCompleted: {
        offloader.operationProgress.connect(onProgressChanged);
        offloader.operationComplete.connect(onComplete);
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