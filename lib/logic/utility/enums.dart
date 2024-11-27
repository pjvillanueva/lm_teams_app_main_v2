enum ProfileMode { viewing, editing }

enum FormStatus {
  valid,
  invalid,
  submissionInProgress,
  submissionSuccess,
  submissionFailed
}

enum SubmissionStatus {
  initial,
  submissionInProgress,
  submissionSuccesful,
  submissionFailed
}

enum SocketStatus { loading, connected, disconnected }

enum AuthenticationStatus { unknown, authenticated, unauthenticated, invited }

enum OnboardingStatus {
  isLoading,
  initialStatus,
  onboardingSuccessful,
  onboardingUnsuccessful
}
