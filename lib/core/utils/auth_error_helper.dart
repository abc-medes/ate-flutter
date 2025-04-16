class AuthErrorHelper {
  static String getLoginErrorMessage(String error) {
    final errorLower = error.toLowerCase();

    // Handle common Supabase error messages

    // Invalid credentials
    if (errorLower.contains('invalid login credentials') ||
        errorLower.contains('invalid credentials') ||
        errorLower.contains('wrong combination') ||
        errorLower.contains('invalid email or password')) {
      return 'The email or password you entered is incorrect. Please try again.';
    }

    // User not found
    if (errorLower.contains('user not found') ||
        errorLower.contains('no user found') ||
        errorLower.contains('no account')) {
      return 'No account found with this email. Would you like to create one?';
    }

    // Email not confirmed
    if (errorLower.contains('email not confirmed') ||
        errorLower.contains('not confirmed')) {
      return 'Your email has not been verified. Please check your inbox for a verification link.';
    }

    // Password-specific errors
    if (errorLower.contains('invalid password') ||
        errorLower.contains('password is incorrect')) {
      return 'The password you entered is incorrect. Please try again.';
    }

    // Rate limiting/Too many requests
    if (errorLower.contains('too many requests') ||
        errorLower.contains('rate limit') ||
        errorLower.contains('too many attempts')) {
      return 'Too many login attempts. Please try again later.';
    }

    // Network issues
    if (errorLower.contains('network') ||
        errorLower.contains('connection') ||
        errorLower.contains('timeout') ||
        errorLower.contains('server error')) {
      return 'Network error. Please check your internet connection and try again.';
    }

    // Auth or access errors
    if ((errorLower.contains('auth') && errorLower.contains('error')) ||
        errorLower.contains('access denied') ||
        errorLower.contains('not allowed')) {
      return 'Authentication failed. Please try again.';
    }

    // Session expired
    if (errorLower.contains('session expired') ||
        errorLower.contains('invalid session')) {
      return 'Your session has expired. Please sign in again.';
    }

    // OAuth specific errors
    if (errorLower.contains('oauth') ||
        errorLower.contains('third party') ||
        errorLower.contains('external provider')) {
      return 'There was a problem with the sign-in provider. Please try again or use another method.';
    }

    // Default error
    return 'Something went wrong. Please try again later.';
  }

  static String getSignupErrorMessage(String error) {
    final errorLower = error.toLowerCase();

    // Email already in use
    if (errorLower.contains('already in use') ||
        errorLower.contains('already exists') ||
        errorLower.contains('email already') ||
        errorLower.contains('email exists')) {
      return 'An account with this email already exists. Try signing in instead.';
    }

    // Weak password
    if (errorLower.contains('weak password') ||
        errorLower.contains('password too weak') ||
        errorLower.contains('password requirements')) {
      return 'Password is too weak. Please use a stronger password with at least 8 characters including numbers.';
    }

    // Invalid email
    if (errorLower.contains('invalid email') ||
        errorLower.contains('email not valid')) {
      return 'Please enter a valid email address.';
    }

    // Invalid phone
    if (errorLower.contains('invalid phone') ||
        errorLower.contains('phone not valid')) {
      return 'Please enter a valid phone number.';
    }

    // Default to generic message
    return getLoginErrorMessage(error);
  }
}
