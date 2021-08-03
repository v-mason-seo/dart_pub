// Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: directives_ordering

/// Support for programming against the Win32 API on Windows operating systems.
///
/// This library provides a wrapper around many useful functions from the API,
/// along with the necessary constants and structs that are supplied. With
/// thousands of APIs and interfaces in the Win32 API, many of which cover areas
/// that would be unlikely to be useful to a Dart or Flutter developer, this
/// library is not intended to be exhaustive. Instead, we focus on the core
/// Win32 APIs that are typically used for Windows development, along with
/// Win32, COM and Windows Runtime APIs that are likely to be wrapped by a
/// Flutter plugin author.
///
/// Win32 is at its heart a C-based API, and accordingly adopts the style and
/// idioms of that language, including heavy usage of pointers, structs
/// allocated on the heap, and null-terminated strings. As a result, you may
/// choose to wrap the exposed APIs in your application to make their invocation
/// more idiomatic for a Dart consumer.
///
/// ## Strings (Win32 and COM)
///
/// Win32 strings are typically stored as null-terminated arrays of UTF-16 code
/// units. (Some older Windows APIs also offer an ANSI, or 8-bit representation,
/// but we use the wide versions, which are suffixed with a capital 'W' (e.g.
/// `FormatMessageW`).
///
/// You can use the [toNativeUtf16] function to convert a Dart string into a
/// `Pointer<Utf16>`, which can be passed to any Windows API expecting a string,
/// for example:
/// ```dart
///   final verb = 'open'.toNativeUtf16();
///   final process = 'notepad.exe'.toNativeUtf16();
///   ShellExecute(0, verb, process, nullptr, nullptr, SW_SHOW);
/// ```
///
/// Note that it is your responsibility to release the memory used when you are
/// finished with it.
///
/// To receive a string, allocate memory with a command like the following:
/// ```dart
///   final buffer = calloc<Uint16>(count: length).cast<Utf16>();
///   GetWindowText(hWnd, buffer, length);
/// ```
///
/// This allocates an array of `length` UTF-16 code units. The cast is necessary
/// because Utf16 has no length of itself. The returned value can be converted
/// back to a Dart string using an extension method on Pointer<Utf16>, as
/// follows:
/// ```dart
///   print(buffer.toDartString());
/// ```
///
/// A small number of APIs offer no wide version (e.g. `GetProcAddress`), and so
/// the [convertToANSIString] method may be of use to convert a Dart string to a
/// `Pointer<Uint8>`, which represents this format:
/// ```dart
///   final ansi = convertToANSIString('Beep');
///   final pGetNativeSystemInfo = GetProcAddress(hModule, ansi);
///   ...
///   free(ansi);
/// ```
///
/// ## Strings (Windows Runtime)
///
/// Windows Runtime APIs use `HSTRING` as their native type, which is created
/// with the [WindowsCreateString] API and deleted with the
/// [WindowsDeleteString] API. A Dart function may be used to convert to and
/// from `HSTRING`s, for example:
/// ```dart
///   final systemPtr = calloc<IntPtr>();
///   calendar.GetCalendarSystem(systemPtr);
///   print('The calendar system is ${convertFromHString(systemPtr)}.');
///   WindowsDeleteString(systemPtr.value);
///   free(systemPtr);
/// ```
///
/// Make sure you dispose of `HSTRING`s by calling `WindowsDeleteString` and
/// passing the string address itself, not the pointer, as shown above.
library win32;

// Core Win32 APIs, constants and macros
export 'src/callbacks.dart';
export 'src/constants.dart';
export 'src/constants_nodoc.dart';
export 'src/exceptions.dart';
export 'src/macros.dart';
export 'src/structs.dart';
export 'src/utils.dart';

// Useful extension methods
export 'src/extensions/dialogs.dart';
export 'src/extensions/int_to_hexstring.dart';
export 'src/extensions/list_to_blob.dart';
export 'src/extensions/set_ansi.dart';
export 'src/extensions/set_string.dart';
export 'src/extensions/unpack_utf16.dart';

