import 'package:flutter/material.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../shared/themes/app_colors.dart';
import '../../domain/entities/signature.dart';

class SignatureGalleryItem extends StatelessWidget {
  final Signature signature;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onUpload;

  const SignatureGalleryItem({
    super.key,
    required this.signature,
    this.onTap,
    this.onDelete,
    this.onUpload,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Signature Thumbnail
              Container(
                width: 80,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: AppColors.grey300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(7),
                  child: Image.memory(
                    signature.imageBytes,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Signature Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Firma ${signature.id.substring(0, 8)}...',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    
                    const SizedBox(height: 4),
                    
                    Text(
                      '${signature.width}x${signature.height} • ${signature.formattedFileSize}',
                      style: TextStyle(
                        color: AppColors.grey600,
                        fontSize: 12,
                      ),
                    ),
                    
                    const SizedBox(height: 2),
                    
                    Text(
                      DateFormatter.getRelativeTime(signature.createdAt),
                      style: TextStyle(
                        color: AppColors.grey500,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Status and Actions
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Upload Status
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: signature.isUploaded 
                          ? AppColors.success.withOpacity(0.1)
                          : AppColors.warning.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      signature.isUploaded ? 'Subido' : 'Local',
                      style: TextStyle(
                        color: signature.isUploaded ? AppColors.success : AppColors.warning,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Action Buttons
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!signature.isUploaded && onUpload != null)
                        IconButton(
                          onPressed: onUpload,
                          icon: const Icon(Icons.cloud_upload),
                          iconSize: 20,
                          color: AppColors.primary,
                          tooltip: 'Subir al servidor',
                        ),
                      
                      if (onDelete != null)
                        IconButton(
                          onPressed: onDelete,
                          icon: const Icon(Icons.delete_outline),
                          iconSize: 20,
                          color: AppColors.error,
                          tooltip: 'Eliminar',
                        ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}