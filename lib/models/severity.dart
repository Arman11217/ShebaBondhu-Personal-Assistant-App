/// How urgent a reminder is. Drives chip color and notification priority.
enum Severity {
  normal,
  important,
  critical,
}

/// Top-level category used to filter on the Home screen and More screen.
enum ReminderCategory {
  money,
  bill,
  document,
  warranty,
  medicine,
  recharge,
  appointment,
  task,
}