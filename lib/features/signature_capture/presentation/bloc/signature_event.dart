import 'package:equatable/equatable.dart';
import '../../domain/entities/signature.dart';
import '../../domain/entities/signature_params.dart';

abstract class SignatureEvent extends Equatable {
  const SignatureEvent();

  @override
  List<Object?> get props => [];
}

class SignatureCaptureStarted extends SignatureEvent {}

class SignatureCaptureCompleted extends SignatureEvent {
  final SignatureParams params;

  const SignatureCaptureCompleted(this.params);

  @override
  List<Object> get props => [params];
}

class SignatureSaveRequested extends SignatureEvent {
  final Signature signature;

  const SignatureSaveRequested(this.signature);

  @override
  List<Object> get props => [signature];
}

class SignatureUploadRequested extends SignatureEvent {
  final Signature signature;

  const SignatureUploadRequested(this.signature);

  @override
  List<Object> get props => [signature];
}

class SignatureValidationRequested extends SignatureEvent {
  final Signature signature;

  const SignatureValidationRequested(this.signature);

  @override
  List<Object> get props => [signature];
}

class SignatureListRequested extends SignatureEvent {}

class SignatureDeleteRequested extends SignatureEvent {
  final String signatureId;

  const SignatureDeleteRequested(this.signatureId);

  @override
  List<Object> get props => [signatureId];
}

class SignatureClearRequested extends SignatureEvent {}

class SignaturePreviewRequested extends SignatureEvent {
  final Signature signature;

  const SignaturePreviewRequested(this.signature);

  @override
  List<Object> get props => [signature];
}