package com.demo.sound;

import android.content.Context;
import android.os.Bundle;
import android.os.Environment;

import androidx.appcompat.app.AppCompatActivity;

import com.core.sound.XSounder;

import java.io.File;

public class PlayerActivity extends AppCompatActivity {

    private XSounder mAudioPlayer;
    private String mRootDir; // "/sdcard/Android/data/com.demo.sound/files"

    static {
        System.loadLibrary("coresound");
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        mRootDir = getPrivateExternalFilesDir(this, "");
        mRootDir = validDirectory(mRootDir);

        setContentView(R.layout.activity_player);

        mAudioPlayer = new XSounder();
        initView();
    }

    private void initView() {
        findViewById(R.id.btn_start).setOnClickListener(v -> {
            mAudioPlayer.setInput(mRootDir + "/jieqian.pcm");
            mAudioPlayer.start();
        });
    }

    private static String getPrivateExternalFilesDir(Context context, String dirName) {
        try {
            String cachePath = null;
            if (Environment.MEDIA_MOUNTED.equals(Environment.getExternalStorageState())) {
                cachePath = context.getExternalFilesDir("").getAbsolutePath();
            } else {
                File cacheDir = context.getCacheDir();
                if (cacheDir != null && cacheDir.exists()) {
                    cachePath = cacheDir.getPath();
                }
            }
            return cachePath + File.separator + dirName;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return "";
    }

    /**
     * 判断文件夹是否存在，若不存在，则创建
     * @param dir 文件夹
     */
    private String validDirectory(String dir) {
        File file = new File(dir);
        if (!file.exists()) {
            file.mkdir();
        }
        return file.getPath();
    }
}
