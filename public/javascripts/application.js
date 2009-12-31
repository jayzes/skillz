// setup the background interface
document.observe("dom:loaded", function() {
  Interface.renderBackground('background', 1555, 1050);
  Event.observe(window, 'resize', function() {
    Interface.renderBackground('background', 1555, 1050);
  });

  Interface.createTabs();
});

var Interface = {
  renderBackground: function(background, imageWidth, imageHeight, center) {
    background = $(background);

    var backgroundImage = $('background_image');
    var imageRatio = imageWidth / imageHeight;
    var bodyDimensions = document.viewport.getDimensions();
    var bodyRatio = bodyDimensions.width / bodyDimensions.height;

    var width = height = 0;
    if (imageRatio <= bodyRatio) {
      width = bodyDimensions.width
      height = bodyDimensions.width / imageRatio;
    } else {
      height = bodyDimensions.height;
      width = bodyDimensions.height * imageRatio;
    }

    background.setStyle({height: bodyDimensions.height + 'px'});
    backgroundImage.setStyle({
      position: 'absolute',
      top: ((center) ? (-(height - bodyDimensions.height) / 2) : '0') + 'px',
      left: ((center) ? (-(width - bodyDimensions.width) / 2) : '0') + 'px',
      width: width + 'px',
      height: height + 'px'
    });
  }
};

