// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get appTitle => 'Digital Arisan';

  @override
  String get navDashboard => 'Dashboard';

  @override
  String get navRoulette => 'Kocokan';

  @override
  String get navKas => 'Kas';

  @override
  String get navProfile => 'Profil';

  @override
  String get dashboardPaymentStatus => 'Daftar Status Pembayaran';

  @override
  String get paid => 'Lunas';

  @override
  String get unpaid => 'BELUM';

  @override
  String get joinGroupViaCode => 'Gabung Kelompok via Kode';

  @override
  String get groupSwitcherTitle => 'Pilih Kelompok Arisan';

  @override
  String get authLoginModeTitle => 'Masuk ke akun kelompok arisan Anda';

  @override
  String get authRegisterModeTitle =>
      'Buat akun arisan baru dalam beberapa detik';

  @override
  String get authLoginTab => 'Masuk';

  @override
  String get authRegisterTab => 'Daftar Baru';

  @override
  String get authNameReq => 'Nama lengkap wajib diisi';

  @override
  String get authNameLabel => 'Nama Lengkap';

  @override
  String get authPhoneLabel => 'Nomor WhatsApp';

  @override
  String get authEmailReq => 'Email wajib diisi';

  @override
  String get authEmailInvalid => 'Format email tidak valid';

  @override
  String get authEmailLabel => 'Alamat Email';

  @override
  String get authPassReq => 'Kata sandi wajib diisi';

  @override
  String get authPassMin => 'Kata sandi minimal 5 karakter';

  @override
  String get authPassNum => 'Kata sandi harus mengandung angka';

  @override
  String get authPassSym =>
      'Kata sandi harus mengandung karakter khusus (simbol)';

  @override
  String get authPassLabel => 'Kata Sandi';

  @override
  String get authBtnLogin => 'Masuk ke Aplikasi';

  @override
  String get authBtnRegister => 'Daftar Akun Baru';

  @override
  String get authOr => 'atau';

  @override
  String get authGoogleSignIn => 'Masuk dengan Akun Google';

  @override
  String get noGroupJoinTitle => 'Gabung Kelompok Arisan';

  @override
  String get noGroupJoinSubtitle =>
      'Masukkan Kode Kelompok atau Tautan Undangan:';

  @override
  String get noGroupJoinHint => 'Contoh: ARISAN-RT05-2026';

  @override
  String get btnCancel => 'Batal';

  @override
  String get btnJoin => 'Gabung';

  @override
  String noGroupGreeting(String name) {
    return 'Halo, $name!';
  }

  @override
  String get noGroupDesc =>
      'Anda belum memiliki atau bergabung ke kelompok arisan manapun.';

  @override
  String get noGroupCreateBtn => 'Buat Kelompok Arisan Baru';

  @override
  String get noGroupJoinBtn => 'Gabung Kelompok Arisan';

  @override
  String get createGroupTitle => 'Buat Kelompok Arisan Baru';

  @override
  String get createGroupAdminNotice =>
      'Anda otomatis menjadi Admin/Ketua di kelompok yang Anda buat.';

  @override
  String get createGroupNameLabel => 'Nama Kelompok Arisan';

  @override
  String get createGroupNameHint =>
      'Contoh: Arisan Keluarga Badrus / Arisan RT 05';

  @override
  String get createGroupPotLabel => 'Nominal Iuran Utama (Rp)';

  @override
  String get createGroupPeriodLabel => 'Periode Pengundian';

  @override
  String get createGroupPeriodMonthly => 'Bulanan (Bulan 1, Bulan 2...)';

  @override
  String get createGroupPeriodWeekly => 'Mingguan (Minggu 1, Minggu 2...)';

  @override
  String get createGroupKasActive => 'Aktifkan Iuran Kas (Opsional)';

  @override
  String get createGroupKasDesc => 'Uang kas terpisah dari pot pemenang';

  @override
  String get createGroupKasAmountLabel => 'Nominal Kas Per Member (Rp)';

  @override
  String get createGroupBtnSave => 'Simpan & Terbitkan Kelompok';

  @override
  String get createGroupWinnerPending => 'Belum Menang';

  @override
  String get createGroupRoleAdmin => 'Admin';

  @override
  String get joinGroupTitle => 'Gabung Kelompok';

  @override
  String get joinGroupCodeLabel => 'Masukkan 6 Karakter Kode Kelompok';

  @override
  String get joinGroupCodeHint => 'Misal: X7K9PQ';

  @override
  String get btnSearch => 'CARI';

  @override
  String get joinGroupErrEmpty => 'Masukkan 6 karakter kode kelompok';

  @override
  String get joinGroupErrNotFound =>
      'Kelompok dengan kode tersebut tidak ditemukan';

  @override
  String get joinGroupErrAlreadyJoined =>
      'Anda sudah bergabung di kelompok ini';

  @override
  String get joinGroupErrFailed =>
      'Gagal bergabung ke kelompok, silakan coba lagi';

  @override
  String get joinGroupErrFailedNew =>
      'Gagal bergabung ke kelompok sebagai anggota baru';

  @override
  String get joinGroupFoundTitle => 'Kelompok Ditemukan 🎉';

  @override
  String get joinGroupSelectName => 'Pilih Nama Anda:';

  @override
  String get joinGroupDropdownHint => 'Saya adalah...';

  @override
  String get joinGroupBtnYes => 'Ya, Ini Saya (Gabung)';

  @override
  String get joinGroupOr => 'ATAU';

  @override
  String get joinGroupBtnNew => 'Daftar sebagai Anggota Baru';

  @override
  String get dashConfirmDeleteTitle => 'Konfirmasi Hapus';

  @override
  String get dashConfirmDeleteBody =>
      'Apakah Anda yakin ingin menghapus anggota ini dari kelompok ini?';

  @override
  String get dashBtnCancel => 'Batal';

  @override
  String get dashBtnDelete => 'Hapus';

  @override
  String get dashTotalCollected => 'Total Terkumpul';

  @override
  String get dashKasCollected => 'Kas Terkumpul';

  @override
  String get dashBtnInviteWA => 'Invite WA';

  @override
  String get dashArisanCompleted =>
      '🎉 Arisan Selesai! Semua periode telah diundi.';

  @override
  String get dashBtnNewCycle => 'Mulai Siklus Baru';

  @override
  String get dashJoinCodeLabel => 'Kode Gabung Kelompok';

  @override
  String get dashBtnSetWinnerOrder => 'Atur Urutan Pemenang';

  @override
  String get dashWinnerLabel => '🏆 Pemenang';

  @override
  String get dashGalleryTitle => '📸 Galeri & Dokumentasi';

  @override
  String get dashBtnGalleryDetail => 'Detail Galeri';

  @override
  String get dashGalleryEmpty => 'Belum ada foto';

  @override
  String get dashBtnUploadPhoto => 'Upload Foto';

  @override
  String get histAddExpenseTitle => '💸 Catat Pengeluaran Kas';

  @override
  String get histExpenseDesc => 'Keterangan Pengeluaran';

  @override
  String get histExpenseDescHint => 'Misal: Konsumsi Arisan, Snack, dll';

  @override
  String get histRequiredField => 'Wajib diisi';

  @override
  String get histExpenseAmount => 'Jumlah Pengeluaran (Rp)';

  @override
  String get histExpenseAmountHint => 'Nominal dalam Rp (contoh: 50.000)';

  @override
  String get histRequiredAmount => 'Nominal wajib diisi';

  @override
  String get histInvalidAmount => 'Masukkan angka valid';

  @override
  String get histBtnSaveExpense => 'Simpan Pengeluaran Kas';

  @override
  String get histMainTitle => '📜 History Keuangan & Kas';

  @override
  String get histBtnSpend => 'Keluar Kas';

  @override
  String get histSummaryTitle => 'Ringkasan Saldo Kas Kelompok';

  @override
  String get histTotalIn => 'Total Kas Masuk:';

  @override
  String get histTotalOut => 'Total Pengeluaran Kas:';

  @override
  String get histBalance => 'Saldo Akhir Kas Saat Ini:';

  @override
  String get histAuditTitle => 'Audit History Per Periode';

  @override
  String get histAuditSub => 'Full Audit Log';

  @override
  String get histWaitingRoulette => 'Menunggu Roulette';

  @override
  String get histActivePeriod => 'PERIODE AKTIF';

  @override
  String get histNotStarted => 'BELUM MULAI';

  @override
  String get histDone => 'SELESAI';

  @override
  String get histPot => 'Pot Arisan:';

  @override
  String get histKas => 'Kas:';

  @override
  String get histPerMember => '/ member';

  @override
  String get histWinner => 'Pemenang:';

  @override
  String get histTransactionsTitle => 'Daftar Transaksi Pengeluaran Kas';

  @override
  String get galUploadFailed => 'Maaf gagal upload gambar, silahkan coba lagi';

  @override
  String get galUploadedBy => 'Diunggah oleh: ';

  @override
  String get galBtnClose => 'Tutup';

  @override
  String get galTitle => 'Galeri & Dokumentasi';

  @override
  String get galBtnUpload => 'Upload';

  @override
  String get galEmpty => 'Belum ada foto';

  @override
  String get galBtnFirstUpload => 'Upload Foto Pertama';

  @override
  String get roulCongrats => 'Selamat Kepada Pemenang!';

  @override
  String get roulWinner => '🏆 PEMENANG';

  @override
  String get roulBtnCloseSave => 'Tutup & Simpan Hasil';

  @override
  String get roulAll => 'Semua';

  @override
  String get roulAlready => 'Sudah';

  @override
  String get roulWon => 'Menang';

  @override
  String get roulTitle => 'Kocokan Roulette Arisan 🎯';

  @override
  String get roulDesc =>
      'Hanya anggota yang BELUM MENANG yang masuk dalam Roda Roulette.';

  @override
  String get roulSpinning => 'MEMUTAR ROULETTE...';

  @override
  String get roulBtnSpinAdmin => 'PUTAR ROULETTE (AKSES KETUA)';

  @override
  String get roulBtnSpinNotAdmin => 'HANYA KETUA YANG BISA MEMUTAR';

  @override
  String get profEditPhoneTitle => '📱 Edit No. WhatsApp';

  @override
  String get profEditPhoneDesc =>
      'Masukkan nomor WhatsApp aktif Anda agar anggota lain dapat dengan mudah menghubungi Anda untuk konfirmasi iuran.';

  @override
  String get profPhoneLabel => 'Nomor WhatsApp';

  @override
  String get profPhoneHint => 'Contoh: 081234567890';

  @override
  String get profPhoneRequired => 'Nomor WhatsApp wajib diisi';

  @override
  String get profPhoneInvalid => 'Nomor WhatsApp tidak valid';

  @override
  String get profBtnSavePhone => 'Simpan Nomor WhatsApp';

  @override
  String get profTitle => '👤 Profil Pengguna';

  @override
  String get profLogoutTooltip => 'Keluar / Logout';

  @override
  String get profAddPhone => 'Tambahkan No. WhatsApp';

  @override
  String get profBtnLogout => 'Keluar Akun';

  @override
  String get profAppVersion => 'Versi App: ';

  @override
  String get profCreateGroupTitle => 'Ingin Membuat Arisan Baru?';

  @override
  String get profCreateGroupDesc =>
      'Anda dapat membuat kelompok arisan sendiri dan menjadi Ketua/Admin.';

  @override
  String get profBtnCreateGroup => 'Buat Kelompok Arisan Baru';

  @override
  String get winModalTitle => 'Atur Urutan Pemenang';

  @override
  String get winModalPeriodType => 'Jenis Periode: ';

  @override
  String get winModalWon => ' (Menang)';

  @override
  String get winModalBtnSave => '💾 Simpan Urutan Pemenang';

  @override
  String get winModalBtnCancel => 'Batal';

  @override
  String get dashTotalPaid => 'LUNAS';

  @override
  String get dashPotWinner => 'Pot Pemenang';

  @override
  String get dashPerMonth => 'bulan';

  @override
  String get dashPerWeek => 'minggu';

  @override
  String get dashActive => '(Aktif)';

  @override
  String get dashMonth => 'Bulan';

  @override
  String get dashWeek => 'Minggu';

  @override
  String get kasDetailsTitle => 'Rincian Saldo Kas';

  @override
  String get kasTotalIn => 'Total Masuk';

  @override
  String get kasTotalOut => 'Total Keluar';

  @override
  String get kasRemaining => 'Sisa Saldo Kas';

  @override
  String get kasEmpty => 'Belum ada riwayat pengeluaran kas.';

  @override
  String get kasAddExpenseTitle => 'Tambah Pengeluaran Kas';

  @override
  String get kasDescHint => 'Keterangan (Makan, dll)';

  @override
  String get kasAmountHint => 'Nominal';

  @override
  String get kasBtnSave => 'Simpan Pengeluaran';
}
