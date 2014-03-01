/* pid structs. */

struct PidParams {
  double proportional_gain;
  double integral_gain;
  double derivative_gain;
};

struct PidState {
  double total_error;
  double last_error;
};

struct PidResult {
  // Updated state from this PID loop execution.
  struct PidState state;
  // Adjustment to make. NOTE THAT THIS MUST HAVE A LINEAR RELATIONSHIP WITH ERROR.
  double adjustment;
};

/* pid functions. */
struct PidResult pid(
    // Contains things like gain parameters. These should be tuned statically.
    struct PidParams params,
    // Contains state related to the pid loop. Keeps track of the integral and derivative terms.
    struct PidState state,
    // Incomming error.
    double error,
    // Time since last pid update.
    double delta_time
);
void print_params(struct PidParams params);
void print_state(struct PidState state);
void print_result(struct PidResult result);
