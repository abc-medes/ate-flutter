// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Ins';

  @override
  String get appLongName => 'Insert Inside';

  @override
  String get appIntroduce_1 => 'Insert Inside';

  @override
  String get appIntroduce_2 => 'Visualize\n the invisible';

  @override
  String get appIntroduce_3 => 'Own yourself.';

  @override
  String get or => 'or';

  @override
  String get signInWithEmail => 'Sign in with Email';

  @override
  String get askingIsMember => 'Don\'t have account? ';

  @override
  String get signUp => 'Sign up';

  @override
  String get logIn => 'Log in';

  @override
  String get forgotPassword => 'Forgot your password?';

  @override
  String get resetPasswordTitle => 'Reset Password';

  @override
  String get sendEmail => 'Send Email';

  @override
  String get onboarding_gender =>
      'We\'ll tune your insights.\n As uniquely as you are.';

  @override
  String get onboarding_birth => 'Your age guides\n how your body recovers.';

  @override
  String get onboarding_bodymetrics =>
      'Your body shape completes\nthe picture.';

  @override
  String get gender_male => 'Male';

  @override
  String get gender_female => 'Female';

  @override
  String get select_gender => 'Select your gender';

  @override
  String get select_birthdate => 'Select your birth date';

  @override
  String get select_hw => 'Select your height and weight';

  @override
  String get select_bodytype => 'Select your body type';

  @override
  String get bodytype_slim => 'Slim';

  @override
  String get bodytype_average => 'Average';

  @override
  String get bodytype_muscular => 'Muscular';

  @override
  String get bodytype_overweight => 'Over-weight';

  @override
  String get bodytype_obese => 'Obese';

  @override
  String onboarding_bodytype_dynamic(int height, int weight) {
    return '$height cm · $weight kg\nAlmost there — pick your body type!';
  }

  @override
  String get authSigningIn => 'Signing in...';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get continueWithApple => 'Continue with Apple';

  @override
  String get authCreatingAccount => 'Creating your account...';

  @override
  String get actionTryAgain => 'Try Again';

  @override
  String get actionGoToLogin => 'Go to Login';

  @override
  String get verifyYourEmail => 'Verify Your Email';

  @override
  String get nextSteps => 'Next steps:';

  @override
  String get resendEmail => 'Didn\'t receive the email? Resend';

  @override
  String get verificationEmailResent => 'Verification email resent';

  @override
  String get actionBackToLogin => 'Back to Login';

  @override
  String get actionContinue => 'Continue';

  @override
  String get fieldEmail => 'Email';

  @override
  String get fieldFullName => 'Full Name';

  @override
  String get fieldPassword => 'Password';

  @override
  String get errorPasswordPolicy =>
      'Password must be at least 8 characters with at least 1 number';

  @override
  String get fieldConfirmPassword => 'Confirm Password';

  @override
  String get errorPasswordsDoNotMatch => 'Passwords do not match';

  @override
  String get signUpWithGoogle => 'Sign up with Google';

  @override
  String get signUpWithApple => 'Sign up with Apple';

  @override
  String get checkYourEmail => 'Check Your Email';

  @override
  String resetEmailSentDescription(String email) {
    return 'We\'ve sent a password reset approval link to $email. Please check your inbox and follow the instructions to reset your password.';
  }

  @override
  String signupEmailSentDescription(String email) {
    return 'We\'ve sent an email to $email with a verification link. Please click the link in your email to complete your registration.';
  }

  @override
  String get signupNextStep1 =>
      'Check your email inbox for a verification link from us';

  @override
  String get signupNextStep2 =>
      'Click on the link in the email to verify your account';

  @override
  String get signupNextStep3 =>
      'Return to the app to complete your registration';

  @override
  String get onboarding_scroll_down => 'Scroll down to save and continue';

  @override
  String get onboarding_scroll_up => 'Scroll up to go back';

  @override
  String get onboarding_saving => 'Saving...';

  @override
  String unit_cm(int value) {
    return '$value cm';
  }

  @override
  String unit_kg(int value) {
    return '$value kg';
  }

  @override
  String get intro_title => 'AI Meal Planner';

  @override
  String get intro_subtitle =>
      'Track, analyze, and optimize your nutrition using AI. Smart meals, smarter habits.';

  @override
  String get intro_get_started => 'Get Started';

  @override
  String get onboarding_log_saving_metrics => 'Saving your health metrics…';

  @override
  String get onboarding_log_initializing_simulator =>
      'Initializing body simulator…';

  @override
  String get errorInvalidEmailShort => 'Please enter a valid email';

  @override
  String get termsTitle => 'Terms & Privacy';

  @override
  String get termsDescription =>
      'Before continuing, please review and accept our Terms of Service and Privacy Policy.';

  @override
  String get termsAcceptAndContinue => 'Accept and Continue';

  @override
  String get iAgreeTo => 'I agree to the ';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String couldNotOpenUrl(String url) {
    return 'Could not open: $url';
  }

  @override
  String get home_score => 'Score';

  @override
  String home_overall_score(String score) {
    return 'Overall $score';
  }

  @override
  String get home_questions => 'Questions';

  @override
  String get home_no_pending_questions => 'No pending questions';

  @override
  String home_num_pending(int count) {
    return '$count pending';
  }

  @override
  String get home_chat_history => 'Chat History';

  @override
  String get home_chat_history_subtitle => 'View your chat history';

  @override
  String get tq_loading_1 => 'Getting your check-ins';

  @override
  String get tq_loading_2 => 'Almost ready';

  @override
  String get tq_loading_3 => 'Let\'s begin';

  @override
  String get tq_empty => 'No questions yet.';

  @override
  String get qs_tab_questions => 'Questions';

  @override
  String get qs_tab_answered => 'Answered';

  @override
  String get qs_update_updating => 'Updating...';

  @override
  String get qs_update_status => 'Update status';

  @override
  String get qs_ask_ai => 'Ask AI';

  @override
  String get qs_sign_in_required => 'Please sign in to start chat';

  @override
  String get qs_updates_intro => 'Here are my latest updates:';

  @override
  String get qs_updates_request => 'Please provide guidance and next steps.';

  @override
  String get bs_loading => 'getting body simulator data...';

  @override
  String get action_retry => 'Retry';

  @override
  String get tab_overview => 'Overview';

  @override
  String get tab_highlights => 'Highlights';

  @override
  String get tab_metrics => 'Metrics';

  @override
  String get label_overall_score => 'Overall score';

  @override
  String get label_insights => 'Insights';

  @override
  String get label_organ_scores => 'Organ scores';

  @override
  String get label_strengths => 'Strengths 💪';

  @override
  String get label_concerns => 'Areas of Concern ⚠️';

  @override
  String get organ_brain => 'Brain';

  @override
  String get organ_heart => 'Heart';

  @override
  String get organ_lungs => 'Lungs';

  @override
  String get organ_liver => 'Liver';

  @override
  String get organ_stomach => 'Stomach';

  @override
  String get organ_intestines => 'Intestines';

  @override
  String get organ_kidneys => 'Kidneys';

  @override
  String get organ_endocrine => 'Endocrine';

  @override
  String get organ_nervous => 'Nervous';

  @override
  String get brain_stress_level => 'Stress level';

  @override
  String get brain_serotonin => 'Serotonin';

  @override
  String get brain_sleep_rhythm => 'Sleep rhythm';

  @override
  String get brain_cortisol => 'Cortisol';

  @override
  String get heart_blood_sugar => 'Blood sugar';

  @override
  String get heart_blood_pressure => 'Blood pressure';

  @override
  String get heart_heart_rate => 'Heart rate';

  @override
  String get heart_hrv => 'HRV';

  @override
  String get lungs_o2_saturation => 'O₂ saturation';

  @override
  String get lungs_health_index => 'Health index';

  @override
  String get lungs_pm_exposure => 'PM exposure';

  @override
  String get lungs_respiratory_rate => 'Respiratory rate';

  @override
  String get liver_detox_capacity => 'Detox capacity';

  @override
  String get liver_enzymes => 'Liver enzymes';

  @override
  String get liver_fat_processing => 'Fat processing';

  @override
  String get liver_alcohol_load => 'Alcohol load';

  @override
  String get stomach_digestion_speed => 'Digestion speed';

  @override
  String get stomach_acidity => 'Acidity';

  @override
  String get stomach_nausea_risk => 'Nausea risk';

  @override
  String get stomach_food_retention => 'Food retention';

  @override
  String get intestines_bacteria_diversity => 'Bacteria diversity';

  @override
  String get intestines_inflammation => 'Inflammation';

  @override
  String get intestines_absorption_rate => 'Absorption rate';

  @override
  String get intestines_gas_level => 'Gas level';

  @override
  String get kidneys_hydration => 'Hydration';

  @override
  String get kidneys_electrolyte_balance => 'Electrolyte balance';

  @override
  String get kidneys_urea_clearance => 'Urea clearance';

  @override
  String get kidneys_toxicity_load => 'Toxicity load';

  @override
  String get endocrine_insulin_sensitivity => 'Insulin sensitivity';

  @override
  String get endocrine_thyroid_function => 'Thyroid function';

  @override
  String get endocrine_et_ratio => 'E/T ratio';

  @override
  String get nervous_focus_level => 'Focus level';

  @override
  String get nervous_mood_stability => 'Mood stability';

  @override
  String get nervous_anxiety_level => 'Anxiety level';

  @override
  String get nervous_neuro_flexibility => 'Neuro flexibility';

  @override
  String get chat_helper_ai_suggestions => 'AI suggestions';

  @override
  String get chat_helper_body_alerts => 'Body Alerts';

  @override
  String get chat_helper_select_system => 'Select body system';

  @override
  String get chat_helper_current_context => 'Current health context';

  @override
  String meta_system(String value) {
    return 'System: $value';
  }

  @override
  String meta_metric(String value) {
    return 'Metric: $value';
  }

  @override
  String meta_category(String value) {
    return 'Category: $value';
  }

  @override
  String get chat_no_messages => 'No messages in this session';

  @override
  String chat_loading_session(int index) {
    return 'Loading session $index';
  }

  @override
  String get chat_swipe_hint => 'Swipe left/right to see other chats';

  @override
  String get chat_generating => 'Generating...';

  @override
  String get chat_getting_checkins => 'Getting your check-ins...';

  @override
  String get time_just_now => 'Just now';

  @override
  String time_minutes_ago(int m) {
    return '${m}m ago';
  }

  @override
  String time_hours_ago(int h) {
    return '${h}h ago';
  }

  @override
  String time_days_ago(int d) {
    return '${d}d ago';
  }

  @override
  String chat_session_indicator(int current, int total) {
    return 'Session $current of $total';
  }

  @override
  String history_body_score_label(String score) {
    return 'Body Score: $score';
  }

  @override
  String image_label(int index) {
    return 'Image $index';
  }

  @override
  String get time_now => 'Now';

  @override
  String time_hours_ago_short(int h) {
    return '${h}h ago';
  }

  @override
  String get chat_hint_context => 'Tell me what you want to remember...';

  @override
  String get chat_hint_healthday => 'How was your health day?';

  @override
  String get tooltip_saving_as_context => 'Saving as context';

  @override
  String get tooltip_save_temp_chat => 'Save as temporary chat';

  @override
  String get tooltip_add_image => 'Add image';

  @override
  String get tooltip_send_message => 'Send message';

  @override
  String get msg_title_generic => 'Message';

  @override
  String get msg_title_error => 'Error';

  @override
  String get msg_title_success => 'Success';

  @override
  String get auth_sign_in => 'Sign In';

  @override
  String get auth_sign_in_required => 'Sign In Required';

  @override
  String get auth_sign_in_request => 'Please sign in to access all features';

  @override
  String get auth_feature_locked =>
      'This feature requires an account. Would you like to sign in?';

  @override
  String get auth_not_now => 'Not Now';

  @override
  String get auth_sign_in_options => 'Sign In Options';

  @override
  String get auth_choose_sign_in => 'Choose how you would like to sign in';

  @override
  String get auth_sign_in_email => 'Sign in with Email';

  @override
  String get auth_sign_in_google => 'Sign in with Google';

  @override
  String get auth_sign_in_apple => 'Sign in with Apple';

  @override
  String get action_cancel => 'Cancel';

  @override
  String get context_title => 'Tell us about you';

  @override
  String get context_subtitle =>
      'What should we know about you? This helps personalize your experience.';

  @override
  String get context_hint_memory => 'What should we know about you?';

  @override
  String get context_hint_ai =>
      'Adjust AI preferences (language, tone, style)...';

  @override
  String get context_hint_auto =>
      'Share context or preferences to personalize your experience';

  @override
  String get context_mode_auto => 'Auto';

  @override
  String get context_mode_mem => 'Mem';

  @override
  String get context_mode_ai => 'AI';

  @override
  String get tooltip_save_context => 'Save context';

  @override
  String get snackbar_processing => 'Saving to memory...';

  @override
  String get snackbar_saved => 'Saved to memory';

  @override
  String get snackbar_failed => 'Failed to save';

  @override
  String get settings_title => 'Settings';

  @override
  String get settings_section_account => 'Account';

  @override
  String get settings_sign_out => 'Sign Out';

  @override
  String get settings_reset_health_data => 'Reset Health Data';

  @override
  String get settings_section_ai => 'AI Settings';

  @override
  String get ai_tone => 'Tone';

  @override
  String get ai_language => 'Language';

  @override
  String get ai_formality => 'Formality';

  @override
  String get ai_detail_level => 'Detail Level';

  @override
  String get ai_emoji_usage => 'Emoji Usage';

  @override
  String get ai_response_length => 'Response Length';

  @override
  String get ai_goal_focus => 'Goal Focus';

  @override
  String get ai_summarize_style => 'Summarize Style';

  @override
  String get settings_section_health_context => 'Health Context';

  @override
  String get settings_section_memorized => 'Memorized Context';

  @override
  String get settings_section_appearance => 'Appearance';

  @override
  String get settings_dark_mode => 'Dark Mode';

  @override
  String get settings_section_about => 'About';

  @override
  String get settings_app_version => 'App Version';

  @override
  String get settings_terms => 'Terms of Service';

  @override
  String get settings_privacy => 'Privacy Policy';

  @override
  String get settings_reset_title => 'Reset Health Data';

  @override
  String get settings_reset_content =>
      'This will reset all your health-related data including height, weight, conditions, and more. This action cannot be undone.';

  @override
  String get settings_resetting => 'Resetting health data...';

  @override
  String get settings_reset_success => 'Health data reset successfully';

  @override
  String settings_reset_error(String error) {
    return 'Error resetting health data: $error';
  }

  @override
  String get action_reset => 'RESET';

  @override
  String get change_password_title => 'Change Password';

  @override
  String get field_current_password => 'Current Password';

  @override
  String get field_new_password => 'New Password';

  @override
  String get field_confirm_new_password => 'Confirm New Password';

  @override
  String get action_update_password => 'Update Password';

  @override
  String get error_fix_before_continue =>
      'Please correct the errors before continuing';

  @override
  String get success_password_updated => 'Password updated';

  @override
  String get recs_title => 'Product Recommendations';

  @override
  String get recs_empty => 'No product recommendations yet';

  @override
  String recs_priority(int value) {
    return 'Priority $value';
  }

  @override
  String get recs_key_benefits => 'Key benefits';

  @override
  String get recs_recommended_use => 'Recommended use';

  @override
  String get recs_notes => 'Notes';

  @override
  String get recs_category_fallback => 'item';

  @override
  String get recs_open_link => 'Open link';

  @override
  String get settings_delete_account => 'Delete Account';

  @override
  String get settings_delete_account_title => 'Delete Account';

  @override
  String get settings_delete_account_content =>
      'Are you sure you want to delete your account? This will permanently delete all your data including your profile, health metrics, chat history, and all other information. This action cannot be undone.';

  @override
  String get settings_deleting_account => 'Deleting account...';

  @override
  String settings_delete_account_error(String error) {
    return 'Error deleting account: $error';
  }

  @override
  String get action_delete => 'DELETE';

  @override
  String get error_check_network =>
      'Can\'t reach the server right now. Please check your network connection and try again.';
}
