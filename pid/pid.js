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
  self.calculateAdjustment = function(error, delta_time) {
    // Calculate terms.
    var proportionalTerm = self.PROPORTIONAL_GAIN * error;
    var integralTerm = self.INTEGRAL_GAIN * (self.totalError + error * deltaTime);
    var derivativeTerm = self.DERIVATIVE_GAIN * (self.lastError / deltaTime);

    // Update the pid loop state.
    self.totalError = self.totalError + error * deltaTime;
    self.lastError = error;

    return proportional_term + integral_term + derivative_term;
  };
}
