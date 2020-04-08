LOCAL_PATH := $(call my-dir)
ARCH_DIR := $(LOCAL_PATH)/../../../../../build/lws-android/$(TARGET_ARCH_ABI)

include $(CLEAR_VARS)
LOCAL_MODULE := libwebsockets
LOCAL_SRC_FILES := $(ARCH_DIR)/lws/lib/libwebsockets.a
include $(PREBUILT_STATIC_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE := libmbedcrypto
LOCAL_SRC_FILES := $(ARCH_DIR)/mbed/lib/libmbedcrypto.a
include $(PREBUILT_STATIC_LIBRARY)


include $(CLEAR_VARS)
LOCAL_MODULE := libmbedx509
LOCAL_SRC_FILES := $(ARCH_DIR)/mbed/lib/libmbedx509.a
include $(PREBUILT_STATIC_LIBRARY)


include $(CLEAR_VARS)
LOCAL_MODULE := libmbedtls
LOCAL_SRC_FILES := $(ARCH_DIR)/mbed/lib/libmbedtls.a
include $(PREBUILT_STATIC_LIBRARY)

include $(CLEAR_VARS)

LOCAL_MODULE := main

SDL2_PATH 		   := $(LOCAL_PATH)/../SDL
SDL2_IMAGE_PATH    := $(LOCAL_PATH)/../SDL_image
SDL2_TTF_PATH 	   := $(LOCAL_PATH)/../SDL_ttf
SDL2_MIXER_PATH	   := $(LOCAL_PATH)/../SDL_mixer
LUA_PATH 		   := $(LOCAL_PATH)/../lua
MBED_PATH		   := $(ARCH_DIR)/mbed/include
LWS_PATH		   := $(ARCH_DIR)/lws/include

LOCAL_C_INCLUDES := \
	$(SDL2_PATH)/include \
	$(SDL2_IMAGE_PATH) \
	$(SDL2_TTF_PATH) \
	$(SDL2_MIXER_PATH) \
	$(LUA_PATH) \
	$(MBED_PATH) \
	$(LWS_PATH)

# Add your application source files here...
LOCAL_SRC_FILES := \
	../../../../../src/main.cpp \
	../../../../../src/gamelib.cpp \
	../../../../../src/network.cpp \
	../../../../../src/android.cpp \
	$(LUA_PATH)/onelua.c

LOCAL_STATIC_LIBRARIES := websockets mbedtls mbedcrypto mbedx509
LOCAL_SHARED_LIBRARIES := SDL2 SDL2_image SDL2_ttf SDL2_mixer

LOCAL_LDLIBS := -lGLESv1_CM -lGLESv2 -llog -landroid

LOCAL_CFLAGS := -D__ANDROID__ -DMAKE_LIB -DBUILD_TARGET_ANDROID $(LOCAL_CFLAGS)

include $(BUILD_SHARED_LIBRARY)
