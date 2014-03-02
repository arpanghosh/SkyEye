#!/usr/bin/env node
// node deps:
// socket.io

// Create http Server stuff
var path = require('path');

// listen on this port for all http, socket.io, and multi-axis requests
var httpPort = 8080;
// serve http from this path
var clientroot = path.join(__dirname, '');

//
// start up the HTTP server
//

var connect = require('connect');

var app = connect()
    .use( connect.logger( 'dev' ) )
    .use( connect.static( clientroot ) ).listen( httpPort );


var io = require('socket.io');
var arDrone = require('ar-drone');

// Constructs a new PID based controller. This is intended to be used within a closed loop control
// system.
//
// @param proportionalGain is the weight applied to the proportional component of the control loop.
// @param integralGain is the weight applied to the integral component of the control loop.
// @param derivativeGain is the weight applied to the derivative component of the control loop.
//
// @note these gain parameter should likely be under 1.0.
function PidController(proportionalGain, integralGain, derivativeGain) {
  var self = this;

  // Setup static parameters.
  self.PROPORTIONAL_GAIN = proportionalGain;
  self.INTEGRAL_GAIN = integralGain;
  self.DERIVATIVE_GAIN = derivativeGain;

  // Initialize state.
  self.totalError = 0.0;
  self.lastError = 0.0;

  // Functions.
  self.calculateAdjustment = function(error, deltaTime) {
    if (isNaN(error) || isNaN(deltaTime)) {
      return 0.0;
    }

    // Calculate terms.
    var proportionalTerm = self.PROPORTIONAL_GAIN * error;
    var integralTerm = self.INTEGRAL_GAIN * (self.totalError + error * deltaTime);
    var derivativeTerm = self.DERIVATIVE_GAIN * (self.lastError / deltaTime);

    // Update the pid loop state.
    self.totalError = self.totalError + error * deltaTime;
    self.lastError = error;

    if (isNaN(proportionalTerm) || isNaN(integralTerm) || isNaN(derivativeTerm)) {
      console.warn('p = ' + proportionalTerm + ', i = ' + integralTerm + ', d = ' + derivativeTerm);
      console.warn(self.INTEGRAL_GAIN + ', ' + error + ', ' + deltaTime + ', ' + self.totalError);
    }

    return proportionalTerm + integralTerm + derivativeTerm;
  };
}

function rssiToDist(rssi) {
  var power = (rssi + 70) / (-10 * 4.23);
  return Math.pow(10, power);
}


DroneController = function (
    pidController,
    trackingDistance,
    trackingDeadzone,
    smoothingWindowSize,
    plottingCallback
) {
  var self = this;

  // Store parameters.
  self.pidController = pidController;
  self.trackingDistance = trackingDistance;
  self.trackingDeadzone = trackingDeadzone;
  self.smoothingWindowSize = smoothingWindowSize;
  self.plottingCallback = plottingCallback;

  // Setup state variables.
  self.beaconData = [];
  self.coreMotionData = null;
  self.droneData = null;
  self.stepData = null;


  self.start = function(ioPort) {
    
    // Private callbacks.
    function updateBeaconData(beaconData) {
      var id = beaconData['beaconId'];
      var data = rssiToDist(parseInt(beaconData['beaconData']));

      console.log("Received beacon data: " + JSON.stringify(beaconData));

      self.beaconData.push(data);
      if (self.beaconData.length > self.smoothingWindowSize) {
        self.beaconData.shift();
      }

      // Attach a timestamp to the receive time and use a moving window
    }
    self.setPlottingCallback = function (callback) { self.plottingCallback = callback; }
    function updateStepData(stepData) { console.log("Step Data Recieved: " + stepData); }
    function updateCoreMotionData(coreMotionData) { self.coreMotionData = coreMotionData; }

    function safeMoveHorizontal(horizontalSpeed, deadZone, distance, error) {
      var timestamp = new Date();

      if (Math.abs(horizontalSpeed) < 0.2) {
        // Send the updated commands to the drone
        if (horizontalSpeed > deadZone) {
          client.front(horizontalSpeed);
          console.log('[' + timestamp + ']: F(' + horizontalSpeed + '), dist = ' + distance + ', error = ' + error);
        } else if (horizontalSpeed < -deadZone) {
          client.back(-horizontalSpeed);
          console.log('[' + timestamp + ']: B(' + (-horizontalSpeed) + '), dist = ' + distance + ', error = ' + error);
        } else {
          client.stop();
          console.log('[' + timestamp + ']: Stop(), dist = ' + distance + ', error = ' + error);
        }
      } else {
        console.warn('TRYING TO MOVE TOO FAST: ' + horizontalSpeed + ' dist = ' + distance + ', error = ' + error);
      }
    }

    function startDrone() { 
      // Connect to the drone
      client  = arDrone.createClient();
      // Enable Navdata reading and listen to it
      client.config('general:navdata_demo', 'FALSE');
      client.on('navdata', updateNavData);
      // Takeoff drone
      console.info("Start Drone");
      //client.takeoff(); 
    }
    function updateNavData(navData) {

    }

    function stopDrone() { 
      console.info("Stop Drone");
      //client.land(); 
    }
    function controlDrone() {
      if (self.beaconData.length == 0) {
        console.warn("self.beaconData is empty!");
      }

      // Combine all of our distance metrics into one
      var distance = 0.0;
      self.beaconData.forEach(function (signalStrength) {
        distance += signalStrength;
      });
      distance = distance / self.beaconData.length;
      // TODO: convert this from decibels to distance.
      if (isNaN(distance)) {
        console.warn("calculated distance is NAN!");
      }

      // Calculate Error
      var error = distance - self.trackingDistance;

      // Calculate adjustments, the new horizontal speed
      var horizontalSpeed = self.pidController.calculateAdjustment(error, 0.025);

      // Call control callback.
      self.plottingCallback(distance, error, horizontalSpeed);

      // Send the updated commands to the drone
      safeMoveHorizontal(horizontalSpeed, self.trackingDeadzone, distance, error);
    }


    // -- Setup --

    self.ioPort = ioPort;
    var server = io.listen(ioPort);

    console.info('Waiting for socket.io connection on port ' + ioPort + '...');

    // Once the iPhone has made the connection initialize the calback functions and initialize
    // the drone.
    server.sockets.on('connection', function (socket) {
      // Register socket event callbacks.
      socket.on('beaconData', updateBeaconData);
      socket.on('coreMotionData', updateCoreMotionData);
      socket.on('stepData', updateStepData);
      socket.on('stopDrone', stopDrone);
      socket.on('startDrone', startDrone);


      console.info('Socket.io connected.');

      // Setup the control loop, and register a shutdown callback.
      setInterval(controlDrone, 25);
      //setTimeout(stopDrone, 60000);
    });
  }
}


// Create a new drone controller and start it.
// NOTE: COMMENT THESE OUT BEFORE USING THIS IN THE FLOT PLOTTER.
 var controller = new DroneController(
     new PidController(0.1, 0, 0.001),
     1.4,
     0.005,
     32,
     function() { }
 );
 controller.start(9000);
