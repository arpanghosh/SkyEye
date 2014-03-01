#include <stdio.h>

#include "pid.h"

/*
 * File containing basic generic PID implementation.
 *
 * PID should require some error input and produce a correction value.
 */

struct PidResult pid(
    // Contains things like gain parameters. These should be tuned statically.
    struct PidParams params,
    // Contains state related to the pid loop. Keeps track of the integral and derivative terms.
    struct PidState state,
    // Incomming error.
    double error,
    // Time since last pid update.
    double delta_time
) {
  // Calculate terms.
  double proportional_term = params.proportional_gain * error;
  double integral_term = params.integral_gain * (state.total_error + error * delta_time);
  double derivative_term = params.derivative_gain * (state.last_error / delta_time);

  // Update the pid loop state.
  state.total_error = state.total_error + error * delta_time;
  state.last_error = error;

  struct PidResult result = {
    .state = state,
    .adjustment = proportional_term + integral_term + derivative_term
  };
  return result;
}

// Utility functions.
void print_params(struct PidParams params) {
  printf(
    "PidParams(Kp = %f, Ki = %f, Kd = %f)\n",
    params.proportional_gain,
    params.integral_gain,
    params.derivative_gain
  );
}

void print_state(struct PidState state) {
  printf(
    "PidState(total_error = %f, last_error = %f)\n",
    state.total_error,
    state.last_error
  );
}

void print_result(struct PidResult result) {
  // This is redundant...
  printf(
    "PidResult(state = PidState(total_error = %f, last_error = %f), adjustment = %f)\n",
    result.state.total_error,
    result.state.last_error,
    result.adjustment
  );
}
