const winmdGenerated = [
  'advapi32',
  'api-ms-win-core-winrt-l1-1-0',
  // 'api-ms-win-core-winrt-string-l1-1-0',
  // 'api-ms-win-ro-typeresolution-l1-1-0',
  'bthprops',
  'comctl32',
  'comdlg32',
  'dxva2',
  'gdi32',
  'kernel32',
  'kernelbase',
  'ole32',
  'oleaut32',
  'powrprof',
  'rometadata',
  'shcore',
  'shell32',
  'user32',
  'version',
  'winmm'
];

// api-ms-win-core-winrt-string is broken because of:
// https://github.com/microsoft/win32metadata/issues/292

// api-ms-win-ro-typeresolution-l1-1-0 is missing in the metadata:
// https://github.com/microsoft/win32metadata/issues/240