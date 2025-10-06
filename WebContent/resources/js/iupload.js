/* Licence:
*   Use this however/wherever you like, just don't blame me if it breaks anything.
*
* Credit:
*   If you're nice, you'll leave this bit:
*
*   Class by Pierre-Alexandre Losson -- http://www.telio.be/blog
*   email : plosson@users.sourceforge.net
*/
function refreshProgress()
{
    UploadMonitor.getUploadInfo(updateProgress);
}

function updateProgress(uploadInfo)
{
    if (uploadInfo.inProgress)
    {
        document.getElementById('uploadbutton').disabled = true;
        document.getElementById('cancelbutton').disabled = true;
        document.getElementById('file1').disabled = true;
        document.getElementById('file2').disabled = true;
//        document.getElementById('file3').disabled = true;
//        document.getElementById('file4').disabled = true;

        var fileIndex = uploadInfo.fileIndex;

        var progressPercent = Math.ceil((uploadInfo.bytesRead / uploadInfo.totalSize) * 100);

        document.getElementById('progressBarText').innerHTML = 'upload in progress: ' + progressPercent + '% , Don\'t close window until progress complete. ';

        document.getElementById('progressBarBoxContent').style.width = parseInt(progressPercent * 3.5) + 'px';

        window.setTimeout('refreshProgress()', 1000);

    }
    else
    {
        document.getElementById('uploadbutton').disabled = false;
        document.getElementById('cancelbutton').disabled = false;
        document.getElementById('file1').disabled = false;
        document.getElementById('file2').disabled = false;
//        document.getElementById('file3').disabled = false;
//        document.getElementById('file4').disabled = false;
    }

    return true;
}

function startProgress()
{
    document.getElementById('progressBar').style.display = 'block';
    document.getElementById('progressBarText').innerHTML = 'upload in progress: &nbsp;&nbsp;0% , Don\'t close window until progress complete. ';
    document.getElementById('uploadbutton').disabled = true;
	document.getElementById('cancelbutton').disabled = true;

    // wait a little while to make sure the upload has started ..
    window.setTimeout("refreshProgress()", 1500);
    return true;
}


function openUploadWindow(contextPath,sessionId, itmNo, keyFile) {
	if (contextPath.length>0 && contextPath.substring(contextPath.length-1)!="/") 	{
	    contextPath += "/";
	}

	var keys = new Array();
	keys[0] = sessionId;
	keys[1] = itmNo;
	keys[2] = keyFile;
	

	vReturnValue = window.showModalDialog(contextPath+"iupload_index.html",keys,"dialogHeight: 200px; dialogWidth: 400px; center: Yes; resizable: No; status: No;");
	return vReturnValue;
}