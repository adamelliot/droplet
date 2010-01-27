function loaded() {
  console.log("iFrame Loaded");
}

$(function() {
  var setupUploadForm = function() {
    var uploadForm = $("#upload_form");
    if (uploadForm.length < 1) return;

    // Attach the target iFrame for submitting.
    $("body").append('<iframe name="upload_frame" onload="loaded();" style=""></iframe>');

    uploadForm.submit(function() {
      setTimeout(function() {
        uploadForm.find('input[type=file]').val('');
      }, 1);
    });
  };

  setupUploadForm();
});
