#!/usr/bin/env node
// node deps:
// socket.io 

var io = require('socket.io').listen(9000);
var arDrone = require('ar-drone');
var client  = arDrone.createClient();
var stateVariables = {'beaconData': null, 'coreMotionData': null, 'droneData': null};
var optimalState = {'optimalBeaconDistance': 5.5, 'beaconDistanceError': 0.5};

// Once the iPhone has made the connection, 
// initialize the calback functions, and initialize the drone
io.sockets.on('connection', function (socket) {
  socket.on('beaconData', updateBeaconData);
  socket.on('coreMotionData', updateMotionData);
  initializeDrone();
});

var updateBeaconData = function (beaconData) {
  stateVariables['beaconData'] =  JSON.parse(beaconData);
}

var updateCoreMotionData = function (coreMotionData) {
  stateVariables['coreMotionData'] =  JSON.parse(coreMotionData);
}

function initializeDrone () {
  client.takeoff();
}

var controlDrone = function () {
  if (stateVariables['beaconData'] > (optimalState['optimalBeaconDistance']+optimalState['beaconDistanceError'])) {
    client.front(0.2);
  };
  else if (stateVariables['beaconData'] < (optimalState['optimalBeaconDistance']-optimalState['beaconDistanceError'])) {
    client.back(0.2);
  };
}