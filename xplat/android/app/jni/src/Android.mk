LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)
LOCAL_MODULE := libwebsockets
LOCAL_SRC_FILES := $(LOCAL_PATH)/../../../../../deps/lws-android/$(TARGET_ARCH_ABI)/lib/libwebsockets.a
include $(PREBUILT_STATIC_LIBRARY)

include $(CLEAR_VARS)

LOCAL_MODULE := main

SDL2_PATH 		   := $(LOCAL_PATH)/../SDL2
SDL2_IMAGE_PATH    := $(LOCAL_PATH)/../SDL2_image
SDL2_TTF_PATH 	   := $(LOCAL_PATH)/../SDL2_ttf
SDL2_MIXER_PATH	   := $(LOCAL_PATH)/../SDL2_mixer
LUA_PATH 		   := $(LOCAL_PATH)/../lua
LWS_PATH		   := $(LOCAL_PATH)/../../../../../deps/libwebsockets/android-build/include

LOCAL_C_INCLUDES := \
	$(SDL2_PATH)/include \
	$(SDL2_IMAGE_PATH) \
	$(SDL2_TTF_PATH) \
	$(SDL2_MIXER_PATH) \
	$(LUA_PATH) \
	$(LWS_PATH)

# Add your application source files here...
LOCAL_SRC_FILES := \
	../../../../../src/client/main.cpp \
	../../../../../src/client/gamelib.cpp \
	../../../../../src/client/network.cpp \
	../../../../../src/client/android.cpp \
	$(LUA_PATH)/lapi.c \
	$(LUA_PATH)/lauxlib.c \
	$(LUA_PATH)/lbaselib.c \
	$(LUA_PATH)/lbitlib.c \
	$(LUA_PATH)/lcode.c \
	$(LUA_PATH)/lcorolib.c \
	$(LUA_PATH)/lctype.c \
	$(LUA_PATH)/ldblib.c \
	$(LUA_PATH)/ldebug.c \
	$(LUA_PATH)/ldo.c \
	$(LUA_PATH)/ldump.c \
	$(LUA_PATH)/lfunc.c \
	$(LUA_PATH)/lgc.c \
	$(LUA_PATH)/linit.c \
	$(LUA_PATH)/liolib.c \
	$(LUA_PATH)/llex.c \
	$(LUA_PATH)/lmathlib.c \
	$(LUA_PATH)/lmem.c \
	$(LUA_PATH)/loadlib.c \
	$(LUA_PATH)/lobject.c \
	$(LUA_PATH)/lopcodes.c \
	$(LUA_PATH)/loslib.c \
	$(LUA_PATH)/lparser.c \
	$(LUA_PATH)/lstate.c \
	$(LUA_PATH)/lstring.c \
	$(LUA_PATH)/lstrlib.c \
	$(LUA_PATH)/ltable.c \
	$(LUA_PATH)/ltablib.c \
	$(LUA_PATH)/ltm.c \
	$(LUA_PATH)/lundump.c \
	$(LUA_PATH)/lutf8lib.c \
	$(LUA_PATH)/lvm.c \
	$(LUA_PATH)/lzio.c

LOCAL_STATIC_LIBRARIES := websockets
LOCAL_SHARED_LIBRARIES := SDL2 SDL2_image SDL2_ttf SDL2_mixer

LOCAL_LDLIBS := -lGLESv1_CM -lGLESv2 -llog -landroid

LOCAL_CFLAGS := -DBUILD_TARGET_ANDROID $(LOCAL_CFLAGS)

include $(BUILD_SHARED_LIBRARY)
