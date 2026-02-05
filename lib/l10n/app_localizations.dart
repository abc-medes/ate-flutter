import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ko.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ko')
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Ins'**
  String get appName;

  /// No description provided for @appLongName.
  ///
  /// In en, this message translates to:
  /// **'Insert Inside'**
  String get appLongName;

  /// No description provided for @appIntroduce_1.
  ///
  /// In en, this message translates to:
  /// **'Insert Inside'**
  String get appIntroduce_1;

  /// No description provided for @appIntroduce_2.
  ///
  /// In en, this message translates to:
  /// **'Visualize\n the invisible'**
  String get appIntroduce_2;

  /// No description provided for @appIntroduce_3.
  ///
  /// In en, this message translates to:
  /// **'Own yourself.'**
  String get appIntroduce_3;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get or;

  /// No description provided for @signInWithEmail.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Email'**
  String get signInWithEmail;

  /// No description provided for @askingIsMember.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have account? '**
  String get askingIsMember;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get signUp;

  /// No description provided for @logIn.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get logIn;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot your password?'**
  String get forgotPassword;

  /// No description provided for @resetPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPasswordTitle;

  /// No description provided for @sendEmail.
  ///
  /// In en, this message translates to:
  /// **'Send Email'**
  String get sendEmail;

  /// No description provided for @onboarding_gender.
  ///
  /// In en, this message translates to:
  /// **'We\'ll tune your insights.\n As uniquely as you are.'**
  String get onboarding_gender;

  /// No description provided for @onboarding_birth.
  ///
  /// In en, this message translates to:
  /// **'Your age guides\n how your body recovers.'**
  String get onboarding_birth;

  /// No description provided for @onboarding_bodymetrics.
  ///
  /// In en, this message translates to:
  /// **'Your body shape completes\nthe picture.'**
  String get onboarding_bodymetrics;

  /// No description provided for @gender_male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get gender_male;

  /// No description provided for @gender_female.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get gender_female;

  /// No description provided for @select_gender.
  ///
  /// In en, this message translates to:
  /// **'Select your gender'**
  String get select_gender;

  /// No description provided for @select_birthdate.
  ///
  /// In en, this message translates to:
  /// **'Select your birth date'**
  String get select_birthdate;

  /// No description provided for @select_hw.
  ///
  /// In en, this message translates to:
  /// **'Select your height and weight'**
  String get select_hw;

  /// No description provided for @select_bodytype.
  ///
  /// In en, this message translates to:
  /// **'Select your body type'**
  String get select_bodytype;

  /// No description provided for @bodytype_slim.
  ///
  /// In en, this message translates to:
  /// **'Slim'**
  String get bodytype_slim;

  /// No description provided for @bodytype_average.
  ///
  /// In en, this message translates to:
  /// **'Average'**
  String get bodytype_average;

  /// No description provided for @bodytype_muscular.
  ///
  /// In en, this message translates to:
  /// **'Muscular'**
  String get bodytype_muscular;

  /// No description provided for @bodytype_overweight.
  ///
  /// In en, this message translates to:
  /// **'Over-weight'**
  String get bodytype_overweight;

  /// No description provided for @bodytype_obese.
  ///
  /// In en, this message translates to:
  /// **'Obese'**
  String get bodytype_obese;

  /// Shows user's height & weight before asking body type
  ///
  /// In en, this message translates to:
  /// **'{height} cm · {weight} kg\nAlmost there — pick your body type!'**
  String onboarding_bodytype_dynamic(int height, int weight);

  /// No description provided for @authSigningIn.
  ///
  /// In en, this message translates to:
  /// **'Signing in...'**
  String get authSigningIn;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @continueWithApple.
  ///
  /// In en, this message translates to:
  /// **'Continue with Apple'**
  String get continueWithApple;

  /// No description provided for @authCreatingAccount.
  ///
  /// In en, this message translates to:
  /// **'Creating your account...'**
  String get authCreatingAccount;

  /// No description provided for @actionTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get actionTryAgain;

  /// No description provided for @actionGoToLogin.
  ///
  /// In en, this message translates to:
  /// **'Go to Login'**
  String get actionGoToLogin;

  /// No description provided for @verifyYourEmail.
  ///
  /// In en, this message translates to:
  /// **'Verify Your Email'**
  String get verifyYourEmail;

  /// No description provided for @nextSteps.
  ///
  /// In en, this message translates to:
  /// **'Next steps:'**
  String get nextSteps;

  /// No description provided for @resendEmail.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t receive the email? Resend'**
  String get resendEmail;

  /// No description provided for @verificationEmailResent.
  ///
  /// In en, this message translates to:
  /// **'Verification email resent'**
  String get verificationEmailResent;

  /// No description provided for @actionBackToLogin.
  ///
  /// In en, this message translates to:
  /// **'Back to Login'**
  String get actionBackToLogin;

  /// No description provided for @actionContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get actionContinue;

  /// No description provided for @fieldEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get fieldEmail;

  /// No description provided for @fieldFullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fieldFullName;

  /// No description provided for @fieldPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get fieldPassword;

  /// No description provided for @errorPasswordPolicy.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters with at least 1 number'**
  String get errorPasswordPolicy;

  /// No description provided for @fieldConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get fieldConfirmPassword;

  /// No description provided for @errorPasswordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get errorPasswordsDoNotMatch;

  /// No description provided for @signUpWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Sign up with Google'**
  String get signUpWithGoogle;

  /// No description provided for @signUpWithApple.
  ///
  /// In en, this message translates to:
  /// **'Sign up with Apple'**
  String get signUpWithApple;

  /// No description provided for @checkYourEmail.
  ///
  /// In en, this message translates to:
  /// **'Check Your Email'**
  String get checkYourEmail;

  /// Password reset email sent message with email address
  ///
  /// In en, this message translates to:
  /// **'We\'ve sent a password reset approval link to {email}. Please check your inbox and follow the instructions to reset your password.'**
  String resetEmailSentDescription(String email);

  /// Signup verification email sent message with email address
  ///
  /// In en, this message translates to:
  /// **'We\'ve sent an email to {email} with a verification link. Please click the link in your email to complete your registration.'**
  String signupEmailSentDescription(String email);

  /// No description provided for @signupNextStep1.
  ///
  /// In en, this message translates to:
  /// **'Check your email inbox for a verification link from us'**
  String get signupNextStep1;

  /// No description provided for @signupNextStep2.
  ///
  /// In en, this message translates to:
  /// **'Click on the link in the email to verify your account'**
  String get signupNextStep2;

  /// No description provided for @signupNextStep3.
  ///
  /// In en, this message translates to:
  /// **'Return to the app to complete your registration'**
  String get signupNextStep3;

  /// No description provided for @onboarding_scroll_down.
  ///
  /// In en, this message translates to:
  /// **'Scroll down to save and continue'**
  String get onboarding_scroll_down;

  /// No description provided for @onboarding_scroll_up.
  ///
  /// In en, this message translates to:
  /// **'Scroll up to go back'**
  String get onboarding_scroll_up;

  /// No description provided for @onboarding_saving.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get onboarding_saving;

  /// Centimeter unit label with value
  ///
  /// In en, this message translates to:
  /// **'{value} cm'**
  String unit_cm(int value);

  /// Kilogram unit label with value
  ///
  /// In en, this message translates to:
  /// **'{value} kg'**
  String unit_kg(int value);

  /// No description provided for @intro_title.
  ///
  /// In en, this message translates to:
  /// **'AI Meal Planner'**
  String get intro_title;

  /// No description provided for @intro_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Track, analyze, and optimize your nutrition using AI. Smart meals, smarter habits.'**
  String get intro_subtitle;

  /// No description provided for @intro_get_started.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get intro_get_started;

  /// No description provided for @onboarding_log_saving_metrics.
  ///
  /// In en, this message translates to:
  /// **'Saving your health metrics…'**
  String get onboarding_log_saving_metrics;

  /// No description provided for @onboarding_log_initializing_simulator.
  ///
  /// In en, this message translates to:
  /// **'Initializing body simulator…'**
  String get onboarding_log_initializing_simulator;

  /// No description provided for @errorInvalidEmailShort.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get errorInvalidEmailShort;

  /// No description provided for @termsTitle.
  ///
  /// In en, this message translates to:
  /// **'Terms & Privacy'**
  String get termsTitle;

  /// No description provided for @termsDescription.
  ///
  /// In en, this message translates to:
  /// **'Before continuing, please review and accept our Terms of Service and Privacy Policy.'**
  String get termsDescription;

  /// No description provided for @termsAcceptAndContinue.
  ///
  /// In en, this message translates to:
  /// **'Accept and Continue'**
  String get termsAcceptAndContinue;

  /// No description provided for @iAgreeTo.
  ///
  /// In en, this message translates to:
  /// **'I agree to the '**
  String get iAgreeTo;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// Shown when failing to open external URL
  ///
  /// In en, this message translates to:
  /// **'Could not open: {url}'**
  String couldNotOpenUrl(String url);

  /// No description provided for @home_score.
  ///
  /// In en, this message translates to:
  /// **'Score'**
  String get home_score;

  /// Subtitle showing overall score value
  ///
  /// In en, this message translates to:
  /// **'Overall {score}'**
  String home_overall_score(String score);

  /// No description provided for @home_questions.
  ///
  /// In en, this message translates to:
  /// **'Questions'**
  String get home_questions;

  /// No description provided for @home_no_pending_questions.
  ///
  /// In en, this message translates to:
  /// **'No pending questions'**
  String get home_no_pending_questions;

  /// Number of pending questions
  ///
  /// In en, this message translates to:
  /// **'{count} pending'**
  String home_num_pending(int count);

  /// No description provided for @home_chat_history.
  ///
  /// In en, this message translates to:
  /// **'Chat History'**
  String get home_chat_history;

  /// No description provided for @home_chat_history_subtitle.
  ///
  /// In en, this message translates to:
  /// **'View your chat history'**
  String get home_chat_history_subtitle;

  /// No description provided for @tq_loading_1.
  ///
  /// In en, this message translates to:
  /// **'Getting your check-ins'**
  String get tq_loading_1;

  /// No description provided for @tq_loading_2.
  ///
  /// In en, this message translates to:
  /// **'Almost ready'**
  String get tq_loading_2;

  /// No description provided for @tq_loading_3.
  ///
  /// In en, this message translates to:
  /// **'Let\'s begin'**
  String get tq_loading_3;

  /// No description provided for @tq_empty.
  ///
  /// In en, this message translates to:
  /// **'No questions yet.'**
  String get tq_empty;

  /// No description provided for @qs_tab_questions.
  ///
  /// In en, this message translates to:
  /// **'Questions'**
  String get qs_tab_questions;

  /// No description provided for @qs_tab_answered.
  ///
  /// In en, this message translates to:
  /// **'Answered'**
  String get qs_tab_answered;

  /// No description provided for @qs_update_updating.
  ///
  /// In en, this message translates to:
  /// **'Updating...'**
  String get qs_update_updating;

  /// No description provided for @qs_update_status.
  ///
  /// In en, this message translates to:
  /// **'Update status'**
  String get qs_update_status;

  /// No description provided for @qs_ask_ai.
  ///
  /// In en, this message translates to:
  /// **'Ask AI'**
  String get qs_ask_ai;

  /// No description provided for @qs_sign_in_required.
  ///
  /// In en, this message translates to:
  /// **'Please sign in to start chat'**
  String get qs_sign_in_required;

  /// No description provided for @qs_updates_intro.
  ///
  /// In en, this message translates to:
  /// **'Here are my latest updates:'**
  String get qs_updates_intro;

  /// No description provided for @qs_updates_request.
  ///
  /// In en, this message translates to:
  /// **'Please provide guidance and next steps.'**
  String get qs_updates_request;

  /// No description provided for @bs_loading.
  ///
  /// In en, this message translates to:
  /// **'getting body simulator data...'**
  String get bs_loading;

  /// No description provided for @action_retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get action_retry;

  /// No description provided for @tab_overview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get tab_overview;

  /// No description provided for @tab_highlights.
  ///
  /// In en, this message translates to:
  /// **'Highlights'**
  String get tab_highlights;

  /// No description provided for @tab_metrics.
  ///
  /// In en, this message translates to:
  /// **'Metrics'**
  String get tab_metrics;

  /// No description provided for @label_overall_score.
  ///
  /// In en, this message translates to:
  /// **'Overall score'**
  String get label_overall_score;

  /// No description provided for @label_insights.
  ///
  /// In en, this message translates to:
  /// **'Insights'**
  String get label_insights;

  /// No description provided for @label_organ_scores.
  ///
  /// In en, this message translates to:
  /// **'Organ scores'**
  String get label_organ_scores;

  /// No description provided for @label_strengths.
  ///
  /// In en, this message translates to:
  /// **'Strengths 💪'**
  String get label_strengths;

  /// No description provided for @label_concerns.
  ///
  /// In en, this message translates to:
  /// **'Areas of Concern ⚠️'**
  String get label_concerns;

  /// No description provided for @organ_brain.
  ///
  /// In en, this message translates to:
  /// **'Brain'**
  String get organ_brain;

  /// No description provided for @organ_heart.
  ///
  /// In en, this message translates to:
  /// **'Heart'**
  String get organ_heart;

  /// No description provided for @organ_lungs.
  ///
  /// In en, this message translates to:
  /// **'Lungs'**
  String get organ_lungs;

  /// No description provided for @organ_liver.
  ///
  /// In en, this message translates to:
  /// **'Liver'**
  String get organ_liver;

  /// No description provided for @organ_stomach.
  ///
  /// In en, this message translates to:
  /// **'Stomach'**
  String get organ_stomach;

  /// No description provided for @organ_intestines.
  ///
  /// In en, this message translates to:
  /// **'Intestines'**
  String get organ_intestines;

  /// No description provided for @organ_kidneys.
  ///
  /// In en, this message translates to:
  /// **'Kidneys'**
  String get organ_kidneys;

  /// No description provided for @organ_endocrine.
  ///
  /// In en, this message translates to:
  /// **'Endocrine'**
  String get organ_endocrine;

  /// No description provided for @organ_nervous.
  ///
  /// In en, this message translates to:
  /// **'Nervous'**
  String get organ_nervous;

  /// No description provided for @brain_stress_level.
  ///
  /// In en, this message translates to:
  /// **'Stress level'**
  String get brain_stress_level;

  /// No description provided for @brain_serotonin.
  ///
  /// In en, this message translates to:
  /// **'Serotonin'**
  String get brain_serotonin;

  /// No description provided for @brain_sleep_rhythm.
  ///
  /// In en, this message translates to:
  /// **'Sleep rhythm'**
  String get brain_sleep_rhythm;

  /// No description provided for @brain_cortisol.
  ///
  /// In en, this message translates to:
  /// **'Cortisol'**
  String get brain_cortisol;

  /// No description provided for @heart_blood_sugar.
  ///
  /// In en, this message translates to:
  /// **'Blood sugar'**
  String get heart_blood_sugar;

  /// No description provided for @heart_blood_pressure.
  ///
  /// In en, this message translates to:
  /// **'Blood pressure'**
  String get heart_blood_pressure;

  /// No description provided for @heart_heart_rate.
  ///
  /// In en, this message translates to:
  /// **'Heart rate'**
  String get heart_heart_rate;

  /// No description provided for @heart_hrv.
  ///
  /// In en, this message translates to:
  /// **'HRV'**
  String get heart_hrv;

  /// No description provided for @lungs_o2_saturation.
  ///
  /// In en, this message translates to:
  /// **'O₂ saturation'**
  String get lungs_o2_saturation;

  /// No description provided for @lungs_health_index.
  ///
  /// In en, this message translates to:
  /// **'Health index'**
  String get lungs_health_index;

  /// No description provided for @lungs_pm_exposure.
  ///
  /// In en, this message translates to:
  /// **'PM exposure'**
  String get lungs_pm_exposure;

  /// No description provided for @lungs_respiratory_rate.
  ///
  /// In en, this message translates to:
  /// **'Respiratory rate'**
  String get lungs_respiratory_rate;

  /// No description provided for @liver_detox_capacity.
  ///
  /// In en, this message translates to:
  /// **'Detox capacity'**
  String get liver_detox_capacity;

  /// No description provided for @liver_enzymes.
  ///
  /// In en, this message translates to:
  /// **'Liver enzymes'**
  String get liver_enzymes;

  /// No description provided for @liver_fat_processing.
  ///
  /// In en, this message translates to:
  /// **'Fat processing'**
  String get liver_fat_processing;

  /// No description provided for @liver_alcohol_load.
  ///
  /// In en, this message translates to:
  /// **'Alcohol load'**
  String get liver_alcohol_load;

  /// No description provided for @stomach_digestion_speed.
  ///
  /// In en, this message translates to:
  /// **'Digestion speed'**
  String get stomach_digestion_speed;

  /// No description provided for @stomach_acidity.
  ///
  /// In en, this message translates to:
  /// **'Acidity'**
  String get stomach_acidity;

  /// No description provided for @stomach_nausea_risk.
  ///
  /// In en, this message translates to:
  /// **'Nausea risk'**
  String get stomach_nausea_risk;

  /// No description provided for @stomach_food_retention.
  ///
  /// In en, this message translates to:
  /// **'Food retention'**
  String get stomach_food_retention;

  /// No description provided for @intestines_bacteria_diversity.
  ///
  /// In en, this message translates to:
  /// **'Bacteria diversity'**
  String get intestines_bacteria_diversity;

  /// No description provided for @intestines_inflammation.
  ///
  /// In en, this message translates to:
  /// **'Inflammation'**
  String get intestines_inflammation;

  /// No description provided for @intestines_absorption_rate.
  ///
  /// In en, this message translates to:
  /// **'Absorption rate'**
  String get intestines_absorption_rate;

  /// No description provided for @intestines_gas_level.
  ///
  /// In en, this message translates to:
  /// **'Gas level'**
  String get intestines_gas_level;

  /// No description provided for @kidneys_hydration.
  ///
  /// In en, this message translates to:
  /// **'Hydration'**
  String get kidneys_hydration;

  /// No description provided for @kidneys_electrolyte_balance.
  ///
  /// In en, this message translates to:
  /// **'Electrolyte balance'**
  String get kidneys_electrolyte_balance;

  /// No description provided for @kidneys_urea_clearance.
  ///
  /// In en, this message translates to:
  /// **'Urea clearance'**
  String get kidneys_urea_clearance;

  /// No description provided for @kidneys_toxicity_load.
  ///
  /// In en, this message translates to:
  /// **'Toxicity load'**
  String get kidneys_toxicity_load;

  /// No description provided for @endocrine_insulin_sensitivity.
  ///
  /// In en, this message translates to:
  /// **'Insulin sensitivity'**
  String get endocrine_insulin_sensitivity;

  /// No description provided for @endocrine_thyroid_function.
  ///
  /// In en, this message translates to:
  /// **'Thyroid function'**
  String get endocrine_thyroid_function;

  /// No description provided for @endocrine_et_ratio.
  ///
  /// In en, this message translates to:
  /// **'E/T ratio'**
  String get endocrine_et_ratio;

  /// No description provided for @nervous_focus_level.
  ///
  /// In en, this message translates to:
  /// **'Focus level'**
  String get nervous_focus_level;

  /// No description provided for @nervous_mood_stability.
  ///
  /// In en, this message translates to:
  /// **'Mood stability'**
  String get nervous_mood_stability;

  /// No description provided for @nervous_anxiety_level.
  ///
  /// In en, this message translates to:
  /// **'Anxiety level'**
  String get nervous_anxiety_level;

  /// No description provided for @nervous_neuro_flexibility.
  ///
  /// In en, this message translates to:
  /// **'Neuro flexibility'**
  String get nervous_neuro_flexibility;

  /// No description provided for @chat_helper_ai_suggestions.
  ///
  /// In en, this message translates to:
  /// **'AI suggestions'**
  String get chat_helper_ai_suggestions;

  /// No description provided for @chat_helper_body_alerts.
  ///
  /// In en, this message translates to:
  /// **'Body Alerts'**
  String get chat_helper_body_alerts;

  /// No description provided for @chat_helper_select_system.
  ///
  /// In en, this message translates to:
  /// **'Select body system'**
  String get chat_helper_select_system;

  /// No description provided for @chat_helper_current_context.
  ///
  /// In en, this message translates to:
  /// **'Current health context'**
  String get chat_helper_current_context;

  /// No description provided for @meta_system.
  ///
  /// In en, this message translates to:
  /// **'System: {value}'**
  String meta_system(String value);

  /// No description provided for @meta_metric.
  ///
  /// In en, this message translates to:
  /// **'Metric: {value}'**
  String meta_metric(String value);

  /// No description provided for @meta_category.
  ///
  /// In en, this message translates to:
  /// **'Category: {value}'**
  String meta_category(String value);

  /// No description provided for @chat_no_messages.
  ///
  /// In en, this message translates to:
  /// **'No messages in this session'**
  String get chat_no_messages;

  /// No description provided for @chat_loading_session.
  ///
  /// In en, this message translates to:
  /// **'Loading session {index}'**
  String chat_loading_session(int index);

  /// No description provided for @chat_swipe_hint.
  ///
  /// In en, this message translates to:
  /// **'Swipe left/right to see other chats'**
  String get chat_swipe_hint;

  /// No description provided for @chat_generating.
  ///
  /// In en, this message translates to:
  /// **'Generating...'**
  String get chat_generating;

  /// No description provided for @chat_getting_checkins.
  ///
  /// In en, this message translates to:
  /// **'Getting your check-ins...'**
  String get chat_getting_checkins;

  /// No description provided for @time_just_now.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get time_just_now;

  /// No description provided for @time_minutes_ago.
  ///
  /// In en, this message translates to:
  /// **'{m}m ago'**
  String time_minutes_ago(int m);

  /// No description provided for @time_hours_ago.
  ///
  /// In en, this message translates to:
  /// **'{h}h ago'**
  String time_hours_ago(int h);

  /// No description provided for @time_days_ago.
  ///
  /// In en, this message translates to:
  /// **'{d}d ago'**
  String time_days_ago(int d);

  /// No description provided for @chat_session_indicator.
  ///
  /// In en, this message translates to:
  /// **'Session {current} of {total}'**
  String chat_session_indicator(int current, int total);

  /// No description provided for @history_body_score_label.
  ///
  /// In en, this message translates to:
  /// **'Body Score: {score}'**
  String history_body_score_label(String score);

  /// No description provided for @image_label.
  ///
  /// In en, this message translates to:
  /// **'Image {index}'**
  String image_label(int index);

  /// No description provided for @time_now.
  ///
  /// In en, this message translates to:
  /// **'Now'**
  String get time_now;

  /// No description provided for @time_hours_ago_short.
  ///
  /// In en, this message translates to:
  /// **'{h}h ago'**
  String time_hours_ago_short(int h);

  /// No description provided for @chat_hint_context.
  ///
  /// In en, this message translates to:
  /// **'Tell me what you want to remember...'**
  String get chat_hint_context;

  /// No description provided for @chat_hint_healthday.
  ///
  /// In en, this message translates to:
  /// **'How was your health day?'**
  String get chat_hint_healthday;

  /// No description provided for @tooltip_saving_as_context.
  ///
  /// In en, this message translates to:
  /// **'Saving as context'**
  String get tooltip_saving_as_context;

  /// No description provided for @tooltip_save_temp_chat.
  ///
  /// In en, this message translates to:
  /// **'Save as temporary chat'**
  String get tooltip_save_temp_chat;

  /// No description provided for @tooltip_add_image.
  ///
  /// In en, this message translates to:
  /// **'Add image'**
  String get tooltip_add_image;

  /// No description provided for @tooltip_send_message.
  ///
  /// In en, this message translates to:
  /// **'Send message'**
  String get tooltip_send_message;

  /// No description provided for @msg_title_generic.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get msg_title_generic;

  /// No description provided for @msg_title_error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get msg_title_error;

  /// No description provided for @msg_title_success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get msg_title_success;

  /// No description provided for @auth_sign_in.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get auth_sign_in;

  /// No description provided for @auth_sign_in_required.
  ///
  /// In en, this message translates to:
  /// **'Sign In Required'**
  String get auth_sign_in_required;

  /// No description provided for @auth_sign_in_request.
  ///
  /// In en, this message translates to:
  /// **'Please sign in to access all features'**
  String get auth_sign_in_request;

  /// No description provided for @auth_feature_locked.
  ///
  /// In en, this message translates to:
  /// **'This feature requires an account. Would you like to sign in?'**
  String get auth_feature_locked;

  /// No description provided for @auth_not_now.
  ///
  /// In en, this message translates to:
  /// **'Not Now'**
  String get auth_not_now;

  /// No description provided for @auth_sign_in_options.
  ///
  /// In en, this message translates to:
  /// **'Sign In Options'**
  String get auth_sign_in_options;

  /// No description provided for @auth_choose_sign_in.
  ///
  /// In en, this message translates to:
  /// **'Choose how you would like to sign in'**
  String get auth_choose_sign_in;

  /// No description provided for @auth_sign_in_email.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Email'**
  String get auth_sign_in_email;

  /// No description provided for @auth_sign_in_google.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get auth_sign_in_google;

  /// No description provided for @auth_sign_in_apple.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Apple'**
  String get auth_sign_in_apple;

  /// No description provided for @action_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get action_cancel;

  /// No description provided for @context_title.
  ///
  /// In en, this message translates to:
  /// **'Tell us about you'**
  String get context_title;

  /// No description provided for @context_subtitle.
  ///
  /// In en, this message translates to:
  /// **'What should we know about you? This helps personalize your experience.'**
  String get context_subtitle;

  /// No description provided for @context_hint_memory.
  ///
  /// In en, this message translates to:
  /// **'What should we know about you?'**
  String get context_hint_memory;

  /// No description provided for @context_hint_ai.
  ///
  /// In en, this message translates to:
  /// **'Adjust AI preferences (language, tone, style)...'**
  String get context_hint_ai;

  /// No description provided for @context_hint_auto.
  ///
  /// In en, this message translates to:
  /// **'Share context or preferences to personalize your experience'**
  String get context_hint_auto;

  /// No description provided for @context_mode_auto.
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get context_mode_auto;

  /// No description provided for @context_mode_mem.
  ///
  /// In en, this message translates to:
  /// **'Mem'**
  String get context_mode_mem;

  /// No description provided for @context_mode_ai.
  ///
  /// In en, this message translates to:
  /// **'AI'**
  String get context_mode_ai;

  /// No description provided for @tooltip_save_context.
  ///
  /// In en, this message translates to:
  /// **'Save context'**
  String get tooltip_save_context;

  /// No description provided for @snackbar_processing.
  ///
  /// In en, this message translates to:
  /// **'Saving to memory...'**
  String get snackbar_processing;

  /// No description provided for @snackbar_saved.
  ///
  /// In en, this message translates to:
  /// **'Saved to memory'**
  String get snackbar_saved;

  /// No description provided for @snackbar_failed.
  ///
  /// In en, this message translates to:
  /// **'Failed to save'**
  String get snackbar_failed;

  /// No description provided for @settings_title.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings_title;

  /// No description provided for @settings_section_account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get settings_section_account;

  /// No description provided for @settings_sign_out.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get settings_sign_out;

  /// No description provided for @settings_reset_health_data.
  ///
  /// In en, this message translates to:
  /// **'Reset Health Data'**
  String get settings_reset_health_data;

  /// No description provided for @settings_section_ai.
  ///
  /// In en, this message translates to:
  /// **'AI Settings'**
  String get settings_section_ai;

  /// No description provided for @ai_tone.
  ///
  /// In en, this message translates to:
  /// **'Tone'**
  String get ai_tone;

  /// No description provided for @ai_language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get ai_language;

  /// No description provided for @ai_formality.
  ///
  /// In en, this message translates to:
  /// **'Formality'**
  String get ai_formality;

  /// No description provided for @ai_detail_level.
  ///
  /// In en, this message translates to:
  /// **'Detail Level'**
  String get ai_detail_level;

  /// No description provided for @ai_emoji_usage.
  ///
  /// In en, this message translates to:
  /// **'Emoji Usage'**
  String get ai_emoji_usage;

  /// No description provided for @ai_response_length.
  ///
  /// In en, this message translates to:
  /// **'Response Length'**
  String get ai_response_length;

  /// No description provided for @ai_goal_focus.
  ///
  /// In en, this message translates to:
  /// **'Goal Focus'**
  String get ai_goal_focus;

  /// No description provided for @ai_summarize_style.
  ///
  /// In en, this message translates to:
  /// **'Summarize Style'**
  String get ai_summarize_style;

  /// No description provided for @settings_section_health_context.
  ///
  /// In en, this message translates to:
  /// **'Health Context'**
  String get settings_section_health_context;

  /// No description provided for @settings_section_memorized.
  ///
  /// In en, this message translates to:
  /// **'Memorized Context'**
  String get settings_section_memorized;

  /// No description provided for @settings_section_appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settings_section_appearance;

  /// No description provided for @settings_dark_mode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get settings_dark_mode;

  /// No description provided for @settings_section_about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settings_section_about;

  /// No description provided for @settings_app_version.
  ///
  /// In en, this message translates to:
  /// **'App Version'**
  String get settings_app_version;

  /// No description provided for @settings_terms.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get settings_terms;

  /// No description provided for @settings_privacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get settings_privacy;

  /// No description provided for @settings_reset_title.
  ///
  /// In en, this message translates to:
  /// **'Reset Health Data'**
  String get settings_reset_title;

  /// No description provided for @settings_reset_content.
  ///
  /// In en, this message translates to:
  /// **'This will reset all your health-related data including height, weight, conditions, and more. This action cannot be undone.'**
  String get settings_reset_content;

  /// No description provided for @settings_resetting.
  ///
  /// In en, this message translates to:
  /// **'Resetting health data...'**
  String get settings_resetting;

  /// No description provided for @settings_reset_success.
  ///
  /// In en, this message translates to:
  /// **'Health data reset successfully'**
  String get settings_reset_success;

  /// No description provided for @settings_reset_error.
  ///
  /// In en, this message translates to:
  /// **'Error resetting health data: {error}'**
  String settings_reset_error(String error);

  /// No description provided for @action_reset.
  ///
  /// In en, this message translates to:
  /// **'RESET'**
  String get action_reset;

  /// No description provided for @change_password_title.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get change_password_title;

  /// No description provided for @field_current_password.
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get field_current_password;

  /// No description provided for @field_new_password.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get field_new_password;

  /// No description provided for @field_confirm_new_password.
  ///
  /// In en, this message translates to:
  /// **'Confirm New Password'**
  String get field_confirm_new_password;

  /// No description provided for @action_update_password.
  ///
  /// In en, this message translates to:
  /// **'Update Password'**
  String get action_update_password;

  /// No description provided for @error_fix_before_continue.
  ///
  /// In en, this message translates to:
  /// **'Please correct the errors before continuing'**
  String get error_fix_before_continue;

  /// No description provided for @success_password_updated.
  ///
  /// In en, this message translates to:
  /// **'Password updated'**
  String get success_password_updated;

  /// No description provided for @recs_title.
  ///
  /// In en, this message translates to:
  /// **'Product Recommendations'**
  String get recs_title;

  /// No description provided for @recs_empty.
  ///
  /// In en, this message translates to:
  /// **'No product recommendations yet'**
  String get recs_empty;

  /// No description provided for @recs_priority.
  ///
  /// In en, this message translates to:
  /// **'Priority {value}'**
  String recs_priority(int value);

  /// No description provided for @recs_key_benefits.
  ///
  /// In en, this message translates to:
  /// **'Key benefits'**
  String get recs_key_benefits;

  /// No description provided for @recs_recommended_use.
  ///
  /// In en, this message translates to:
  /// **'Recommended use'**
  String get recs_recommended_use;

  /// No description provided for @recs_notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get recs_notes;

  /// No description provided for @recs_category_fallback.
  ///
  /// In en, this message translates to:
  /// **'item'**
  String get recs_category_fallback;

  /// No description provided for @recs_open_link.
  ///
  /// In en, this message translates to:
  /// **'Open link'**
  String get recs_open_link;

  /// No description provided for @settings_delete_account.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get settings_delete_account;

  /// No description provided for @settings_delete_account_title.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get settings_delete_account_title;

  /// No description provided for @settings_delete_account_content.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete your account? This will permanently delete all your data including your profile, health metrics, chat history, and all other information. This action cannot be undone.'**
  String get settings_delete_account_content;

  /// No description provided for @settings_deleting_account.
  ///
  /// In en, this message translates to:
  /// **'Deleting account...'**
  String get settings_deleting_account;

  /// No description provided for @settings_delete_account_error.
  ///
  /// In en, this message translates to:
  /// **'Error deleting account: {error}'**
  String settings_delete_account_error(String error);

  /// No description provided for @action_delete.
  ///
  /// In en, this message translates to:
  /// **'DELETE'**
  String get action_delete;

  /// Shown when the backend health check cannot be reached
  ///
  /// In en, this message translates to:
  /// **'Can\'t reach the server right now. Please check your network connection and try again.'**
  String get error_check_network;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ko'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ko':
      return AppLocalizationsKo();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
