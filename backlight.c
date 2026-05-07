/*
  MNT Reform 2.0 Keyboard Firmware
  See keyboard.c for Copyright
  SPDX-License-Identifier: MIT
*/

#include <avr/io.h>
#include "backlight.h"

#define KBD_MIN_PWMVAL 0
#define KBD_MAX_PWMVAL 6
#define KBD_PWM_STEP 1
int16_t pwmval = KBD_MAX_PWMVAL;

void kbd_brightness_init(void) {
  // Set initial brightness
  OCR0A = pwmval;

  // Set 'Waveform Generation Mode' to:
  // - Mode 1:
  //   * Phase correct PWM
  //   * TOP = 0xFF
  //   * Update OCRx at TOP
  //   * TOV flag set on BOTTOM (0x00)
  TCCR0A |=  (1 << WGM00);
  TCCR0A &= ~(1 << WGM01);

  // Set 'Compare Output Mode' to:
  // - Clear OC0A on Compare Match when up-counting.
  // - Set   OC0A on Compare Match when down-counting.
  TCCR0A &= ~(1 << COM0A0);
  TCCR0A |=  (1 << COM0A1);

  // Set 'Clock Select' to:
  // - prescale clk_io / 8
  TCCR0B &= ~(1 << CS00);
  TCCR0B |=  (1 << CS01);
  TCCR0B &= ~(1 << CS02);
}

void kbd_brightness_inc(void) {
  pwmval += KBD_PWM_STEP;
  if (pwmval >= KBD_MAX_PWMVAL) pwmval = KBD_MAX_PWMVAL;
  OCR0A = pwmval;
}

void kbd_brightness_dec(void) {
  pwmval -= KBD_PWM_STEP;
  if (pwmval < KBD_MIN_PWMVAL) pwmval = KBD_MIN_PWMVAL;
  OCR0A = pwmval;
}

void kbd_brightness_set(int brite) {
  pwmval = brite;
  if (pwmval < KBD_MIN_PWMVAL) pwmval = KBD_MIN_PWMVAL;
  if (pwmval >= KBD_MAX_PWMVAL) pwmval = KBD_MAX_PWMVAL;
  OCR0A = pwmval;
}

int16_t kbd_brightness_get(void) {
  return pwmval;
}
