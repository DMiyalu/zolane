import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

class ProfileState extends Equatable {
  final String name;
  final String phone;
  final String? profileImagePath;

  const ProfileState({
    required this.name,
    required this.phone,
    this.profileImagePath,
  });

  ProfileState copyWith({
    String? name,
    String? phone,
    String? profileImagePath,
  }) {
    return ProfileState(
      name: name ?? this.name,
      phone: phone ?? this.phone,
      profileImagePath: profileImagePath ?? this.profileImagePath,
    );
  }

  @override
  List<Object?> get props => [name, phone, profileImagePath];
}

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit()
      : super(const ProfileState(
          name: 'Sylvaine NKOUKA',
          phone: '+596 696 45 75 10',
        ));

  void updateName(String name) {
    emit(state.copyWith(name: name));
  }

  void updateProfileImage(String? imagePath) {
    emit(state.copyWith(profileImagePath: imagePath));
  }
}







