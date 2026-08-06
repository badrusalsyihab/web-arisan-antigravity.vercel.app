// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Digital Arisan';

  @override
  String get navDashboard => 'Dashboard';

  @override
  String get navRoulette => 'Roulette';

  @override
  String get navKas => 'Fund';

  @override
  String get navProfile => 'Profile';

  @override
  String get dashboardPaymentStatus => 'Payment Status List';

  @override
  String get paid => 'Paid';

  @override
  String get unpaid => 'UNPAID';

  @override
  String get joinGroupViaCode => 'Join Group via Code';

  @override
  String get groupSwitcherTitle => 'Choose Arisan Group';

  @override
  String get authLoginModeTitle => 'Login to your arisan group account';

  @override
  String get authRegisterModeTitle => 'Create a new arisan account in seconds';

  @override
  String get authLoginTab => 'Login';

  @override
  String get authRegisterTab => 'Register New';

  @override
  String get authNameReq => 'Full name is required';

  @override
  String get authNameLabel => 'Full Name';

  @override
  String get authPhoneLabel => 'WhatsApp Number';

  @override
  String get authEmailReq => 'Email is required';

  @override
  String get authEmailInvalid => 'Invalid email format';

  @override
  String get authEmailLabel => 'Email Address';

  @override
  String get authPassReq => 'Password is required';

  @override
  String get authPassMin => 'Password must be at least 5 characters';

  @override
  String get authPassNum => 'Password must contain a number';

  @override
  String get authPassSym =>
      'Password must contain a special character (symbol)';

  @override
  String get authPassLabel => 'Password';

  @override
  String get authBtnLogin => 'Log In';

  @override
  String get authBtnRegister => 'Create New Account';

  @override
  String get authOr => 'or';

  @override
  String get authGoogleSignIn => 'Sign in with Google';

  @override
  String get noGroupJoinTitle => 'Join Arisan Group';

  @override
  String get noGroupJoinSubtitle => 'Enter Group Code or Invite Link:';

  @override
  String get noGroupJoinHint => 'Example: ARISAN-RT05-2026';

  @override
  String get btnCancel => 'Cancel';

  @override
  String get btnJoin => 'Join';

  @override
  String noGroupGreeting(String name) {
    return 'Hello, $name!';
  }

  @override
  String get noGroupDesc =>
      'You haven\'t created or joined any arisan group yet.';

  @override
  String get noGroupCreateBtn => 'Create New Arisan Group';

  @override
  String get noGroupJoinBtn => 'Join Arisan Group';

  @override
  String get createGroupTitle => 'Create New Arisan Group';

  @override
  String get createGroupAdminNotice =>
      'You will automatically become the Admin/Leader of the group you create.';

  @override
  String get createGroupNameLabel => 'Arisan Group Name';

  @override
  String get createGroupNameHint => 'Example: Family Arisan / Community Arisan';

  @override
  String get createGroupPotLabel => 'Main Contribution Amount (Rp)';

  @override
  String get createGroupPeriodLabel => 'Draw Period';

  @override
  String get createGroupPeriodMonthly => 'Monthly (Month 1, Month 2...)';

  @override
  String get createGroupPeriodWeekly => 'Weekly (Week 1, Week 2...)';

  @override
  String get createGroupKasActive => 'Enable Kas Contribution (Optional)';

  @override
  String get createGroupKasDesc =>
      'Kas money is separated from the winner\'s pot';

  @override
  String get createGroupKasAmountLabel => 'Kas Amount Per Member (Rp)';

  @override
  String get createGroupBtnSave => 'Save & Publish Group';

  @override
  String get createGroupWinnerPending => 'Not Yet Won';

  @override
  String get createGroupRoleAdmin => 'Admin';

  @override
  String get joinGroupTitle => 'Join Group';

  @override
  String get joinGroupCodeLabel => 'Enter 6 Character Group Code';

  @override
  String get joinGroupCodeHint => 'Example: X7K9PQ';

  @override
  String get btnSearch => 'SEARCH';

  @override
  String get joinGroupErrEmpty => 'Enter 6 character group code';

  @override
  String get joinGroupErrNotFound => 'Group with that code was not found';

  @override
  String get joinGroupErrAlreadyJoined => 'You have already joined this group';

  @override
  String get joinGroupErrFailed => 'Failed to join group, please try again';

  @override
  String get joinGroupErrFailedNew => 'Failed to join group as a new member';

  @override
  String get joinGroupFoundTitle => 'Group Found 🎉';

  @override
  String get joinGroupSelectName => 'Select Your Name:';

  @override
  String get joinGroupDropdownHint => 'I am...';

  @override
  String get joinGroupBtnYes => 'Yes, This is Me (Join)';

  @override
  String get joinGroupOr => 'OR';

  @override
  String get joinGroupBtnNew => 'Register as New Member';

  @override
  String get dashConfirmDeleteTitle => 'Confirm Delete';

  @override
  String get dashConfirmDeleteBody =>
      'Are you sure you want to remove this member from the group?';

  @override
  String get dashBtnCancel => 'Cancel';

  @override
  String get dashBtnDelete => 'Delete';

  @override
  String get dashTotalCollected => 'Total Collected';

  @override
  String get dashKasCollected => 'Kas Collected';

  @override
  String get dashBtnInviteWA => 'Invite WA';

  @override
  String get dashArisanCompleted =>
      '🎉 Arisan Completed! All periods have been drawn.';

  @override
  String get dashBtnNewCycle => 'Start New Cycle';

  @override
  String get dashJoinCodeLabel => 'Group Join Code';

  @override
  String get dashBtnSetWinnerOrder => 'Set Winner Order';

  @override
  String get dashWinnerLabel => '🏆 Winner';

  @override
  String get dashGalleryTitle => '📸 Gallery & Documentation';

  @override
  String get dashBtnGalleryDetail => 'Gallery Detail';

  @override
  String get dashGalleryEmpty => 'No photos yet';

  @override
  String get dashBtnUploadPhoto => 'Upload Photo';

  @override
  String get histAddExpenseTitle => '💸 Log Kas Expense';

  @override
  String get histExpenseDesc => 'Expense Description';

  @override
  String get histExpenseDescHint => 'e.g. Snacks, Drinks, etc.';

  @override
  String get histRequiredField => 'Required field';

  @override
  String get histExpenseAmount => 'Expense Amount (Rp)';

  @override
  String get histExpenseAmountHint => 'Amount in Rp (e.g. 50000)';

  @override
  String get histRequiredAmount => 'Amount is required';

  @override
  String get histInvalidAmount => 'Enter a valid amount';

  @override
  String get histBtnSaveExpense => 'Save Kas Expense';

  @override
  String get histMainTitle => '📜 Financial & Kas History';

  @override
  String get histBtnSpend => 'Spend Kas';

  @override
  String get histSummaryTitle => 'Group Kas Balance Summary';

  @override
  String get histTotalIn => 'Total Kas In:';

  @override
  String get histTotalOut => 'Total Kas Out:';

  @override
  String get histBalance => 'Current Kas Balance:';

  @override
  String get histAuditTitle => 'Audit History Per Period';

  @override
  String get histAuditSub => 'Full Audit Log';

  @override
  String get histWaitingRoulette => 'Waiting Roulette';

  @override
  String get histActivePeriod => 'ACTIVE PERIOD';

  @override
  String get histNotStarted => 'NOT STARTED';

  @override
  String get histDone => 'DONE';

  @override
  String get histPot => 'Arisan Pot:';

  @override
  String get histKas => 'Kas:';

  @override
  String get histPerMember => '/ member';

  @override
  String get histWinner => 'Winner:';

  @override
  String get histTransactionsTitle => 'Kas Expense Transactions List';

  @override
  String get galUploadFailed =>
      'Sorry, failed to upload image. Please try again.';

  @override
  String get galUploadedBy => 'Uploaded by: ';

  @override
  String get galBtnClose => 'Close';

  @override
  String get galTitle => 'Gallery & Documentation';

  @override
  String get galBtnUpload => 'Upload';

  @override
  String get galEmpty => 'No photos yet';

  @override
  String get galBtnFirstUpload => 'Upload First Photo';

  @override
  String get roulCongrats => 'Congratulations to the Winner!';

  @override
  String get roulWinner => '🏆 WINNER';

  @override
  String get roulBtnCloseSave => 'Close & Save Results';

  @override
  String get roulAll => 'All';

  @override
  String get roulAlready => 'Already';

  @override
  String get roulWon => 'Won';

  @override
  String get roulTitle => 'Arisan Roulette Spin 🎯';

  @override
  String get roulDesc =>
      'Only members who HAVE NOT WON are entered into the Roulette Wheel.';

  @override
  String get roulSpinning => 'SPINNING ROULETTE...';

  @override
  String get roulBtnSpinAdmin => 'SPIN ROULETTE (ADMIN ACCESS)';

  @override
  String get roulBtnSpinNotAdmin => 'ONLY ADMIN CAN SPIN';

  @override
  String get profEditPhoneTitle => '📱 Edit WhatsApp No.';

  @override
  String get profEditPhoneDesc =>
      'Enter your active WhatsApp number so other members can easily contact you for payment confirmation.';

  @override
  String get profPhoneLabel => 'WhatsApp Number';

  @override
  String get profPhoneHint => 'Example: 081234567890';

  @override
  String get profPhoneRequired => 'WhatsApp Number is required';

  @override
  String get profPhoneInvalid => 'Invalid WhatsApp Number';

  @override
  String get profBtnSavePhone => 'Save WhatsApp Number';

  @override
  String get profTitle => '👤 User Profile';

  @override
  String get profLogoutTooltip => 'Logout';

  @override
  String get profAddPhone => 'Add WhatsApp No.';

  @override
  String get profBtnLogout => 'Logout Account';

  @override
  String get profAppVersion => 'App Version: ';

  @override
  String get profCreateGroupTitle => 'Want to Create a New Arisan?';

  @override
  String get profCreateGroupDesc =>
      'You can create your own arisan group and become the Admin/Leader.';

  @override
  String get profBtnCreateGroup => 'Create New Arisan Group';

  @override
  String get winModalTitle => 'Set Winner Order';

  @override
  String get winModalPeriodType => 'Period Type: ';

  @override
  String get winModalWon => ' (Won)';

  @override
  String get winModalBtnSave => '💾 Save Winner Order';

  @override
  String get winModalBtnCancel => 'Cancel';

  @override
  String get dashTotalPaid => 'PAID';

  @override
  String get dashPotWinner => 'Winner Pot';

  @override
  String get dashPerMonth => 'month';

  @override
  String get dashPerWeek => 'week';

  @override
  String get dashActive => '(Active)';

  @override
  String get dashMonth => 'Month';

  @override
  String get dashWeek => 'Week';

  @override
  String get kasDetailsTitle => 'Kas Balance Details';

  @override
  String get kasTotalIn => 'Total In';

  @override
  String get kasTotalOut => 'Total Out';

  @override
  String get kasRemaining => 'Remaining Kas Balance';

  @override
  String get kasEmpty => 'No kas expense history yet.';

  @override
  String get kasAddExpenseTitle => 'Add Kas Expense';

  @override
  String get kasDescHint => 'Description (Food, etc)';

  @override
  String get kasAmountHint => 'Amount';

  @override
  String get kasBtnSave => 'Save Expense';
}
