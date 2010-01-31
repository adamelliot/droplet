String.prototype.ellipis = function(len) {
  len = len || 60;
  if (this.length > len) return this.substr(0, len - 3) + "...";
  return this;
};

$(function() {
  var pendingTransfers = 0;
    var resourceTemplate = $('#templates .resource').compile({
      '@href': 'url',
      '.name': 'name',
      '.size': 'size',
      '.date': 'date'
    });
  
  var loadResources = function() {
    $.getJSON("/resources.js", function(data) {
      var resources = $("#resources");
      
      for (var i = 0; i < data.length; i++) {
        // data[i].file_content_type

        var d = new Date(data[i].updated_at);

        var resource = $(resourceTemplate({
          url: data[i].path,
          name: data[i].name.ellipis(30),
          size: Math.floor(data[i].size / 1024) + " kb",
          date: d.toDateString()
      }));
        
        resources.append(resource);
      }
      
      console.log(data.length);
    });
  };
  
  var setupUploadForm = function() {
    var uploadFrameCount = 1;
    
    var uploadForm = $("#upload_form");
    if (uploadForm.length < 1) return;

    uploadForm.submit(function(e) {
      var uploadFrameName = 'upload_frame_' + uploadFrameCount++;
      pendingTransfers++;
      $("#transfer_count").text(pendingTransfers);
      $("#pending").show();

      // Attach the target iFrame for submitting.
      var uploadFrame = $('<iframe name="' + uploadFrameName + '" style="display:none"></iframe>');
      $("body").append(uploadFrame);
      setTimeout(function() {
        uploadFrame.load(function() {
          console.log("Uploaded");
          setTimeout(function() {
            uploadFrame.remove();
            pendingTransfers--;
            
            $("#transfer_count").text(pendingTransfers);
            if (pendingTransfers < 1) $("#pending").hide();
          }, 1);
        });
      }, 1);
      uploadForm.attr('target', uploadFrameName);

      setTimeout(function() {
        uploadForm.find('input[type=file]').val('');
      }, 1);
    });
  };

  setupUploadForm();
  loadResources();
});
