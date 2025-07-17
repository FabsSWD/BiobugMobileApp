import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/error/failures.dart';
import '../../domain/usecases/capture_signature.dart';
import '../../domain/usecases/save_signature.dart';
import '../../domain/usecases/validate_signature.dart';
import '../../domain/usecases/upload_signature.dart';
import '../../domain/usecases/get_saved_signatures.dart';
import '../../domain/usecases/delete_signature.dart';
import 'signature_event.dart';
import 'signature_state.dart';

@Injectable()
class SignatureBloc extends Bloc<SignatureEvent, SignatureState> {
  final CaptureSignature _captureSignature;
  final SaveSignature _saveSignature;
  final ValidateSignature _validateSignature;
  final UploadSignature _uploadSignature;
  final GetSavedSignatures _getSavedSignatures;
  final DeleteSignature _deleteSignature;

  SignatureBloc(
    this._captureSignature,
    this._saveSignature,
    this._validateSignature,
    this._uploadSignature,
    this._getSavedSignatures,
    this._deleteSignature,
  ) : super(SignatureInitial()) {
    on<SignatureCaptureStarted>(_onCaptureStarted);
    on<SignatureCaptureCompleted>(_onCaptureCompleted);
    on<SignatureSaveRequested>(_onSaveRequested);
    on<SignatureUploadRequested>(_onUploadRequested);
    on<SignatureValidationRequested>(_onValidationRequested);
    on<SignatureListRequested>(_onListRequested);
    on<SignatureDeleteRequested>(_onDeleteRequested);
    on<SignatureClearRequested>(_onClearRequested);
    on<SignaturePreviewRequested>(_onPreviewRequested);
  }

  Future<void> _onCaptureStarted(
    SignatureCaptureStarted event,
    Emitter<SignatureState> emit,
  ) async {
    // Ya no necesario - el estado inicial ya está listo
    // Solo emitir si necesitas hacer alguna inicialización específica
    emit(SignatureInitial());
  }

  Future<void> _onCaptureCompleted(
    SignatureCaptureCompleted event,
    Emitter<SignatureState> emit,
  ) async {
    try {
      emit(SignatureCapturing());

      final result = await _captureSignature(event.params);

      result.fold(
        (failure) => emit(SignatureError(failure, context: 'capture')),
        (signature) {
          // Auto-validate the captured signature
          add(SignatureValidationRequested(signature));
        },
      );
    } catch (e) {
      emit(SignatureError(
        ServerFailure('Error inesperado al capturar firma: $e'),
        context: 'capture',
      ));
    }
  }

  Future<void> _onValidationRequested(
    SignatureValidationRequested event,
    Emitter<SignatureState> emit,
  ) async {
    try {
      emit(SignatureValidating());

      final result = await _validateSignature(event.signature);

      result.fold(
        (failure) => emit(SignatureError(failure, context: 'validation')),
        (isValid) {
          String? message;
          if (!isValid) {
            final signature = event.signature;
            final issues = <String>[];
            
            if (signature.width < 300 || signature.height < 150) {
              issues.add('Resolución insuficiente (mínimo 300x150)');
            }
            if (signature.pointsCount < 10) {
              issues.add('Muy pocos puntos de trazo (mínimo 10)');
            }
            if (signature.fileSizeInBytes > 51200) {
              issues.add('Archivo muy grande (máximo 50KB)');
            }
            
            message = issues.join(', ');
          }

          emit(SignatureValidated(
            signature: event.signature,
            isValid: isValid,
            validationMessage: message,
          ));
        },
      );
    } catch (e) {
      emit(SignatureError(
        ValidationFailure('Error al validar firma: $e'),
        context: 'validation',
      ));
    }
  }

  Future<void> _onSaveRequested(
    SignatureSaveRequested event,
    Emitter<SignatureState> emit,
  ) async {
    try {
      emit(SignatureSaving());

      final result = await _saveSignature(event.signature);

      result.fold(
        (failure) => emit(SignatureError(failure, context: 'save')),
        (_) => emit(SignatureSaved(event.signature)),
      );
    } catch (e) {
      emit(SignatureError(
        CacheFailure('Error inesperado al guardar firma: $e'),
        context: 'save',
      ));
    }
  }

  Future<void> _onUploadRequested(
    SignatureUploadRequested event,
    Emitter<SignatureState> emit,
  ) async {
    try {
      emit(SignatureUploading(event.signature));

      final result = await _uploadSignature(event.signature);

      result.fold(
        (failure) => emit(SignatureError(failure, context: 'upload')),
        (_) => emit(SignatureUploaded(event.signature)),
      );
    } catch (e) {
      emit(SignatureError(
        NetworkFailure('Error inesperado al subir firma: $e'),
        context: 'upload',
      ));
    }
  }

  Future<void> _onListRequested(
    SignatureListRequested event,
    Emitter<SignatureState> emit,
  ) async {
    try {
      emit(SignatureListLoading());

      final result = await _getSavedSignatures(NoParams());

      result.fold(
        (failure) => emit(SignatureError(failure, context: 'list')),
        (signatures) => emit(SignatureListLoaded(signatures)),
      );
    } catch (e) {
      emit(SignatureError(
        CacheFailure('Error inesperado al cargar firmas: $e'),
        context: 'list',
      ));
    }
  }

  Future<void> _onDeleteRequested(
    SignatureDeleteRequested event,
    Emitter<SignatureState> emit,
  ) async {
    try {
      emit(SignatureDeleting(event.signatureId));

      final result = await _deleteSignature(
        DeleteSignatureParams(id: event.signatureId),
      );

      result.fold(
        (failure) => emit(SignatureError(failure, context: 'delete')),
        (_) => emit(SignatureDeleted(event.signatureId)),
      );
    } catch (e) {
      emit(SignatureError(
        CacheFailure('Error inesperado al eliminar firma: $e'),
        context: 'delete',
      ));
    }
  }

  Future<void> _onClearRequested(
    SignatureClearRequested event,
    Emitter<SignatureState> emit,
  ) async {
    emit(SignatureCleared());
  }

  Future<void> _onPreviewRequested(
    SignaturePreviewRequested event,
    Emitter<SignatureState> emit,
  ) async {
    emit(SignaturePreviewing(event.signature));
  }
}