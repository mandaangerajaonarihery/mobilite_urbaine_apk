class FileService {
  static String getPreviewUrl(String filename) {
    final encoded = Uri.encodeComponent(filename);
    return 'https://gateway.agvm.mg/serviceupload/file/preview/$encoded';
  }
}
