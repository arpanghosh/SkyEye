#!/usr/bin/env node
// node deps:
// socket.io

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
    // Calculate terms.
    var proportionalTerm = self.PROPORTIONAL_GAIN * error;
    var integralTerm = self.INTEGRAL_GAIN * (self.totalError + error * deltaTime);
    var derivativeTerm = self.DERIVATIVE_GAIN * (self.lastError / deltaTime);

    // Update the pid loop state.
    self.totalError = self.totalError + error * deltaTime;
    self.lastError = error;

    return proportionalTerm + integralTerm + derivativeTerm;
  };
}

function rssiToDist(rssi) {
  var power = (rssi + 70) / (-10 * 4.23);
  return Math.pow(10, power);
}


function DroneController(
    pidController,
    trackingDistance,
    trackingDeadzone,
    smoothingWindowSize
) {
  var self = this;

  // Store parameters.
  self.trackingDistance = trackingDistance;
  self.trackingDeadzone = trackingDeadzone;
  self.smoothingWindowSize = smoothingWindowSize;

  // Setup state variables.
  self.beaconData = [];
  self.coreMotionData = null;
  self.droneData = null;
  self.stepData = null;

  self.start = function(ioPort) {
    var client  = arDrone.createClient();

    // Private callbacks.
    function updateBeaconData(beaconData) {
      var id = beaconData['beaconId'];
      var data = rssiToDist(parseInt(beaconData['beaconData']));

      console.log("Received beacon data: " + beaconData);

      self.beaconData.push(data);
      if (self.beaconData.length > self.smoothingWindowSize) {
        self.beaconData.shift();
      }

      // Attach a timestamp to the receive time and use a moving window
    }
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
        console.log('WARNING: TRYING TO MOVE TOO FAST: ' + horizontalSpeed + ' distance = : '+ distance+' error : '+error);
      }
    }

    function startDrone() { client.takeoff(); }
    function stopDrone() { client.land(); }
    function controlDrone() {
      // Combine all of our distance metrics into one
      var distance = 0.0;
      self.beaconData.forEach(function (signalStrength) {
        distance += signalStrength;
      });
      distance = distance / self.beaconData.length;
      // TODO: convert this from decibels to distance.

      // Calculate Error
      var error = distance - self.trackingDistance'];

      // Calculate adjustments, the new horizontal speed
      var horizontalSpeed = self.pidController.calculateAdjustment(error, 0.025);

      // Send the updated commands to the drone
      safeMoveHorizontal(horizontalSpeed, self.trackingDeadzone, distance, error);
    }


    // -- Setup --

    self.ioPort = ioPort;
    io.listen(ioPort);

    console.log('Waiting for socket.io connection on port ' + ioPort + '...');

    // Once the iPhone has made the connection initialize the calback functions and initialize
    // the drone.
    io.sockets.on('connection', function (socket) {
      // Register socket event callbacks.
      socket.on('beaconData', updateBeaconData);
      socket.on('coreMotionData', updateCoreMotionData);
      socket.on('stepData', updateStepData)

      console.log('Socket.io connected.');

      // Start the drone, setup the control loop, and register a shutdown callback.
      initializeDrone();
      setInterval(controlDrone, 25);
      setTimeout(shutDownDrone, 60000);
    });
  }
}


// Create a new drone controller and start it.
var controller = new DroneController(new PidController(0.1, 0, 0.001), 1.4, 0.005, 8);
controller.start(9000);
