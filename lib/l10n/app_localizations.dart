import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_id.dart';

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
    Locale('id'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In id, this message translates to:
  /// **'Digital Arisan'**
  String get appTitle;

  /// No description provided for @navDashboard.
  ///
  /// In id, this message translates to:
  /// **'Dashboard'**
  String get navDashboard;

  /// No description provided for @navRoulette.
  ///
  /// In id, this message translates to:
  /// **'Kocokan'**
  String get navRoulette;

  /// No description provided for @navKas.
  ///
  /// In id, this message translates to:
  /// **'Kas'**
  String get navKas;

  /// No description provided for @navProfile.
  ///
  /// In id, this message translates to:
  /// **'Profil'**
  String get navProfile;

  /// No description provided for @dashboardPaymentStatus.
  ///
  /// In id, this message translates to:
  /// **'Daftar Status Pembayaran'**
  String get dashboardPaymentStatus;

  /// No description provided for @paid.
  ///
  /// In id, this message translates to:
  /// **'Lunas'**
  String get paid;

  /// No description provided for @unpaid.
  ///
  /// In id, this message translates to:
  /// **'BELUM'**
  String get unpaid;

  /// No description provided for @joinGroupViaCode.
  ///
  /// In id, this message translates to:
  /// **'Gabung Kelompok via Kode'**
  String get joinGroupViaCode;

  /// No description provided for @groupSwitcherTitle.
  ///
  /// In id, this message translates to:
  /// **'Pilih Kelompok Arisan'**
  String get groupSwitcherTitle;

  /// No description provided for @authLoginModeTitle.
  ///
  /// In id, this message translates to:
  /// **'Masuk ke akun kelompok arisan Anda'**
  String get authLoginModeTitle;

  /// No description provided for @authRegisterModeTitle.
  ///
  /// In id, this message translates to:
  /// **'Buat akun arisan baru dalam beberapa detik'**
  String get authRegisterModeTitle;

  /// No description provided for @authLoginTab.
  ///
  /// In id, this message translates to:
  /// **'Masuk'**
  String get authLoginTab;

  /// No description provided for @authRegisterTab.
  ///
  /// In id, this message translates to:
  /// **'Daftar Baru'**
  String get authRegisterTab;

  /// No description provided for @authNameReq.
  ///
  /// In id, this message translates to:
  /// **'Nama lengkap wajib diisi'**
  String get authNameReq;

  /// No description provided for @authNameLabel.
  ///
  /// In id, this message translates to:
  /// **'Nama Lengkap'**
  String get authNameLabel;

  /// No description provided for @authPhoneLabel.
  ///
  /// In id, this message translates to:
  /// **'Nomor WhatsApp'**
  String get authPhoneLabel;

  /// No description provided for @authEmailReq.
  ///
  /// In id, this message translates to:
  /// **'Email wajib diisi'**
  String get authEmailReq;

  /// No description provided for @authEmailInvalid.
  ///
  /// In id, this message translates to:
  /// **'Format email tidak valid'**
  String get authEmailInvalid;

  /// No description provided for @authEmailLabel.
  ///
  /// In id, this message translates to:
  /// **'Alamat Email'**
  String get authEmailLabel;

  /// No description provided for @authPassReq.
  ///
  /// In id, this message translates to:
  /// **'Kata sandi wajib diisi'**
  String get authPassReq;

  /// No description provided for @authPassMin.
  ///
  /// In id, this message translates to:
  /// **'Kata sandi minimal 5 karakter'**
  String get authPassMin;

  /// No description provided for @authPassNum.
  ///
  /// In id, this message translates to:
  /// **'Kata sandi harus mengandung angka'**
  String get authPassNum;

  /// No description provided for @authPassSym.
  ///
  /// In id, this message translates to:
  /// **'Kata sandi harus mengandung karakter khusus (simbol)'**
  String get authPassSym;

  /// No description provided for @authPassLabel.
  ///
  /// In id, this message translates to:
  /// **'Kata Sandi'**
  String get authPassLabel;

  /// No description provided for @authBtnLogin.
  ///
  /// In id, this message translates to:
  /// **'Masuk ke Aplikasi'**
  String get authBtnLogin;

  /// No description provided for @authBtnRegister.
  ///
  /// In id, this message translates to:
  /// **'Daftar Akun Baru'**
  String get authBtnRegister;

  /// No description provided for @authOr.
  ///
  /// In id, this message translates to:
  /// **'atau'**
  String get authOr;

  /// No description provided for @authGoogleSignIn.
  ///
  /// In id, this message translates to:
  /// **'Masuk dengan Akun Google'**
  String get authGoogleSignIn;

  /// No description provided for @noGroupJoinTitle.
  ///
  /// In id, this message translates to:
  /// **'Gabung Kelompok Arisan'**
  String get noGroupJoinTitle;

  /// No description provided for @noGroupJoinSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Masukkan Kode Kelompok atau Tautan Undangan:'**
  String get noGroupJoinSubtitle;

  /// No description provided for @noGroupJoinHint.
  ///
  /// In id, this message translates to:
  /// **'Contoh: ARISAN-RT05-2026'**
  String get noGroupJoinHint;

  /// No description provided for @btnCancel.
  ///
  /// In id, this message translates to:
  /// **'Batal'**
  String get btnCancel;

  /// No description provided for @btnJoin.
  ///
  /// In id, this message translates to:
  /// **'Gabung'**
  String get btnJoin;

  /// No description provided for @noGroupGreeting.
  ///
  /// In id, this message translates to:
  /// **'Halo, {name}!'**
  String noGroupGreeting(String name);

  /// No description provided for @noGroupDesc.
  ///
  /// In id, this message translates to:
  /// **'Anda belum memiliki atau bergabung ke kelompok arisan manapun.'**
  String get noGroupDesc;

  /// No description provided for @noGroupCreateBtn.
  ///
  /// In id, this message translates to:
  /// **'Buat Kelompok Arisan Baru'**
  String get noGroupCreateBtn;

  /// No description provided for @noGroupJoinBtn.
  ///
  /// In id, this message translates to:
  /// **'Gabung Kelompok Arisan'**
  String get noGroupJoinBtn;

  /// No description provided for @createGroupTitle.
  ///
  /// In id, this message translates to:
  /// **'Buat Kelompok Arisan Baru'**
  String get createGroupTitle;

  /// No description provided for @createGroupAdminNotice.
  ///
  /// In id, this message translates to:
  /// **'Anda otomatis menjadi Admin/Ketua di kelompok yang Anda buat.'**
  String get createGroupAdminNotice;

  /// No description provided for @createGroupNameLabel.
  ///
  /// In id, this message translates to:
  /// **'Nama Kelompok Arisan'**
  String get createGroupNameLabel;

  /// No description provided for @createGroupNameHint.
  ///
  /// In id, this message translates to:
  /// **'Contoh: Arisan Keluarga Badrus / Arisan RT 05'**
  String get createGroupNameHint;

  /// No description provided for @createGroupPotLabel.
  ///
  /// In id, this message translates to:
  /// **'Nominal Iuran Utama (Rp)'**
  String get createGroupPotLabel;

  /// No description provided for @createGroupPeriodLabel.
  ///
  /// In id, this message translates to:
  /// **'Periode Pengundian'**
  String get createGroupPeriodLabel;

  /// No description provided for @createGroupPeriodMonthly.
  ///
  /// In id, this message translates to:
  /// **'Bulanan (Bulan 1, Bulan 2...)'**
  String get createGroupPeriodMonthly;

  /// No description provided for @createGroupPeriodWeekly.
  ///
  /// In id, this message translates to:
  /// **'Mingguan (Minggu 1, Minggu 2...)'**
  String get createGroupPeriodWeekly;

  /// No description provided for @createGroupKasActive.
  ///
  /// In id, this message translates to:
  /// **'Aktifkan Iuran Kas (Opsional)'**
  String get createGroupKasActive;

  /// No description provided for @createGroupKasDesc.
  ///
  /// In id, this message translates to:
  /// **'Uang kas terpisah dari pot pemenang'**
  String get createGroupKasDesc;

  /// No description provided for @createGroupKasAmountLabel.
  ///
  /// In id, this message translates to:
  /// **'Nominal Kas Per Member (Rp)'**
  String get createGroupKasAmountLabel;

  /// No description provided for @createGroupBtnSave.
  ///
  /// In id, this message translates to:
  /// **'Simpan & Terbitkan Kelompok'**
  String get createGroupBtnSave;

  /// No description provided for @createGroupWinnerPending.
  ///
  /// In id, this message translates to:
  /// **'Belum Menang'**
  String get createGroupWinnerPending;

  /// No description provided for @createGroupRoleAdmin.
  ///
  /// In id, this message translates to:
  /// **'Admin'**
  String get createGroupRoleAdmin;

  /// No description provided for @joinGroupTitle.
  ///
  /// In id, this message translates to:
  /// **'Gabung Kelompok'**
  String get joinGroupTitle;

  /// No description provided for @joinGroupCodeLabel.
  ///
  /// In id, this message translates to:
  /// **'Masukkan 6 Karakter Kode Kelompok'**
  String get joinGroupCodeLabel;

  /// No description provided for @joinGroupCodeHint.
  ///
  /// In id, this message translates to:
  /// **'Misal: X7K9PQ'**
  String get joinGroupCodeHint;

  /// No description provided for @btnSearch.
  ///
  /// In id, this message translates to:
  /// **'CARI'**
  String get btnSearch;

  /// No description provided for @joinGroupErrEmpty.
  ///
  /// In id, this message translates to:
  /// **'Masukkan 6 karakter kode kelompok'**
  String get joinGroupErrEmpty;

  /// No description provided for @joinGroupErrNotFound.
  ///
  /// In id, this message translates to:
  /// **'Kelompok dengan kode tersebut tidak ditemukan'**
  String get joinGroupErrNotFound;

  /// No description provided for @joinGroupErrAlreadyJoined.
  ///
  /// In id, this message translates to:
  /// **'Anda sudah bergabung di kelompok ini'**
  String get joinGroupErrAlreadyJoined;

  /// No description provided for @joinGroupErrFailed.
  ///
  /// In id, this message translates to:
  /// **'Gagal bergabung ke kelompok, silakan coba lagi'**
  String get joinGroupErrFailed;

  /// No description provided for @joinGroupErrFailedNew.
  ///
  /// In id, this message translates to:
  /// **'Gagal bergabung ke kelompok sebagai anggota baru'**
  String get joinGroupErrFailedNew;

  /// No description provided for @joinGroupFoundTitle.
  ///
  /// In id, this message translates to:
  /// **'Kelompok Ditemukan 🎉'**
  String get joinGroupFoundTitle;

  /// No description provided for @joinGroupSelectName.
  ///
  /// In id, this message translates to:
  /// **'Pilih Nama Anda:'**
  String get joinGroupSelectName;

  /// No description provided for @joinGroupDropdownHint.
  ///
  /// In id, this message translates to:
  /// **'Saya adalah...'**
  String get joinGroupDropdownHint;

  /// No description provided for @joinGroupBtnYes.
  ///
  /// In id, this message translates to:
  /// **'Ya, Ini Saya (Gabung)'**
  String get joinGroupBtnYes;

  /// No description provided for @joinGroupOr.
  ///
  /// In id, this message translates to:
  /// **'ATAU'**
  String get joinGroupOr;

  /// No description provided for @joinGroupBtnNew.
  ///
  /// In id, this message translates to:
  /// **'Daftar sebagai Anggota Baru'**
  String get joinGroupBtnNew;

  /// No description provided for @dashConfirmDeleteTitle.
  ///
  /// In id, this message translates to:
  /// **'Konfirmasi Hapus'**
  String get dashConfirmDeleteTitle;

  /// No description provided for @dashConfirmDeleteBody.
  ///
  /// In id, this message translates to:
  /// **'Apakah Anda yakin ingin menghapus anggota ini dari kelompok ini?'**
  String get dashConfirmDeleteBody;

  /// No description provided for @dashBtnCancel.
  ///
  /// In id, this message translates to:
  /// **'Batal'**
  String get dashBtnCancel;

  /// No description provided for @dashBtnDelete.
  ///
  /// In id, this message translates to:
  /// **'Hapus'**
  String get dashBtnDelete;

  /// No description provided for @dashTotalCollected.
  ///
  /// In id, this message translates to:
  /// **'Total Terkumpul'**
  String get dashTotalCollected;

  /// No description provided for @dashKasCollected.
  ///
  /// In id, this message translates to:
  /// **'Kas Terkumpul'**
  String get dashKasCollected;

  /// No description provided for @dashBtnInviteWA.
  ///
  /// In id, this message translates to:
  /// **'Invite WA'**
  String get dashBtnInviteWA;

  /// No description provided for @dashArisanCompleted.
  ///
  /// In id, this message translates to:
  /// **'🎉 Arisan Selesai! Semua periode telah diundi.'**
  String get dashArisanCompleted;

  /// No description provided for @dashBtnNewCycle.
  ///
  /// In id, this message translates to:
  /// **'Mulai Siklus Baru'**
  String get dashBtnNewCycle;

  /// No description provided for @dashJoinCodeLabel.
  ///
  /// In id, this message translates to:
  /// **'Kode Gabung Kelompok'**
  String get dashJoinCodeLabel;

  /// No description provided for @dashBtnSetWinnerOrder.
  ///
  /// In id, this message translates to:
  /// **'Atur Urutan Pemenang'**
  String get dashBtnSetWinnerOrder;

  /// No description provided for @dashWinnerLabel.
  ///
  /// In id, this message translates to:
  /// **'🏆 Pemenang'**
  String get dashWinnerLabel;

  /// No description provided for @dashGalleryTitle.
  ///
  /// In id, this message translates to:
  /// **'📸 Galeri & Dokumentasi'**
  String get dashGalleryTitle;

  /// No description provided for @dashBtnGalleryDetail.
  ///
  /// In id, this message translates to:
  /// **'Detail Galeri'**
  String get dashBtnGalleryDetail;

  /// No description provided for @dashBtnUploadPhoto.
  ///
  /// In id, this message translates to:
  /// **'Upload Foto'**
  String get dashBtnUploadPhoto;

  /// No description provided for @histAddExpenseTitle.
  ///
  /// In id, this message translates to:
  /// **'💸 Catat Pengeluaran Kas'**
  String get histAddExpenseTitle;

  /// No description provided for @histExpenseDesc.
  ///
  /// In id, this message translates to:
  /// **'Keterangan Pengeluaran'**
  String get histExpenseDesc;

  /// No description provided for @histExpenseDescHint.
  ///
  /// In id, this message translates to:
  /// **'Misal: Konsumsi Arisan, Snack, dll'**
  String get histExpenseDescHint;

  /// No description provided for @histRequiredField.
  ///
  /// In id, this message translates to:
  /// **'Wajib diisi'**
  String get histRequiredField;

  /// No description provided for @histExpenseAmount.
  ///
  /// In id, this message translates to:
  /// **'Jumlah Pengeluaran (Rp)'**
  String get histExpenseAmount;

  /// No description provided for @histExpenseAmountHint.
  ///
  /// In id, this message translates to:
  /// **'Nominal dalam Rp (contoh: 50.000)'**
  String get histExpenseAmountHint;

  /// No description provided for @histRequiredAmount.
  ///
  /// In id, this message translates to:
  /// **'Nominal wajib diisi'**
  String get histRequiredAmount;

  /// No description provided for @histInvalidAmount.
  ///
  /// In id, this message translates to:
  /// **'Masukkan angka valid'**
  String get histInvalidAmount;

  /// No description provided for @histBtnSaveExpense.
  ///
  /// In id, this message translates to:
  /// **'Simpan Pengeluaran Kas'**
  String get histBtnSaveExpense;

  /// No description provided for @histMainTitle.
  ///
  /// In id, this message translates to:
  /// **'📜 History Keuangan & Kas'**
  String get histMainTitle;

  /// No description provided for @histBtnSpend.
  ///
  /// In id, this message translates to:
  /// **'Keluar Kas'**
  String get histBtnSpend;

  /// No description provided for @histSummaryTitle.
  ///
  /// In id, this message translates to:
  /// **'Ringkasan Saldo Kas Kelompok'**
  String get histSummaryTitle;

  /// No description provided for @histTotalIn.
  ///
  /// In id, this message translates to:
  /// **'Total Kas Masuk:'**
  String get histTotalIn;

  /// No description provided for @histTotalOut.
  ///
  /// In id, this message translates to:
  /// **'Total Pengeluaran Kas:'**
  String get histTotalOut;

  /// No description provided for @histBalance.
  ///
  /// In id, this message translates to:
  /// **'Saldo Akhir Kas Saat Ini:'**
  String get histBalance;

  /// No description provided for @histAuditTitle.
  ///
  /// In id, this message translates to:
  /// **'Audit History Per Periode'**
  String get histAuditTitle;

  /// No description provided for @histAuditSub.
  ///
  /// In id, this message translates to:
  /// **'Full Audit Log'**
  String get histAuditSub;

  /// No description provided for @histWaitingRoulette.
  ///
  /// In id, this message translates to:
  /// **'Menunggu Roulette'**
  String get histWaitingRoulette;

  /// No description provided for @histActivePeriod.
  ///
  /// In id, this message translates to:
  /// **'PERIODE AKTIF'**
  String get histActivePeriod;

  /// No description provided for @histNotStarted.
  ///
  /// In id, this message translates to:
  /// **'BELUM MULAI'**
  String get histNotStarted;

  /// No description provided for @histDone.
  ///
  /// In id, this message translates to:
  /// **'SELESAI'**
  String get histDone;

  /// No description provided for @histPot.
  ///
  /// In id, this message translates to:
  /// **'Pot Arisan:'**
  String get histPot;

  /// No description provided for @histKas.
  ///
  /// In id, this message translates to:
  /// **'Kas:'**
  String get histKas;

  /// No description provided for @histPerMember.
  ///
  /// In id, this message translates to:
  /// **'/ member'**
  String get histPerMember;

  /// No description provided for @histWinner.
  ///
  /// In id, this message translates to:
  /// **'Pemenang:'**
  String get histWinner;

  /// No description provided for @histTransactionsTitle.
  ///
  /// In id, this message translates to:
  /// **'Daftar Transaksi Pengeluaran Kas'**
  String get histTransactionsTitle;

  /// No description provided for @galUploadFailed.
  ///
  /// In id, this message translates to:
  /// **'Maaf gagal upload gambar, silahkan coba lagi'**
  String get galUploadFailed;

  /// No description provided for @galUploadedBy.
  ///
  /// In id, this message translates to:
  /// **'Diunggah oleh: '**
  String get galUploadedBy;

  /// No description provided for @galBtnClose.
  ///
  /// In id, this message translates to:
  /// **'Tutup'**
  String get galBtnClose;

  /// No description provided for @galTitle.
  ///
  /// In id, this message translates to:
  /// **'Galeri & Dokumentasi'**
  String get galTitle;

  /// No description provided for @galBtnUpload.
  ///
  /// In id, this message translates to:
  /// **'Upload'**
  String get galBtnUpload;

  /// No description provided for @galEmpty.
  ///
  /// In id, this message translates to:
  /// **'Belum ada foto'**
  String get galEmpty;

  /// No description provided for @galBtnFirstUpload.
  ///
  /// In id, this message translates to:
  /// **'Upload Foto Pertama'**
  String get galBtnFirstUpload;

  /// No description provided for @roulCongrats.
  ///
  /// In id, this message translates to:
  /// **'Selamat Kepada Pemenang!'**
  String get roulCongrats;

  /// No description provided for @roulWinner.
  ///
  /// In id, this message translates to:
  /// **'🏆 PEMENANG'**
  String get roulWinner;

  /// No description provided for @roulBtnCloseSave.
  ///
  /// In id, this message translates to:
  /// **'Tutup & Simpan Hasil'**
  String get roulBtnCloseSave;

  /// No description provided for @roulAll.
  ///
  /// In id, this message translates to:
  /// **'Semua'**
  String get roulAll;

  /// No description provided for @roulAlready.
  ///
  /// In id, this message translates to:
  /// **'Sudah'**
  String get roulAlready;

  /// No description provided for @roulWon.
  ///
  /// In id, this message translates to:
  /// **'Menang'**
  String get roulWon;

  /// No description provided for @roulTitle.
  ///
  /// In id, this message translates to:
  /// **'Kocokan Roulette Arisan 🎯'**
  String get roulTitle;

  /// No description provided for @roulDesc.
  ///
  /// In id, this message translates to:
  /// **'Hanya anggota yang BELUM MENANG yang masuk dalam Roda Roulette.'**
  String get roulDesc;

  /// No description provided for @roulSpinning.
  ///
  /// In id, this message translates to:
  /// **'MEMUTAR ROULETTE...'**
  String get roulSpinning;

  /// No description provided for @roulBtnSpinAdmin.
  ///
  /// In id, this message translates to:
  /// **'PUTAR ROULETTE (AKSES KETUA)'**
  String get roulBtnSpinAdmin;

  /// No description provided for @roulBtnSpinNotAdmin.
  ///
  /// In id, this message translates to:
  /// **'HANYA KETUA YANG BISA MEMUTAR'**
  String get roulBtnSpinNotAdmin;

  /// No description provided for @profEditPhoneTitle.
  ///
  /// In id, this message translates to:
  /// **'📱 Edit No. WhatsApp'**
  String get profEditPhoneTitle;

  /// No description provided for @profEditPhoneDesc.
  ///
  /// In id, this message translates to:
  /// **'Masukkan nomor WhatsApp aktif Anda agar anggota lain dapat dengan mudah menghubungi Anda untuk konfirmasi iuran.'**
  String get profEditPhoneDesc;

  /// No description provided for @profPhoneLabel.
  ///
  /// In id, this message translates to:
  /// **'Nomor WhatsApp'**
  String get profPhoneLabel;

  /// No description provided for @profPhoneHint.
  ///
  /// In id, this message translates to:
  /// **'Contoh: 081234567890'**
  String get profPhoneHint;

  /// No description provided for @profPhoneRequired.
  ///
  /// In id, this message translates to:
  /// **'Nomor WhatsApp wajib diisi'**
  String get profPhoneRequired;

  /// No description provided for @profPhoneInvalid.
  ///
  /// In id, this message translates to:
  /// **'Nomor WhatsApp tidak valid'**
  String get profPhoneInvalid;

  /// No description provided for @profBtnSavePhone.
  ///
  /// In id, this message translates to:
  /// **'Simpan Nomor WhatsApp'**
  String get profBtnSavePhone;

  /// No description provided for @profTitle.
  ///
  /// In id, this message translates to:
  /// **'👤 Profil Pengguna'**
  String get profTitle;

  /// No description provided for @profLogoutTooltip.
  ///
  /// In id, this message translates to:
  /// **'Keluar / Logout'**
  String get profLogoutTooltip;

  /// No description provided for @profAddPhone.
  ///
  /// In id, this message translates to:
  /// **'Tambahkan No. WhatsApp'**
  String get profAddPhone;

  /// No description provided for @profBtnLogout.
  ///
  /// In id, this message translates to:
  /// **'Keluar Akun'**
  String get profBtnLogout;

  /// No description provided for @profAppVersion.
  ///
  /// In id, this message translates to:
  /// **'Versi App: '**
  String get profAppVersion;

  /// No description provided for @profCreateGroupTitle.
  ///
  /// In id, this message translates to:
  /// **'Ingin Membuat Arisan Baru?'**
  String get profCreateGroupTitle;

  /// No description provided for @profCreateGroupDesc.
  ///
  /// In id, this message translates to:
  /// **'Anda dapat membuat kelompok arisan sendiri dan menjadi Ketua/Admin.'**
  String get profCreateGroupDesc;

  /// No description provided for @profBtnCreateGroup.
  ///
  /// In id, this message translates to:
  /// **'Buat Kelompok Arisan Baru'**
  String get profBtnCreateGroup;

  /// No description provided for @winModalTitle.
  ///
  /// In id, this message translates to:
  /// **'Atur Urutan Pemenang'**
  String get winModalTitle;

  /// No description provided for @winModalPeriodType.
  ///
  /// In id, this message translates to:
  /// **'Jenis Periode: '**
  String get winModalPeriodType;

  /// No description provided for @winModalWon.
  ///
  /// In id, this message translates to:
  /// **' (Menang)'**
  String get winModalWon;

  /// No description provided for @winModalBtnSave.
  ///
  /// In id, this message translates to:
  /// **'💾 Simpan Urutan Pemenang'**
  String get winModalBtnSave;

  /// No description provided for @winModalBtnCancel.
  ///
  /// In id, this message translates to:
  /// **'Batal'**
  String get winModalBtnCancel;

  /// No description provided for @dashTotalPaid.
  ///
  /// In id, this message translates to:
  /// **'LUNAS'**
  String get dashTotalPaid;

  /// No description provided for @dashPotWinner.
  ///
  /// In id, this message translates to:
  /// **'Pot Pemenang'**
  String get dashPotWinner;

  /// No description provided for @dashPerMonth.
  ///
  /// In id, this message translates to:
  /// **'bulan'**
  String get dashPerMonth;

  /// No description provided for @dashPerWeek.
  ///
  /// In id, this message translates to:
  /// **'minggu'**
  String get dashPerWeek;

  /// No description provided for @dashActive.
  ///
  /// In id, this message translates to:
  /// **'(Aktif)'**
  String get dashActive;

  /// No description provided for @dashMonth.
  ///
  /// In id, this message translates to:
  /// **'Bulan'**
  String get dashMonth;

  /// No description provided for @dashWeek.
  ///
  /// In id, this message translates to:
  /// **'Minggu'**
  String get dashWeek;

  /// No description provided for @kasDetailsTitle.
  ///
  /// In id, this message translates to:
  /// **'Rincian Saldo Kas'**
  String get kasDetailsTitle;

  /// No description provided for @kasTotalIn.
  ///
  /// In id, this message translates to:
  /// **'Total Masuk'**
  String get kasTotalIn;

  /// No description provided for @kasTotalOut.
  ///
  /// In id, this message translates to:
  /// **'Total Keluar'**
  String get kasTotalOut;

  /// No description provided for @kasRemaining.
  ///
  /// In id, this message translates to:
  /// **'Sisa Saldo Kas'**
  String get kasRemaining;

  /// No description provided for @kasEmpty.
  ///
  /// In id, this message translates to:
  /// **'Belum ada riwayat pengeluaran kas.'**
  String get kasEmpty;

  /// No description provided for @kasAddExpenseTitle.
  ///
  /// In id, this message translates to:
  /// **'Tambah Pengeluaran Kas'**
  String get kasAddExpenseTitle;

  /// No description provided for @kasDescHint.
  ///
  /// In id, this message translates to:
  /// **'Keterangan (Makan, dll)'**
  String get kasDescHint;

  /// No description provided for @kasAmountHint.
  ///
  /// In id, this message translates to:
  /// **'Nominal'**
  String get kasAmountHint;

  /// No description provided for @kasBtnSave.
  ///
  /// In id, this message translates to:
  /// **'Simpan Pengeluaran'**
  String get kasBtnSave;
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
      <String>['en', 'id'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'id':
      return AppLocalizationsId();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
