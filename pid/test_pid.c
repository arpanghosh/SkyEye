#include <stdio.h>

#include "pid.h"

/* Calculates a bunch of points over time using a PID with a fixed time interval. */
void simple_pid_test() {
  int MAX_T = 1000;
  int DELTA_T = 1;
  double REF_SIGNAL = 5.5;

  struct PidParams params = {
    .proportional_gain = 0.1,
    .integral_gain = 0.1,
    .derivative_gain = 0.1
  };
  struct PidState state = {
    .total_error = 0.0,
    .last_error = 0.0
  };

  double x = 0.0;
  int t;
  for (t = 0; t <= MAX_T; t += DELTA_T) {
    // Log data.
    printf("x_%04d = %f\n", t, x);

    // Calculate error.
    double error = REF_SIGNAL - x;

    // Calculate adjustment.
    struct PidResult result = pid(params, state, error, DELTA_T);

    // Perform adjustment.
    x += result.adjustment * DELTA_T;
    printf("adjustment_%04d = %f\n", t, result.adjustment);
  }
}

/* Tests for pid loops. */
int main() {
  printf("Running pid tests...\n");

  // Call other tests.
  simple_pid_test();
}
