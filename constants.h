/*
  MNT Reform 2.0 Keyboard Firmware
  See keyboard.c for Copyright
  SPDX-License-Identifier: MIT
*/

#ifndef _CONSTANTS_H_
#define _CONSTANTS_H_

// KBD_VARIANT_*_US sets KBD_VARIANT_QWERTY_US
#if defined KBD_VARIANT_2_US || defined KBD_VARIANT_3_US
#  define KBD_VARIANT_QWERTY_US
#endif
// KBD_VARIANT_3_US sets KBD_VARIANT_3
#ifdef KBD_VARIANT_3_US
#  define KBD_VARIANT_3
#endif
// KBD_VARIANT_2_NEO2 sets KBD_VARIANT_2 and KBD_VARIANT_NEO2
#ifdef KBD_VARIANT_2_NEO2
#  define KBD_VARIANT_2
#  define KBD_VARIANT_NEO2
#endif
// KBD_VARIANT_3_NEO2 sets KBD_VARIANT_3 and KBD_VARIANT_NEO2
#ifdef KBD_VARIANT_3_NEO2
#  define KBD_VARIANT_3
#  define KBD_VARIANT_NEO2
#endif
// KBD_VARIANT_2_US sets KBD_VARIANT_2 (which does nothing right now as it's
// the default)
#ifdef KBD_VARIANT_2_US
#  define KBD_VARIANT_2
#endif

#if defined(KBD_VARIANT_3)
#  define KBD_USB_MODEL_STRING L"MNT Reform Keyboard 3.0"
#elif defined(KBD_VARIANT_2)
#  define KBD_USB_MODEL_STRING L"MNT Reform Keyboard 2.0"
#endif

#if defined(KBD_MODE_STANDALONE)
#  define KBD_USB_MODE_STRING L"/ST"
#else
#  define KBD_USB_MODE_STRING L"/LT"
#endif

#if defined(KBD_VARIANT_QWERTY_US)
#  define KBD_USB_PRODUCT_STRING (KBD_USB_MODEL_STRING L" US" KBD_USB_MODE_STRING)
#elif defined(KBD_VARIANT_NEO2)
#  define KBD_USB_PRODUCT_STRING (KBD_USB_MODEL_STRING L" Neo2" KBD_USB_MODE_STRING)
#else
#  define KBD_USB_PRODUCT_STRING (KBD_USB_MODEL_STRING L" Intl" KBD_USB_MODE_STRING)
#endif

// allow overriding KBD_FW_VERSION by not touching it if it's already set
#ifndef KBD_FW_VERSION
#  define KBD_FW_VERSION "debug"
#endif
// set KBD_FW_REV according to variant 2 or 3
#ifdef KBD_VARIANT_3
#  define KBD_FW_REV "R3 " KBD_FW_VERSION
#else
#  define KBD_FW_REV "R2 " KBD_FW_VERSION
#endif

#define KBD_COLS 14
#define KBD_ROWS 6
#define KBD_MATRIX_SZ KBD_COLS * KBD_ROWS + 4
#define KBD_EDITOR_MARKER 0xfe,0xed,0xca,0xfe

#endif
