#ifndef ANDROID_ANDROID_H
#define ANDROID_ANDROID_H

#ifdef BUILD_TARGET_ANDROID

#include <unistd.h>
#include <pthread.h>
#include <android/log.h>
#include "global.h"

int start_logger(const char* appname);

#endif
#endif
