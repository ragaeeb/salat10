import bb.cascades 1.0

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
    
    function onProgressChanged(current, total)
    {
        showBusy = false;
        value = current;
        toValue = total;
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
}