// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appName => '인스';

  @override
  String get appLongName => '인서트 인사이드';

  @override
  String get appIntroduce_1 => '눌러봐, 인사이드';

  @override
  String get appIntroduce_2 => '눈에 보이지 않던 모든 것\n 이제 당신의 시선으로';

  @override
  String get appIntroduce_3 => '스스로를 완성하다.';

  @override
  String get or => '또는';

  @override
  String get signInWithEmail => '이메일 로그인';

  @override
  String get askingIsMember => '아직 회원이 아니신가요?';

  @override
  String get signUp => '회원가입';

  @override
  String get logIn => '로그인';

  @override
  String get forgotPassword => '비밀번호를 잊으셨나요?';

  @override
  String get resetPasswordTitle => '비밀번호 재설정';

  @override
  String get sendEmail => '이메일 보내기';

  @override
  String get onboarding_gender => '당신만큼 고유한 인사이트를 드려요.';

  @override
  String get onboarding_birth => '나이는 몸의 회복에 영향을 줍니다.';

  @override
  String get onboarding_bodymetrics => '당신의 체형이 그림을 완성합니다.';

  @override
  String get gender_male => '남성';

  @override
  String get gender_female => '여성';

  @override
  String get select_gender => '성별을 선택하세요';

  @override
  String get select_birthdate => '생년월일을 선택하세요';

  @override
  String get select_hw => '키와 몸무게를 선택하세요';

  @override
  String get select_bodytype => '체형을 선택하세요';

  @override
  String get bodytype_slim => '마름';

  @override
  String get bodytype_average => '평균';

  @override
  String get bodytype_muscular => '근육질';

  @override
  String get bodytype_overweight => '과체중';

  @override
  String get bodytype_obese => '비만';

  @override
  String onboarding_bodytype_dynamic(int height, int weight) {
    return '$height cm · $weight kg\n거의 끝났어요! 체형을 골라 주세요';
  }

  @override
  String get authSigningIn => '로그인 중...';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get continueWithApple => 'Continue with Apple';

  @override
  String get authCreatingAccount => '계정 생성 중...';

  @override
  String get actionTryAgain => '다시 시도';

  @override
  String get actionGoToLogin => '로그인으로 이동';

  @override
  String get verifyYourEmail => '이메일 인증';

  @override
  String get nextSteps => '다음 단계:';

  @override
  String get resendEmail => '이메일을 받지 못하셨나요? 다시 보내기';

  @override
  String get verificationEmailResent => '인증 이메일을 다시 보냈습니다';

  @override
  String get actionBackToLogin => '로그인으로 돌아가기';

  @override
  String get actionContinue => '계속';

  @override
  String get fieldEmail => '이메일';

  @override
  String get fieldFullName => '이름';

  @override
  String get fieldPassword => '비밀번호';

  @override
  String get errorPasswordPolicy => '비밀번호는 숫자 1개 이상을 포함해 8자 이상이어야 합니다';

  @override
  String get fieldConfirmPassword => '비밀번호 확인';

  @override
  String get errorPasswordsDoNotMatch => '비밀번호가 일치하지 않습니다';

  @override
  String get signUpWithGoogle => 'Sign up with Google';

  @override
  String get signUpWithApple => 'Sign up with Apple';

  @override
  String get checkYourEmail => '이메일을 확인하세요';

  @override
  String resetEmailSentDescription(String email) {
    return '$email 주소로 비밀번호 재설정 링크를 보냈습니다. 받은편지함을 확인하고 안내에 따라 비밀번호를 재설정해 주세요.';
  }

  @override
  String signupEmailSentDescription(String email) {
    return '$email 주소로 인증 메일을 보냈습니다. 메일의 링크를 눌러 회원가입을 완료해 주세요.';
  }

  @override
  String get signupNextStep1 => '받은편지함에서 인증 메일을 확인하세요';

  @override
  String get signupNextStep2 => '메일의 링크를 눌러 계정을 인증하세요';

  @override
  String get signupNextStep3 => '앱으로 돌아와 회원가입을 완료하세요';

  @override
  String get onboarding_scroll_down => '아래로 스크롤하여 저장하고 계속하세요';

  @override
  String get onboarding_scroll_up => '위로 스크롤하여 뒤로 가기';

  @override
  String get onboarding_saving => '저장 중...';

  @override
  String unit_cm(int value) {
    return '$value cm';
  }

  @override
  String unit_kg(int value) {
    return '$value kg';
  }

  @override
  String get intro_title => 'AI 식단 플래너';

  @override
  String get intro_subtitle => 'AI로 영양을 기록, 분석하고 최적화하세요. 똑똑한 식사, 더 나은 습관.';

  @override
  String get intro_get_started => '시작하기';

  @override
  String get onboarding_log_saving_metrics => '건강 지표를 저장하는 중…';

  @override
  String get onboarding_log_initializing_simulator => '신체 시뮬레이터를 초기화하는 중…';

  @override
  String get errorInvalidEmailShort => '유효한 이메일을 입력해 주세요';

  @override
  String get termsTitle => '이용약관 및 개인정보처리방침';

  @override
  String get termsDescription => '계속하기 전에 이용약관과 개인정보처리방침을 확인하고 동의해 주세요.';

  @override
  String get termsAcceptAndContinue => '동의하고 계속하기';

  @override
  String get iAgreeTo => '';

  @override
  String get termsOfService => '이용약관';

  @override
  String get privacyPolicy => '개인정보처리방침';

  @override
  String couldNotOpenUrl(String url) {
    return '$url을(를) 열 수 없습니다';
  }

  @override
  String get home_score => '점수';

  @override
  String home_overall_score(String score) {
    return '전체 $score';
  }

  @override
  String get home_questions => '질문';

  @override
  String get home_no_pending_questions => '대기 중인 질문 없음';

  @override
  String home_num_pending(int count) {
    return '$count개 대기 중';
  }

  @override
  String get home_chat_history => '채팅 기록';

  @override
  String get home_chat_history_subtitle => '채팅 기록 보기';

  @override
  String get tq_loading_1 => '체크인을 불러오는 중';

  @override
  String get tq_loading_2 => '거의 준비됐어요';

  @override
  String get tq_loading_3 => '시작해 볼까요';

  @override
  String get tq_empty => '질문이 아직 없습니다.';

  @override
  String get qs_tab_questions => '질문';

  @override
  String get qs_tab_answered => '답변 완료';

  @override
  String get qs_update_updating => '업데이트 중...';

  @override
  String get qs_update_status => '상태 업데이트';

  @override
  String get qs_ask_ai => 'AI에게 물어보기';

  @override
  String get qs_sign_in_required => '채팅을 시작하려면 로그인해 주세요';

  @override
  String get qs_updates_intro => '최근 업데이트입니다:';

  @override
  String get qs_updates_request => '다음 단계와 가이드를 알려주세요.';

  @override
  String get bs_loading => '신체 시뮬레이터 데이터를 불러오는 중...';

  @override
  String get action_retry => '다시 시도';

  @override
  String get tab_overview => '개요';

  @override
  String get tab_highlights => '하이라이트';

  @override
  String get tab_metrics => '지표';

  @override
  String get label_overall_score => '전체 점수';

  @override
  String get label_insights => '인사이트';

  @override
  String get label_organ_scores => '장기별 점수';

  @override
  String get label_strengths => '강점 💪';

  @override
  String get label_concerns => '주의 필요 ⚠️';

  @override
  String get organ_brain => '뇌';

  @override
  String get organ_heart => '심장';

  @override
  String get organ_lungs => '폐';

  @override
  String get organ_liver => '간';

  @override
  String get organ_stomach => '위';

  @override
  String get organ_intestines => '장';

  @override
  String get organ_kidneys => '신장';

  @override
  String get organ_endocrine => '내분비';

  @override
  String get organ_nervous => '신경계';

  @override
  String get brain_stress_level => '스트레스 수준';

  @override
  String get brain_serotonin => '세로토닌';

  @override
  String get brain_sleep_rhythm => '수면 리듬';

  @override
  String get brain_cortisol => '코르티솔';

  @override
  String get heart_blood_sugar => '혈당';

  @override
  String get heart_blood_pressure => '혈압';

  @override
  String get heart_heart_rate => '심박수';

  @override
  String get heart_hrv => 'HRV';

  @override
  String get lungs_o2_saturation => '산소포화도';

  @override
  String get lungs_health_index => '건강 지수';

  @override
  String get lungs_pm_exposure => '미세먼지 노출';

  @override
  String get lungs_respiratory_rate => '호흡수';

  @override
  String get liver_detox_capacity => '해독 능력';

  @override
  String get liver_enzymes => '간 효소';

  @override
  String get liver_fat_processing => '지방 처리';

  @override
  String get liver_alcohol_load => '알코올 부담';

  @override
  String get stomach_digestion_speed => '소화 속도';

  @override
  String get stomach_acidity => '산도';

  @override
  String get stomach_nausea_risk => '메스꺼움 위험';

  @override
  String get stomach_food_retention => '음식 정체';

  @override
  String get intestines_bacteria_diversity => '장내 세균 다양성';

  @override
  String get intestines_inflammation => '염증';

  @override
  String get intestines_absorption_rate => '흡수율';

  @override
  String get intestines_gas_level => '가스 수준';

  @override
  String get kidneys_hydration => '수분 상태';

  @override
  String get kidneys_electrolyte_balance => '전해질 균형';

  @override
  String get kidneys_urea_clearance => '요소 제거율';

  @override
  String get kidneys_toxicity_load => '독성 부담';

  @override
  String get endocrine_insulin_sensitivity => '인슐린 감수성';

  @override
  String get endocrine_thyroid_function => '갑상선 기능';

  @override
  String get endocrine_et_ratio => 'E/T 비율';

  @override
  String get nervous_focus_level => '집중도';

  @override
  String get nervous_mood_stability => '기분 안정성';

  @override
  String get nervous_anxiety_level => '불안 수준';

  @override
  String get nervous_neuro_flexibility => '신경 가소성';

  @override
  String get chat_helper_ai_suggestions => 'AI 추천';

  @override
  String get chat_helper_body_alerts => '신체 알림';

  @override
  String get chat_helper_select_system => '신체 계통 선택';

  @override
  String get chat_helper_current_context => '현재 건강 컨텍스트';

  @override
  String meta_system(String value) {
    return '계통: $value';
  }

  @override
  String meta_metric(String value) {
    return '지표: $value';
  }

  @override
  String meta_category(String value) {
    return '분류: $value';
  }

  @override
  String get chat_no_messages => '이 세션에는 메시지가 없습니다';

  @override
  String chat_loading_session(int index) {
    return '$index번째 세션 불러오는 중';
  }

  @override
  String get chat_swipe_hint => '좌우로 스와이프하여 다른 채팅 보기';

  @override
  String get chat_generating => '생성 중...';

  @override
  String get chat_getting_checkins => '체크인을 불러오는 중...';

  @override
  String get time_just_now => '방금 전';

  @override
  String time_minutes_ago(int m) {
    return '$m분 전';
  }

  @override
  String time_hours_ago(int h) {
    return '$h시간 전';
  }

  @override
  String time_days_ago(int d) {
    return '$d일 전';
  }

  @override
  String chat_session_indicator(int current, int total) {
    return '세션 $current / $total';
  }

  @override
  String history_body_score_label(String score) {
    return '신체 점수: $score';
  }

  @override
  String image_label(int index) {
    return '이미지 $index';
  }

  @override
  String get time_now => '현재';

  @override
  String time_hours_ago_short(int h) {
    return '$h시간 전';
  }

  @override
  String get chat_hint_context => '기억해 두고 싶은 내용을 알려주세요...';

  @override
  String get chat_hint_healthday => '오늘 건강 상태는 어땠나요?';

  @override
  String get tooltip_saving_as_context => '컨텍스트로 저장';

  @override
  String get tooltip_save_temp_chat => '임시 채팅으로 저장';

  @override
  String get tooltip_add_image => '이미지 추가';

  @override
  String get tooltip_send_message => '메시지 보내기';

  @override
  String get msg_title_generic => '메시지';

  @override
  String get msg_title_error => '오류';

  @override
  String get msg_title_success => '성공';

  @override
  String get auth_sign_in => '로그인';

  @override
  String get auth_sign_in_required => '로그인 필요';

  @override
  String get auth_sign_in_request => '전체 기능을 사용하려면 로그인해 주세요';

  @override
  String get auth_feature_locked => '이 기능은 계정이 필요합니다. 로그인하시겠어요?';

  @override
  String get auth_not_now => '나중에';

  @override
  String get auth_sign_in_options => '로그인 옵션';

  @override
  String get auth_choose_sign_in => '로그인 방법을 선택하세요';

  @override
  String get auth_sign_in_email => '이메일로 로그인';

  @override
  String get auth_sign_in_google => 'Google로 로그인';

  @override
  String get auth_sign_in_apple => 'Apple로 로그인';

  @override
  String get action_cancel => '취소';

  @override
  String get context_title => '당신에 대해 알려주세요';

  @override
  String get context_subtitle => '무엇을 알고 있으면 좋을까요? 더 나은 개인화를 돕습니다.';

  @override
  String get context_hint_memory => '당신에 대해 무엇을 알고 있으면 좋을까요?';

  @override
  String get context_hint_ai => 'AI 설정을 조정하세요 (언어, 톤, 스타일 등)';

  @override
  String get context_hint_auto => '경험을 개인화할 수 있도록 컨텍스트/선호를 공유하세요';

  @override
  String get context_mode_auto => '자동';

  @override
  String get context_mode_mem => '메모리';

  @override
  String get context_mode_ai => 'AI';

  @override
  String get tooltip_save_context => '컨텍스트 저장';

  @override
  String get snackbar_processing => '메모리에 저장 중...';

  @override
  String get snackbar_saved => '메모리에 저장됐습니다';

  @override
  String get snackbar_failed => '저장에 실패했습니다';

  @override
  String get settings_title => '설정';

  @override
  String get settings_section_account => '계정';

  @override
  String get settings_sign_out => '로그아웃';

  @override
  String get settings_reset_health_data => '건강 데이터 초기화';

  @override
  String get settings_section_ai => 'AI 설정';

  @override
  String get ai_tone => '톤';

  @override
  String get ai_language => '언어';

  @override
  String get ai_formality => '격식';

  @override
  String get ai_detail_level => '상세 수준';

  @override
  String get ai_emoji_usage => '이모지 사용';

  @override
  String get ai_response_length => '응답 길이';

  @override
  String get ai_goal_focus => '목표 집중';

  @override
  String get ai_summarize_style => '요약 스타일';

  @override
  String get settings_section_health_context => '건강 컨텍스트';

  @override
  String get settings_section_memorized => '저장된 컨텍스트';

  @override
  String get settings_section_appearance => '모양';

  @override
  String get settings_dark_mode => '다크 모드';

  @override
  String get settings_section_about => '정보';

  @override
  String get settings_app_version => '앱 버전';

  @override
  String get settings_terms => '이용약관';

  @override
  String get settings_privacy => '개인정보처리방침';

  @override
  String get settings_reset_title => '건강 데이터 초기화';

  @override
  String get settings_reset_content =>
      '신장, 체중, 질환 등 건강 관련 데이터를 모두 초기화합니다. 이 작업은 되돌릴 수 없습니다.';

  @override
  String get settings_resetting => '건강 데이터를 초기화하는 중...';

  @override
  String get settings_reset_success => '건강 데이터가 초기화되었습니다';

  @override
  String settings_reset_error(String error) {
    return '건강 데이터 초기화 오류: $error';
  }

  @override
  String get action_reset => '초기화';

  @override
  String get change_password_title => '비밀번호 변경';

  @override
  String get field_current_password => '현재 비밀번호';

  @override
  String get field_new_password => '새 비밀번호';

  @override
  String get field_confirm_new_password => '새 비밀번호 확인';

  @override
  String get action_update_password => '비밀번호 업데이트';

  @override
  String get error_fix_before_continue => '계속하기 전에 오류를 수정해 주세요';

  @override
  String get success_password_updated => '비밀번호가 업데이트되었습니다';

  @override
  String get recs_title => '제품 추천';

  @override
  String get recs_empty => '추천할 제품이 아직 없습니다';

  @override
  String recs_priority(int value) {
    return '우선순위 $value';
  }

  @override
  String get recs_key_benefits => '핵심 이점';

  @override
  String get recs_recommended_use => '추천 사용법';

  @override
  String get recs_notes => '메모';

  @override
  String get recs_category_fallback => '항목';

  @override
  String get recs_open_link => '링크 열기';

  @override
  String get settings_delete_account => '계정 삭제';

  @override
  String get settings_delete_account_title => '계정 삭제';

  @override
  String get settings_delete_account_content =>
      '정말 계정을 삭제하시겠습니까? 프로필, 건강 지표, 채팅 기록 등 모든 데이터가 영구적으로 삭제됩니다. 이 작업은 되돌릴 수 없습니다.';

  @override
  String get settings_deleting_account => '계정을 삭제하는 중...';

  @override
  String settings_delete_account_error(String error) {
    return '계정 삭제 오류: $error';
  }

  @override
  String get action_delete => '삭제';

  @override
  String get error_check_network =>
      '서버에 연결할 수 없습니다. 네트워크 상태를 확인한 뒤 다시 시도해 주세요.';
}