// Traditional C-style Windows APIs
export 'src/_manual.dart';
export 'src/advapi32.dart';
export 'src/bthprops.dart';
export 'src/comctl32.dart';
export 'src/comdlg32.dart';
export 'src/dxva2.dart';
export 'src/gdi32.dart';
export 'src/kernel32.dart';
export 'src/kernelbase.dart';
export 'src/ole32.dart';
export 'src/oleaut32.dart';
export 'src/powrprof.dart';
export 'src/rometadata.dart';
export 'src/shcore.dart';
export 'src/shell32.dart';
export 'src/user32.dart';
export 'src/version.dart';
export 'src/winmm.dart';

export 'src/api-ms-win-core-winrt-l1-1-0.dart';
export 'src/api-ms-win-core-winrt-string-l1-1-0.dart';
export 'src/api-ms-win-ro-typeresolution-l1-1-0.dart';

// COM foundational exports
export 'src/com/combase.dart';

// WinRT foundational exports
export 'src/winrt/winrt_constants.dart';
export 'src/winrt/winrt_helpers.dart';

// COM and Windows Runtime interfaces
export 'src/generated/IApplicationActivationManager.dart';
export 'src/generated/IAsyncInfo.dart';
export 'src/generated/IBindCtx.dart';
export 'src/generated/ICalendar.dart';
export 'src/generated/IClassFactory.dart';
export 'src/generated/IConnectionPoint.dart';
export 'src/generated/IConnectionPointContainer.dart';
export 'src/generated/IDesktopWallpaper.dart';
export 'src/generated/IDispatch.dart';
export 'src/generated/IEnumIDList.dart';
export 'src/generated/IEnumMoniker.dart';
export 'src/generated/IEnumNetworkConnections.dart';
export 'src/generated/IEnumNetworks.dart';
export 'src/generated/IEnumSpellingError.dart';
export 'src/generated/IEnumString.dart';
export 'src/generated/IEnumVARIANT.dart';
export 'src/generated/IEnumWbemClassObject.dart';
export 'src/generated/IErrorInfo.dart';
export 'src/generated/IFileDialog.dart';
export 'src/generated/IFileDialog2.dart';
export 'src/generated/IFileDialogCustomize.dart';
export 'src/generated/IFileIsInUse.dart';
export 'src/generated/IFileOpenDialog.dart';
export 'src/generated/IFileOpenPicker.dart';
export 'src/generated/IFileSaveDialog.dart';
export 'src/generated/IInspectable.dart';
export 'src/generated/IKnownFolder.dart';
export 'src/generated/IKnownFolderManager.dart';
export 'src/generated/IModalWindow.dart';
export 'src/generated/IMoniker.dart';
export 'src/generated/INetwork.dart';
export 'src/generated/INetworkConnection.dart';
export 'src/generated/INetworkListManager.dart';
export 'src/generated/INetworkListManagerEvents.dart';
export 'src/generated/IPersist.dart';
export 'src/generated/IPersistStream.dart';
export 'src/generated/IPropertyValue.dart';
export 'src/generated/IProvideClassInfo.dart';
export 'src/generated/IRunningObjectTable.dart';
export 'src/generated/ISequentialStream.dart';
export 'src/generated/IShellFolder.dart';
export 'src/generated/IShellItem.dart';
export 'src/generated/IShellItem2.dart';
export 'src/generated/IShellItemArray.dart';
export 'src/generated/IShellItemFilter.dart';
export 'src/generated/ISpellChecker.dart';
export 'src/generated/ISpellCheckerChangedEventHandler.dart';
export 'src/generated/ISpellCheckerFactory.dart';
export 'src/generated/ISpellingError.dart';
export 'src/generated/IStream.dart';
export 'src/generated/ISupportErrorInfo.dart';
export 'src/generated/IUnknown.dart';
export 'src/generated/IWbemClassObject.dart';
export 'src/generated/IWbemContext.dart';
export 'src/generated/IWbemLocator.dart';
export 'src/generated/IWbemServices.dart';
