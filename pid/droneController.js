#!/usr/bin/env node
// node deps:
// socket.io

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


// -- Initialize State --

var io = require('socket.io').listen(9000);
var arDrone = require('ar-drone');
// var client  = arDrone.createClient();
var stateVariables = {
  'beaconData': [],
  'coreMotionData': null,
  'droneData': null,
  'stepData': null,
  'pidController': new PidController(0.1, 0.1, 0.1)
};
var optimalState = {
  'optimalBeaconDistance': 5.5,
  'beaconDistanceError': 0.5,
  'beaconWindowSize': 8
};


// -- Setup --

console.log('Waiting for socket.io connection...');

// Once the iPhone has made the connection,
// initialize the calback functions, and initialize the drone
io.sockets.on('connection', function (socket) {
  socket.on('beaconData', updateBeaconData);
  socket.on('coreMotionData', updateCoreMotionData);
  socket.on('stepData', updateStepData)
  console.log('Socket.io connected.');

  initializeDrone();
  setInterval(controlDrone,25);
});

// For beacon we are just getting one float, signal strength. May need to de-log this.
var updateBeaconData = function (beaconData) {
  var timestamp = new Date();
  console.log("beacon Data Recieved is : "+ beaconData['beaconData'] + "from beacon ID :" + beaconData["beaconID"]);
  stateVariables['beaconData'].push(parseInt(beaconData['beaconData']));
  if (stateVariables.length > optimalState['beaconWindowSize']) {
    stateVariables.shift();
  }

  // Attach a timestamp to the receive time and use a moving window
}

var updateStepData = function (stepData) {
  console.log("Step Data Recieved : "+stepData);
}
// For core motion we should get two 3d vectors
var updateCoreMotionData = function (coreMotionData) {
  stateVariables['coreMotionData'] =  coreMotionData;
}

function initializeDrone () {
  // client.takeoff();
}

function controlDrone() {
  var timestamp = new Date();

  // Get drone AV Data

  // Combine all of our distance metrics into one
  var distance = 0.0;
  stateVariables['beaconData'].forEach(function (signalStrength) {
    distance += signalStrength;
  });
  distance = distance / stateVariables.length;
  // TODO: convert this from decibels to distance.

  // Calculate Error
  var error = distance - optimalState['optimalBeaconDistance'];

  // Calculate adjustments, the new horizontal speed
  var horizontalSpeed = stateVariables['pidController'].calculateAdjustment(error, 0.025);

  // Send the updated commands to the drone
  if (horizontalSpeed > optimalState['beaconDistanceError']) {
    // client.front(horizontalSpeed);
    console.log('[' + timestamp + ']: F(' + horizontalSpeed + '), dist = ' + distance + ', error = ' + error);
  } else if (horizontalSpeed < -optimalState['beaconDistanceError']) {
    // client.back(-horizontalSpeed);
    console.log('[' + timestamp + ']: B(' + (-horizontalSpeed) + '), dist = ' + distance + ', error = ' + error);
  } else {
    // client.stop();
    console.log('[' + timestamp + ']: Stop(), dist = ' + distance + ', error = ' + error);
  }
}
