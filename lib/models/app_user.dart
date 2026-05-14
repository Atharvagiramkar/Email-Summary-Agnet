class AppUser {
  const AppUser({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.photoUrl,
  });

  // Immutable view of the signed-in user.
  final String uid;
  final String email;
  final String displayName;
  final String photoUrl;
}
