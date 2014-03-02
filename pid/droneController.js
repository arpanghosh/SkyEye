#!/usr/bin/env node
// node deps:
// socket.io


// -- Initialize State --

var io = require('socket.io').listen(9000);
var arDrone = require('ar-drone');
// var client  = arDrone.createClient();
var stateVariables = {
  'beaconData': [],
  'coreMotionData': null,
  'droneData': null,
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
  socket.on('coreMotionData', updateMotionData);
  console.log('Socket.io connected.');

  initializeDrone();
  setInterval(controlDrone,25);
});

// For beacon we are just getting one float, signal strength. May need to de-log this.
var updateBeaconData = function (beaconData) {
  var timestamp = new Date();

  stateVariables['beaconData'].push(JSON.parse(beaconData).beaconData);
  if (stateVariables.length > optimalState['beaconWindowSize']) {
    stateVariables.shift();
  }

  // Attach a timestamp to the receive time and use a moving window
}

// For core motion we should get two 3d vectors
var updateCoreMotionData = function (coreMotionData) {
  stateVariables['coreMotionData'] =  JSON.parse(coreMotionData);
}

function initializeDrone () {
  // client.takeoff();
}

function controlDrone() {
  var timestamp = new Date();

  // Get drone AV Data

  // Combine all of our distance metrics into one
  var distance = 0.0;
  stateVariables.forEach(function (signalStrength) {
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
