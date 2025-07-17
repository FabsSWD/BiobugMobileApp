import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/signature.dart';

abstract class SignatureState extends Equatable {
  const SignatureState();

  @override
  List<Object?> get props => [];
}

class SignatureInitial extends SignatureState {}

class SignatureCapturing extends SignatureState {}

class SignatureDrawing extends SignatureState {
  final int pointsCount;
  final bool isValid;

  const SignatureDrawing({
    required this.pointsCount,
    required this.isValid,
  });

  @override
  List<Object> get props => [pointsCount, isValid];
}

class SignatureCaptured extends SignatureState {
  final Signature signature;
  final bool isValid;

  const SignatureCaptured({
    required this.signature,
    required this.isValid,
  });

  @override
  List<Object> get props => [signature, isValid];
}

class SignatureValidating extends SignatureState {}

class SignatureValidated extends SignatureState {
  final Signature signature;
  final bool isValid;
  final String? validationMessage;

  const SignatureValidated({
    required this.signature,
    required this.isValid,
    this.validationMessage,
  });

  @override
  List<Object?> get props => [signature, isValid, validationMessage];
}

class SignatureSaving extends SignatureState {}

class SignatureSaved extends SignatureState {
  final Signature signature;

  const SignatureSaved(this.signature);

  @override
  List<Object> get props => [signature];
}

class SignatureUploading extends SignatureState {
  final Signature signature;

  const SignatureUploading(this.signature);

  @override
  List<Object> get props => [signature];
}

class SignatureUploaded extends SignatureState {
  final Signature signature;

  const SignatureUploaded(this.signature);

  @override
  List<Object> get props => [signature];
}

class SignatureListLoading extends SignatureState {}

class SignatureListLoaded extends SignatureState {
  final List<Signature> signatures;

  const SignatureListLoaded(this.signatures);

  @override
  List<Object> get props => [signatures];
}

class SignatureDeleting extends SignatureState {
  final String signatureId;

  const SignatureDeleting(this.signatureId);

  @override
  List<Object> get props => [signatureId];
}

class SignatureDeleted extends SignatureState {
  final String signatureId;

  const SignatureDeleted(this.signatureId);

  @override
  List<Object> get props => [signatureId];
}

class SignaturePreviewing extends SignatureState {
  final Signature signature;

  const SignaturePreviewing(this.signature);

  @override
  List<Object> get props => [signature];
}

class SignatureError extends SignatureState {
  final Failure failure;
  final String? context;

  const SignatureError(this.failure, {this.context});

  @override
  List<Object?> get props => [failure, context];
}

class SignatureCleared extends SignatureState {}
