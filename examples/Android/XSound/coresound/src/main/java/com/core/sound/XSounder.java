package com.core.sound;

public class XSounder {
    private long mNativePtr = -1L;

    public XSounder() {
        mNativePtr = nativeCreateSounder();
    }

    public void setInput(String filename) {
        nativeSetInput(mNativePtr, filename);
    }

    public void start() {
        nativeStart(mNativePtr);
    }

    public void destroy() {
        nativeDestroySounder(mNativePtr);
    }

    private native long nativeCreateSounder();

    private native void nativeSetInput(long nativePtr, String filename);

    private native void nativeStart(long nativePtr);

    private native void nativeDestroySounder(long nativePtr);
}
