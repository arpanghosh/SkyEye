     // Runs this code after page load.
      $(function() {
        // Data buffers:
        var distanceData = [];
        var errorData = [];
        var adjustmentData = [];

        // Set up the plot widget
        var plot = $.plot(
            "#placeholder",
            [distanceData, errorData, adjustmentData],
            {
              series: {
                shadowSize: 0	// Drawing is faster without shadows
              },
              yaxis: {
                min: -20,
                max: 20
              },
              xaxis: {
                show: false
              }
            }
        );

        // Add the Flot version string to the footer
        $("#footer").prepend("Flot " + $.plot.version + " &ndash; ");

        // Setup the callback such that it appends data as received.
        function plotData(distance, error, adjustent) {
          // Store incomming data in appropriate buffers.
          distanceData.push(distance);
          errorData.push(error);
          adjustmentData.push(adjustent);

          // Update the plot with new incoming data. Since the axes don't change, we don't need to
          // call plot.setupGrid().
          plot.setData([distanceData, errorData, adjustmentData]);
          plot.draw();

        }

        // Create & start the controller.
        controller.setPlottingCallback(plotData);
      });
    